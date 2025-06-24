//
//  Challenge.swift
//  FantasyFitness
//
//  Created by Jawwaad Sabree on 6/18/25.
//
import SwiftUI

enum ChallengeType: String, Codable, CaseIterable, Identifiable {
    case goal = "goal"
    case week = "week"
    var id: String { self.rawValue }
}
enum ChallengeStatus: String, Codable, CaseIterable, Identifiable {
    case pending = "pending"
    case active = "active"
    case completed = "completed"
    var id: String { self.rawValue }
}

struct Challenge: Identifiable, Codable {
    let id: UUID
    let size: Int
    let challengeType: ChallengeType
    let goal: Int?
    let startDate: Date
    let endDate: Date?
    var teamAName: String = "Team A"
    var teamBName: String = "Team B"
    var teamAScore: Double = 0
    var teamBScore: Double = 0
    var status: ChallengeStatus = .pending
    
    enum CodingKeys: String, CodingKey {
        case id
        case goal
        case startDate = "start_date"
        case endDate = "end_date"
        case challengeType = "challenge_type"
        case size
        case teamAName = "team_a_name"
        case teamBName = "team_b_name"
        case teamAScore = "team_a_score"
        case teamBScore = "team_b_score"
    }
}

struct ChallengeInsert: Codable {
    let size: Int
    let scoring_type: String
    let challenge_type: String
    let goal: Int?
    let start_date: Date
    let end_date: Date?
    let created_by: UUID
    let team_a_name: String?
}
struct ChallengeParticipant: Codable {
    let userId: UUID
    let challengeId: UUID
    let team: String
    let score: Double
    let name: String
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case challengeId = "challenge_id"
        case team
        case score
        case name
    }
}

struct ChallengeParticipantInsert: Codable {
    let challenge_id: UUID
    let user_id: UUID
    let team: String  // e.g., "a" or "b"
    let name: String
}

struct ChallengeParticipantJoinUsers: Codable {
    let userId: UUID
    let challengeId: UUID
    let team: String
    let score: Double
    let users: FFUser
    let name: String
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case challengeId = "challenge_id"
        case team
        case score
        case users
        case name
    }
}
