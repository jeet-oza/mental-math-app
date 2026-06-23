//
//  GridArenaView.swift
//  MentalMathApp
//
//  Grid Arena UI: tap adjacent tiles to build a path summing to a multiple
//  of 10. Globally-synced rounds, leaderboard, and lifetime stats.
//

import SwiftUI

struct GridArenaView: View {
    @EnvironmentObject var viewModel: GridArenaViewModel
    @EnvironmentObject var stats: GridStatsStore

    var body: some View {
        ZStack {
            Color.groupedBackground.ignoresSafeArea()

            switch viewModel.phase {
            case .waiting:
                GridWaitingView(
                    secondsUntilStart: viewModel.nextRoundStartsIn,
                    roundNumber: viewModel.currentRoundIndex
                )
            case .playing:
                GridPlayingView().environmentObject(viewModel)
            case .submitting:
                ProgressView("Submitting…")
            case .leaderboard:
                GridResultsView().environmentObject(viewModel).environmentObject(stats)
            }
        }
        .onAppear { viewModel.connect() }
        .onDisappear { viewModel.disconnect() }
    }
}

// MARK: - Waiting

private struct GridWaitingView: View {
    let secondsUntilStart: Int
    let roundNumber: Int

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "square.grid.3x3.fill")
                .font(.system(size: 60))
                .foregroundStyle(Color.brandPrimary)
            Text("Number Grid")
                .font(.largeTitle.bold())
            Text("Trace tiles that add up to a multiple of 10.\nLonger paths score more.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            VStack(spacing: 4) {
                Text("Next round starts in").font(.subheadline).foregroundStyle(.secondary)
                Text("\(secondsUntilStart)s")
                    .font(.system(size: 52, weight: .heavy, design: .rounded).monospacedDigit())
                    .foregroundStyle(Color.brandPrimary)
                    .contentTransition(.numericText())
                Text("Round #\(roundNumber + 1)").font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding()
    }
}

// MARK: - Playing

private struct GridPlayingView: View {
    @EnvironmentObject var viewModel: GridArenaViewModel

    var body: some View {
        VStack(spacing: 16) {
            header
            grid
            selectionBar
            if let message = viewModel.message {
                Text(message)
                    .font(.subheadline.bold())
                    .foregroundStyle(viewModel.currentIsValid || message.hasPrefix("+") ? .green : .red)
            }
            actions
            foundSummary
            Spacer()
        }
        .padding()
    }

    private var header: some View {
        HStack {
            HStack(spacing: 4) {
                Image(systemName: "clock.fill")
                    .foregroundStyle(viewModel.remainingSeconds <= 10 ? .red : Color.brandPrimary)
                Text("\(viewModel.remainingSeconds)s")
                    .font(.title2.bold().monospacedDigit())
                    .foregroundStyle(viewModel.remainingSeconds <= 10 ? .red : .primary)
            }
            Spacer()
            Text("\(viewModel.score) pts")
                .font(.title2.bold().monospacedDigit())
                .foregroundStyle(Color.brandPrimary)
        }
        .padding(.horizontal, 4)
    }

    private var grid: some View {
        VStack(spacing: 8) {
            ForEach(0..<GridBoard.size, id: \.self) { row in
                HStack(spacing: 8) {
                    ForEach(0..<GridBoard.size, id: \.self) { col in
                        let pos = GridPosition(row: row, col: col)
                        GridTileView(
                            value: viewModel.board.value(at: pos),
                            selectionIndex: viewModel.currentPath.firstIndex(of: pos)
                        )
                        .onTapGesture { viewModel.tapTile(pos) }
                    }
                }
            }
        }
    }

    private var selectionBar: some View {
        HStack {
            Text("Sum: \(viewModel.currentSum)")
                .font(.headline.monospacedDigit())
                .foregroundStyle(viewModel.currentIsValid ? .green : .primary)
            Spacer()
            if viewModel.currentPotentialPoints > 0 {
                Text("+\(viewModel.currentPotentialPoints) pts")
                    .font(.headline.monospacedDigit())
                    .foregroundStyle(.green)
            }
        }
        .padding(.horizontal, 4)
        .frame(height: 24)
    }

