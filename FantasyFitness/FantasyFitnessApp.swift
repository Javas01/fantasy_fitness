//
//  FantasyFitnessApp.swift
//  FantasyFitness
//
//  Created by Jawwaad Sabree on 6/17/25.
//

import SwiftUI
import SwiftData
import UserNotifications
import OneSignalFramework
import WidgetKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        // Enable verbose logging for debugging (remove in production)
        OneSignal.Debug.setLogLevel(.LL_ERROR)
        // Initialize with your OneSignal App ID
        OneSignal.initialize("89ce9cde-cf9b-4eb5-beee-0c0588eff190", withLaunchOptions: launchOptions)
        // Use this method to prompt for push notifications.
        // We recommend removing this method after testing and instead use In-App Messages to prompt for notification permission.
        OneSignal.Notifications.requestPermission({ accepted in
            print("User accepted notifications: \(accepted)")
        }, fallbackToSettings: false)
        
        // ✅ Save player ID if available
        if let playerId = OneSignal.User.pushSubscription.id {
            print("✅ OneSignal Player ID: \(playerId)")
            print("Push Token: \(OneSignal.User.pushSubscription.token ?? "nil")")
            
            Task {
                await sendNotificationTokenToSupabase(token: playerId)
            }
        } else {
            print("❌ No OneSignal Player ID available")
        }
        
        return true
    }
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        print("📬 Received silent push")
        
        if let data = userInfo["custom"] as? [String: Any],
           let additional = data["a"] as? [String: Any],
           additional["type"] as? String == "widget_update" {
            WidgetCenter.shared.reloadAllTimelines()
            print("🔁 Widget refresh triggered from silent push")
        }
        
        completionHandler(.newData)
    }
    // ✅ Called when a notification is about to be shown in foreground
    func onWillDisplay(event: OSNotificationWillDisplayEvent) {
        print("recieved notif")
        print(event)
        if event.notification.additionalData?["type"] as? String == "widget_update" {
            WidgetCenter.shared.reloadAllTimelines()
            print("🔁 Widget refresh triggered from foreground notification")
            event.preventDefault()
        }
    }
}

@main
struct FantasyFitnessApp: App {
    // this gives us access to our app delegate in SwiftUI
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @StateObject private var appUser = AppUser(user: FFUser.placeholder)
    @StateObject private var healthManager = HealthManager()
    @State private var isSignedIn = false
    
//    init() {
//        requestNotificationPermission()
//    }
    
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
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appUser)
                .environmentObject(healthManager)
                .onAppear {
                    WidgetCenter.shared.reloadAllTimelines()
                    Task {
                        do {
                            let session = try await supabase.auth.session
                            let userId = session.user.id
                            print("✅ User ID: \(userId)")
                            isSignedIn = true
                        } catch {
                            print("❌ No active session or failed to get session: \(error)")
                        }
                    }
                }
        }
        .modelContainer(sharedModelContainer)
    }
}

struct RootView: View {
    @EnvironmentObject var appUser: AppUser
    
    var body: some View {
        if appUser.isSignedIn {
            ContentView()
        } else {
            LoginView()
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

func sendNotificationTokenToSupabase(token: String) async {
    guard let userId = supabase.auth.currentUser?.id else {
        print("User not logged in.")
        return
    }
    
    let newToken = await NewNotificationToken(
        userId: userId,
        token: token,
        deviceInfo: UIDevice.current.name
    )
    
    do {
        let _ = try await supabase
            .from("notification_tokens")
            .upsert(newToken, onConflict: "user_id,token")
            .execute()
        
        print("✅ Token sent to Supabase")
    } catch {
        print("❌ Error sending token to Supabase: \(error)")
    }
}
