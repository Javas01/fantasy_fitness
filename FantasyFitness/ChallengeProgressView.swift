//
//  ChallengeProgressView.swift
//  FantasyFitness
//
//  Created by Jawwaad Sabree on 6/24/25.
//


import SwiftUI

struct ChallengeProgressView: View {
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
        }
    }


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
