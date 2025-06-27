//
//  UserPickerView.swift
//  FantasyFitness
//
//  Created by Jawwaad Sabree on 6/22/25.
//

import SwiftUI
import PostgREST

extension Double {
    func format(_ format: String) -> String {
        String(format: format, self)
    }
}

struct UserPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appUser: AppUser
    
    @Binding var didInvite: Bool
    
    @State private var searchText = ""
    @State private var allUsers: [FFUser] = []
    
    let challenge: Challenge
    
    var filteredUsers: [FFUser] {
        if searchText.isEmpty {
            return allUsers
        } else {
            return allUsers.filter {
                $0.name.lowercased().contains(searchText.lowercased())
            }
        }
    }
    
    var body: some View {
        VStack {
            UserGridView(users: filteredUsers) { user in
                Task {
                    do {
                        let newParticipant = ChallengeParticipantInsert(
                            challenge_id: challenge.id,
                            user_id: user.id,
                            team: "b",
                            name: user.name
                        )
                        
                        try await supabase
                            .from("challenge_participants")
                            .insert(newParticipant)
                            .execute()
                        print("✅ Added \(user.name) to Team B")
                        
                        if challenge.size == 1 {
                            let payload = ChallengeUpdatePayload(
                                teamBName: user.name,
                                teamBLogo: user.avatarName,
                                status: ChallengeStatus.active.rawValue,
                                startDate: ISO8601DateFormatter().string(from: .now)
                            )
                            
                            // 1. Update challenge with new user
                            try await supabase
                                .from("challenges")
                                .update(payload)
                                .eq("id", value: challenge.id)
                                .execute()
                            
                            DispatchQueue.main.async {
                                didInvite.toggle()
                            }
                            
                            // 2. Query notification_tokens for user(s)
                            struct Token: Decodable {
                                let token: String
                            }
                            let tokenResponse: PostgrestResponse<[Token]> = try await supabase
                                .from("notification_tokens")
                                .select("token")
                                .eq("user_id", value: user.id.uuidString) // Or `.in()` for a team
                                .execute()
                            
                            // 3. Extract player IDs
                            let tokens = tokenResponse.value.map { $0.token }
                            
                            // 4. Send the push
                            guard !tokens.isEmpty else {
                                print("⚠️ No tokens found for \(user.name)")
                                dismiss()
                                return
                            }
                            
                            try await sendPushNotification(
                                to: tokens,
                                title: "Challenge Updated!",
                                message: "\(challenge.teamAName) has added you to a challenge, Good luck!"
                            )
                        } else {
                            // Handle team invite logic
                        }
                        
                        print("✅ Updated Team B Name")
                        dismiss()
                    } catch {
                        print("❌ Error adding user to team: \(error)")
                        dismiss()
                    }
                }
            }
        }
        .navigationTitle("Invite Player")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground))
        .onAppear {
            Task {
                do {
                    let response: PostgrestResponse<[FFUser]> = try await supabase
                        .from("users")
                        .select()
                        .notEquals("id", value: appUser.id.uuidString)
                        .execute()
                    
                    self.allUsers = response.value
                } catch {
                    print("❌ Failed to fetch users: \(error)")
                }
            }
        }
    }
}

struct UserGridView: View {
    let users: [FFUser]
    let onSelect: (FFUser) -> Void
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(users, id: \.id) { user in
                    Button(action: {
                        onSelect(user)
                    }) {
                        VStack(spacing: 6) {
                            Image(user.avatarName)
                                .resizable()
                                .frame(width: 60, height: 60)
                                .clipShape(Circle())
                            
                            Text(user.name)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .lineLimit(1)
                            
                            Text("\(user.ffScore.format("%.1f")) pts")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 4, y: 2)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding()
        }
    }
}

#Preview {
    PreviewWrapper {
        UserPickerView(didInvite: .constant(true), challenge: testChallenge)
    }
}

struct ChallengeUpdatePayload: Codable {
    let teamBName: String
    let teamBLogo: String
    let status: String
    let startDate: String
    
    enum CodingKeys: String, CodingKey {
        case teamBName = "team_b_name"
        case teamBLogo = "team_b_logo"
        case status
        case startDate = "start_date"
    }
}
