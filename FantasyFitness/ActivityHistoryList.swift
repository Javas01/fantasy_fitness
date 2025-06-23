//
//  ActivityHistoryList.swift
//  FantasyFitness
//
//  Created by Jawwaad Sabree on 6/20/25.
//


import SwiftUI
import PostgREST

struct ActivityHistoryList: View {
    @State private var healthData: [HealthSample] = []
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ForEach(healthData) { sample in
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
                            Text("+\(calculateFFScore(distanceMeters: sample.distanceMeters, durationSeconds: sample.durationSeconds)) FF")
                                .foregroundColor(.orange)
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .padding(.leading, 8)
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    .frame(maxWidth: .infinity)
                }            }
            .padding(.horizontal)
        }
        .onAppear {
            Task {
                do {
                    #if targetEnvironment(simulator)
                        DispatchQueue.main.async {
                            self.healthData = [
                                HealthSample(sampleId: "", userId: "", quantityType: "", distanceMeters: 100, startTime: Date(), endTime: Date(), durationSeconds: 100),
                                HealthSample(sampleId: "", userId: "", quantityType: "", distanceMeters: 100, startTime: Date(), endTime: Date(), durationSeconds: 100),
                                HealthSample(sampleId: "", userId: "", quantityType: "", distanceMeters: 100, startTime: Date(), endTime: Date(), durationSeconds: 100),
                                HealthSample(sampleId: "", userId: "", quantityType: "", distanceMeters: 100, startTime: Date(), endTime: Date(), durationSeconds: 100),
                                HealthSample(sampleId: "", userId: "", quantityType: "", distanceMeters: 100, startTime: Date(), endTime: Date(), durationSeconds: 100),
                                HealthSample(sampleId: "", userId: "", quantityType: "", distanceMeters: 100, startTime: Date(), endTime: Date(), durationSeconds: 100)
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
