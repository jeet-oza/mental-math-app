//
//  MathEngineTests.swift
//  CalcathonTests
//
//  Unit tests for the deterministic MathEngine.
//

import XCTest
@testable import Calcathon

final class MathEngineTests: XCTestCase {

    // MARK: - Determinism Tests

    func testSameSeedProducesSameSequence() {
        let engineA = MathEngine(seed: "round_42", difficulty: .easy)
        let engineB = MathEngine(seed: "round_42", difficulty: .easy)

        let batchA = engineA.generateBatch(count: 20)
        let batchB = engineB.generateBatch(count: 20)

        for i in 0..<20 {
            XCTAssertEqual(batchA[i].operandA, batchB[i].operandA, "Mismatch at index \(i)")
            XCTAssertEqual(batchA[i].operandB, batchB[i].operandB, "Mismatch at index \(i)")
            XCTAssertEqual(batchA[i].operation, batchB[i].operation, "Mismatch at index \(i)")
        }
    }

    func testDifferentSeedsProduceDifferentSequences() {
        let engineA = MathEngine(seed: "alpha", difficulty: .easy)
        let engineB = MathEngine(seed: "beta", difficulty: .easy)

        let batchA = engineA.generateBatch(count: 10)
        let batchB = engineB.generateBatch(count: 10)

        // At least one problem should differ (statistically guaranteed)
        let allSame = batchA.indices.allSatisfy { i in
            batchA[i].operandA == batchB[i].operandA &&
            batchA[i].operandB == batchB[i].operandB &&
            batchA[i].operation == batchB[i].operation
        }
        XCTAssertFalse(allSame, "Different seeds should produce different sequences")
    }

    // MARK: - Reset Tests

    func testResetReproducesSequence() {
        let engine = MathEngine(seed: "test_seed", difficulty: .medium)

        let firstRun = engine.generateBatch(count: 10)
        engine.reset(seed: "test_seed")
        let secondRun = engine.generateBatch(count: 10)

        for i in 0..<10 {
            XCTAssertEqual(firstRun[i].operandA, secondRun[i].operandA)
            XCTAssertEqual(firstRun[i].operandB, secondRun[i].operandB)
            XCTAssertEqual(firstRun[i].operation, secondRun[i].operation)
        }
    }

    // MARK: - Question Index Tests

    func testCurrentIndexStartsAtZero() {
        let engine = MathEngine(seed: "idx_test")
        XCTAssertEqual(engine.currentIndex, 0)
    }

    func testCurrentIndexIncrements() {
        let engine = MathEngine(seed: "idx_test")
        _ = engine.nextProblem()
        _ = engine.nextProblem()
        _ = engine.nextProblem()
        XCTAssertEqual(engine.currentIndex, 3)
    }

    func testCurrentIndexResetsOnReset() {
        let engine = MathEngine(seed: "idx_test")
        _ = engine.generateBatch(count: 5)
        engine.reset(seed: "idx_test")
        XCTAssertEqual(engine.currentIndex, 0)
    }

    // MARK: - Difficulty Operand Range Tests

    func testEasyOperandsInRange() {
        let engine = MathEngine(seed: "easy_range", difficulty: .easy, operations: [.addition])
        let problems = engine.generateBatch(count: 50)
        let range = MathEngine.Difficulty.easy.operandRange

        for problem in problems {
            XCTAssertTrue(range.contains(problem.operandA), "operandA \(problem.operandA) out of easy range")
            XCTAssertTrue(range.contains(problem.operandB), "operandB \(problem.operandB) out of easy range")
        }
    }

    func testHardOperandsInRange() {
        let engine = MathEngine(seed: "hard_range", difficulty: .hard, operations: [.addition])
        let problems = engine.generateBatch(count: 50)
        let range = MathEngine.Difficulty.hard.operandRange

        for problem in problems {
            XCTAssertTrue(range.contains(problem.operandA), "operandA \(problem.operandA) out of hard range")
            XCTAssertTrue(range.contains(problem.operandB), "operandB \(problem.operandB) out of hard range")
        }
    }

    // MARK: - Operation-Specific Constraint Tests

    func testDivisionProducesCleanIntegerAnswers() {
        let engine = MathEngine(seed: "div_clean", difficulty: .easy, operations: [.division])
        let problems = engine.generateBatch(count: 50)

        for problem in problems {
            XCTAssertEqual(
                problem.operandA % problem.operandB, 0,
                "\(problem.operandA) ÷ \(problem.operandB) is not clean"
            )
        }
    }

    func testDivisionNeverDividesByZero() {
        let engine = MathEngine(seed: "div_zero", difficulty: .easy, operations: [.division])
        let problems = engine.generateBatch(count: 100)

        for problem in problems {
            XCTAssertGreaterThan(problem.operandB, 0, "Division by zero detected")
        }
    }

    func testSubtractionEasyNonNegative() {
        let engine = MathEngine(seed: "sub_pos", difficulty: .easy, operations: [.subtraction])
        let problems = engine.generateBatch(count: 50)

        for problem in problems {
            XCTAssertGreaterThanOrEqual(
                problem.correctAnswer, 0,
                "\(problem.operandA) − \(problem.operandB) is negative"
            )
        }
    }

    // MARK: - Filtered Operations Tests

    func testSingleOperationFilter() {
        let engine = MathEngine(seed: "single_op", operations: [.multiplication])
        let problems = engine.generateBatch(count: 30)

        for problem in problems {
            XCTAssertEqual(problem.operation, .multiplication)
        }
    }
}
