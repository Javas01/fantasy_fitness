//
//  ChallengeMatchupView.swift
//  FantasyFitness
//
//  Created by Jawwaad Sabree on 6/21/25.
//

import SwiftUI
import PostgREST
import Supabase

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
    
    func fetchLabeledHealthDataForChallenge() async {
        var labeledSamples: [LabeledHealthSession] = []
        
        do {
            print(challenge.status)
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
            print(userIds)

            // 2. Fetch all health samples within challenge range for those users
            let sampleResponse: PostgrestResponse<[HealthSample]> = try await supabase
                .from("health_data")
                .select("*")
                .in("user_id", values: userIds)
                .gte("start_time", value: challenge.startDate)
                .lte("end_time", value: challenge.endDate ?? .now)
                .execute()
            
            let samples = sampleResponse.value
            print(samples)
            
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
        
        print(labeledSamples)
        
        self.challengeActivities = labeledSamples
    }
    
    func fetchTeams() async {
        do {
            let participants: PostgrestResponse<[ChallengeParticipantJoinUsers]> = try await supabase
                .from("challenge_participants")
                .select("*, users(*)") // join users
                .eq("challenge_id", value: challenge.id.uuidString)
                .execute()
            print(participants.value)
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
                    teamAProjection: 200,
                    teamBProjection: 300
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
                
                Text("Scoring Log").font(.title)
                HealthDataScroll(
                    data: viewModel.challengeActivities
                )
            } else {
                ProgressView("Loading match...")
            }
        }
        .padding(5)
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



struct PlayerRowView: View {
    let player: ChallengeParticipantJoinUsers
    let alignLeft: Bool
        
    var body: some View {
        if(alignLeft) {
            Image(player.users.avatarName)
                .resizable()
                .frame(width: 40, height: 40)
        }
        if !alignLeft {
            Text("\(player.score, specifier: "%.1f")")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(.orange)
            Spacer()
        }
        VStack(alignment: alignLeft ? .leading : .trailing, spacing: 4) {
            Text(player.name)
                .fontWeight(.semibold)
            Text(playerDisplayInfo)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(width: 80, alignment: alignLeft ? .leading : .trailing)
        if alignLeft {
            Spacer()
            Text("\(player.score, specifier: "%.1f")")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(.orange)
        }
        if(!alignLeft) {
            Image(player.users.avatarName)
                .resizable()
                .frame(width: 40, height: 40)
        }
    }
    
    var playerDisplayInfo: String {
        "Athlete"
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
