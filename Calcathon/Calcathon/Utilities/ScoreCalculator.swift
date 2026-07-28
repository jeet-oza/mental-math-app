//
//  ScoreCalculator.swift
//  Calcathon
//
//  Centralized scoring logic used by both Learn Mode and Arena Mode.
//

import Foundation

/// Calculates scores for math problem answers.
/// Shared between Learn Mode practice and Arena Mode gameplay.
nonisolated enum ScoreCalculator {

    /// Base points awarded for a correct answer.
    static let basePoints = 100

    /// Bonus multiplier for fast answers (under threshold).
    static let speedBonusMultiplier = 1.5

    /// Time threshold (seconds) under which a speed bonus is awarded.
    static let speedBonusThreshold: Double = 3.0

    /// Points deducted for skipping a question in Arena Mode.
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

    // MARK: - Arena Scoring

    /// Points for a correct multiplication or division answer (the "hard" tier).
    static let arenaHardPoints = 12
    /// Points for a correct 3-digit addition/subtraction answer.
    static let arenaThreeDigitPoints = 6
    /// Points for a correct 2-digit addition/subtraction answer.
    static let arenaTwoDigitPoints = 3

    /// Base points a problem is worth in the Equation Arena, by type:
    /// multiplication and division = 12; addition/subtraction = 6 if any operand
    /// is 3-digit, otherwise 3. (Speed is rewarded implicitly via throughput.)
    static func arenaPoints(for problem: MathProblem) -> Int {
        switch problem.operation {
        case .multiplication, .division:
            return arenaHardPoints
        case .addition, .subtraction:
            let largest = max(problem.operandA, problem.operandB)
            return largest >= 100 ? arenaThreeDigitPoints : arenaTwoDigitPoints
        case .percentage, .remainder, .divisionWithRemainder,
             .cube, .squareRoot, .cubeRoot, .differenceOfSquares,
             .fractionAddition, .fractionSubtraction,
             .fractionMultiplication, .fractionDivision,
             .approximateSquareRoot, .approximateCubeRoot,
             .estimateProduct, .percentageIncrease, .percentageDecrease:
            return 0 // concept-only: never generated in the Arena
        }
    }

    /// Streak multiplier for consecutive correct answers: 1× → 1.25× → 1.5× →
    /// 1.75× → 2× (capped). A wrong answer or skip resets the streak to 0.
    static func arenaStreakMultiplier(streak: Int) -> Double {
        guard streak > 1 else { return 1.0 }
        return min(2.0, 1.0 + 0.25 * Double(streak - 1))
    }

    /// Total Arena points for a correct answer: type points × streak multiplier.
    static func arenaScore(for problem: MathProblem, streak: Int) -> Int {
        Int((Double(arenaPoints(for: problem)) * arenaStreakMultiplier(streak: streak)).rounded())
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
