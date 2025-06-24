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
            if isSignedIn {
                ContentView()
            } else {
                LoginView(isSignedIn: $isSignedIn)
            }
        }
        .modelContainer(sharedModelContainer)
    }
}


struct PreviewWrapper<Content: View>: View {
    let content: () -> Content
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    var body: some View {
        let appUser = AppUser(user: placeholderUser)
        let healthManager = HealthManager(appUser: appUser)
        
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
