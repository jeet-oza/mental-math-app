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

    func testOperationsAreOnlyAddSubMultiply() {
        for p in batch(seed: "arena_ops", count: 400) {
            XCTAssertTrue([.addition, .subtraction, .multiplication].contains(p.operation),
                          "Arena must not generate \(p.operation)")
        }
    }

    func testMultiplicationIsTwoDigitByOneDigit() {
        for p in batch(seed: "arena_mult", count: 400) where p.operation == .multiplication {
            XCTAssertTrue((10...99).contains(p.operandA), "left should be 2-digit")
            XCTAssertTrue((2...9).contains(p.operandB), "right should be 1-digit")
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
        XCTAssertEqual(ScoreCalculator.arenaPoints(for: mult), 10)

        let add3 = MathProblem(operandA: 540, operandB: 120, operation: .addition)
        XCTAssertEqual(ScoreCalculator.arenaPoints(for: add3), 5)

        let sub3 = MathProblem(operandA: 800, operandB: 250, operation: .subtraction)
        XCTAssertEqual(ScoreCalculator.arenaPoints(for: sub3), 5)

        let add2 = MathProblem(operandA: 40, operandB: 55, operation: .addition)
        XCTAssertEqual(ScoreCalculator.arenaPoints(for: add2), 2)

        let sub2 = MathProblem(operandA: 90, operandB: 30, operation: .subtraction)
        XCTAssertEqual(ScoreCalculator.arenaPoints(for: sub2), 2)
    }

    func testArenaTimeBonus() {
        XCTAssertEqual(ScoreCalculator.arenaTimeBonus(secondsTaken: 0), 10)
        XCTAssertEqual(ScoreCalculator.arenaTimeBonus(secondsTaken: 3.9), 6)   // floor(6.1)
        XCTAssertEqual(ScoreCalculator.arenaTimeBonus(secondsTaken: 10), 0)
        XCTAssertEqual(ScoreCalculator.arenaTimeBonus(secondsTaken: 25), 0)
    }

    func testArenaScoreCombinesTypeAndBonus() {
        let mult = MathProblem(operandA: 47, operandB: 6, operation: .multiplication)
        // 10 (type) + max(10 - 2, 0) = 18
        XCTAssertEqual(ScoreCalculator.arenaScore(for: mult, secondsTaken: 2), 18)
    }
}
