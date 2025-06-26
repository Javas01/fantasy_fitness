//
//  ContentView.swift
//  FantasyFitness
//
//  Created by Jawwaad Sabree on 6/17/25.
//
import SwiftUI
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

@MainActor
struct ContentView: View {
    @EnvironmentObject var appUser: AppUser
    @EnvironmentObject var healthManager: HealthManager

    var body: some View {
        ZStack {
            if appUser.email == FFUser.placeholder.email {
                ProgressView("Loading…")
                    .task { await loadSession() }  // ← kick off your login/database fetch
            } else {
                MainAppView()
                    .environmentObject(appUser)
                    .environmentObject(healthManager)
                    .task {
                        // Sync Health Data
                        await healthManager.syncAllHealthData(appUser: appUser)
                        
                        // Save user ID to App Group for widget access
                        let userDefaults = UserDefaults(suiteName: "group.com.Jawwaad.FantasyFitness.shared")
                        userDefaults?.set(appUser.id.uuidString, forKey: "widget_user_id")
                    }
            }
        }
    }
    
    /// Load the supabase session and pull down your real FFUser, then flip `isLoading` off.
    private func loadSession() async {
#if targetEnvironment(simulator)
        // Skip auth on Simulator:
#else
        do {
            let session = try await supabase.auth.session
            let userId   = session.user.id
            
            // Use `.single()` so you get back one row ⇒ `FFUser` instead of `[FFUser]`
            let response: PostgrestResponse<FFUser> = try await supabase
                .from("users")
                .select("*")
                .eq("id", value: userId.uuidString)
                .single()
                .execute()
            
             let fetchedUser = response.value
            // Update on main thread:
            DispatchQueue.main.async {
                appUser.update(with: fetchedUser)
            }
        } catch {
            print("❌ Failed to load session:", error)
        }
#endif
    }
}
