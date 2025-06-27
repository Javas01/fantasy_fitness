//
//  LeaderBoard.swift
//  FantasyFitness
//
//  Created by Jawwaad Sabree on 6/17/25.
//

import SwiftUI
import PostgREST

// MARK: - ViewModels
@MainActor
final class LeaderboardViewModel: ObservableObject {
    @Published var players: [FFUser] = []
    
    init() {
        Task {
            await loadData()
        }
    }
    
    func loadData() async {
        do {
            let response: PostgrestResponse<[FFUser]> = try await supabase
                .from("users")
                .select("*")
                .order("ff_score", ascending: false)
                .limit(50)
                .execute()
            
            let fetchedPlayers = response.value
            
            DispatchQueue.main.async {
                self.players = fetchedPlayers
            }
        } catch {
            print("⚠️ Error loading leaderboard: \(error)")
        }
    }
}

// MARK: - Views

struct LeaderboardView: View {
    @StateObject private var viewModel = LeaderboardViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 215/255, green: 236/255, blue: 250/255),
                        Color(red: 190/255, green: 224/255, blue: 245/255)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Text("Leaderboard")
                        .font(.largeTitle.bold())
                        .padding(.bottom, 10)
                    
                    if viewModel.players.count >= 3 {
                        TopThreePodiumView(players: Array(viewModel.players.prefix(3)))
                    }
                    
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(Array(viewModel.players.dropFirst(3).enumerated()), id: \.element.id) { i, player in
                                UserRowView(player: player, rank: i + 4) // because top 3 were dropped
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.top)
            }

        }
    }
}
let fakeUser = FFUser(id: UUID(), name: "Bob", email: "", avatarName: "avatar_0_0", ffScore: 100, lastSync: nil)
struct TopThreePodiumView: View {
    let players: [FFUser] // assumes contains top 3 players

    var body: some View {
        let first = (players.indices.contains(0) ? players[0] : nil) ?? fakeUser
        let second = (players.indices.contains(1) ? players[1] : nil) ?? fakeUser
        let third = (players.indices.contains(2) ? players[2] : nil) ?? fakeUser
        
        HStack(alignment: .bottom, spacing: 16) {
            PodiumAvatar(player: second, size: 80, imageSize: 60, offsetY: 10, color: Color.gray.opacity(0.2), rank: 2)
            PodiumAvatar(player: first, size: 100, imageSize: 70, offsetY: -10, color: Color.yellow.opacity(0.3), rank: 1)
                .scaleEffect(1.1)
            PodiumAvatar(player: third, size: 80, imageSize: 60, offsetY: 10, color: Color.brown.opacity(0.6), rank: 3)
        }
        .padding(.horizontal)
    }
}

struct PodiumAvatar: View {
    let player: FFUser
    let size: CGFloat
    let imageSize: CGFloat
    let offsetY: CGFloat
    let color: Color
    let rank: Int
    
    @State private var bounceOffset: CGFloat = -40
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                // Crown floating separately above everything
                if rank == 1 {
                    VStack {
                        Image(systemName: "crown.fill")
                            .foregroundColor(.yellow)
                            .offset(y: bounceOffset)
                            .animation(
                                Animation.easeInOut(duration: 0.4)
                                    .repeatForever(autoreverses: true),
                                value: bounceOffset
                            )
                        Spacer(minLength: 0)
                    }
                    .frame(height: 30) // fixed space so it doesn't push layout
                }
                
                RoundedRectangle(cornerRadius: 16)
                    .fill(color)
                    .frame(width: size, height: size + 20)
                    .shadow(color: .black.opacity(0.1), radius: rank == 1 ? 8 : 4)
                
                Image(player.avatarName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: imageSize, height: imageSize)
            }
            .onAppear {
                if rank == 1 {
                    bounceOffset = -35
                }
            }
            
            Text(player.name)
                .bold()
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(maxWidth: 100)
            Text("\(player.ffScore, specifier: "%.1f") FF")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .offset(y: offsetY)
    }
}

struct UserRowView: View {
    let player: FFUser
    let rank: Int
    
    var body: some View {
        HStack(spacing: 16) {
            Text("#\(rank)")
                .font(.title3)
                .frame(width: 40)
            
            Image(player.avatarName)
                .resizable()
                .frame(width: 50, height: 50)
                .clipShape(Circle())
            
            VStack(alignment: .leading) {
                Text(player.name).bold()
                Text("\(player.ffScore, specifier: "%.1f") pts")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Preview
#Preview {
    LeaderboardView()
}
