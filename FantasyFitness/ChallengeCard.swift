//
//  ChallengeCard.swift
//  FantasyFitness
//
//  Created by Jawwaad Sabree on 6/18/25.
//

import SwiftUI

struct ChallengeCardView: View {
    let challenge: Challenge
    
    var teamAScore: Double = 0.0
    var teamBScore: Double = 0.0
    var teamAProjection: Double = 124.1
    var teamBProjection: Double = 129.0
    
    private var totalProjection: Double {
        teamAProjection + teamBProjection
    }
    
    private var teamAPercent: Double {
        totalProjection == 0 ? 0.5 : teamAProjection / totalProjection
    }

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image("avatar_0_0")
                    .resizable()
                    .frame(width: 55, height: 55)
                VStack {
                    Text(String(format: "%.1f", teamAScore))
                        .font(.system(size: 32, weight: .bold))
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
                    Text(String(format: "%.1f", teamBScore))
                        .font(.system(size: 32, weight: .bold))
                    Text(challenge.teamBName)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                }
                Image("avatar_0_1")
                    .resizable()
                    .frame(width: 55, height: 55)
            }
            
            HStack {
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
                Text("\(Int((1 - teamAPercent) * 100))%")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            HStack {
                Text("Proj \(String(format: "%.1f", teamAProjection))")
                    .font(.footnote)
                    .foregroundColor(.gray)
                Spacer()
                Text("Proj \(String(format: "%.1f", teamBProjection))")
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.white.opacity(0.5)) // or .background(Color.blue.opacity(0.1))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 4, y: 2)
    }
}

let testChallenge = Challenge(id: UUID(uuidString: "7ee298cf-8b28-425b-8e29-7f29646aa41e")!, size: 1, challengeType: .goal, goal: 50, startDate: Date(), endDate: Date())

// MARK: - Preview
struct ChallengeCard_Previews: PreviewProvider {
    static var previews: some View {
        AllChallengesView()
            .environmentObject(AppUser(user: placeholderUser))
    }
}
