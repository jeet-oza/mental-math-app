//
//  ArenaSchedule.swift
//  MentalMathApp
//
//  Wall-clock-derived global schedule for Arena Mode.
//
//  There is no game server, so synchronization is achieved by deriving the
//  current round purely from the clock: rounds run on a fixed 2-minute cadence
//  anchored to a shared epoch. Every device computes the same round index,
//  the same seed (so the same questions), and the same play/results windows.
//

import Foundation

/// Computes the globally-synchronized Arena round state from the current time.
nonisolated enum ArenaSchedule {

    /// Seconds of active gameplay per round.
    static let playDuration = 90
    /// Seconds of results/intermission between rounds.
    static let intermission = 30
    /// Full cycle length: a new round starts every `cycle` seconds.
    static var cycle: Int { playDuration + intermission } // 120

    /// Fixed reference instant all devices agree on (2024-01-01 00:00:00 UTC).
    static let epoch = Date(timeIntervalSince1970: 1_704_067_200)

    /// The current phase of the global Arena cycle.
    enum Phase: Equatable {
        /// A round is live. `remaining` counts down to 0.
        case playing(roundIndex: Int, remaining: Int)
        /// Between rounds. `startsIn` counts down to the next round.
        case intermission(nextRoundIndex: Int, startsIn: Int)
    }

    /// Resolves the phase for a given instant (defaults to now).
    static func phase(at date: Date = Date()) -> Phase {
        let elapsed = max(0, date.timeIntervalSince(epoch))
        let index = Int(elapsed / Double(cycle))
        let offset = Int(elapsed.truncatingRemainder(dividingBy: Double(cycle)))

        if offset < playDuration {
            return .playing(roundIndex: index, remaining: playDuration - offset)
        } else {
            return .intermission(nextRoundIndex: index + 1, startsIn: cycle - offset)
        }
    }

    /// Deterministic seed for a round so all players face identical questions.
    static func seed(forRound index: Int) -> String {
        "arena_round_\(index)"
    }

    /// Rotating difficulty so rounds vary, but identically for everyone.
    static func difficulty(forRound index: Int) -> MathEngine.Difficulty {
        switch index % 3 {
        case 0: return .easy
        case 1: return .medium
        default: return .hard
        }
    }

    /// Generates a deterministic set of computer opponents for a round so the
    /// leaderboard is populated identically on every device. The player's own
    /// score is merged and ranked in by the view model.
    static func opponents(forRound index: Int) -> [LeaderboardEntry] {
        var rng = SeededRandomNumberGenerator(seed: "leaderboard_\(index)")
        let names = ["Ava", "Liam", "Noah", "Mia", "Kai", "Zoe", "Leo", "Ivy"]
        let difficulty = difficulty(forRound: index)
        let ceiling = Int(2200 * ScoreCalculator.difficultyBonus(for: difficulty))

        return names.map { name in
            let score = Int.random(in: 200...ceiling, using: &rng)
            let accuracy = Double.random(in: 0.55...0.98, using: &rng)
            return LeaderboardEntry(
                id: "bot_\(name)_\(index)",
                username: name,
                score: score,
                accuracy: accuracy,
                rank: 0 // assigned after merging with the player
            )
        }
    }
}
