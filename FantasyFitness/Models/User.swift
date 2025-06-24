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

class AppUser: ObservableObject {
    @Published var id: UUID
    @Published var name: String
    @Published var email: String
    @Published var avatarName: String?
    @Published var ffScore: Double
    @Published var lastSync: Date?
    
    init(user: FFUser) {
        self.id = user.id
        self.name = user.name
        self.email = user.email
        self.avatarName = user.avatarName
        self.ffScore = user.ffScore
        self.lastSync = user.lastSync
    }
    
    func update(with newUser: FFUser) {
        DispatchQueue.main.async {
            self.id = newUser.id
            self.name = newUser.name
            self.email = newUser.email
            self.avatarName = newUser.avatarName
            self.ffScore = newUser.ffScore
            self.lastSync = newUser.lastSync
        }
    }
    
    var asUser: FFUser {
        FFUser(
            id: self.id,
            name: self.name,
            email: self.email,
            avatarName: self.avatarName,
            ffScore: self.ffScore,
            lastSync: self.lastSync
        )
    }
}

let placeholderUser = FFUser(id: UUID(uuidString: "d48fe750-b692-4f7a-a929-841b9de43b3e")!, name: "", email: "", avatarName: "", ffScore: 25, lastSync: nil)
