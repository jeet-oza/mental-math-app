//
//  ScoreCalculator.swift
//  Calcathon
//
//  Scoring for untimed lesson practice.
//

import Foundation

/// Calculates scores for math problem answers.
/// Used by the optional ten-question lesson drills.
nonisolated enum ScoreCalculator {

    /// Base points awarded for a correct answer.
    static let basePoints = 100

    /// Bonus multiplier for fast answers (under threshold).
    static let speedBonusMultiplier = 1.5

    /// Time threshold (seconds) under which a speed bonus is awarded.
    static let speedBonusThreshold: Double = 3.0

    /// Skipped questions receive no points.
    static let skipPenalty = 0

    /// Calculates points for a single answer.
    /// - Parameters:
    ///   - isCorrect: Whether the answer was correct.
    ///   - timeElapsed: Seconds taken to answer.
    ///   - difficulty: The difficulty tier for bonus scaling.
    /// - Returns: Points earned (0 if incorrect).
    static func calculatePoints(
        isCorrect: Bool,
        timeElapsed: Double,
        difficulty: MathEngine.Difficulty
    ) -> Int {
        guard isCorrect else { return 0 }

        let difficultyMultiplier = difficultyBonus(for: difficulty)
        var points = Double(basePoints) * difficultyMultiplier

        if timeElapsed < speedBonusThreshold {
            points *= speedBonusMultiplier
        }

        return Int(points)
    }

    /// Returns a multiplier based on difficulty.
    /// - Parameter difficulty: The current difficulty tier.
    /// - Returns: A multiplier (1.0 for easy, scaling up).
    static func difficultyBonus(for difficulty: MathEngine.Difficulty) -> Double {
        switch difficulty {
        case .easy:
            return 1.0
        case .medium:
            return 1.5
        case .hard:
            return 2.5
        }
    }

    /// Calculates the total score for a completed round.
    /// - Parameter answers: Array of individual answer results.
    /// - Returns: The total score.
    static func totalScore(from answers: [AnswerResult]) -> Int {
        answers.reduce(0) { $0 + $1.pointsEarned }
    }

}

/// Records the result of answering a single problem.
struct AnswerResult: Codable, Equatable, Sendable {
    let problemIndex: Int
    let isCorrect: Bool
    let isSkipped: Bool
    let userAnswer: Int?
    let correctAnswer: Int
    let timeElapsed: Double
    let pointsEarned: Int
}
