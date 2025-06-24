//
//  ActivityHistoryList.swift
//  FantasyFitness
//
//  Created by Jawwaad Sabree on 6/20/25.
//


import SwiftUI
import PostgREST

struct ActivityHistoryList: View {
    let activities: [LabeledHealthSample]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ForEach(activities.sorted { $0.sample.startTime > $1.sample.startTime }) { item in
                    let sample = item.sample
                    let imperialDistance = convertToImperial(fromMeters: sample.distanceMeters)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(formattedDate(sample.startTime))
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
                                Text("🏃 \(displayDistance(miles: imperialDistance.miles, yards: imperialDistance.yards, feet: imperialDistance.feet))")
                                Text("⏱️ \(displayDuration(sample.durationSeconds))")
                            }
                            Spacer()
                            Text("+\(String(format: "%.1f", calculateFFScore(distanceMeters: sample.distanceMeters, durationSeconds: sample.durationSeconds))) FF")
                                .foregroundColor(.orange)
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .padding(.leading, 8)
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal)
        }
    }
}
