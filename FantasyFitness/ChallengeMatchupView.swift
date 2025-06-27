//
//  ChallengeMatchupView.swift
//  FantasyFitness
//
//  Created by Jawwaad Sabree on 6/21/25.
//

import SwiftUI
import PostgREST
import Supabase
import WidgetKit

struct ChallengeParticipantSlim: Decodable {
    let userId: UUID
    let name: String
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case name
    }
}

@MainActor
class ChallengeMatchupViewModel: ObservableObject {
    @Published var teamA: FantasyTeam?
    @Published var teamB: FantasyTeam?
    @Published var challengeActivities: [LabeledHealthSession] = []
    
    let challenge: Challenge
    
    init(challenge: Challenge) {
        self.challenge = challenge
        Task {
            await fetchTeams()
            await fetchLabeledHealthDataForChallenge()
        }
    }
    
    func saveChallengeAsWidget(_ challenge: Challenge) {
        let userDefaults = UserDefaults(suiteName: "group.com.Jawwaad.FantasyFitness.shared")
        userDefaults?.set(challenge.id.uuidString, forKey: "starred_challenge_id")
        WidgetCenter.shared.reloadTimelines(ofKind: "ChallengeProgressWidget")
    }
    
    func fetchLabeledHealthDataForChallenge() async {
        var labeledSamples: [LabeledHealthSession] = []
        
        do {
            guard challenge.status == .active else { return }
            // 1. Fetch all participants (with name and user_id)
            let participantResponse: PostgrestResponse<[ChallengeParticipantSlim]> = try await supabase
                .from("challenge_participants")
                .select("user_id, name")
                .eq("challenge_id", value: challenge.id.uuidString)
                .execute()
            
            let participants = participantResponse.value
            let userIds = participants.map { $0.userId.uuidString.lowercased() }
            let userIdToName = Dictionary(uniqueKeysWithValues: participants.map { ($0.userId.uuidString.lowercased(), $0.name) })

            // 2. Fetch all health samples within challenge range for those users
            let sampleResponse: PostgrestResponse<[HealthSample]> = try await supabase
                .from("health_data")
                .select("*")
                .in("user_id", values: userIds)
                .gte("start_time", value: challenge.startDate)
                .lte("end_time", value: challenge.endDate ?? .now)
                .execute()
            
            let samples = sampleResponse.value
            
            let grouped: [String: [HealthSample]] = Dictionary(grouping: samples, by: { $0.userId })
            let sessions = grouped.flatMap { (_, userSamples) in
                groupIntoSessions(samples: userSamples)
            }

            // 3. Attach name to each sample
            labeledSamples = sessions.compactMap { sample -> LabeledHealthSession? in
                guard let name = userIdToName[sample.userId] else { return nil }
                return LabeledHealthSession(sample: sample, name: name)
            }
        } catch {
            print("❌ Error fetching labeled health data: \(error)")
        }
                
        self.challengeActivities = labeledSamples
    }
    
    func fetchTeams() async {
        do {
            let participants: PostgrestResponse<[ChallengeParticipantJoinUsers]> = try await supabase
                .from("challenge_participants")
                .select("*, users(*)") // join users
                .eq("challenge_id", value: challenge.id.uuidString)
                .execute()
            let teamA = participants.value.filter { $0.team == "a" }
            let teamB = participants.value.filter { $0.team == "b" }
            
            self.teamA = FantasyTeam(
                name: challenge.teamAName,
                score: challenge.teamAScore,
                projectedScore: teamA.map { Double($0.score) }.reduce(0, +),
                players: teamA
            )
            
            self.teamB = FantasyTeam(
                name: challenge.teamBName,
                score: challenge.teamBScore,
                projectedScore: teamB.map { Double($0.score) }.reduce(0, +),
                players: teamB
            )
        } catch {
            print("❌ Failed to load challenge participants: \(error)")
        }
    }
}

struct ChallengeMatchupView: View {
    @EnvironmentObject var appUser: AppUser
    let challenge: Challenge
    @StateObject private var viewModel: ChallengeMatchupViewModel
    @State private var isSheetOpen = false
    @State private var didInviteUser = false
    @State private var isWidgetChallenge: Bool = false
    @State private var showScoringInfo = false

