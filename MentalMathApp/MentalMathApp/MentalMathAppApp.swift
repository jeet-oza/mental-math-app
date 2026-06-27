//
//  MentalMathAppApp.swift
//  MentalMathApp
//
//  Created by Jeet Oza on 5/28/26.
//

import SwiftUI
import FirebaseCore

@main
struct MentalMathAppApp: App {
    @StateObject private var auth = AuthService()
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if !hasSeenOnboarding {
                    OnboardingView { hasSeenOnboarding = true }
                } else if auth.isSignedIn {
                    ContentView()
                } else {
                    SignInView()
                }
            }
            .environmentObject(auth)
            .tint(Color.brandAccent)
            .preferredColorScheme(.dark)
        }
    }
}
