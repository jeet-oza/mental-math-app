//
//  GridArenaStats.swift
//  MentalMathApp
//
//  Cumulative lifetime stats for Grid Arena, additive across games like
//  Wordament's personal stats.
//

import Foundation

/// Lifetime Grid Arena stats for a single player.
struct GridArenaStats: Codable, Equatable, Sendable {
    var gamesPlayed: Int = 0
    var totalScore: Int = 0
    var bestGameScore: Int = 0
    var totalPathsFound: Int = 0
    var longestPath: Int = 0
    var hundredsFound: Int = 0

    /// Folds a finished game's results into the lifetime totals.
    mutating func record(
        gameScore: Int,
        pathsFound: Int,
        longestPathThisGame: Int,
        hundredsThisGame: Int
    ) {
        gamesPlayed += 1
        totalScore += gameScore
        bestGameScore = max(bestGameScore, gameScore)
        totalPathsFound += pathsFound
        longestPath = max(longestPath, longestPathThisGame)
        hundredsFound += hundredsThisGame
    }

    /// Average score per game, for display.
    var averageScore: Int {
        guard gamesPlayed > 0 else { return 0 }
        return totalScore / gamesPlayed
    }

    /// Reconciles two lifetime records without double-counting: stats only ever
    /// grow, so element-wise max is a safe offline-first merge across devices.
    func merged(with other: GridArenaStats) -> GridArenaStats {
        GridArenaStats(
            gamesPlayed: max(gamesPlayed, other.gamesPlayed),
            totalScore: max(totalScore, other.totalScore),
            bestGameScore: max(bestGameScore, other.bestGameScore),
            totalPathsFound: max(totalPathsFound, other.totalPathsFound),
            longestPath: max(longestPath, other.longestPath),
            hundredsFound: max(hundredsFound, other.hundredsFound)
        )
    }
}
