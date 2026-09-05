//
//  ContentView.swift
//  Calcathon
//
//  Root view for the local learning and practice experience.
//

import SwiftUI

/// The root view of the app, providing tab navigation between lessons and practice.
struct ContentView: View {
    @StateObject private var curriculumVM = CurriculumViewModel()

    var body: some View {
        TabView {
            LearnTabView()
                .environmentObject(curriculumVM)
                .tabItem {
                    Label("Learn", systemImage: "book.fill")
                }

            PracticeTabView()
                .environmentObject(curriculumVM)
                .tabItem {
                    Label("Practice", systemImage: "timer")
                }
        }
        .environmentObject(curriculumVM)
        .tint(Color.brandAccent)
    }
}

#Preview {
    ContentView()
}
