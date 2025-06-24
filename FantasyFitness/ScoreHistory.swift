//
//  ScoreHistory.swift
//  FantasyFitness
//
//  Created by Jawwaad Sabree on 6/19/25.
//

import SwiftUI
import PostgREST

struct ScoreLog: Identifiable {
    let id: UUID
    let date: Date
    let distanceInMeters: Double
    let durationInSeconds: Double
    let ffScoreEarned: Int
}

struct ScoreHistoryView: View {
    @EnvironmentObject var healthManager: HealthManager
    @EnvironmentObject var appUser: AppUser

    @State private var healthData: [HealthSample] = []
    @State private var showScoringInfo = false
        
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // MARK: Header
            HStack {
                Text("FantasyFitness Score")
                    .font(.title2.bold())
                
                Spacer()
                
                Button {
                    showScoringInfo = true
                } label: {
                    Image(systemName: "info.circle")
                        .foregroundColor(.blue)
                }
                .popover(isPresented: $showScoringInfo) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("How Scoring Works")
                            .font(.headline)
                        
                        Text("- 1 FF per 100 meters")
                        Text("- 10 FF for daily bonus")
                        Text("- 2x FF for fast runs")
                    }
                    .presentationCompactAdaptation(.popover)
                    .padding()
                    .frame(width: 250)
                }
                .accessibilityLabel("How scoring works")
            }
            
            // MARK: Total Score
            Text("\(appUser.ffScore, specifier: "%.1f") FF")
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundColor(.orange)
                .padding(.bottom)
            
            FFScoreProgressView(ffScore: appUser.ffScore)
            
            Divider()
            
            // MARK: Scrollable Activity History
            ActivityHistoryList(
                activities: healthData.map {
                    LabeledHealthSample(sample: $0, name: nil)
                }
            )
        }
        .padding()
        .navigationTitle("Score History")
        .onAppear {
            Task {
                do {
#if targetEnvironment(simulator)
                    DispatchQueue.main.async {
                        self.healthData = [
                            HealthSample(sampleId: "", userId: "", quantityType: "", distanceMeters: 100, startTime: .now, endTime: .now, durationSeconds: 100),
                            HealthSample(sampleId: "", userId: "", quantityType: "", distanceMeters: 100, startTime: .now, endTime: .now, durationSeconds: 100),
                            HealthSample(sampleId: "", userId: "", quantityType: "", distanceMeters: 100, startTime: .now, endTime: .now, durationSeconds: 100),
                            HealthSample(sampleId: "", userId: "", quantityType: "", distanceMeters: 100, startTime: .now, endTime: .now, durationSeconds: 100),
                            HealthSample(sampleId: "", userId: "", quantityType: "", distanceMeters: 100, startTime: .now, endTime: .now, durationSeconds: 100),
                            HealthSample(sampleId: "", userId: "", quantityType: "", distanceMeters: 100, startTime: .now, endTime: .now, durationSeconds: 100)
                        ]
                    }
#else
                    let session = try await supabase.auth.session
                    let userId = session.user.id
                    
                    let response: PostgrestResponse<[HealthSample]> = try await supabase
                        .from("health_data")
                        .select("*")
                        .eq("user_id", value: userId)
                        .order("end_time", ascending: false)
                        .execute()
                    
                    DispatchQueue.main.async {
                        self.healthData = response.value
                    }
#endif
                } catch {
                    print("❌ Error fetching health data: \(error)")
                }
            }
        }
    }
}

func displayDistance(miles: Double, yards: Double, feet: Double) -> String {
    if miles >= 1 {
        return String(format: "%.0f mile%@, %.0f yard%@", miles, miles == 1 ? "" : "s", yards, yards == 1 ? "" : "s")
    } else if yards >= 1 {
        return String(format: "%.0f yard%@", yards, yards == 1 ? "" : "s")
    } else {
        return String(format: "%.0f foot%@", feet, feet == 1 ? "" : "feet")
    }
}
func displayDuration(_ interval: TimeInterval) -> String {
    let minutes = Int(interval) / 60
    let seconds = Int(interval) % 60
    return "\(minutes) min \(seconds) sec"
}
func formattedDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter.string(from: date)
}

struct ScoringInfoView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("How Scoring Works")
                .font(.title.bold())
                .padding(.top)
            
            VStack(alignment: .leading, spacing: 12) {
                Label("1 FF per 100 meters", systemImage: "figure.run")
                Label("Bonus for longer runs", systemImage: "plus.circle")
                Label("Daily streak bonus", systemImage: "flame.fill")
            }
            .font(.body)
            .padding()
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - Preview
#Preview {
    PreviewWrapper {
        return ScoreHistoryView()
    }
}
