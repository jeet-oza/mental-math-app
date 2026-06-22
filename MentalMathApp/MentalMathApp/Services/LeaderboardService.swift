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
    /// Records the player's result for a round.
    func submit(_ score: ArenaScore) async throws

    /// Returns the round's leaderboard with the player's entry merged and ranked.
    func leaderboard(
        forRound index: Int,
        including player: LeaderboardEntry
    ) async throws -> [LeaderboardEntry]
}

/// Offline implementation: deterministic computer opponents seeded per round,
/// merged with the local player. Identical output on every device.
struct LocalLeaderboardService: LeaderboardService {

    func submit(_ score: ArenaScore) async throws {
        // No-op offline. A networked service would persist the score here.
    }

    func leaderboard(
        forRound index: Int,
        including player: LeaderboardEntry
    ) async throws -> [LeaderboardEntry] {
        let merged = (ArenaSchedule.opponents(forRound: index) + [player])
            .sorted { $0.score > $1.score }

        return merged.enumerated().map { position, entry in
            LeaderboardEntry(
                id: entry.id,
                username: entry.username,
                score: entry.score,
                accuracy: entry.accuracy,
                rank: position + 1
            )
        }
    }
}
