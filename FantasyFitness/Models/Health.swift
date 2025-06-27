//
//  Health.swift
//  FantasyFitness
//
//  Created by Jawwaad Sabree on 6/26/25.
//
import SwiftUI

struct HealthSample: Codable, Identifiable {
    var id: String { sampleId }
    let sampleId: String
    let userId: String
    let quantityType: String
    let distanceMeters: Double
    let startTime: Date
    let endTime: Date
    let durationSeconds: Double
    
    enum CodingKeys: String, CodingKey {
        case sampleId = "sample_id", userId = "user_id", quantityType = "quantity_type"
        case distanceMeters = "distance_meters", startTime = "start_time", endTime = "end_time"
        case durationSeconds = "duration_seconds"
    }
}
extension HealthSample {
    var ffScore: Double {
        guard distanceMeters > 0, durationSeconds > 0 else { return 0 }
        
        let base = distanceMeters / 100
        let speed = distanceMeters / durationSeconds
        
        let multiplier: Double
        switch speed {
            case ..<1.5: multiplier = 1.0
            case ..<2.5: multiplier = 1.25
            case ..<3.5: multiplier = 1.5
            case ..<4.5: multiplier = 2.0
            default:     multiplier = 2.5
        }
        
        return base * multiplier
    }
}

struct LabeledHealthSession: Identifiable {
    var id: String { sample.id.uuidString }
    let sample: HealthSession
    let name: String? // Optional
}

struct HealthSession: Identifiable {
    let id = UUID()
    let startTime: Date
    let endTime: Date
    let totalDistance: Double
    let duration: TimeInterval
    let averageSpeed: Double // in mph
    let totalFFScore: Double
    let userId: String
}

extension HealthSession {
    var ffScore: Double {
        guard totalDistance > 0, averageSpeed > 0 else { return 0 }
        
        let base = totalDistance / 100
        let speed = averageSpeed
        
        let multiplier: Double
        switch speed {
            case ..<1.5: multiplier = 1.0
            case ..<2.5: multiplier = 1.25
            case ..<3.5: multiplier = 1.5
            case ..<4.5: multiplier = 2.0
            default:     multiplier = 2.5
        }
        
        return base * multiplier
    }
    var multiplier: Double {
        let speed = averageSpeed
        
        let multiplier: Double
        switch speed {
            case ..<1.5: multiplier = 1.0
            case ..<2.5: multiplier = 1.25
            case ..<3.5: multiplier = 1.5
            case ..<4.5: multiplier = 2.0
            default:     multiplier = 2.5
        }
        
        return multiplier
    }
}
extension HealthSession {
    var formattedDistance: String {
        let meters = totalDistance
        let miles = meters / 1609.34
        let feet = meters * 3.28084
        let yards = meters * 1.09361
        
        if miles >= 1 {
            return String(format: "%.0f mile%@, %.0f yard%@",
                          miles, miles == 1 ? "" : "s",
                          yards, yards == 1 ? "" : "s")
        } else if yards >= 1 {
            return String(format: "%.0f yard%@",
                          yards, yards == 1 ? "" : "s")
        } else {
            return String(format: "%.0f foot%@",
                          feet, feet == 1 ? "" : "s")
        }
    }
}

func groupIntoSessions(samples: [HealthSample], maxGap: TimeInterval = 5 * 60) -> [HealthSession] {
    guard !samples.isEmpty else { return [] }
    
    let sortedSamples = samples.sorted { $0.startTime < $1.startTime }
    var sessions: [HealthSession] = []
    
    var currentGroup: [HealthSample] = [sortedSamples.first!]
    
    for sample in sortedSamples.dropFirst() {
        let previous = currentGroup.last!
        if sample.startTime.timeIntervalSince(previous.endTime) <= maxGap {
            currentGroup.append(sample)
        } else {
            sessions.append(aggregateSession(from: currentGroup))
            currentGroup = [sample]
        }
    }
    
    // Add the last session
    if !currentGroup.isEmpty {
        sessions.append(aggregateSession(from: currentGroup))
    }
    
    return sessions
}

func aggregateSession(from samples: [HealthSample]) -> HealthSession {
    let totalDistance = samples.map { $0.distanceMeters }.reduce(0, +)
    let totalDuration = samples.map { $0.endTime.timeIntervalSince($0.startTime) }.reduce(0, +)
    let averageSpeed = (totalDistance / 1609.34) / (totalDuration / 3600) // m/s to mph
    let totalFF = samples.map { $0.ffScore}.reduce(0, +)
    return HealthSession(
        startTime: samples.first!.startTime,
        endTime: samples.last!.endTime,
        totalDistance: totalDistance,
        duration: totalDuration,
        averageSpeed: averageSpeed,
        totalFFScore: totalFF,
        userId: samples.first?.userId ?? ""
    )
}