    init(challenge: Challenge) {
        _viewModel = StateObject(wrappedValue: ChallengeMatchupViewModel(challenge: challenge))
        self.challenge = challenge
    }

    var body: some View {
        VStack(spacing: 16) {
            if let teamA = viewModel.teamA, let teamB = viewModel.teamB {
                // Team names and scores
                HStack {
                    teamScoreView(team: teamA)
                    Spacer()
                    teamScoreView(team: teamB)
                }
                
                ChallengeProgressView(
                    challenge: challenge,
                )
                
                Divider()
                
                ForEach(0..<challenge.size, id: \.self) { i in
                    HStack {
                        // Team A
                        if i < viewModel.teamA?.players.count ?? 0 {
                            PlayerRowView(player: viewModel.teamA!.players[i], alignLeft: true)
                        } else {
                            EmptyPlayerRowView(alignLeft: true)
                                .onTapGesture {
                                    isSheetOpen = true
                                }
                        }
                        
                        Spacer()
                        Divider()
                        Spacer()

                        // Team B
                        if i < viewModel.teamB?.players.count ?? 0 {
                            PlayerRowView(player: viewModel.teamB!.players[i], alignLeft: false)
                        } else {
                            EmptyPlayerRowView(alignLeft: false)
                                .onTapGesture {
                                    isSheetOpen = true
                                }
                        }
                    }
                    .frame(height: 25)
                    Divider()
                }
                
                HStack {
                    Text("Scoring Log").font(.title)
                    Button {
                        showScoringInfo = true
                    } label: {
                        Image(systemName: "info.circle")
                            .font(.system(size: 24)) // sets icon size
                    }
                    .popover(isPresented: $showScoringInfo) {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("How Scoring Works")
                                .font(.headline)
                            
                            Text("- 1 FF per 100 meters")
                            Text("- Speed bonus multiplies your score:")
                            Text("  • <1.5 m/s → ×1.0")
                            Text("  • 1.5 – 2.5 m/s → ×1.25")
                            Text("  • 2.5 – 3.5 m/s → ×1.5")
                            Text("  • 3.5 – 4.5 m/s → ×2.0")
                            Text("  • >4.5 m/s → ×2.5")
                        }
                        .presentationCompactAdaptation(.popover)
                        .padding()
                        .frame(width: 250)
                    }
                    .accessibilityLabel("How scoring works")
                }
                
                HealthDataScroll(
                    data: viewModel.challengeActivities
                )
            } else {
                ProgressView("Loading match...")
            }
        }
        .padding(.horizontal, 5)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    viewModel.saveChallengeAsWidget(challenge)
                    isWidgetChallenge = true
                } label: {
                    Image(systemName: isWidgetChallenge ? "star.fill" : "star")
                        .foregroundColor(.yellow)
                }
            }
        }
        .onAppear {
            let id = UserDefaults(suiteName: "group.com.Jawwaad.FantasyFitness.shared")?
                .string(forKey: "starred_challenge_id")
            isWidgetChallenge = id == challenge.id.uuidString
        }
        .appBackground()
        .sheet(isPresented: $isSheetOpen) {
            UserPickerView(didInvite: $didInviteUser, challenge: challenge)
                .environmentObject(appUser)
        }
        .onChange(of: didInviteUser) {
            if didInviteUser {
                Task {
                    await viewModel.fetchTeams()
                    didInviteUser = false // reset flag
                }
            }
        }
    }
    
    func teamScoreView(team: FantasyTeam) -> some View {
        VStack(spacing: 4) {
            Text(String(format: "%.1f", team.score))
                .font(.largeTitle.bold())
            Text(team.name)
                .font(.caption)
                .multilineTextAlignment(.center)
        }
        .frame(width: 100)
    }
}

struct FantasyTeam {
    let name: String
    let score: Double
    let projectedScore: Double
    let players: [ChallengeParticipantJoinUsers]
}

#Preview {
    PreviewWrapper {
        ChallengeMatchupView(
            challenge: testChallenge
        )
    }
}
