//
//  ChallengeCard.swift
//  FantasyFitness
//
//  Created by Jawwaad Sabree on 6/18/25.
//

import SwiftUI

struct ChallengeCardView: View {
    let challenge: Challenge
        
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(challenge.teamALogo)
                    .resizable()
                    .frame(width: 55, height: 55)
                VStack {
                    Text(String(format: "%.1f", challenge.teamAScore))
                        .font(.system(size: 24, weight: .bold))
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
                        .font(.system(size: 24, weight: .bold))
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
            )
        }
        .padding(
            .horizontal, -1
        )
        .padding(
            .vertical, 10
        )
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 4, y: 2)
    }
}

let testChallenge = Challenge(
    id: UUID(uuidString: "147b7689-f5de-4779-af94-005e24056bef")!,
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
            AllChallengesView(challenges: [testChallenge])
        }
    }
}


