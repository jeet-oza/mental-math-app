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
    @EnvironmentObject private var auth: AuthService
    @StateObject private var curriculumVM = CurriculumViewModel()
    @StateObject private var arenaVM = ArenaViewModel()

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
                    Label("Practice", systemImage: "pencil.and.list.clipboard")
                }

            ArenaTabView()
                .environmentObject(arenaVM)
                .tabItem {
                    Label("Arena", systemImage: "flame.fill")
                }
        }
        .tint(Color.brandPrimary)
        .task(id: auth.user?.uid) {
            if let uid = auth.user?.uid {
                await curriculumVM.enableCloudSync(uid: uid)
            }
        }
    }
}

#Preview {
    ContentView()
}
