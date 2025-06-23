//
//  LeaderBoard.swift
//  FantasyFitness
//
//  Created by Jawwaad Sabree on 6/17/25.
//

// MARK: - Model

import SwiftUI

struct Player: Identifiable, Hashable {
    let id: UUID = UUID()
    let name: String
    let points: Int
    let avatarName: String
    let rank: Int
    let isTopThree: Bool
}

// MARK: - ViewModels

final class LeaderboardViewModel: ObservableObject {
    @Published var players: [Player] = []
    
    init() {
        loadMockData()
    }
    
    private func loadMockData() {
        players = [
            Player(name: "Amir", points: 1620, avatarName: "avatar_0_0", rank: 1, isTopThree: true),
            Player(name: "Layl", points: 1485, avatarName: "avatar_0_1", rank: 2, isTopThree: true),
            Player(name: "Zayd", points: 1390, avatarName: "avatar_0_2", rank: 3, isTopThree: true),
            Player(name: "Noor", points: 1175, avatarName: "avatar_1_0", rank: 4, isTopThree: false),
            Player(name: "Samir", points: 1100, avatarName: "avatar_1_1", rank: 5, isTopThree: false),
            Player(name: "Hana", points: 1050, avatarName: "avatar_1_2", rank: 6, isTopThree: false),
            Player(name: "Arjun", points: 980, avatarName: "avatar_2_0", rank: 7, isTopThree: false),
            Player(name: "Jawwaada", points: 900, avatarName: "avatar_2_1", rank: 8, isTopThree: false),
            Player(name: "Jawwaad", points: 900, avatarName: "avatar_2_2", rank: 9, isTopThree: false)
        ]
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
                        .padding(.top, 12)
                    TopThreePodiumView(players: viewModel.players.filter { $0.isTopThree })
                    
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(viewModel.players.filter { !$0.isTopThree }) { player in
                                UserRowView(player: player)
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

struct TopThreePodiumView: View {
    let players: [Player] // assumes contains top 3 players
    
    var body: some View {
        let first = players.first(where: { $0.rank == 1 })
        let second = players.first(where: { $0.rank == 2 })
        let third = players.first(where: { $0.rank == 3 })
        
        HStack(alignment: .bottom, spacing: 16) {
            if let second = second {
                PodiumAvatar(player: second, size: 80, imageSize: 60, offsetY: 10, color: Color.gray.opacity(0.2))
            }
            if let first = first {
                PodiumAvatar(player: first, size: 100, imageSize: 70, offsetY: -10, color: Color.yellow.opacity(0.3))
                    .scaleEffect(1.1)
            }
            if let third = third {
                PodiumAvatar(player: third, size: 80, imageSize: 60, offsetY: 10, color: Color.brown.opacity(0.6))
            }
        }
        .padding(.horizontal)
    }
}

struct PodiumAvatar: View {
    let player: Player
    let size: CGFloat
    let imageSize: CGFloat
    let offsetY: CGFloat
    let color: Color
    
    @State private var bounceOffset: CGFloat = -40
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                // Crown floating separately above everything
                if player.rank == 1 {
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
                    .shadow(color: .black.opacity(0.1), radius: player.rank == 1 ? 8 : 4)
                
                Image(player.avatarName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: imageSize, height: imageSize)
            }
            .onAppear {
                if player.rank == 1 {
                    bounceOffset = -35
                }
            }
            
            Text(player.name).bold()
            Text("\(player.points) pts")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .offset(y: offsetY)
    }
}

struct UserRowView: View {
    let player: Player
    
    var body: some View {
        HStack(spacing: 16) {
            Text("#\(player.rank)")
                .font(.title3)
                .frame(width: 40)
            
            Image(player.avatarName)
                .resizable()
                .frame(width: 50, height: 50)
                .clipShape(Circle())
            
            VStack(alignment: .leading) {
                Text(player.name).bold()
                Text("\(player.points) pts")
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
