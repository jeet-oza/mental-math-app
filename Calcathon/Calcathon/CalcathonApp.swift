//
//  CalcathonApp.swift
//  Calcathon
//
//  Created by Jeet Oza on 5/28/26.
//

import SwiftUI

@main
struct CalcathonApp: App {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    var body: some Scene {
        WindowGroup {
            Group {
                if !hasSeenOnboarding {
                    OnboardingView { hasSeenOnboarding = true }
                } else {
                    ContentView()
                }
            }
            .tint(Color.brandAccent)
            .preferredColorScheme(.dark)
        }
    }
}
