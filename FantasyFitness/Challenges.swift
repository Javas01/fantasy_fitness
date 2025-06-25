//
//  Challenges.swift
//  FantasyFitness
//
//  Created by Jawwaad Sabree on 6/17/25.
//

import SwiftUI
import PostgREST

struct AllChallengesView: View {
    @State private var challenges: [Challenge] = []
    @State private var showCreateChallengeSheet = false
    @EnvironmentObject var appUser: AppUser

    var body: some View {
            VStack {
                AllChallengesList(
                    challenges: challenges
                )
                
                // Create Challenge Button
                Button(action: {
                    // Action: navigate to form, show modal, etc.
                    showCreateChallengeSheet = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Create New Challenge")
                            .bold()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(radius: 4)
                }
                .padding(.horizontal)
                .padding(.bottom, 12)
                .sheet(isPresented: $showCreateChallengeSheet) {
                    CreateChallengeView(challenges: $challenges)
                        .environmentObject(appUser)
                }
            }
        .navigationTitle("Challenges")
        .appBackground()
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
}

#Preview {
    PreviewWrapper {
        AllChallengesView()
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
                }
            }
            
            Section(header: Text("Active")) {
                ForEach(challenges.filter { $0.status == .active }) { challenge in
                    NavigationLink(destination: ChallengeMatchupView(challenge: challenge).environmentObject(appUser)) {
                        ChallengeCardView(challenge: challenge)
                    }
//                    .listRowBackground(Color.secondary.opacity(0.2)) // 👈 changes row background

                }
            }
            
            Section(header: Text("Completed")) {
                ForEach(challenges.filter { $0.status == .completed }) { challenge in
                    NavigationLink(destination: ChallengeMatchupView(challenge: challenge).environmentObject(appUser)) {
                        ChallengeCardView(challenge: challenge)
                    }
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
