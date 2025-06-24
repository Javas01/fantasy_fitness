//
//  Untitled.swift
//  FantasyFitness
//
//  Created by Jawwaad Sabree on 6/17/25.
//

import SwiftUI
import AuthenticationServices
import Supabase

private func handleAppleLogin(result: Result<ASAuthorization, Error>) {
    switch result {
        case .success(let authResults):
            if let appleIDCredential = authResults.credential as? ASAuthorizationAppleIDCredential,
               let identityToken = appleIDCredential.identityToken,
               let idTokenString = String(data: identityToken, encoding: .utf8) {
                
                Task {
                    do {
                        let session = try await supabase.auth.signInWithIdToken(
                            credentials: OpenIDConnectCredentials(
                                provider: .apple,
                                idToken: idTokenString,
                                nonce: nil
                            )
                        )
                        print("Signed in to Supabase as user: \(session.user.id.uuidString.lowercased())")
                        
                        let fullName = [
                            appleIDCredential.fullName?.givenName,
                            appleIDCredential.fullName?.familyName
                        ].compactMap { $0 }.joined(separator: " ")
                        
                        print(fullName)
                        
                        let response: PostgrestResponse<[FFUser]> = try await supabase
                            .from("users")
                            .select("*")
                            .eq("id", value: session.user.id)
                            .limit(1)
                            .execute()
                                                
                        let users: [FFUser] = response.value
                        
                        if users.isEmpty {
                            print("Creating new user")
                            let newUser = FFUser(
                                id: session.user.id,
                                name: fullName.isEmpty ? "Anonymous" : fullName,
                                email: session.user.email ?? "",
                                avatarName: "",
                                ffScore: 0,
                                lastSync: Calendar.current.date(byAdding: .hour, value: -24, to: .now)!
                            )
                            try await supabase.from("users").insert(newUser).execute()
                        } else {
                            print("User already exists")
                        }
                    } catch {
                        print("Supabase login failed: \(error.localizedDescription)")
                    }
                }
            }
            
        case .failure(let error):
            print("Sign in failed: \(error.localizedDescription)")
    }
}

struct LoginView: View {
    @Binding var isSignedIn: Bool

    @State private var selection = 0
    
    let onboardingSlides = [
        ("Train with Friends", "Join challenges with your crew and compete for the top spot."),
        ("Track Your Progress", "Earn FantasyFitness Score and unlock new levels as you go."),
        ("Crush Daily Goals", "Complete daily challenges to stay consistent and motivated.")
    ]
    
    var body: some View {
        VStack(spacing: 40) {
            // Onboarding Carousel
            TabView(selection: $selection) {
                ForEach(0..<onboardingSlides.count, id: \.self) { index in
                    VStack(spacing: 20) {
                        Image("avatar_0_\(index)")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                        
                        Text(onboardingSlides[index].0)
                            .font(.title.bold())
                        
                        Text(onboardingSlides[index].1)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
            .frame(height: 500)
            
            Spacer()
            
            #if targetEnvironment(simulator)
            Button("Skip") {
                DispatchQueue.main.async {
                    isSignedIn = true
                }
            }
            #endif

            // Sign In With Apple Button
            SignInWithAppleButton(
                .signIn,
                onRequest: { request in
                    request.requestedScopes = [.fullName, .email]
                },
                onCompletion: { result in
                    handleAppleLogin(result: result)
                    DispatchQueue.main.async {
                        isSignedIn = true
                    }
                }
            )
            .signInWithAppleButtonStyle(.whiteOutline)
            .frame(height: 50)
            .padding(.horizontal, 40)
            
            Spacer(minLength: 40)
        }
        .padding(.top, 60)
        .appBackground()
    }
}

// MARK: - Preview

#Preview {
    LoginView(isSignedIn: .constant(false))
}
