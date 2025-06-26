import WidgetKit
import PostgREST
import SwiftUI

// MARK: - Timeline Entry
struct FFEntry: TimelineEntry {
    let date: Date
    let challenge: Challenge
}

// MARK: - Timeline Provider
struct FFProvider: TimelineProvider {
    func placeholder(in context: Context) -> FFEntry {
        FFEntry(date: Date(), challenge: testChallenge)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (FFEntry) -> Void) {
        let entry = FFEntry(date: Date(), challenge: testChallenge)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<FFEntry>) -> Void) {
        print("📦 Fetching widget challenge from Supabase")
        
        let sharedDefaults = UserDefaults(suiteName: "group.com.Jawwaad.FantasyFitness.shared")
        
        guard let idString = sharedDefaults?.string(forKey: "starred_challenge_id"),
              let challengeId = UUID(uuidString: idString) else {
            print("⚠️ No starred_challenge_id found, using fallback")
            let entry = FFEntry(date: .now, challenge: testChallenge)
            let timeline = Timeline(entries: [entry], policy: .after(.now.addingTimeInterval(1800)))
            return completion(timeline)
        }
        
        Task {
            do {
                let response: PostgrestResponse<[Challenge]> = try await supabase
                    .from("challenges")
                    .select()
                    .eq("id", value: challengeId.uuidString)
                    .execute()
                
                if let challenge = response.value.first {
                    print("✅ Challenge fetched from Supabase: \(challenge.id)")
                    let entry = FFEntry(date: .now, challenge: challenge)
                    let timeline = Timeline(entries: [entry], policy: .after(.now.addingTimeInterval(1800)))
                    completion(timeline)
                } else {
                    print("❌ No challenge found with ID: \(challengeId)")
                    let entry = FFEntry(date: .now, challenge: testChallenge)
                    let timeline = Timeline(entries: [entry], policy: .after(.now.addingTimeInterval(1800)))
                    completion(timeline)
                }
            } catch {
                print("❌ Error fetching challenge from Supabase: \(error)")
                let entry = FFEntry(date: .now, challenge: testChallenge)
                let timeline = Timeline(entries: [entry], policy: .after(.now.addingTimeInterval(1800)))
                completion(timeline)
            }
        }
    }
}

// MARK: - Widget View
struct ChallengeProgressWidgetEntryView: View {
    var entry: FFProvider.Entry
    
    var body: some View {
        ChallengeProgressWidgetView(
            challenge: entry.challenge,
        )
        .padding()
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

// MARK: - Main Widget Config
struct ChallengeProgressWidget: Widget {
    let kind: String = "ChallengeProgressWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: FFProvider()) { entry in
            ChallengeProgressWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("FantasyFitness Challenge")
        .description("See how your team is stacking up in the current challenge.")
        .supportedFamilies([.systemMedium])
    }
}

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
    var teamALogo: String = "avatar_0_0"
    var teamBLogo: String = "avatar_0_1"
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
        case teamALogo = "team_a_logo"
        case teamBLogo = "team_b_logo"
        case status
    }
}

// MARK: - Preview
let testChallenge = Challenge(
    id: UUID(uuidString: "147b7689-f5de-4779-af94-005e24056bef")!,
    size: 1,
    challengeType: .goal,
    goal: 500,
    startDate: Calendar.current.date(byAdding: .day, value: -1, to: .now)!,
    endDate: .now,
    status: .active
)

#Preview(as: .systemMedium) {
    ChallengeProgressWidget()
} timeline: {
    FFEntry(date: .now, challenge: testChallenge)
}


struct ChallengeProgressWidgetView: View {
    let challenge: Challenge
    
    private var teamAPercent: Double {
        if (challenge.challengeType == ChallengeType.week) {
            return 0.0
        } else {
            return challenge.teamAScore / Double(challenge.goal!)
        }
    }
    private var teamBPercent: Double {
        if (challenge.challengeType == ChallengeType.week) {
            return 0.0
        } else {
            return challenge.teamBScore / Double(challenge.goal!)
        }    }
    
    
    var body: some View {
        VStack {
            HStack {
                Image(challenge.teamALogo)
                    .resizable()
                    .frame(width: 50, height: 50)
                VStack {
                    Text(String(format: "%.1f", challenge.teamAScore))
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.orange)
                    Text(challenge.teamAName)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                }
                Spacer()
                Text("Vs")
                    .font(.headline)
                Spacer()
                VStack {
                    Text(String(format: "%.1f", challenge.teamBScore))
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.orange)
                    Text(challenge.teamBName)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                }
                Image(challenge.teamBLogo)
                    .resizable()
                    .frame(width: 50, height: 50)
            }
            HStack {
                if (challenge.challengeType == ChallengeType.week) {
                    Text("\(Int(teamAPercent * 100))%")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 6)
                            
                            Capsule()
                                .fill(Color.orange)
                                .frame(width: geometry.size.width * CGFloat(teamAPercent), height: 6)
                        }
                    }
                    .frame(height: 6)
                    
                    Text("\(Int((1 - teamBPercent) * 100))%")
                        .font(.caption)
                        .foregroundColor(.gray)
                } else if (challenge.challengeType == ChallengeType.goal) {
                    Text("\(Int(teamAPercent * 100))%")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    ProgressView(value: teamAPercent)
                        .accentColor(.orange)
                        .frame(height: 6)
                    ProgressView(value: teamBPercent)
                        .scaleEffect(x: -1, y: 1) // flips it horizontally
                        .accentColor(.orange)
                        .frame(height: 6)
                    
                    Text("\(Int(teamBPercent * 100))%")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            HStack {
                if (challenge.challengeType == ChallengeType.week) {
                    Text("Proj \(String(format: "%.1f", 0.0))")
                        .font(.footnote)
                        .foregroundColor(.gray)
                    Spacer()
                    Text("Proj \(String(format: "%.1f", 0.0))")
                        .font(.footnote)
                        .foregroundColor(.gray)
                } else {
                    Text("Goal: \(challenge.goal!)")
                        .font(.footnote)
                        .foregroundColor(.gray)
                    Spacer()
                    Text("Goal: \(challenge.goal!)")
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal)
        }
    }
}
