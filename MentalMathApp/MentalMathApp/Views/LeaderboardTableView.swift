//
//  LeaderboardTableView.swift
//  MentalMathApp
//
//  Wordament-style ranked leaderboard: a player summary band, a column
//  header, and ranked rows with the player's row highlighted.
//

import SwiftUI

/// Tabs on the post-round results screen.
enum ResultsTab: String, CaseIterable, Identifiable {
    case results = "Results"
    case leaderboards = "Leaderboards"
    var id: String { rawValue }
}

struct LeaderboardTableView: View {
    let entries: [LeaderboardEntry]
    let playerId: String

    /// The top 10 entries.
    private var topRows: [LeaderboardEntry] {
        Array(entries.sorted { $0.rank < $1.rank }.prefix(10))
    }

    /// Entries within ±5 ranks of the player, excluding the top 10 already shown.
    private var nearRows: [LeaderboardEntry] {
        guard let myRank = entries.first(where: { $0.id == playerId })?.rank else { return [] }
        let lower = max(11, myRank - 5)
        let upper = myRank + 5
        return entries
            .filter { $0.rank >= lower && $0.rank <= upper }
            .sorted { $0.rank < $1.rank }
    }

    @ViewBuilder
    private func row(for entry: LeaderboardEntry) -> some View {
        let isYou = entry.id == playerId
        HStack {
            Text("\(entry.rank)")
                .font(.subheadline.monospacedDigit())
                .frame(width: 52, alignment: .leading)
            Text(entry.username)
                .font(isYou ? .subheadline.bold() : .subheadline)
            Spacer()
            Text("\(entry.score)")
                .font(.subheadline.bold().monospacedDigit())
                .foregroundStyle(isYou ? Color.brandAccent : .primary)
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(isYou ? Color.brandAccent.opacity(0.15) : Color.clear)
    }

    var body: some View {
        let me = entries.first { $0.id == playerId }

        VStack(spacing: 0) {
            // Player summary band (rank / name / score)
            if let me {
                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("\(me.rank)")
                            .font(.title.bold())
                        Text("of \(entries.count)")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.8))
                    }
                    Text(me.username)
                        .font(.headline)
                        .padding(.leading, 8)
                    Spacer()
                    VStack(alignment: .trailing, spacing: 0) {
                        Text("\(me.score)")
                            .font(.title2.bold().monospacedDigit())
                        Text("points")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.8))
                    }
                }
                .padding()
                .background(Color.brandPrimary)
                .foregroundStyle(.white)
            }

            // Column header
            HStack {
                Text("Rank").frame(width: 52, alignment: .leading)
                Text("Name")
                Spacer()
                Text("Score")
            }
            .font(.caption.bold())
            .foregroundStyle(.secondary)
            .padding(.horizontal)
            .padding(.vertical, 8)

            Divider()

            // Top 10
            ForEach(topRows) { row(for: $0) }

            // Window of ±5 around the player's rank (when below the top 10).
            if !nearRows.isEmpty {
                Text("Results near your rank")
                    .font(.caption.bold())
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                    .background(Color.brandMaroon)
                ForEach(nearRows) { row(for: $0) }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.appBackground)
                .shadow(color: .black.opacity(0.05), radius: 6, y: 3)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
