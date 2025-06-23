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
                            Image(/*appUser.user.avatarName ??*/ "avatar_0_0")
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
                    NavigationLink(destination: ScoreHistoryView()
                        .environmentObject(appUser)
                    ) {
                        FFScoreProgressView(ffScore: appUser.user.ffScore)
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
                            
                            NavigationLink(destination: AllChallengesView()
                                .environmentObject(appUser)
                            ) {
                                Image(systemName: "chevron.right")
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        
                        ForEach(viewModel.activeChallenges.prefix(2)) { challenge in
                            ChallengeCardView(challenge: challenge)
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
                    if (healthManager.recentSamples.isEmpty) {
                        Text("No New Activity, Put your phone down")
                            .font(.headline)
                            .padding()
                    } else {
                        Text("New Activity:")
                            .font(.headline)
                            .padding()
                        ScrollView {
                            VStack(alignment: .leading, spacing: 16) {
                                ForEach(healthManager.recentSamples) { sample in
                                    VStack(alignment: .leading, spacing: 8) {
                                        let imperialDistance = convertToImperial(fromMeters: sample.distanceMeters)
                                        Text(formattedDate(sample.startTime))
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                        
                                        HStack(alignment: .top) {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text("🏃 \(displayDistance(miles: imperialDistance.miles, yards: imperialDistance.yards, feet: imperialDistance.feet))")
                                                Text("⏱️ \(displayDuration(sample.durationSeconds))")
                                            }
                                            Spacer()
                                            Text("+\(calculateFFScore(distanceMeters: sample.distanceMeters, durationSeconds: sample.durationSeconds)) FF")
                                                .foregroundColor(.orange)
                                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                                .padding(.leading, 8)
                                        }
                                    }
                                    .padding()
                                    .background(Color(.secondarySystemBackground))
                                    .cornerRadius(12)
                                    .frame(maxWidth: .infinity)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                })
        }
        .appBackground()
        .onAppear {
            viewModel.loadActiveChallenges(for: appUser.user.id)
        }
    }
}

// MARK: - HomeViewModel
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
                self.activeChallenges = wrappers.map { $0.challenge }
            } catch {
                print("❌ Failed to load challenges: \(error)")
            }
        }
    }
}



// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    @StateObject var healthManager = HealthManager(appUser: placeholderUser)

    static var previews: some View {
        HomeView()
            .environmentObject(HealthManager(appUser: placeholderUser)) // This is the key line
            .environmentObject(AppUser(user: placeholderUser))
    }
}

// MARK: FFScoreProgressView
struct FFScoreProgressView: View {
    let ffScore: Int
    @State private var animatedScore: Int = 0
    @State private var animatedProgress: CGFloat = 0.0
    
    var body: some View {
        let nextLevel = nextFF(currentScore: ffScore)
//        let targetProgress = CGFloat(ffScore) / CGFloat(nextLevel)
        
        VStack {
            ProgressView(value: animatedProgress)
                .tint(.orange)
                .shadow(color: .orange, radius: 4)
                .frame(height: 10)
            
            Text("\(animatedScore) / \(nextLevel) FF")
                .font(.footnote)
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity)
        }
        .onAppear {
            // Reset before animating
            animatedScore = 0
            animatedProgress = 0.0
            
            // Animate score count
            Timer.scheduledTimer(withTimeInterval: 0.075, repeats: true) { timer in
                if animatedScore < ffScore {
                    animatedScore += max(1, ffScore / 60)
                } else {
                    animatedScore = ffScore
                    timer.invalidate()
                }
                
                // Sync progress to score
                animatedProgress = CGFloat(animatedScore) / CGFloat(nextLevel)
            }
        }
    }
}

func nextFF(currentScore: Int) -> Int {
    switch currentScore {
        case 0..<50:
            return 50
        case 50..<150:
            return 150
        case 150..<300:
            return 300
        case 300..<500:
            return 500
        case 500..<750:
            return 750
        case 750..<1000:
            return 1000
        case 1000..<1400:
            return 1400
        case 1400..<1800:
            return 1800
        case 1800..<2300:
            return 2300
        case 2300..<3000:
            return 3000
        case 3000..<4000:
            return 4000
        case 4000..<5000:
            return 5000
        case 5000..<6000:
            return 6000
        case 6000..<7000:
            return 7000
        case 7000..<8000:
            return 8000
        case 8000..<9000:
            return 9000
        case 9000..<10000:
            return 10000
        default:
            return 10000 // Maxed out
    }
}
