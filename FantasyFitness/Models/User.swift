//
//  User.swift
//  FantasyFitness
//
//  Created by Jawwaad Sabree on 6/18/25.
//


import SwiftUI

struct TierInfo {
    let title: String
    let currentXP: Int
    let maxXP: Int
}

struct FFUser: Codable, Equatable {
    let id: UUID
    let name: String
    let email: String
    let avatarName: String?
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
        id: UUID(),
        name: "Demo User",
        email: "demo@example.com",
        avatarName: nil,
        ffScore: 0.0,
        lastSync: nil
    )
}
class AppUser: ObservableObject {
    @Published var user: FFUser
    
    init(user: FFUser) {
        self.user = user
    }
    
    func update(with newUser: FFUser) {
        print(newUser)
        DispatchQueue.main.async {
            self.user = newUser
        }
    }
}
extension AppUser {
    var id: UUID { user.id }
    var ffScore: Double { user.ffScore }
    var name: String { user.name }
    var email: String { user.email }
    var lastSync: Date? { user.lastSync }
}
