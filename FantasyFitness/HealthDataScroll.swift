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
                    ExtractedView(
                        sample: sample,
                        name: item.name
                    )
                        .padding()
                        .background(Color.white.opacity(0.5))
                        .cornerRadius(12)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal)
        }
        .onAppear {
            print(data)
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

struct ExtractedView: View {
    let sample: HealthSession
    let name: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack{
                Text("\(sample.startTime.formattedDate) -> \(sample.endTime.formattedTime)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                if let name  {
                    Spacer()
                    Text(name)
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            }
            
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("🏃 \(sample.totalDistance.format("%.1f")) meters")
                    Text("⏱️ \(displayDuration(sample.duration))")
                }
                Spacer()
                HStack(spacing: 4) {
                    Text("x\(sample.multiplier.format("%.1f"))")
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(6)
                    Text("+\(String(format: "%.1f", sample.ffScore))FF")
                        .font(.title3)
                        .bold()
                        .foregroundColor(.orange)
                }
            }
        }
    }
}
