//
//  ArenaProblemGeneratorTests.swift
//  MentalMathAppTests
//
//  Verifies Equation Arena problem generation rules and type-based scoring.
//

import XCTest
@testable import MentalMathApp

final class ArenaProblemGeneratorTests: XCTestCase {

    private func batch(seed: String, count: Int) -> [MathProblem] {
        var gen = ArenaProblemGenerator(seed: seed)
        return (0..<count).map { _ in gen.next() }
    }

    func testOperationsAreAddSubMultiplyDivide() {
        for p in batch(seed: "arena_ops", count: 400) {
            XCTAssertTrue([.addition, .subtraction, .multiplication, .division].contains(p.operation),
                          "Arena must not generate \(p.operation)")
        }
    }

    func testMultiplicationIsTwoDigitByOneDigit() {
        for p in batch(seed: "arena_mult", count: 400) where p.operation == .multiplication {
            XCTAssertTrue((10...99).contains(p.operandA), "left should be 2-digit")
            XCTAssertTrue((2...9).contains(p.operandB), "right should be 1-digit")
        }
    }

    func testDivisionIsExactThreeDigitDividend() {
        for p in batch(seed: "arena_div", count: 400) where p.operation == .division {
            XCTAssertTrue((2...20).contains(p.operandB), "divisor should be 1–2 digit")
            XCTAssertEqual(p.operandA % p.operandB, 0, "division must be exact")
            XCTAssertTrue((100...999).contains(p.operandA), "dividend should be 3-digit")
        }
    }

    func testAddSubOperandsAtMostThreeDigits() {
        for p in batch(seed: "arena_addsub", count: 400)
        where p.operation == .addition || p.operation == .subtraction {
            XCTAssertLessThanOrEqual(p.operandA, 999)
            XCTAssertLessThanOrEqual(p.operandB, 999)
            XCTAssertGreaterThanOrEqual(p.operandA, 10)
            XCTAssertGreaterThanOrEqual(p.operandB, 10)
        }
    }

    func testSubtractionNeverNegative() {
        for p in batch(seed: "arena_sub", count: 500) where p.operation == .subtraction {
            XCTAssertGreaterThanOrEqual(p.correctAnswer, 0,
                "\(p.operandA) − \(p.operandB) is negative")
        }
    }

    func testGenerationIsDeterministic() {
        let a = batch(seed: "same", count: 50).map { [$0.operandA, $0.operandB, $0.operation.hashValue] }
        let b = batch(seed: "same", count: 50).map { [$0.operandA, $0.operandB, $0.operation.hashValue] }
        XCTAssertEqual(a, b)
    }

    // MARK: - Scoring

    func testArenaPointsByType() {
        let mult = MathProblem(operandA: 47, operandB: 6, operation: .multiplication)
        XCTAssertEqual(ScoreCalculator.arenaPoints(for: mult), 12)

        let div = MathProblem(operandA: 72, operandB: 6, operation: .division)
        XCTAssertEqual(ScoreCalculator.arenaPoints(for: div), 12) // same tier as ×

        let add3 = MathProblem(operandA: 540, operandB: 120, operation: .addition)
        XCTAssertEqual(ScoreCalculator.arenaPoints(for: add3), 6)

        let sub3 = MathProblem(operandA: 800, operandB: 250, operation: .subtraction)
        XCTAssertEqual(ScoreCalculator.arenaPoints(for: sub3), 6)

        let add2 = MathProblem(operandA: 40, operandB: 55, operation: .addition)
        XCTAssertEqual(ScoreCalculator.arenaPoints(for: add2), 3)

        let sub2 = MathProblem(operandA: 90, operandB: 30, operation: .subtraction)
        XCTAssertEqual(ScoreCalculator.arenaPoints(for: sub2), 3)
    }

    func testArenaStreakMultiplier() {
        XCTAssertEqual(ScoreCalculator.arenaStreakMultiplier(streak: 0), 1.0)
        XCTAssertEqual(ScoreCalculator.arenaStreakMultiplier(streak: 1), 1.0)
        XCTAssertEqual(ScoreCalculator.arenaStreakMultiplier(streak: 2), 1.25)
        XCTAssertEqual(ScoreCalculator.arenaStreakMultiplier(streak: 3), 1.5)
        XCTAssertEqual(ScoreCalculator.arenaStreakMultiplier(streak: 5), 2.0)
        XCTAssertEqual(ScoreCalculator.arenaStreakMultiplier(streak: 9), 2.0) // capped
    }

    func testArenaScoreAppliesStreak() {
        let mult = MathProblem(operandA: 47, operandB: 6, operation: .multiplication)
        XCTAssertEqual(ScoreCalculator.arenaScore(for: mult, streak: 1), 12) // 12 × 1.0
        XCTAssertEqual(ScoreCalculator.arenaScore(for: mult, streak: 3), 18) // 12 × 1.5
        XCTAssertEqual(ScoreCalculator.arenaScore(for: mult, streak: 5), 24) // 12 × 2.0
    }
}
