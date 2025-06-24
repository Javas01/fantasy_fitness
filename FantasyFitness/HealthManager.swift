//
//  HealthManager.swift (Refactored)
//  FantasyFitness
//
//  Created by Jawwaad Sabree on 6/17/25.

import HealthKit
import PostgREST
import SwiftUICore

let supportedTypes: [HKQuantityTypeIdentifier] = [
    .distanceWalkingRunning,
//    .stepCount,
//    .heartRate,
//    .runningSpeed -> might be cool to use later
]

func formatDuration(_ seconds: TimeInterval) -> String {
    let minutes = Int(seconds) / 60
    let secs = Int(seconds) % 60
    return "\(minutes) min \(secs) sec"
}

func convertToImperial(fromMeters meters: Double) -> (miles: Double, feet: Double, yards: Double) {
    (meters / 1609.34, meters * 3.28084, meters * 1.09361)
}

struct HealthSample: Codable, Identifiable {
    var id: String { sampleId }
    let sampleId: String
    let userId: String
    let quantityType: String
    let distanceMeters: Double
    let startTime: Date
    let endTime: Date
    let durationSeconds: Double
    
    enum CodingKeys: String, CodingKey {
        case sampleId = "sample_id", userId = "user_id", quantityType = "quantity_type"
        case distanceMeters = "distance_meters", startTime = "start_time", endTime = "end_time"
        case durationSeconds = "duration_seconds"
    }
}

struct ChallengeParticipantWithChallenge: Codable {
    let challenges: Challenge?
}

func calculateFFScore(distanceMeters: Double, durationSeconds: Double) -> Double {
    guard distanceMeters > 0, durationSeconds > 0 else { return 0 }
    let base = distanceMeters / 100
    let speed = distanceMeters / durationSeconds
    let multiplier: Double =
    speed < 1.5 ? 1.0 :
    speed < 2.5 ? 1.25 :
    speed < 3.5 ? 1.5 :
    speed < 4.5 ? 2.0 : 2.5
    return base * multiplier
}

struct UpdateUserPayload: Codable {
    let ff_score: Double
    let last_sync: Date
}

@MainActor
class HealthManager: ObservableObject {
    @ObservedObject var appUser: AppUser
    @Published var recentSamples: [HealthSample] = []
    let healthStore = HKHealthStore()
    
    init(appUser: AppUser) {
        self.appUser = appUser
    }
    
    func syncAllHealthData() async {
        guard await requestAuthorization() else { return }
        
        let allSamples = await fetchAllSupportedSamples()
        guard !allSamples.isEmpty else { return }
        self.recentSamples.append(contentsOf: allSamples)
        
        do {
            try await supabase.from("health_data").insert(allSamples).execute()
            print("inserted health data")
            
            let latestUserResp: PostgrestResponse<[FFUser]> = try await supabase
                .from("users")
                .select("*")
                .eq("id", value: appUser.id)
                .limit(1)
                .execute()
            
            guard let latestUser = latestUserResp.value.first else {
                print("❌ User not found before update")
                return
            }
            
            let ffGained = allSamples.reduce(0.0) { $0 + calculateFFScore(distanceMeters: $1.distanceMeters, durationSeconds: $1.durationSeconds) }
            let updatedFF = latestUser.ffScore + ffGained

            let payload = UpdateUserPayload(ff_score: updatedFF, last_sync: .now)

            let userResponse: PostgrestResponse<[FFUser]> = try await supabase
                .from("users")
                .update(payload)
                .eq("id", value: appUser.id)
                .select("*") // 👈 forces return of updated row
                .execute()
            if let updated = userResponse.value.first {
                appUser.update(with: updated)
            }
            print("updated user last sync and ff score")
            
            let challengeResponse: PostgrestResponse<[ChallengeParticipantWithChallenge]> = try await supabase
                .from("challenge_participants")
                .select("*, challenges(*)")
                .eq("user_id", value: appUser.id)
                .eq("challenges.status", value: "active")
                .execute()
            
            let activeChallenges = challengeResponse.value.compactMap { $0.challenges }
            for challenge in activeChallenges {
                await self.updateScore(for: challenge, with: allSamples)
            }
            
        } catch {
            print("❌ Sync failure: \(error)")
        }
    }
    
    private func requestAuthorization() async -> Bool {
        guard HKHealthStore.isHealthDataAvailable(),
              let type = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning) else {
            return false
        }
        
