//
//  ArenaContainerView.swift
//  Calcathon
//
//  Arena home (Wordament-style): pick a mode, see your lifetime stats, and
//  tap PLAY to join the live round. The live round screen connects to the
//  global schedule on appear and disconnects when you leave.
//

import SwiftUI

struct ArenaContainerView: View {
    enum Mode: String, CaseIterable, Identifiable {
        case equations = "Equations"
        case grid = "Grid"
        var id: String { rawValue }
    }

    @EnvironmentObject private var equationStats: EquationStatsStore
    @EnvironmentObject private var gridStats: GridStatsStore

    @AppStorage("hasSeenEquationHowToPlay") private var hasSeenEquationHowToPlay = false
    @AppStorage("hasSeenGridHowToPlay") private var hasSeenGridHowToPlay = false

    /// A pending How to Play presentation: which mode, and whether dismissing
    /// it should join the round (a gate on first PLAY) or just close it (a
    /// voluntary lookup via the toolbar's "?" button). Bundled into one value
    /// so the two facts can never end up out of sync.
    private struct HowToPlayRequest: Identifiable {
        let mode: Mode
        let joinsOnDismiss: Bool
        var id: String { "\(mode.rawValue)-\(joinsOnDismiss)" }
    }

    @State private var mode: Mode = .equations
    @State private var isPlaying = false
    @State private var howToPlayRequest: HowToPlayRequest?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("Mode", selection: $mode) {
                    ForEach(Mode.allCases) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.segmented)
                .padding([.horizontal, .top])

                ScrollView { landing }
            }
            .background(Color.groupedBackground)
            .navigationTitle("Arena")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        howToPlayRequest = HowToPlayRequest(mode: mode, joinsOnDismiss: false)
                    } label: {
                        Image(systemName: "questionmark.circle")
                    }
                    .accessibilityLabel(Text("How to Play"))
                }
            }
            .navigationDestination(isPresented: $isPlaying) { liveView }
            .fullScreenCover(item: $howToPlayRequest) { request in
                howToPlaySheet(for: request)
            }
        }
    }

    @ViewBuilder
    private var landing: some View {
        switch mode {
        case .equations:
            ArenaLandingView(
                title: "Equation Arena",
                subtitle: "Solve as many equations as you can in 90 seconds.",
                icon: "flame.fill",
                statRows: equationRows,
                onPlay: { play(.equations) }
            )
        case .grid:
            ArenaLandingView(
                title: "Number Grid",
                subtitle: "Each round picks a new rule — multiples, targets, and more.",
                icon: "square.grid.3x3.fill",
                statRows: gridRows,
                onPlay: { play(.grid) }
            )
        }
    }

    /// Shows the mode's How to Play sheet the first time a player joins it;
    /// afterwards jumps straight into the live round.
    private func play(_ mode: Mode) {
        let hasSeen = mode == .equations ? hasSeenEquationHowToPlay : hasSeenGridHowToPlay
        if hasSeen {
            isPlaying = true
        } else {
            howToPlayRequest = HowToPlayRequest(mode: mode, joinsOnDismiss: true)
        }
    }

    @ViewBuilder
    private func howToPlaySheet(for request: HowToPlayRequest) -> some View {
        let dismiss = {
            howToPlayRequest = nil
            if request.joinsOnDismiss { isPlaying = true }
        }
        switch request.mode {
        case .equations:
            HowToPlaySheet.equationArena(buttonTitle: request.joinsOnDismiss ? "Let's Play" : "Got it") {
                hasSeenEquationHowToPlay = true
                dismiss()
            }
        case .grid:
            HowToPlaySheet.gridArena(buttonTitle: request.joinsOnDismiss ? "Let's Play" : "Got it") {
                hasSeenGridHowToPlay = true
                dismiss()
            }
        }
    }

    @ViewBuilder
    private var liveView: some View {
        switch mode {
        case .equations: ArenaTabView()
        case .grid: GridArenaView()
        }
    }

    private var equationRows: [(String, String)] {
        let s = equationStats.stats
        return [
            ("Games played", "\(s.gamesPlayed)"),
            ("Best score", "\(s.bestGameScore)"),
            ("Avg / game", "\(s.averageScore)"),
            ("Total score", "\(s.totalScore)"),
            ("Lifetime accuracy", "\(s.lifetimeAccuracyPct)%"),
            ("Best accuracy", "\(s.bestAccuracyPct)%")
        ]
    }

    private var gridRows: [(String, String)] {
        let s = gridStats.stats
        return [
            ("Games played", "\(s.gamesPlayed)"),
            ("Best score", "\(s.bestGameScore)"),
            ("Avg / game", "\(s.averageScore)"),
            ("Total score", "\(s.totalScore)"),
            ("Paths found", "\(s.totalPathsFound)"),
            ("Longest path", "\(s.longestPath)"),
            ("Multiples of 100", "\(s.hundredsFound)")
        ]
    }
}

/// A Wordament-style mode landing: hero, big PLAY button, and lifetime stats.
private struct ArenaLandingView: View {
    let title: String
    let subtitle: String
    let icon: String
    let statRows: [(String, String)]
    let onPlay: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: icon)
                .font(.system(size: 56))
                .foregroundStyle(Color.brandAccent)
                .padding(.top, 16)

            VStack(spacing: 6) {
                Text(title).font(.title.bold())
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Button(action: onPlay) {
                Label("PLAY", systemImage: "play.fill")
                    .font(.title2.bold())
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .foregroundStyle(.white)
                    .background(RoundedRectangle(cornerRadius: 16).fill(.accentGradient))
            }
            .accessibilityHint(Text("Joins the next live round"))

            VStack(alignment: .leading, spacing: 10) {
                Text("Your Stats").font(.headline)
                ForEach(statRows, id: \.0) { label, value in
                    HStack {
                        Text(label).foregroundStyle(.secondary)
                        Spacer()
                        Text(value).font(.headline.monospacedDigit())
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.appBackground)
                    .shadow(color: .black.opacity(0.05), radius: 6, y: 3)
            )
        }
        .padding()
    }
}
