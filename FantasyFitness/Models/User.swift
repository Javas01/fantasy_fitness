//
//  User.swift
//  FantasyFitness
//
//  Created by Jawwaad Sabree on 6/18/25.
//


import SwiftUI
import PostgREST

struct TierInfo {
    let title: String
    let currentXP: Int
    let maxXP: Int
}

struct FFUser: Codable, Equatable, Identifiable {
    let id: UUID
    let name: String
    let email: String
    let avatarName: String
    let ffScore: Double
    let lastSync: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case email
        case ffScore = "ff_score"
        case avatarName = "avatar_name"
        case lastSync = "last_sync"
    }
}
extension FFUser {
    static let placeholder = FFUser(
        id: UUID(uuidString: "d48fe750-b692-4f7a-a929-841b9de43b3e")!, //UUID(),
        name: "Jawwaad", // "Demo User",
        email: "demo@example.com",
        avatarName: "avatar_0_0",
        ffScore: 0.0,
        lastSync: nil
    )
}
struct UpdateProfile: Codable {
    let name: String
    let avatarName: String
    
    enum CodingKeys: String, CodingKey {
        case name
        case avatarName = "avatar_name"
    }
}
class AppUser: ObservableObject {
    @Published var user: FFUser
    @Published var isSignedIn: Bool = false
    @Published var didRunStartupSync: Bool = false
    
    init(user: FFUser) {
        self.user = user
    }
    
    func update(with newUser: FFUser) {
        DispatchQueue.main.async {
            self.user = newUser
            self.isSignedIn = true
        }
    }
    func logOut() {
        DispatchQueue.main.async {
            self.user = FFUser.placeholder
            self.isSignedIn = false
        }
    }
}
extension AppUser {
    var id: UUID { user.id }
    var ffScore: Double { user.ffScore }
    var name: String { user.name }
    var email: String { user.email }
    var lastSync: Date? { user.lastSync }
    var avatarName: String { user.avatarName }
}

extension AppUser {
    func loadSession() async {
        do {
            let session = try await supabase.auth.session
            let userId = session.user.id
            
            let response: PostgrestResponse<FFUser> = try await supabase
                .from("users")
                .select("*")
                .eq("id", value: userId.uuidString)
                .single()
                .execute()
            
            await MainActor.run {
                self.update(with: response.value)
                self.isSignedIn = true
            }
        } catch {
            print("❌ Failed to load session: \(error)")
            await MainActor.run {
                self.isSignedIn = false
            }
        }
    }
}
