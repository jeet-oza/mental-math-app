//
//  EquationArenaStats.swift
//  MentalMathApp
//
//  Cumulative lifetime stats for the Equation Arena, additive across runs.
//

import Foundation

struct EquationArenaStats: Codable, Equatable, Sendable {
    var gamesPlayed: Int = 0
    var totalScore: Int = 0
    var bestGameScore: Int = 0
    var totalCorrect: Int = 0
    var totalAnswered: Int = 0
    var bestAccuracyPct: Int = 0

    mutating func record(gameScore: Int, correct: Int, answered: Int) {
        gamesPlayed += 1
        totalScore += gameScore
        bestGameScore = max(bestGameScore, gameScore)
        totalCorrect += correct
        totalAnswered += answered
        if answered > 0 {
            bestAccuracyPct = max(bestAccuracyPct, Int(Double(correct) / Double(answered) * 100))
        }
    }

    var averageScore: Int {
        guard gamesPlayed > 0 else { return 0 }
        return totalScore / gamesPlayed
    }

    var lifetimeAccuracyPct: Int {
        guard totalAnswered > 0 else { return 0 }
        return Int(Double(totalCorrect) / Double(totalAnswered) * 100)
    }

    /// Element-wise max merge (stats only grow), safe across devices.
    func merged(with other: EquationArenaStats) -> EquationArenaStats {
        EquationArenaStats(
            gamesPlayed: max(gamesPlayed, other.gamesPlayed),
            totalScore: max(totalScore, other.totalScore),
            bestGameScore: max(bestGameScore, other.bestGameScore),
            totalCorrect: max(totalCorrect, other.totalCorrect),
            totalAnswered: max(totalAnswered, other.totalAnswered),
            bestAccuracyPct: max(bestAccuracyPct, other.bestAccuracyPct)
        )
    }
}
