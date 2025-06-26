//
//  Home.swift
//  FantasyFitness
//
//  Created by Jawwaad Sabree on 6/17/25.
//

import SwiftUI
import HealthKitUI
import PostgREST

// MARK: - HomeView
struct HomeView: View {
    @EnvironmentObject var healthManager: HealthManager
    @EnvironmentObject var appUser: AppUser
    
    let activeChallenges: [Challenge]
    
    var body: some View {
        ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // MARK: Avatar + FF Score Section
                    PlayerLevel()
                    NavigationLink(destination:
                                    ScoreHistoryView()
                        .environmentObject(appUser)
                        .appBackground()
                    ) {
                        FFScoreProgressView(ffScore: appUser.user.ffScore)
                    }
                    // MARK: Daily Challenge Section
                    Text("Daily Quest")
                        .font(.headline)
                    DailyChallengeView(challenge: DailyChallenge(
                        title: "Run 1 mile today",
                        progress: 0.6,
                        goal: 1.0,
                        rewardFF: 25
                    ))
                    
                    // MARK: Active Challenges Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Active Challenges")
                            .font(.headline)
                        ForEach(activeChallenges.prefix(2)) { challenge in
                            NavigationLink(destination: ChallengeMatchupView(challenge: challenge).environmentObject(appUser)) {
                                ChallengeCardView(challenge: challenge)
                                    .environmentObject(appUser)
                                    .padding()
                                    .background(Color.white.opacity(0.5))
                                    .cornerRadius(16)
                            }
                        }
                    }
                }
                .padding()
        }
        .refreshable {
            await healthManager.syncAllHealthData(appUser: appUser)
            Haptics.success()
        }
        .appBackground()
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper {
            MainAppView()
        }
    }
}
