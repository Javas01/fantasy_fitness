//
//  FantasyFitnessApp.swift
//  FantasyFitness
//
//  Created by Jawwaad Sabree on 6/17/25.
//

import SwiftUI
import SwiftData

@main
struct FantasyFitnessApp: App {
    @StateObject private var appUser = AppUser(user: FFUser.placeholder)
    @StateObject private var healthManager = HealthManager()
    @State private var isSignedIn = false
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootView(isSignedIn: $isSignedIn)
                .environmentObject(appUser)
                .environmentObject(healthManager)
        }
        .modelContainer(sharedModelContainer)
    }
}

struct RootView: View {
    @Binding var isSignedIn: Bool
    @EnvironmentObject var appUser: AppUser
    
    var body: some View {
        if isSignedIn {
            ContentView()
        } else {
            LoginView(isSignedIn: $isSignedIn)
        }
    }
}

struct PreviewWrapper<Content: View>: View {
    let content: () -> Content
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    var body: some View {
        let appUser = AppUser(user: FFUser.placeholder)
        let healthManager = HealthManager()
        
        return content()
            .environmentObject(appUser)
            .environmentObject(healthManager)
    }
}

enum Haptics {
    static func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    static func error() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
    
    static func warning() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }
}
