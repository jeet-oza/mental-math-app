//
//  ContentView.swift
//  MentalMathApp
//
//  Root view with tab-based navigation between Learn and Arena modes.
//

import SwiftUI

/// The root view of the app, providing tab navigation
/// between Learn Mode and Arena Mode.
struct ContentView: View {
    @StateObject private var curriculumVM = CurriculumViewModel()
    @StateObject private var arenaVM = ArenaViewModel()

    var body: some View {
        TabView {
            LearnTabView()
                .environmentObject(curriculumVM)
                .tabItem {
                    Label("Learn", systemImage: "book.fill")
                }

            ArenaTabView()
                .environmentObject(arenaVM)
                .tabItem {
                    Label("Arena", systemImage: "flame.fill")
                }
        }
        .tint(.orange)
    }
}

#Preview {
    ContentView()
}
