//
//  ChallengeMatchupView.swift
//  FantasyFitness
//
//  Created by Jawwaad Sabree on 6/21/25.
//

import SwiftUI
import PostgREST
import Supabase

@MainActor
class ChallengeMatchupViewModel: ObservableObject {
    @Published var teamA: FantasyTeam?
    @Published var teamB: FantasyTeam?
    
    let challenge: Challenge
    
    init(challenge: Challenge) {
        self.challenge = challenge
        Task { await fetchTeams() }
    }
    
    func fetchTeams() async {
        do {
            print(challenge.id)
            let participants: PostgrestResponse<[ChallengeParticipant]> = try await supabase
                .from("challenge_participants")
                .select("*, users(*)") // join users
                .eq("challenge_id", value: challenge.id.uuidString)
                .execute()
            print(participants.value)
            let teamA = participants.value.filter { $0.team == "a" }
            let teamB = participants.value.filter { $0.team == "b" }
            
            self.teamA = FantasyTeam(
                name: challenge.teamAName,
                projectedScore: teamA.map { Double($0.score) }.reduce(0, +),
                players: teamA.map {
                    FantasyPlayer(
                        name: $0.users.name,
                        title: /*$0.users.role ?? */"Athlete",
                        avatarName: $0.users.avatarName ?? "avatar_0_0"
                    )
                }
            )
            
            self.teamB = FantasyTeam(
                name: challenge.teamBName,
                projectedScore: teamB.map { Double($0.score) }.reduce(0, +),
                players: teamB.map {
                    FantasyPlayer(
                        name: $0.users.name,
                        title: /*$0.users.role ??*/ "Athlete",
                        avatarName: $0.users.avatarName ?? "avatar_0_0"
                    )
                }
            )
            print(teamA)
            print(teamB)
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
                
                winProbabilityBar
                
                HStack {
                    Text("Proj \(teamA.projectedScore, specifier: "%.1f")").font(.caption)
                    Spacer()
                    Text("Proj \(teamB.projectedScore, specifier: "%.1f")").font(.caption)
                }
                .padding(.horizontal)
                
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
                ActivityHistoryList()
            } else {
                ProgressView("Loading match...")
            }
        }
        .padding(5)
        .appBackground()
        .sheet(isPresented: $isSheetOpen) {
            UserPickerView(challenge: challenge)
                .environmentObject(appUser)
        }
    }
    
    func teamScoreView(team: FantasyTeam) -> some View {
        VStack(spacing: 4) {
            Text("0.0") // Replace with live score if needed
                .font(.largeTitle.bold())
            Text(team.name)
                .font(.caption)
                .multilineTextAlignment(.center)
        }
        .frame(width: 100)
    }
    
    var winProbabilityBar: some View {
        HStack {
            Text("48%").font(.caption)
            ProgressView(value: 0.48)
                .progressViewStyle(LinearProgressViewStyle(tint: .orange))
                .frame(height: 8)
            Text("52%").font(.caption)
        }
        .padding(.horizontal)
    }
}

struct EmptyPlayerRowView: View {
    let alignLeft: Bool
    
    var body: some View {
        if alignLeft {
            Image(systemName: "person.crop.circle.badge.plus")
                .resizable()
                .frame(width: 40, height: 40)
        }
        
        VStack(alignment: alignLeft ? .leading : .trailing, spacing: 4) {
            Text("Tap to Invite")
                .font(.subheadline)
                .foregroundColor(.gray)
            Text("Open Slot")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(width: 80, alignment: alignLeft ? .leading : .trailing)
        
        if !alignLeft {
            Image(systemName: "person.crop.circle.badge.plus")
                .resizable()
                .frame(width: 40, height: 40)
        }
    }
}

struct PlayerRowView: View {
    let player: FantasyPlayer
    let alignLeft: Bool
    
    var body: some View {
        if(alignLeft) {
            Image(player.avatarName)
                .resizable()
                .frame(width: 40, height: 40)
        }
        VStack(alignment: alignLeft ? .leading : .trailing, spacing: 4) {
            Text(player.name)
                .fontWeight(.semibold)
            Text(playerDisplayInfo)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(width: 80, alignment: alignLeft ? .leading : .trailing)
        if(!alignLeft) {
            Image(player.avatarName)
                .resizable()
                .frame(width: 40, height: 40)
        }
    }
    
    var playerDisplayInfo: String {
        "\(player.title)"
    }
}

struct FantasyTeam {
    let name: String
    let projectedScore: Double
    let players: [FantasyPlayer]
}

struct FantasyPlayer: Identifiable {
    let id = UUID()
    let name: String
    let title: String
    let avatarName: String
}

#Preview {
    ChallengeMatchupView(
        challenge: testChallenge
    )
    .environmentObject(AppUser(user: placeholderUser))
}
