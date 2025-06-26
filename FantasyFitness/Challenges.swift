//
//  Challenges.swift
//  FantasyFitness
//
//  Created by Jawwaad Sabree on 6/17/25.
//

import SwiftUI
import PostgREST

struct AllChallengesView: View {
    let challenges: [Challenge]

    var body: some View {
            VStack {
                AllChallengesList(
                    challenges: challenges
                )
            }
        .navigationTitle("Challenges")
        .appBackground()
    }
}

#Preview {
    PreviewWrapper {
        AllChallengesView(challenges: [testChallenge])
    }
}

struct AllChallengesList: View {
    let challenges: [Challenge]
    @EnvironmentObject var appUser: AppUser
    
    var body: some View {
        List {
            Section(header: Text("Pending")) {
                ForEach(challenges.filter { $0.status == .pending }) { challenge in
                    NavigationLink(destination: ChallengeMatchupView(challenge: challenge).environmentObject(appUser)) {
                        ChallengeCardView(challenge: challenge)
                    }
                    .listRowBackground(Color.white.opacity(0.5)) // 👈 changes row background
                }
            }
            
            Section(header: Text("Active")) {
                ForEach(challenges.filter { $0.status == .active }) { challenge in
                    NavigationLink(destination: ChallengeMatchupView(challenge: challenge).environmentObject(appUser)) {
                        ChallengeCardView(challenge: challenge)
                    }
                    .listRowBackground(Color.white.opacity(0.5)) // 👈 changes row background

                }
            }
            
            Section(header: Text("Completed")) {
                ForEach(challenges.filter { $0.status == .completed }) { challenge in
                    NavigationLink(destination: ChallengeMatchupView(challenge: challenge).environmentObject(appUser)) {
                        ChallengeCardView(challenge: challenge)
                    }
                    .listRowBackground(Color.white.opacity(0.5)) // 👈 changes row background
                }
            }
        }
        .scrollContentBackground(.hidden) // Hides default background of List
        .background(Color.clear)
        .listStyle(.insetGrouped)
        .navigationTitle("All Challenges")
        .appBackground()
    }
}
