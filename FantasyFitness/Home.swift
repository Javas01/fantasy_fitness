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

    @State private var healthData: [HealthSample] = []

    @StateObject private var viewModel = HomeViewModel()
    @State var authenticated = false
    @State var trigger = false
    @State var isFirstLogin = false
    
    @State var showRecentActivity = true
    
    var body: some View {
        ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // MARK: Avatar + FF Score Section
                    HStack {
                        VStack(alignment: .leading){
                            Text("SPD: 99")
                                .padding(10.0)
                            Text("STM: 99")
                                .padding(10.0)
                            Text("END: 99")
                                .padding(10.0)
                        }
                        .frame(width: 100)
                        Spacer()
                        VStack(spacing: 12) {
                            Image(appUser.avatarName?.isEmpty == false ? appUser.avatarName! : "avatar_0_0")
                                .resizable()
                                .frame(width: 100, height: 100)
                            
                            Text(viewModel.tier.title)
                                .font(.title2.bold())
                            
                            (
                                Text("FF").bold() + Text("itness Level")
                            )
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            
                        }
                        Spacer()
                        VStack(alignment: .center){
                            Text("AGI: 99")
                                .padding(10.0)
                            Text("ACC: 99")
                                .padding(10.0)
                            Text("REC: 99")
                                .padding(10.0)

                        }
                        .frame(width: 100)
                    }
                    NavigationLink(destination: ScoreHistoryView().environmentObject(appUser)) {
                        FFScoreProgressView(ffScore: appUser.ffScore)
                    }
                    // MARK: Daily Challenge Section
                    Text("Daily Bonus")
                        .font(.headline)
                    DailyChallengeView(challenge: DailyChallenge(
                        title: "Run 1 mile today",
                        progress: 0.6,
                        goal: 1.0,
                        rewardFF: 25
                    ))
                    
                    // MARK: Active Challenges Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Active Challenges")
                                .font(.headline)
                            
                            Spacer()
                            
                            NavigationLink(
                                destination: AllChallengesView()
                            ) {
                                Image(systemName: "chevron.right")
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        
                        ForEach(viewModel.activeChallenges.prefix(2)) { challenge in
                            ChallengeCardView(challenge: challenge)
                                .environmentObject(appUser)
                        }
                    }
                    
                    // MARK: Friend Activity Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Friends Activity")
                                .font(.headline)
                            
                            Spacer()
                            
                            NavigationLink(destination: FriendsView()) {
                                Image(systemName: "chevron.right")
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        
                        ForEach(viewModel.friendFeed) { activity in
                            FriendActivityRow(activity: activity)
                        }
                    }
                }
                .padding()
                .sheet(isPresented: $showRecentActivity, content: {
                    NewActivitySheet()
                        .environmentObject(healthManager)
                })
        }
        .refreshable {
            await healthManager.syncAllHealthData(appUser: appUser)
            Haptics.success()
        }
        .appBackground()
        .onAppear {
            print("wtf")
            print(appUser.name)
            viewModel.loadActiveChallenges(for: appUser.id)
        }
    }
}

// MARK: - HomeViewModel
@MainActor
class HomeViewModel: ObservableObject {
    @Published var tier = TierInfo(title: "Beach Bum", currentXP: 360, maxXP: 500)
    @Published var activeChallenges: [Challenge] = []
    @Published var friendFeed: [FriendActivity] = [
        FriendActivity(name: "Jay", avatarName: "avatar_0_0", action: "ran a mile", timestamp: "2025"),
        FriendActivity(name: "Bob", avatarName: "avatar_0_2", action: "completed the Shape Up challenge", timestamp: "2025")
    ]
    
    var tierProgress: Double {
        Double(tier.currentXP) / Double(tier.maxXP)
    }
    
    func loadActiveChallenges(for userId: UUID) {
        Task {
            do {
                let response: PostgrestResponse<[ChallengeWrapper]> = try await supabase
                    .from("challenge_participants")
                    .select("challenge:challenges(*)")
                    .eq("user_id", value: userId.uuidString)
                    .execute()
                
                // Parse the nested `challenge` objects
                struct ChallengeWrapper: Codable {
                    let challenge: Challenge
                }
                
                let wrappers = response.value
                DispatchQueue.main.async {
                    self.activeChallenges = wrappers.map { $0.challenge }
                }
            } catch {
                print("❌ Failed to load challenges: \(error)")
            }
        }
    }
}



// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper {
            HomeView()
        }
    }
}
