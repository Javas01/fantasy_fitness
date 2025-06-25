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
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("All Challenges")
                            .font(.largeTitle.bold())
                            .padding(.top)
                        
                        ForEach(challenges) { challenge in
                            NavigationLink(destination: ChallengeMatchupView(challenge: challenge).environmentObject(appUser)) {
                                ChallengeCardView(
                                    challenge: challenge
                                )
                            }
                            .buttonStyle(DefaultButtonStyle())
                        }
                    }
                    .padding()
                }
                
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
                    CreateChallengeView()
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
