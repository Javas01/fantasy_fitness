//
//  HealthManager.swift (Refactored)
//  FantasyFitness
//
//  Created by Jawwaad Sabree on 6/17/25.

import HealthKit
import PostgREST
import SwiftUICore
import WidgetKit

let supportedTypes: [HKQuantityTypeIdentifier] = [
    .distanceWalkingRunning,
//    .stepCount,
//    .heartRate,
//    .runningSpeed -> might be cool to use later
]

struct ChallengeParticipantWithChallenge: Codable {
    let challenges: Challenge?
}

struct UpdateUserPayload: Codable {
    let ff_score: Double
    let last_sync: Date
}

@MainActor
class HealthManager: ObservableObject {
    @Published var recentSamples: [HealthSession] = []
    let healthStore = HKHealthStore()
    
    func syncAllHealthData(appUser: AppUser) async {
        guard await requestAuthorization() else { return }
        
        let allSamples = await fetchAllSupportedSamples(appUser: appUser)
        guard !allSamples.isEmpty else { return }
        let sessions = groupIntoSessions(samples: allSamples)
        self.recentSamples.append(contentsOf: sessions)
        
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
            
            let ffGained = allSamples.reduce(0.0) { $0 + $1.ffScore }
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
            WidgetCenter.shared.reloadTimelines(ofKind: "PlayerLevelWidget")
            
            let challengeResponse: PostgrestResponse<[ChallengeParticipantWithChallenge]> = try await supabase
                .from("challenge_participants")
                .select("*, challenges(*)")
                .eq("user_id", value: appUser.id)
                .eq("challenges.status", value: "active")
                .execute()
            
            let activeChallenges = challengeResponse.value.compactMap { $0.challenges }
            for challenge in activeChallenges {
                await self.updateScore(appUser: appUser, for: challenge, with: allSamples)
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
    
    private func fetchAllSupportedSamples(appUser: AppUser) async -> [HealthSample] {
        await withTaskGroup(of: [HealthSample].self) { group in
            for identifier in supportedTypes {
                if let type = HKObjectType.quantityType(forIdentifier: identifier) {
                    group.addTask { await self.fetchSamples(appUser: appUser, for: type) }
                }
            }
            var all: [HealthSample] = []
            for await batch in group {
                all.append(contentsOf: batch)
            }
            return all
        }
    }
    
    private func fetchSamples(appUser: AppUser, for type: HKQuantityType) async -> [HealthSample] {
#if targetEnvironment(simulator)
        let userId = appUser.id.uuidString
        let twentyFourHoursAgo = Date().addingTimeInterval(-86400) // 60 * 60 * 24
        
        do {
            let response: PostgrestResponse<[HealthSample]> = try await supabase
                .from("health_data")
                .select()
                .eq("user_id", value: userId)
                .gte("start_time", value: ISO8601DateFormatter().string(from: twentyFourHoursAgo))
                .order("start_time", ascending: true)
                .execute()
            
            return response.value
        } catch {
            print("❌ Failed to fetch 24hr data from Supabase: \(error)")
            return []
        }
#else
        let userId = appUser.id.uuidString
        let lastSync = appUser.lastSync
        return await withCheckedContinuation { continuation in
            let predicate = HKQuery.predicateForSamples(withStart: lastSync, end: .now, options: .strictEndDate)
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
                        userId: userId,
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
    
    private func updateScore(appUser: AppUser, for challenge: Challenge, with samples: [HealthSample]) async {
        let relevant = samples.filter {
            $0.startTime >= challenge.startDate && $0.endTime <= (challenge.endDate ?? .now)
        }
        let gained = relevant.reduce(0.0) { $0 + $1.ffScore }
        
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
