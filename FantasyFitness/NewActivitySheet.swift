//
//  NewActivitySheet.swift
//  FantasyFitness
//
//  Created by Jawwaad Sabree on 6/24/25.
//

import SwiftUI

struct NewActivitySheet: View {
    @EnvironmentObject var healthManager: HealthManager
    
    var body: some View {
        if (healthManager.recentSamples.isEmpty) {
            Text("No New Activity, Put your phone down")
                .font(.headline)
                .padding()
        } else {
            Text("New Activity:")
                .font(.headline)
                .padding()
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(healthManager.recentSamples) { sample in
                        VStack(alignment: .leading, spacing: 8) {
                            let imperialDistance = convertToImperial(fromMeters: sample.distanceMeters)
                            Text(formattedDate(sample.startTime))
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
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
}
