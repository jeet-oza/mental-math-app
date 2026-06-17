//
//  ArenaRound.swift
//  MentalMathApp
//
//  Models for the Wordament-style Arena multiplayer mode.
//

import Foundation

/// Represents a single arena round fetched from the server.
/// All players receive the same round data simultaneously.
struct ArenaRound: Codable, Equatable, Sendable {
    let roundId: String
    let seed: String
    let difficulty: MathEngine.Difficulty
    let durationSeconds: Int
    let startTimestamp: Date

    /// Whether the round is currently in the play phase.
    func isActive(at currentTime: Date) -> Bool {
        let elapsed = currentTime.timeIntervalSince(startTimestamp)
        return elapsed >= 0 && elapsed < Double(durationSeconds)
    }

    /// Remaining seconds in the round. Returns 0 if expired.
    func remainingSeconds(at currentTime: Date) -> Int {
        let elapsed = currentTime.timeIntervalSince(startTimestamp)
        let remaining = Double(durationSeconds) - elapsed
        return max(0, Int(remaining))
    }
}

/// The player's result submitted at end of a round.
struct ArenaScore: Codable, Equatable, Sendable {
    let roundId: String
    let userId: String
    let totalScore: Int
    let correctCount: Int
    let skippedCount: Int
    let totalAttempted: Int
    let timeTakenSeconds: Double

    /// Accuracy as a value between 0.0 and 1.0.
    var accuracy: Double {
        guard totalAttempted > 0 else { return 0 }
        return Double(correctCount) / Double(totalAttempted)
    }

    /// Average time per correctly answered question in seconds.
    var averageTimePerCorrect: Double {
        guard correctCount > 0 else { return 0 }
        return timeTakenSeconds / Double(correctCount)
    }
}

/// Leaderboard entry shown during intermission.
struct LeaderboardEntry: Identifiable, Codable, Equatable, Sendable {
    let id: String
    let username: String
    let score: Int
    let accuracy: Double
    let rank: Int
}
