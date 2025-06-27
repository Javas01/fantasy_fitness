//
//  NewActivitySheet.swift
//  FantasyFitness
//
//  Created by Jawwaad Sabree on 6/24/25.
//

import SwiftUI

struct NewActivitySheet: View {
    @EnvironmentObject var healthManager: HealthManager
    @State private var showScoringInfo = false
    
    var body: some View {
        VStack {
            if (healthManager.recentSamples.isEmpty) {
                Text("No New Activity, Put your phone down")
                    .font(.headline)
                    .padding()
            } else {
                HStack{
                    Text("New Activity:")
                        .font(.headline)
                        .padding()
                    Button {
                        showScoringInfo = true
                    } label: {
                        Image(systemName: "info.circle")
                            .font(.system(size: 24)) // sets icon size
                    }
                    .popover(isPresented: $showScoringInfo) {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("How Scoring Works")
                                .font(.headline)
                            
                            Text("- 1 FF per 100 meters")
                            Text("- Speed bonus multiplies your score:")
                            Text("  • <1.5 m/s → ×1.0")
                            Text("  • 1.5 – 2.5 m/s → ×1.25")
                            Text("  • 2.5 – 3.5 m/s → ×1.5")
                            Text("  • 3.5 – 4.5 m/s → ×2.0")
                            Text("  • >4.5 m/s → ×2.5")
                        }
                        .presentationCompactAdaptation(.popover)
                        .padding()
                        .frame(width: 250)
                    }
                    .accessibilityLabel("How scoring works")
                }
                
                
                HealthDataScroll(data: healthManager.recentSamples.map({ sample in
                    print("\(sample.id)")
                    return LabeledHealthSession(sample: sample, name: nil)
                }))
            }
        }
    }
}
