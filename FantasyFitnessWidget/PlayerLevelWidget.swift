//
//  PlayerLevelWidget.swift
//  FantasyFitness
//
//  Created by Jawwaad Sabree on 6/25/25.
//

import WidgetKit
import SwiftUI
import Supabase

let supabase = SupabaseClient(
    supabaseURL: URL(string: "https://oqyigcstkojffdkwmbgf.supabase.co")!,
    supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9xeWlnY3N0a29qZmZka3dtYmdmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTAyMTY1MzIsImV4cCI6MjA2NTc5MjUzMn0.Uc5d9B6uo1XOCWeLhOK2GVs4OJzJyVTMU64LgYkvEgo"
)

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

struct PlayerLevelEntry: TimelineEntry {
    let date: Date
    let avatarName: String
    let ffScore: Double
}

struct PlayerLevelProvider: TimelineProvider {
    func placeholder(in context: Context) -> PlayerLevelEntry {
        PlayerLevelEntry(date: Date(), avatarName: "avatar_0_0", ffScore: 360)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (PlayerLevelEntry) -> Void) {
        let entry = PlayerLevelEntry(date: Date(), avatarName: "avatar_0_0", ffScore: 360)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<PlayerLevelEntry>) -> Void) {
        let userDefaults = UserDefaults(suiteName: "group.com.Jawwaad.FantasyFitness.shared")
        
        guard let userIdString = userDefaults?.string(forKey: "widget_user_id"),
              let userId = UUID(uuidString: userIdString) else {
            let fallback = PlayerLevelEntry(date: .now, avatarName: "avatar_0_0", ffScore: 0)
            return completion(Timeline(entries: [fallback], policy: .after(.now.addingTimeInterval(3600))))
        }
        
        Task {
            do {
                // 🧠 Supabase call
                let response: PostgrestResponse<[FFUser]> = try await supabase
                    .from("users")
                    .select()
                    .eq("id", value: userId.uuidString)
                    .execute()
                
                guard let user = response.value.first else {
                    throw URLError(.badServerResponse)
                }
                
                let entry = PlayerLevelEntry(
                    date: .now,
                    avatarName: user.avatarName,
                    ffScore: user.ffScore
                )
                
                let timeline = Timeline(entries: [entry], policy: .after(.now.addingTimeInterval(3600)))
                completion(timeline)
            } catch {
                print("❌ Supabase widget fetch failed:", error)
                let fallback = PlayerLevelEntry(date: .now, avatarName: "avatar_0_0", ffScore: 0)
                completion(Timeline(entries: [fallback], policy: .after(.now.addingTimeInterval(3600))))
            }
        }
    }
}

struct PlayerLevelWidgetView: View {
    var entry: PlayerLevelEntry
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .center, spacing: 15){
                    Text("SPD: 99")
                    Text("STM: 99")
                    Text("END: 99")
                }
                .frame(width: 80)
                
                Spacer()
                
                VStack(spacing: 4) {
                    Image(entry.avatarName)
                        .resizable()
                        .frame(width: 60, height: 60)
                    
                    Text(ffTitle(for: entry.ffScore))
                        .font(.headline)
                    
                    Text("FF Level")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                VStack(alignment: .center, spacing: 15){
                    Text("AGI: 99")
                    Text("ACC: 99")
                    Text("REC: 99")
                }
                .frame(width: 80)
            }
            .font(.caption)
            
            ProgressView(value: entry.ffScore, total: Double(nextFF(currentScore: entry.ffScore)))
                .progressViewStyle(LinearProgressViewStyle(tint: .orange))
                .frame(height: 10)
            
            Text("\(String(format: "%.1f", entry.ffScore)) / \(nextFF(currentScore: entry.ffScore))")
                .font(.footnote)
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity)
        }
        .containerBackground(for: .widget) {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 215/255, green: 236/255, blue: 250/255),
                    Color(red: 190/255, green: 224/255, blue: 245/255)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

struct PlayerLevelWidget: Widget {
    let kind: String = "PlayerLevelWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PlayerLevelProvider()) { entry in
            PlayerLevelWidgetView(entry: entry)
        }
        .configurationDisplayName("Player Stats")
        .description("See your FF level and stats at a glance.")
        .supportedFamilies([.systemMedium])
    }
}

#Preview(as: .systemMedium) {
    PlayerLevelWidget()
} timeline: {
    PlayerLevelEntry(
        date: .now,
        avatarName: "avatar_0_1",
        ffScore: 500
    )
}

func nextFF(currentScore: Double) -> Int {
    switch currentScore {
        case 0..<50: return 50
        case 50..<150: return 150
        case 150..<300: return 300
        case 300..<500: return 500
        case 500..<750: return 750
        case 750..<1000: return 1000
        case 1000..<1400: return 1400
        case 1400..<1800: return 1800
        case 1800..<2300: return 2300
        case 2300..<3000: return 3000
        case 3000..<4000: return 4000
        case 4000..<5000: return 5000
        case 5000..<6000: return 6000
        case 6000..<7000: return 7000
        case 7000..<8000: return 8000
        case 8000..<9000: return 9000
        case 9000..<10000: return 10000
        default: return 10000
    }
}
func ffTitle(for score: Double) -> String {
    switch score {
        case 0..<50: return "Couch Potato"
        case 50..<150: return "Remote Warrior"
        case 150..<300: return "Slow Jogger"
        case 300..<500: return "Gym Dabbler"
        case 500..<750: return "Step Counter"
        case 750..<1000: return "Fitness Fan"
        case 1000..<1400: return "Park Powerwalker"
        case 1400..<1800: return "Spin Class Survivor"
        case 1800..<2300: return "Yoga Yoda"
        case 2300..<3000: return "Marathon Maybe"
        case 3000..<4000: return "Beast Mode Lite"
        case 4000..<5000: return "Cardio Commander"
        case 5000..<6000: return "Lift Lord"
        case 6000..<7000: return "Treadmill Titan"
        case 7000..<8000: return "Crossfit Cultist"
        case 8000..<9000: return "Sweat Machine"
        case 9000..<10000: return "Olympic Hopeful"
        default: return "Fantasy Fitness Legend 💪"
    }
}
