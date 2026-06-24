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

            // Ranked rows
            ForEach(entries) { entry in
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
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.appBackground)
                .shadow(color: .black.opacity(0.05), radius: 6, y: 3)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
