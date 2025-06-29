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
    private var observersRegistered: Bool = false
    
    func syncAllHealthData(appUser: AppUser) async {
        guard await requestAuthorization(appUser: appUser) else { return }
        
        registerHealthObserversIfNeeded()
        
        let allSamples = await fetchAllSupportedSamples(appUser: appUser)
        guard !allSamples.isEmpty else { return }
        let sessions = groupIntoSessions(samples: allSamples)
        self.recentSamples = sessions
        
        do {
            try await supabase.from("health_data")
                .upsert(allSamples, onConflict: "user_id,sample_id")
                .execute()
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
            WidgetCenter.shared.reloadAllTimelines()
            
            let challengeResponse: PostgrestResponse<[ChallengeParticipantWithChallenge]> = try await supabase
                .from("challenge_participants")
                .select("*, challenges(*)")
                .eq("user_id", value: appUser.id)
                .eq("challenges.status", value: "active")
                .execute()
            
            let activeChallenges = challengeResponse.value.compactMap { $0.challenges }
            for challenge in activeChallenges {
                await self.updateScore(appUser: appUser, for: challenge, with: allSamples)
                
                do {
                    let allResp: PostgrestResponse<[ChallengeParticipant]> = try await supabase
                        .from("challenge_participants")
                        .select()
                        .eq("challenge_id", value: challenge.id)
                        .execute()
                    
                    let userIds = allResp.value.map { $0.userId }
                    
                    struct Token: Decodable {
                        let token: String
                    }
                    let tokenResponse: PostgrestResponse<[Token]> = try await supabase
                        .from("notification_tokens")
                        .select("token")
                        .in("user_id", values: userIds)
                        .execute()
                    
                    // 3. Extract player IDs
                    let tokens = tokenResponse.value.map { $0.token }
                    
                    // 4. Send the push
                    guard !tokens.isEmpty else {
                        print("⚠️ No tokens found")
                        return
                    }
                    
                    try await sendWidgetUpdatePush(to: tokens)
                } catch {
                    
                }
            }
            
        } catch {
            print("❌ Sync failure: \(error)")
        }
    }
    
    private func requestAuthorization(appUser: AppUser) async -> Bool {
        guard HKHealthStore.isHealthDataAvailable() else { return false }
        
        let readTypes = Set(supportedTypes.compactMap { HKObjectType.quantityType(forIdentifier: $0) })
        
        return await withCheckedContinuation { continuation in
            healthStore.requestAuthorization(toShare: [], read: readTypes) { success, _ in
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
            if let goal = challenge.goal, teamA >= Double(goal) || teamB >= Double(goal) {
                struct EndChallengePayload: Codable {
                    let status: ChallengeStatus
                    let endDate: Date
                    enum CodingKeys: String, CodingKey {
                        case status
                        case endDate = "end_date"
                    }
                }
                let payload = EndChallengePayload(
                    status: .completed, endDate: .now
                )
                
                try await supabase
                    .from("challenges")
                    .update(payload)
                    .eq("id", value: challenge.id)
                    .execute()
                
                let userIds = allResp.value.map { $0.userId }
                
                struct Token: Decodable {
                    let token: String
                }
                
                let tokenResponse: PostgrestResponse<[Token]> = try await supabase
                    .from("notification_tokens")
                    .select("token")
                    .in("user_id", values: userIds)
                    .execute()
                
                let tokens = tokenResponse.value.map { $0.token }
                
                guard !tokens.isEmpty else {
                    print("⚠️ No tokens found")
                    return
                }
                
                // 🏷️ Use challenge.teamAName / challenge.teamBName if your model includes them
                let teamAName = challenge.teamAName
                let teamBName = challenge.teamBName
                
                let winningTeam: String
                if teamA == teamB {
                    winningTeam = "It’s a tie! 🤝"
                } else if teamA > teamB {
                    winningTeam = "\(teamAName) Wins 🎉"
                } else {
                    winningTeam = "\(teamBName) Wins 🎉"
                }
                try await sendPushNotification(
                    to: tokens,
                    title: winningTeam,
                    message: "Your challenge has ended. Check the final scores!"
                )

                print("🏁 Challenge \(challenge.id) ended (A: \(teamA), B: \(teamB), goal: \(goal))")
            }
        } catch {
            print("❌ Challenge update error: \(error)")
        }
    }
    private func loadCachedAppUserFromSharedDefaults() async -> AppUser? {
        let userDefaults = UserDefaults(suiteName: "group.com.Jawwaad.FantasyFitness.shared")
        guard let idString = userDefaults?.string(forKey: "widget_user_id"),
              let uuid = UUID(uuidString: idString) else {
            print("❌ Couldn’t get cached user ID")
            return nil
        }
        
        do {
            let resp: PostgrestResponse<[FFUser]> = try await supabase
                .from("users")
                .select("*")
                .eq("id", value: uuid.uuidString)
                .limit(1)
                .execute()
            
            guard let user = resp.value.first else { return nil }
            return AppUser(user: user)
        } catch {
            print("❌ Failed to fetch cached AppUser: \(error)")
            return nil
        }
    }
    
    @MainActor
    func registerHealthObserversIfNeeded() {
        print("👀 Registering health observers...")
        if observersRegistered { return }
        
        let readTypes = Set(supportedTypes.compactMap { HKObjectType.quantityType(forIdentifier: $0) })
        
        for type in readTypes {
            self.healthStore.enableBackgroundDelivery(for: type, frequency: .immediate) { delivered, error in
                if delivered {
                    print("✅ Background delivery enabled for \(type.identifier)")
                } else {
                    print("❌ Failed background delivery: \(error?.localizedDescription ?? "")")
                }
            }
            
            let query = HKObserverQuery(sampleType: type, predicate: nil) { _, completionHandler, error in
                if let error = error {
                    print("❌ Observer query error for \(type.identifier): \(error)")
                } else {
                    Task {
                        print("📥 Background HealthKit update triggered for \(type.identifier)")
                        if let appUser = await self.loadCachedAppUserFromSharedDefaults() {
                            await self.syncAllHealthData(appUser: appUser)
                        } else {
                            print("❌ Background sync skipped — no cached AppUser found")
                        }
                    }
                }
                completionHandler()
            }
            
            self.healthStore.execute(query)
        }
        
        observersRegistered = true
    }
}
