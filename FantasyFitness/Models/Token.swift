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

func sendPushNotification(
    to playerIds: [String],
    title: String,
    message: String
) async throws {
    let payload: [String: Any] = [
        "app_id": "89ce9cde-cf9b-4eb5-beee-0c0588eff190",
        "include_player_ids": playerIds,
        "headings": ["en": title],
        "contents": ["en": message]
    ]
    
    let jsonData = try JSONSerialization.data(withJSONObject: payload)
    
    var request = URLRequest(url: URL(string: "https://onesignal.com/api/v1/notifications")!)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("Basic os_v2_app_rhhjzxwptnhllpxobqcyr37rsa3yanj3akke6t53cbs35mk5wqpjul4phsizi24x7tlooqscjaesnswikdjzbz4syqnujfuui3nlncq", forHTTPHeaderField: "Authorization")
    request.httpBody = jsonData
    
    let (_, response) = try await URLSession.shared.data(for: request)
    
    if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
        print("Push notification failed with status code \(httpResponse.statusCode)")
    } else {
        print("Push notification sent successfully.")
    }
}

func sendWidgetUpdatePush(to playerIds: [String]) async throws {
    let payload: [String: Any] = [
        "app_id": "89ce9cde-cf9b-4eb5-beee-0c0588eff190",
        "include_player_ids": playerIds,
        "content_available": true, // 🔕 silent push
        "data": [
            "type": "widget_update"
        ]
    ]
    
    let jsonData = try JSONSerialization.data(withJSONObject: payload)
    
    var request = URLRequest(url: URL(string: "https://onesignal.com/api/v1/notifications")!)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("Basic os_v2_app_rhhjzxwptnhllpxobqcyr37rsa3yanj3akke6t53cbs35mk5wqpjul4phsizi24x7tlooqscjaesnswikdjzbz4syqnujfuui3nlncq", forHTTPHeaderField: "Authorization")
    request.httpBody = jsonData
    
    let (_, response) = try await URLSession.shared.data(for: request)
    
    if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
        print("🔴 Widget update push failed with status code \(httpResponse.statusCode)")
    } else {
        print("✅ Widget update push sent successfully.")
    }
}
