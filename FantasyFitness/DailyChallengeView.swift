//
//  DailyChallenge.swift
//  FantasyFitness
//
//  Created by Jawwaad Sabree on 6/18/25.
//
import SwiftUI

struct DailyChallengeView: View {
    let challenge: DailyChallenge
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: challenge.isCompleted ? "checkmark.seal.fill" : "bolt.fill")
                    .foregroundColor(challenge.isCompleted ? .green : .blue)
                    .font(.title2)
                    .padding(6)
                    .background(Circle().fill(Color(.systemGray6)))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(challenge.title)
                        .font(.subheadline.bold())
                    
                    Text(String(format: "%.1f / %.1f completed", challenge.progress, challenge.goal))
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    if !challenge.isCompleted {
                        ProgressView(value: challenge.progress / challenge.goal)
                            .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                    } else {
                        Text("🎁 +\(challenge.rewardFF) FF")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
                
                Spacer()
            }
        }
        .padding()
        .background(Color.white.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

let previewDailyChallenge = DailyChallenge(
    title: "Run 1 mile today",
    progress: 0.6,
    goal: 1.0,
    rewardFF: 25
)
#Preview {
    DailyChallengeView(challenge: previewDailyChallenge)
}
