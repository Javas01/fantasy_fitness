//
//  ChallengeCard.swift
//  FantasyFitness
//
//  Created by Jawwaad Sabree on 6/18/25.
//

import SwiftUI

struct ChallengeCardView: View {
    let challenge: Challenge
    
    var teamAProjection: Double = 124.1
    var teamBProjection: Double = 129.0
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(challenge.teamALogo)
                    .resizable()
                    .frame(width: 55, height: 55)
                VStack {
                    Text(String(format: "%.1f", challenge.teamAScore))
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
                    Text(String(format: "%.1f", challenge.teamBScore))
                        .font(.system(size: 32, weight: .bold))
                    Text(challenge.teamBName)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                }
                Image(challenge.teamBLogo)
                    .resizable()
                    .frame(width: 55, height: 55)
            }
            
            ChallengeProgressView(
                challenge: challenge,
                teamAProjection: teamAProjection,
                teamBProjection: teamBProjection
            )
        }
        .padding()
        .background(Color.white.opacity(0.5)) // or .background(Color.blue.opacity(0.1))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 4, y: 2)
    }
}

let testChallenge = Challenge(
    id: UUID(uuidString: "7ee298cf-8b28-425b-8e29-7f29646aa41e")!,
    size: 1,
    challengeType: .goal,
    goal: 500,
    startDate: Calendar.current.date(byAdding: .day, value: -1, to: .now)!,
    endDate: .now,
    status: .active
)

// MARK: - Preview
struct ChallengeCard_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper {
            AllChallengesView()
        }
    }
}

struct ChallengeProgressView: View {
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
