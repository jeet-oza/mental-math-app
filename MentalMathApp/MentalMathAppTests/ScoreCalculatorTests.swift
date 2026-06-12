//
//  ScoreCalculatorTests.swift
//  MentalMathAppTests
//
//  Unit tests for ScoreCalculator.
//

import XCTest
@testable import MentalMathApp

final class ScoreCalculatorTests: XCTestCase {

    // MARK: - Correct Answer Tests

    func testCorrectAnswerEasyBasePoints() {
        let points = ScoreCalculator.calculatePoints(
            isCorrect: true,
            timeElapsed: 5.0,
            difficulty: .easy
        )
        XCTAssertEqual(points, 100)
    }

    func testCorrectAnswerMediumBasePoints() {
        let points = ScoreCalculator.calculatePoints(
            isCorrect: true,
            timeElapsed: 5.0,
            difficulty: .medium
        )
        XCTAssertEqual(points, 150)
    }

    func testCorrectAnswerHardBasePoints() {
        let points = ScoreCalculator.calculatePoints(
            isCorrect: true,
            timeElapsed: 5.0,
            difficulty: .hard
        )
        XCTAssertEqual(points, 250)
    }

    // MARK: - Incorrect Answer Tests

    func testIncorrectAnswerZeroPoints() {
        let points = ScoreCalculator.calculatePoints(
            isCorrect: false,
            timeElapsed: 1.0,
            difficulty: .easy
        )
        XCTAssertEqual(points, 0)
    }

    // MARK: - Speed Bonus Tests

    func testSpeedBonusAppliedUnderThreshold() {
        let points = ScoreCalculator.calculatePoints(
            isCorrect: true,
            timeElapsed: 2.0,
            difficulty: .easy
        )
        XCTAssertEqual(points, 150) // 100 * 1.5
    }

    func testSpeedBonusNotAppliedAtThreshold() {
        let points = ScoreCalculator.calculatePoints(
            isCorrect: true,
            timeElapsed: 3.0,
            difficulty: .easy
        )
        XCTAssertEqual(points, 100) // no bonus at exactly 3.0
    }

    func testSpeedBonusWithMediumDifficulty() {
        let points = ScoreCalculator.calculatePoints(
            isCorrect: true,
            timeElapsed: 1.5,
            difficulty: .medium
        )
        XCTAssertEqual(points, 225) // 100 * 1.5 (difficulty) * 1.5 (speed)
    }

    // MARK: - Total Score Tests

    func testTotalScoreFromMultipleAnswers() {
        let answers = [
            AnswerResult(problemIndex: 0, isCorrect: true, isSkipped: false,
                         userAnswer: 5, correctAnswer: 5, timeElapsed: 2.0, pointsEarned: 150),
            AnswerResult(problemIndex: 1, isCorrect: false, isSkipped: false,
                         userAnswer: 3, correctAnswer: 7, timeElapsed: 4.0, pointsEarned: 0),
            AnswerResult(problemIndex: 2, isCorrect: true, isSkipped: false,
                         userAnswer: 12, correctAnswer: 12, timeElapsed: 5.0, pointsEarned: 100)
        ]
        XCTAssertEqual(ScoreCalculator.totalScore(from: answers), 250)
    }

    func testTotalScoreEmptyArray() {
        XCTAssertEqual(ScoreCalculator.totalScore(from: []), 0)
    }

    // MARK: - Difficulty Bonus Tests

    func testDifficultyBonusValues() {
        XCTAssertEqual(ScoreCalculator.difficultyBonus(for: .easy), 1.0)
        XCTAssertEqual(ScoreCalculator.difficultyBonus(for: .medium), 1.5)
        XCTAssertEqual(ScoreCalculator.difficultyBonus(for: .hard), 2.5)
    }
}
