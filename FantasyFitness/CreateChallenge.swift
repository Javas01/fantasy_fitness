//
//  CreateChallenge.swift
//  FantasyFitness
//
//  Created by Jawwaad Sabree on 6/17/25.
//

import SwiftUI
import PostgREST

func sampleUsers() -> [FFUser] {
    (1...6).map {
        FFUser(id: UUID(), name: "User \($0)", email: "", avatarName: "avatar_0_0", ffScore: 50, lastSync: .now)
    }
}

struct CreateChallengeView: View {
    @Binding var challenges: [Challenge]

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appUser: AppUser

    @State private var allUsers: [FFUser] = []
    @State private var selectedSize: Int = 1
    @State private var selectedScoring: String = "Standard"
    @State private var selectedType: String = "Goal"
    @State private var startDate = Date.now
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                
                Text("Create New Challenge")
                    .font(.largeTitle.bold())
                    .padding(.top)
                
                SectionCard(title: "Challenge Size") {
                    SizePicker(selected: $selectedSize)
                }
                SectionCard(title: "Scoring Type") {
                    ScoringPicker(selected: $selectedScoring)
                }
                SectionCard(title: "Challenge Type") {
                    TypePicker(selected: $selectedType)
                }
                
                Spacer()
                
                Button(action: {
                    Task {
                        do {                            
                            let newChallenge = ChallengeInsert(
                                size: Int(selectedSize),
                                scoring_type: selectedScoring.lowercased() == "ppr" ? "ppr" : "standard",
                                challenge_type: selectedType.lowercased() == "goal" ? "goal" : "week",
                                goal: selectedType.lowercased() == "goal" ? 500 : nil,
                                start_date: startDate,
                                end_date: nil, // Optional: allow adding later
                                created_by: appUser.id,
                                team_a_name: appUser.name,
                                team_a_logo: appUser.avatarName
                            )

                            let response: PostgrestResponse<[Challenge]> = try await supabase
                                .from("challenges")
                                .insert(newChallenge)
                                .select()
                                .execute()
                            guard let insertedChallenge = response.value.first else {
                                print("❌ Failed to fetch inserted challenge ID.")
                                return
                            }
                        
                            print("✅ Challenge created successfully")
                            let challengeId = insertedChallenge.id
                            
                            let participants: [ChallengeParticipantInsert] = [
                                ChallengeParticipantInsert(
                                    challenge_id: challengeId,
                                    user_id: appUser.id,
                                    team: "a",
                                    name: appUser.name
                                )
                                // Add more participants if needed
                            ]
                            try await supabase
                                .from("challenge_participants")
                                .insert(participants)
                                .execute()
                            
                            DispatchQueue.main.async {
                                challenges.append(
                                    Challenge.from(insert: newChallenge, id: challengeId)
                                )
                            }
                            print("✅ Challenge + Participants created successfully")
                            dismiss()
                        } catch {
                            print("❌ Error creating challenge: \(error)")
                        }
                    }
                }) {
                    Text("Create Challenge")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(color: .orange.opacity(0.3), radius: 6, y: 3)
                }
            }
            .padding()
        }
        .navigationTitle("Create Challenge")
        .navigationBarTitleDisplayMode(.inline)
        .appBackground()
        .onAppear {
            allUsers = sampleUsers()
        }
    }
}

struct SectionCard<Content: View>: View {
    var title: String
    @ViewBuilder var content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title.uppercased())
                .font(.caption)
                .foregroundColor(.gray)
            
            content()
                .padding(5)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
        }
    }
}

// MARK: SizePicker Row
struct SizePicker: View {
    let options = [1, 2, 3, 4, 5]
    @Binding var selected: Int

    @State private var showAlert = false

    var body: some View {
        HStack(spacing: 20) {
            ForEach(options, id: \.self) { option in
                Button(action: {
                    if option != 1 {
                        showAlert = true
                    } else {
                        selected = option
                    }
                }) {
                    ButtonText(selected: selected, option: option)
                }
                .alert("Teams Coming Soon", isPresented: $showAlert) {
                    Button("OK", role: .cancel) {}
                }
                .animation(.easeInOut(duration: 0.2), value: selected)
            }
        }
    }
}

struct ScoringPicker: View {
    let options = ["Standard", "PPR"]
    @Binding var selected: String
    @State private var showAlert = false

    func optionDescription(_ option: String) -> String {
        switch option {
            case "PPR": return "Get extra points per logged workout"
            default: return "No extra points"
        }
    }
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(options, id: \.self) { option in
                Button(action: {
                    if option != "Standard" {
                        showAlert = true
                    } else {
                        selected = option
                    }
                }) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(option)
                            .font(.system(size: 16, weight: .semibold))
                        Text(optionDescription(option))
                            .font(.footnote)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(selected == option ? Color.orange : Color.gray.opacity(0.1))
                    .foregroundColor(selected == option ? .white : .black)
                    .cornerRadius(10)
                }
                .buttonStyle(.plain)
                .animation(.easeInOut(duration: 0.2), value: selected)
            }
        }
        .alert("PPR Coming Soon", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        }
    }
}

struct TypePicker: View {
    let options = ["Goal", "Week"]
    @Binding var selected: String
    @State private var showAlert = false

    func optionDescription(_ option: String) -> String {
        switch option {
            case "Goal": return "First team to target wins"
            default: return "Most points after one week wins"
        }
    }
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(options, id: \.self) { option in
                Button(action: {
                    if option != "Goal" {
                        showAlert = true
                    } else {
                        selected = option
                    }
                }) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(option)
                            .font(.system(size: 16, weight: .semibold))
                        Text(optionDescription(option))
                            .font(.footnote)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(selected == option ? Color.orange : Color.gray.opacity(0.1))
                    .foregroundColor(selected == option ? .white : .black)
                    .cornerRadius(10)
                }
                .buttonStyle(.plain)
                .animation(.easeInOut(duration: 0.2), value: selected)
            }
        }
        .alert("Week Challenges Coming Soon", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        }
    }
}

struct ButtonText: View {
    let selected: Int
    let option: Int
    
    var body: some View {
        Text(selected == option ? "\(option)v\(option)" : String(option))
            .font(.system(size: 16, weight: .semibold))
            .padding(.vertical, 10)
            .padding(.horizontal, 20)
            .background(selected == option ? Color.orange : Color.gray.opacity(0.2))
            .foregroundColor(selected == option ? .white : .black)
            .clipShape(Capsule())
            .overlay(
                selected == option ? Capsule()
                    .stroke(Color.orange, lineWidth: selected == option ? 0 : 1) : nil
            )
    }
}

#Preview {
    @Previewable @State var c = [testChallenge]
    PreviewWrapper {
        CreateChallengeView(
            challenges: $c
        )
    }
}
