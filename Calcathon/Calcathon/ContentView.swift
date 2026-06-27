//
//  ContentView.swift
//  Calcathon
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
    @StateObject private var gridArenaVM = GridArenaViewModel()
    @StateObject private var gridStats = GridStatsStore()
    @StateObject private var equationStats = EquationStatsStore()

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

            ArenaContainerView()
                .environmentObject(arenaVM)
                .environmentObject(gridArenaVM)
                .environmentObject(gridStats)
                .environmentObject(equationStats)
                .tabItem {
                    Label("Arena", systemImage: "flame.fill")
                }
        }
        // Shared with all tabs (and the Settings sheet opened from Learn).
        .environmentObject(curriculumVM)
        .environmentObject(equationStats)
        .environmentObject(gridStats)
        .tint(Color.brandAccent)
        .task(id: auth.user?.uid) {
            gridArenaVM.onRoundComplete { score, paths, longest, hundreds in
                gridStats.record(
                    gameScore: score,
                    pathsFound: paths,
                    longestPathThisGame: longest,
                    hundredsThisGame: hundreds
                )
            }
            arenaVM.onRoundComplete { score, correct, answered in
                equationStats.record(gameScore: score, correct: correct, answered: answered)
            }
            if let user = auth.user {
                arenaVM.configureOnlinePlay(userId: user.uid, displayName: user.displayName)
                gridArenaVM.configureOnlinePlay(userId: user.uid, displayName: user.displayName)
                await curriculumVM.enableCloudSync(uid: user.uid)
                await gridStats.enableCloudSync(uid: user.uid)
                await equationStats.enableCloudSync(uid: user.uid)
            }
        }
    }
}

#Preview {
    ContentView()
}
