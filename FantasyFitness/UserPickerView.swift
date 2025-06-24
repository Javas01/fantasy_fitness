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
            // Search Bar
            TextField("Search users...", text: $searchText)
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
            
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
                        
                        try await supabase
                            .from("challenges")
                            .update(["team_b_name": user.name])
                            .eq("id", value: challenge.id)
                            .execute()
                        print("✅ Updated Team B Name")

                        dismiss()
                    } catch {
                        print("❌ Error adding user to team: \(error)")
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
                            Image(user.avatarName?.isEmpty == false ? user.avatarName! : "avatar_0_0")   .resizable()
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
        UserPickerView(challenge: testChallenge)
    }
}
