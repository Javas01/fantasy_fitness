//
//  HealthDataScroll.swift
//  FantasyFitness
//
//  Created by Jawwaad Sabree on 6/26/25.
//

import SwiftUI

struct HealthDataScroll: View {
    let data: [LabeledHealthSession]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ForEach(data.sorted { $0.sample.startTime > $1.sample.startTime }) { item in
                    let sample = item.sample

                    VStack(alignment: .leading, spacing: 8) {
                        HStack{
                            Text("\(sample.startTime.formattedDate) -> \(sample.endTime.formattedTime)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            if let name = item.name {
                                Spacer()
                                Text(name)
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                            }
                        }
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("🏃 \(sample.formattedDistance)")
                                Text("⏱️ \(displayDuration(sample.duration))")
                            }
                            Spacer()
                            Text("+\(String(format: "%.1f", sample.ffScore)) FF")
                                .foregroundColor(.orange)
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .padding(.leading, 8)
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.5))
                    .cornerRadius(12)
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal)
        }
    }
}
// MARK: - Preview
#Preview {
    PreviewWrapper {
        return ScoreHistoryView()
            .appBackground()
    }
}
