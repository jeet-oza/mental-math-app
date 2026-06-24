//
//  ArenaContainerView.swift
//  MentalMathApp
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

    @State private var mode: Mode = .equations
    @State private var isPlaying = false

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
            .navigationDestination(isPresented: $isPlaying) { liveView }
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
                onPlay: { isPlaying = true }
            )
        case .grid:
            ArenaLandingView(
                title: "Number Grid",
                subtitle: "Trace tiles that add up to a multiple of 10.",
                icon: "square.grid.3x3.fill",
                statRows: gridRows,
                onPlay: { isPlaying = true }
            )
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
                .foregroundStyle(Color.brandPrimary)
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