        return await withCheckedContinuation { continuation in
            healthStore.requestAuthorization(toShare: [], read: [type]) { success, _ in
                continuation.resume(returning: success)
            }
        }
    }
    
    private func fetchAllSupportedSamples() async -> [HealthSample] {
        await withTaskGroup(of: [HealthSample].self) { group in
            for identifier in supportedTypes {
                if let type = HKObjectType.quantityType(forIdentifier: identifier) {
                    group.addTask { await self.fetchSamples(for: type) }
                }
            }
            var all: [HealthSample] = []
            for await batch in group {
                all.append(contentsOf: batch)
            }
            return all
        }
    }
    
    private func fetchSamples(for type: HKQuantityType) async -> [HealthSample] {
        #if targetEnvironment(simulator)
                // Return fake samples for testing in the simulator
                let now = Date()
                let tenMinutes: TimeInterval = 600
                let start = now.addingTimeInterval(-tenMinutes)
                
                let fakeSample = HealthSample(
                    sampleId: UUID().uuidString,
                    userId: self.appUser.id.uuidString,
                    quantityType: type.identifier,
                    distanceMeters: 500, // 1.5km
                    startTime: start,
                    endTime: now,
                    durationSeconds: tenMinutes
                )
        
                let fakeSampleTwo = HealthSample(
                    sampleId: UUID().uuidString,
                    userId: self.appUser.id.uuidString,
                    quantityType: type.identifier,
                    distanceMeters: 200, // 1.5km
                    startTime: start,
                    endTime: now,
                    durationSeconds: tenMinutes
                )
                
        return [fakeSample, fakeSampleTwo]
        #else
        await withCheckedContinuation { continuation in
            let predicate = HKQuery.predicateForSamples(withStart: self.appUser.lastSync, end: .now, options: .strictEndDate)
            let sort = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
            
            let query = HKSampleQuery(sampleType: type, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sort]) { _, results, error in
                guard let results = results as? [HKQuantitySample], error == nil else {
                    print("❌ Error fetching \(type.identifier): \(error?.localizedDescription ?? "Unknown")")
                    continuation.resume(returning: [])
                    return
                }
                
                let samples = results.map { sample -> HealthSample in
                    HealthSample(
                        sampleId: sample.uuid.uuidString,
                        userId: self.appUser.id.uuidString,
                        quantityType: type.identifier,
                        distanceMeters: sample.quantity.doubleValue(for: .meter()),
                        startTime: sample.startDate,
                        endTime: sample.endDate,
                        durationSeconds: sample.endDate.timeIntervalSince(sample.startDate)
                    )
                }
                continuation.resume(returning: samples)
            }
            healthStore.execute(query)
        }
        #endif
    }
    
    private func updateScore(for challenge: Challenge, with samples: [HealthSample]) async {
        let relevant = samples.filter {
            $0.startTime >= challenge.startDate && $0.endTime <= (challenge.endDate ?? .now)
        }
        let gained = relevant.reduce(0.0) { $0 + calculateFFScore(distanceMeters: $1.distanceMeters, durationSeconds: $1.durationSeconds) }
        
        do {
            let resp: PostgrestResponse<[ChallengeParticipant]> = try await supabase
                .from("challenge_participants")
                .select()
                .eq("user_id", value: appUser.id)
                .eq("challenge_id", value: challenge.id)
                .execute()
            
            guard let current = resp.value.first else { return }
            
            let totalScore = current.score + gained
            
            try await supabase
                .from("challenge_participants")
                .update(["score": totalScore])
                .eq("user_id", value: appUser.id)
                .eq("challenge_id", value: challenge.id)
                .execute()
            
            let allResp: PostgrestResponse<[ChallengeParticipant]> = try await supabase
                .from("challenge_participants")
                .select()
                .eq("challenge_id", value: challenge.id)
                .execute()
            
            let teamA = allResp.value.filter { $0.team == "a" }.map { $0.score }.reduce(0, +)
            let teamB = allResp.value.filter { $0.team == "b" }.map { $0.score }.reduce(0, +)
            
            try await supabase
                .from("challenges")
                .update(["team_a_score": teamA, "team_b_score": teamB])
                .eq("id", value: challenge.id)
                .execute()
            
            print("🧮 Updated \(appUser.id) score in challenge \(challenge.id) to \(totalScore)")
        } catch {
            print("❌ Challenge update error: \(error)")
        }
    }
}
