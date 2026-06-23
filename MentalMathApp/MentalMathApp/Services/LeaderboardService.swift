//
//  LeaderboardService.swift
//  MentalMathApp
//
//  Backend-agnostic boundary for Arena score submission and leaderboards.
//
//  Today the only implementation is `LocalLeaderboardService` (deterministic
//  computer opponents, no network). A future `FirebaseLeaderboardService` can
//  conform to the same protocol so real multiplayer drops in without touching
//  the view model or views.
//

import Foundation

/// Submits a player's Arena result and returns the ranked leaderboard for a round.
protocol LeaderboardService: Sendable {
    /// Records the player's entry for a round.
    func submit(_ entry: LeaderboardEntry, forRound index: Int) async throws

    /// Returns the round's leaderboard with the player's entry included and ranked.
    func leaderboard(
        forRound index: Int,
        including player: LeaderboardEntry
    ) async throws -> [LeaderboardEntry]
}

/// Ranks entries by score (descending) and assigns 1-based ranks.
func rankedLeaderboard(_ entries: [LeaderboardEntry]) -> [LeaderboardEntry] {
    entries.sorted { $0.score > $1.score }.enumerated().map { position, entry in
        LeaderboardEntry(
            id: entry.id,
            username: entry.username,
            score: entry.score,
            accuracy: entry.accuracy,
            rank: position + 1
        )
    }
}

/// Offline implementation: deterministic computer opponents seeded per round,
/// merged with the local player. Identical output on every device.
struct LocalLeaderboardService: LeaderboardService {

    func submit(_ entry: LeaderboardEntry, forRound index: Int) async throws {
        // No-op offline. A networked service persists the entry here.
    }

    func leaderboard(
        forRound index: Int,
        including player: LeaderboardEntry
    ) async throws -> [LeaderboardEntry] {
        rankedLeaderboard(ArenaSchedule.opponents(forRound: index) + [player])
    }
}