    private var actions: some View {
        HStack(spacing: 16) {
            Button(action: viewModel.clearPath) {
                Text("Clear")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundStyle(Color.brandPrimary)
                    .background(RoundedRectangle(cornerRadius: 12).stroke(Color.brandPrimary, lineWidth: 2))
            }
            .disabled(viewModel.currentPath.isEmpty)

            Button(action: viewModel.submitPath) {
                Text("Submit")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundStyle(.white)
                    .background(RoundedRectangle(cornerRadius: 12).fill(.brandGradient))
            }
            .disabled(viewModel.currentPath.count < GridScoring.minimumLength)
        }
    }

    private var foundSummary: some View {
        HStack {
            Label("\(viewModel.foundPaths.count) found", systemImage: "checkmark.circle.fill")
                .foregroundStyle(.green)
            Spacer()
            if let best = viewModel.foundPaths.map(\.points).max() {
                Text("Best: \(best) pts").foregroundStyle(.secondary)
            }
        }
        .font(.footnote)
        .padding(.horizontal, 4)
    }
}

/// A single grid tile, highlighted with its selection order when in the path.
private struct GridTileView: View {
    let value: Int
    let selectionIndex: Int?

    private var isSelected: Bool { selectionIndex != nil }

    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? AnyShapeStyle(.brandGradient) : AnyShapeStyle(Color.appBackground))
                .shadow(color: .black.opacity(0.06), radius: 3, y: 2)

            Text("\(value)")
                .font(.title.bold().monospacedDigit())
                .foregroundStyle(isSelected ? .white : .primary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            if let index = selectionIndex {
                Text("\(index + 1)")
                    .font(.caption2.bold())
                    .foregroundStyle(Color.brandPrimary)
                    .padding(4)
                    .background(Circle().fill(.white))
                    .padding(4)
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

// MARK: - Results

private struct GridResultsView: View {
    @EnvironmentObject var viewModel: GridArenaViewModel
    @EnvironmentObject var stats: GridStatsStore

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Round Complete!").font(.largeTitle.bold())

                Text("\(viewModel.score)")
                    .font(.system(size: 52, weight: .heavy, design: .rounded))
                    .foregroundStyle(Color.brandPrimary)
                Text("points this round").font(.subheadline).foregroundStyle(.secondary)

                statsCard(title: "This Round", rows: [
                    ("Paths found", "\(viewModel.foundPaths.count)"),
                    ("Longest path", "\(viewModel.foundPaths.map(\.positions.count).max() ?? 0)"),
                    ("Multiples of 100", "\(viewModel.foundPaths.filter(\.isHundred).count)")
                ])

                statsCard(title: "Lifetime", rows: [
                    ("Games played", "\(stats.stats.gamesPlayed)"),
                    ("Total score", "\(stats.stats.totalScore)"),
                    ("Best game", "\(stats.stats.bestGameScore)"),
                    ("Avg / game", "\(stats.stats.averageScore)"),
                    ("Paths found", "\(stats.stats.totalPathsFound)"),
                    ("Longest ever", "\(stats.stats.longestPath)")
                ])

                if !viewModel.leaderboard.isEmpty {
                    leaderboardCard
                }

                VStack(spacing: 4) {
                    Text("Next round starts in").font(.subheadline).foregroundStyle(.secondary)
                    Text("\(viewModel.nextRoundStartsIn)s")
                        .font(.title.bold().monospacedDigit())
                        .foregroundStyle(Color.brandPrimary)
                        .contentTransition(.numericText())
                }
            }
            .padding()
        }
    }

    private func statsCard(title: String, rows: [(String, String)]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.headline)
            ForEach(rows, id: \.0) { label, value in
                HStack {
                    Text(label).foregroundStyle(.secondary)
                    Spacer()
                    Text(value).font(.headline.monospacedDigit())
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.appBackground)
            .shadow(color: .black.opacity(0.05), radius: 6, y: 3))
    }

    private var leaderboardCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Leaderboard").font(.headline)
            ForEach(viewModel.leaderboard) { entry in
                let isYou = entry.id == viewModel.currentPlayerId
                HStack {
                    Text("#\(entry.rank)").font(.headline.monospacedDigit()).frame(width: 40)
                    Text(entry.username).font(isYou ? .body.bold() : .body)
                    Spacer()
                    Text("\(entry.score) pts").font(.headline.monospacedDigit())
                        .foregroundStyle(Color.brandPrimary)
                }
                .padding(.vertical, 6).padding(.horizontal, 8)
                .background(RoundedRectangle(cornerRadius: 8)
                    .fill(isYou ? Color.brandPrimary.opacity(0.12) : .clear))
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.appBackground)
            .shadow(color: .black.opacity(0.05), radius: 6, y: 3))
    }
}
