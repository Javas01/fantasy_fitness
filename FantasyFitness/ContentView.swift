//
//  ContentView.swift
//  FantasyFitness
//
//  Created by Jawwaad Sabree on 6/17/25.
//
import SwiftUI
import PostgREST

@MainActor
struct ContentView: View {
    @EnvironmentObject var appUser: AppUser
    @EnvironmentObject var healthManager: HealthManager

    var body: some View {
        ZStack {
            if !appUser.isSignedIn {
                ProgressView("Loading…")
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
}
