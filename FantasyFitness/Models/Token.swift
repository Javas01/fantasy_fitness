//
//  Token.swift
//  FantasyFitness
//
//  Created by Jawwaad Sabree on 6/24/25.
//
import SwiftUI

struct NotificationToken: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let token: String
    let deviceInfo: String?
    let lastUpdated: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case token
        case deviceInfo = "device_info"
        case lastUpdated = "last_updated"
    }
}

struct NewNotificationToken: Codable {
    let userId: UUID
    let token: String
    let deviceInfo: String?
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case token
        case deviceInfo = "device_info"
    }
}
