//
//  TabBar.swift
//  FantasyFitness
//
//  Created by Jawwaad Sabree on 6/26/25.
//

import SwiftUI
import PostgREST

struct MainAppView: View {
    @EnvironmentObject var healthManager: HealthManager
    @EnvironmentObject var appUser: AppUser
    
    @State private var selectedTab: Tab = .home
    @State private var showCreateSheet = false
    @State private var challenges: [Challenge] = []
    @State private var showRecentActivity = true

    enum Tab {
        case home, challenges, create, activity, profile
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                selectedView
                    .padding(.bottom, 50)
                
                VStack {
                    Spacer()
                    LiquidGlassTabBar(
                        selectedTab: $selectedTab,
                        showCreateSheet: $showCreateSheet
                    )
                }
            }
            .ignoresSafeArea(.keyboard) // to prevent keyboard from pushing the tab bar
            .sheet(isPresented: $showCreateSheet) {
                CreateChallengeView(
                    challenges: $challenges
                )
                .appBackground()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 215/255, green: 236/255, blue: 250/255),
                        Color(red: 190/255, green: 224/255, blue: 245/255)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
        }
        .sheet(isPresented: $showRecentActivity, content: {
            NewActivitySheet()
                .environmentObject(healthManager)
                .appBackground()
        })
//        .refreshable {
//            await healthManager.syncAllHealthData(appUser: appUser)
//            Haptics.success()
//        }
        .onAppear {
            Task {
                do {
                    let response: PostgrestResponse<[ChallengeWrapper]> = try await supabase
                        .from("challenge_participants")
                        .select("challenge:challenges(*)")
                        .eq("user_id", value: appUser.id.uuidString)
                        .execute()
                    
                    struct ChallengeWrapper: Codable {
                        let challenge: Challenge
                    }
                    
                    let wrappers = response.value
                    DispatchQueue.main.async {
                        self.challenges = wrappers.map { $0.challenge }
                    }
                } catch {
                    print("❌ Failed to fetch challenges: \(error)")
                }
            }
        }
    }
    
    // Renders view based on selected tab
    @ViewBuilder
    var selectedView: some View {
        switch selectedTab {
            case .home:
                HomeView(
                    activeChallenges: challenges.filter({ challenge in
                        challenge.status == .active
                    })
                )
            case .challenges:
                AllChallengesView(
                    challenges: challenges
                )
            case .create:
                EmptyView()
            case .activity:
                LeaderboardView()
            case .profile:
                ProfileView()
        }
    }
}

// MARK: - Preview
struct TabView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper {
            MainAppView()
        }
    }
}
