//
//  ProfileView.swift
//  FantasyFitness
//
//  Created by Jawwaad Sabree on 6/26/25.
//

import SwiftUI
import PostgREST

struct ProfileView: View {
    @EnvironmentObject var appUser: AppUser
    @State private var isEditing = false
    
    var body: some View {
        
        VStack(spacing: 24) {
            // MARK: - Header
            PlayerLevel()
            FFScoreProgressView(ffScore: appUser.ffScore)
                .frame(height: 10)
                .padding(.horizontal, 40)
            
            Button(action: {
                isEditing = true
            }) {
                Label("Edit Profile", systemImage: "pencil")
                    .font(.subheadline)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.orange.opacity(0.1))
                    .foregroundColor(.orange)
                    .clipShape(Capsule())
            }
            
            Spacer()
            
            Button(role: .destructive) {
                Task {
                    do {
                        try await supabase.auth.signOut()
                        
                        await MainActor.run {
                            appUser.logOut()
                        }
                    } catch {
                        print("⚠️ Logout failed: \(error)")
                    }
                }
            } label: {
                Text("Log Out")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .foregroundColor(.red)
                    .clipShape(Capsule())
            }
            .padding()
            
            
        }
        .frame(maxHeight: .infinity)
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        .shadow(radius: 3)
        .padding()
        .padding(.bottom, 15)
        .sheet(isPresented: $isEditing) {
                EditProfileView()
                .environmentObject(appUser)
                .appBackground()
        }
        .background(
            LinearGradient(
                colors: [
                    Color(red: 215/255, green: 236/255, blue: 250/255),
                    Color(red: 190/255, green: 220/255, blue: 250/255)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper {
            ProfileView()
        }
    }
}

struct EditProfileView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appUser: AppUser
    
    @State private var name: String = ""
    @State private var selectedAvatar: String = ""
    
    let availableAvatars = [
        "avatar_0_0", "avatar_0_1", "avatar_0_2",
        "avatar_1_0", "avatar_1_1", "avatar_1_2",
        "avatar_2_0", "avatar_2_1", "avatar_2_2",
    ]
    
    var body: some View {
        Form {
            Section(header: Text("Name")) {
                TextField("Your Name", text: $name)
            }
            
            Section(header: Text("Avatar")) {
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(availableAvatars, id: \.self) { icon in
                            Image(icon)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .padding(6)
                                .background(selectedAvatar == icon ? Color.orange.opacity(0.2) : Color.clear)
                                .clipShape(Circle())
                                .onTapGesture {
                                    selectedAvatar = icon
                                }
                        }
                    }
                }
            }
            Button("Save") {
                Task {
                    do {
                        let updatePayload = UpdateProfile(
                            name: name,
                            avatarName: selectedAvatar
                        )
                        
                        let updatedUser: PostgrestResponse<[FFUser]> = try await supabase
                            .from("users")
                            .update(updatePayload)
                            .eq("id", value: appUser.id.uuidString)
                            .select()
                            .execute()
                        
                        if let user = updatedUser.value.first {
                            appUser.update(with: user)
                            dismiss()
                        } else {
                            print("⚠️ No user returned from update")
                        }
                        dismiss()
                    } catch {
                        print("⚠️ Error updating user: \(error)")
                        // Optionally show alert
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            name = appUser.name
            selectedAvatar = appUser.avatarName
        }
    }
}


