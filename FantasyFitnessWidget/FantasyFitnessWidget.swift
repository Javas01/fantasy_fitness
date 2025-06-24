import WidgetKit
import SwiftUI

// MARK: - Timeline Entry
struct FFEntry: TimelineEntry {
    let date: Date
    let challenge: Challenge
    let teamAProjection: Double
    let teamBProjection: Double
}

// MARK: - Timeline Provider
struct FFProvider: TimelineProvider {
    
    func placeholder(in context: Context) -> FFEntry {
        FFEntry(
            date: Date(),
            challenge: testChallenge,
            teamAProjection: 5600,
            teamBProjection: 4400
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (FFEntry) -> Void) {
        let entry = FFEntry(
            date: Date(),
            challenge: testChallenge,
            teamAProjection: 5600,
            teamBProjection: 4400
        )
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<FFEntry>) -> Void) {
        let entry = FFEntry(
            date: Date(),
            challenge: testChallenge,
            teamAProjection: 5600,
            teamBProjection: 4400
        )
        
        // Refresh in 30 minutes
        let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(1800)))
        completion(timeline)
    }
}

// MARK: - Widget View
struct FantasyFitnessWidgetEntryView: View {
    var entry: FFProvider.Entry
    
    var body: some View {
        ChallengeProgressWidgetView(
            challenge: entry.challenge,
            teamAProjection: entry.teamAProjection,
            teamBProjection: entry.teamBProjection
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
struct FantasyFitnessWidget: Widget {
    let kind: String = "FantasyFitnessWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: FFProvider()) { entry in
            FantasyFitnessWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("FantasyFitness Challenge")
        .description("See how your team is stacking up in the current challenge.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct Challenge: Codable, Hashable {
    let id: UUID
    let name: String
    let challengeType: ChallengeType
    let teamAName: String
    let teamBName: String
    let teamAScore: Double
    let teamBScore: Double
    let goal: Int?
    let teamALogo: String
    let teamBLogo: String
}

enum ChallengeType: String, Codable {
    case week, goal
}

// MARK: - Preview
let testChallenge = Challenge(
    id: UUID(),
    name: "WHY",
    challengeType: .goal,
    teamAName: "Jaw",
    teamBName: "Mak",
    teamAScore: 320,
    teamBScore: 280,
    goal: 10000,
    teamALogo: "avatar_0_0",
    teamBLogo: "avatar_0_1",
)

#Preview(as: .systemMedium) {
    FantasyFitnessWidget()
} timeline: {
    FFEntry(date: .now, challenge: testChallenge, teamAProjection: 5600, teamBProjection: 4400)
}


struct ChallengeProgressWidgetView: View {
    let challenge: Challenge
    let teamAProjection: Double
    let teamBProjection: Double
    
    private var totalProjection: Double {
        teamAProjection + teamBProjection
    }
    
    private var teamAPercent: Double {
        if (challenge.challengeType == ChallengeType.week) {
            return totalProjection == 0 ? 0.5 : teamAProjection / totalProjection
        } else {
            return challenge.teamAScore / Double(challenge.goal!)
        }
    }
    private var teamBPercent: Double {
        if (challenge.challengeType == ChallengeType.week) {
            return totalProjection == 0 ? 0.5 : teamBProjection / totalProjection
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
                    Text("Proj \(String(format: "%.1f", teamAProjection))")
                        .font(.footnote)
                        .foregroundColor(.gray)
                    Spacer()
                    Text("Proj \(String(format: "%.1f", teamBProjection))")
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
