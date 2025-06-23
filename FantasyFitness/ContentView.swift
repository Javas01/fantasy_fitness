//
//  ContentView.swift
//  FantasyFitness
//
//  Created by Jawwaad Sabree on 6/17/25.
//

import SwiftUI
import SwiftData
import PostgREST

struct AppBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 215/255, green: 236/255, blue: 250/255),
                    Color(red: 190/255, green: 224/255, blue: 245/255)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            content
        }
    }
}

extension View {
    func appBackground() -> some View {
        self.modifier(AppBackgroundModifier())
    }
}
let placeholderUser = FFUser(id: UUID(uuidString: "d48fe750-b692-4f7a-a929-841b9de43b3e")!, name: "", email: "", avatarName: "", ffScore: 25, lastSync: nil)

struct ContentView: View {
    @State private var healthManager: HealthManager? = nil
    @StateObject private var appUser = AppUser(user: placeholderUser) // placeholder until loaded

    
    var body: some View {
        ZStack {
            if let manager = healthManager {
                NavigationStack {
                    HomeView()
                        .environmentObject(manager)
                        .environmentObject(appUser)
                }
                .onAppear {
                    manager.fetchRecentRunningData()
                }
            } else {
                ProgressView("Loading...")
                    .task {
                        do {
                            let session = try await supabase.auth.session
                            let userId = session.user.id
                            
                            let response: PostgrestResponse<[FFUser]> = try await supabase
                                .from("users")
                                .select("*") // pull full row
                                .eq("id", value: userId.uuidString)
                                .limit(1)
                                .execute()
                            
                            if let user = response.value.first {
                                print(user)
                                appUser.user = user
                                healthManager = HealthManager(appUser: user)
                            }
                        } catch {
                            print("❌ Failed to load session: \(error)")
                        }
                    }
            }
        }
    }
}
struct LastSync: Decodable {
    let lastSync: Date?
    
    enum CodingKeys: String, CodingKey {
        case lastSync = "last_sync"
    }
}
#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
