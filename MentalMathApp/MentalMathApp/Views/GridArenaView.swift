//
//  GridArenaView.swift
//  MentalMathApp
//
//  Grid Arena UI: tap adjacent tiles to build a path summing to a multiple
//  of 10. Globally-synced rounds, leaderboard, and lifetime stats.
//

import SwiftUI

/// Reports the laid-out grid width so drag locations map to tiles.
private struct GridWidthKey: PreferenceKey {
    static let defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

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
                .foregroundStyle(Color.brandAccent)
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
                    .foregroundStyle(Color.brandAccent)
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
            Text("Drag across tiles that sum to a multiple of 10")
                .font(.caption)
                .foregroundStyle(.secondary)
            grid
            selectionBar
            if let message = viewModel.message {
                Text(message)
                    .font(.subheadline.bold())
                    .foregroundStyle(message.hasPrefix("+") ? .green : .secondary)
            }
            foundSummary
            Spacer()
        }
        .padding()
    }

    private var header: some View {
        HStack {
            HStack(spacing: 4) {
                Image(systemName: "clock.fill")
                    .foregroundStyle(viewModel.remainingSeconds <= 10 ? .red : Color.brandAccent)
                Text("\(viewModel.remainingSeconds)s")
                    .font(.title2.bold().monospacedDigit())
                    .foregroundStyle(viewModel.remainingSeconds <= 10 ? .red : .primary)
            }
            Spacer()
            Text("\(viewModel.score) pts")
                .font(.title2.bold().monospacedDigit())
                .foregroundStyle(Color.brandAccent)
        }
        .padding(.horizontal, 4)
    }

    private let spacing: CGFloat = 8
    @State private var gridWidth: CGFloat = 0

    private var grid: some View {
        VStack(spacing: spacing) {
            ForEach(0..<GridBoard.size, id: \.self) { row in
                HStack(spacing: spacing) {
                    ForEach(0..<GridBoard.size, id: \.self) { col in
                        let pos = GridPosition(row: row, col: col)
                        GridTileView(
                            value: viewModel.board.value(at: pos),
                            selectionIndex: viewModel.currentPath.firstIndex(of: pos)
                        )
                    }
                }
            }
        }
        .background(
            GeometryReader { proxy in
                Color.clear.preference(key: GridWidthKey.self, value: proxy.size.width)
            }
        )
        .onPreferenceChange(GridWidthKey.self) { gridWidth = $0 }
        .coordinateSpace(name: "grid")
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 0, coordinateSpace: .named("grid"))
                .onChanged { value in
                    guard gridWidth > 0 else { return }
                    let cell = (gridWidth - spacing * CGFloat(GridBoard.size - 1)) / CGFloat(GridBoard.size) + spacing
                    let col = Int(value.location.x / cell)
                    let row = Int(value.location.y / cell)
                    // Only register when the finger is inside the tile body, not
                    // the gap between tiles — lets diagonal drags trace cleanly
                    // instead of grabbing an orthogonal in-between tile.
                    let xInCell = value.location.x - CGFloat(col) * cell
                    let yInCell = value.location.y - CGFloat(row) * cell
                    let tile = cell - spacing
                    guard xInCell <= tile, yInCell <= tile else { return }
                    let pos = GridPosition(row: row, col: col)
                    if GridBoard.isInBounds(pos) { viewModel.dragEntered(pos) }
                }
                .onEnded { _ in viewModel.endDrag() }
        )
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
                .fill(isSelected ? AnyShapeStyle(.accentGradient) : AnyShapeStyle(Color.brandBeige))
                .shadow(color: .black.opacity(0.25), radius: 3, y: 2)

            Text("\(value)")
                .font(.title.bold().monospacedDigit())
                .foregroundStyle(isSelected ? .white : Color.groupedBackground)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            if let index = selectionIndex {
                Text("\(index + 1)")
                    .font(.caption2.bold())
                    .foregroundStyle(Color.brandRust)
                    .padding(4)
                    .background(Circle().fill(.white))
                    .padding(4)
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("\(value)"))
        .accessibilityValue(Text(selectionIndex.map { "Selected, position \($0 + 1)" } ?? "Not selected"))
    }
}

// MARK: - Results

private struct GridResultsView: View {
    @EnvironmentObject var viewModel: GridArenaViewModel
    @EnvironmentObject var stats: GridStatsStore
    @State private var tab: ResultsTab = .results

    var body: some View {
        VStack(spacing: 12) {
            Text("Next game in 0:\(String(format: "%02d", viewModel.nextRoundStartsIn))")
                .font(.headline.monospacedDigit())
                .foregroundStyle(Color.brandAccent)

            if viewModel.leaderboardReady {
                Picker("View", selection: $tab) {
                    ForEach(ResultsTab.allCases) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
            }

            ScrollView {
                VStack(spacing: 20) {
                    if viewModel.leaderboardReady && tab == .leaderboards {
                        LeaderboardTableView(
                            entries: viewModel.leaderboard,
                            playerId: viewModel.currentPlayerId
                        )
                    } else {
                        resultsContent
                        if !viewModel.leaderboardReady {
                            HStack(spacing: 8) {
                                ProgressView()
                                Text("Final standings in \(secondsUntilReady)s…")
                                    .font(.subheadline).foregroundStyle(.secondary)
                            }
                            .padding()
                        }
                    }
                }
                .padding()
            }
        }
        .onChange(of: viewModel.leaderboardReady) { _, ready in
            if ready { tab = .leaderboards }
        }
    }

    private var secondsUntilReady: Int {
        max(0, viewModel.nextRoundStartsIn - (ArenaSchedule.intermission - ArenaSchedule.leaderboardDelaySeconds))
    }

    private var resultsContent: some View {
        VStack(spacing: 20) {
            VStack(spacing: 4) {
                Text("\(viewModel.score)")
                    .font(.system(size: 52, weight: .heavy, design: .rounded))
                    .foregroundStyle(Color.brandAccent)
                Text("points this round").font(.subheadline).foregroundStyle(.secondary)
            }

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

            if !viewModel.solutionsHundreds.isEmpty {
                solutionsCard(title: "Multiples of 100", solutions: viewModel.solutionsHundreds)
            }
            if !viewModel.solutionsTens.isEmpty {
                solutionsCard(title: "Multiples of 10", solutions: viewModel.solutionsTens)
            }
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

    /// A capped, Wordament-style list of board solutions, marking ones the
    /// player found. Sorted by points; shows the top entries with a "+N more".
    private func solutionsCard(title: String, solutions: [GridSolution]) -> some View {
        let cap = 30
        let shown = Array(solutions.prefix(cap))
        let found = viewModel.foundSolutionKeys
        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title).font(.headline)
                Spacer()
                Text("\(found.intersection(Set(solutions.map(\.id))).count)/\(solutions.count) found")
                    .font(.caption).foregroundStyle(.secondary)
            }
            ForEach(shown) { solution in
                HStack(spacing: 8) {
                    Image(systemName: found.contains(solution.id) ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(found.contains(solution.id) ? .green : .secondary)
                    Text(solution.expression)
                        .font(.subheadline.monospacedDigit())
                        .foregroundStyle(found.contains(solution.id) ? .primary : .secondary)
                    Spacer()
                    Text("\(solution.points)")
                        .font(.subheadline.bold().monospacedDigit())
                        .foregroundStyle(Color.brandAccent)
                }
                .padding(.vertical, 2)
            }
            if solutions.count > cap {
                Text("+\(solutions.count - cap) more combinations")
                    .font(.caption).foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.appBackground)
            .shadow(color: .black.opacity(0.05), radius: 6, y: 3))
    }

}
