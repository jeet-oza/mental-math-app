//
//  ProblemPatternTests.swift
//  CalcathonTests
//
//  Verifies that pattern-based generation always matches the lesson concept.
//

import XCTest
@testable import Calcathon

final class ProblemPatternTests: XCTestCase {

    func testFixedOperandRightAlwaysPresent() {
        let pattern = ProblemPattern.fixedOperand(
            operation: .multiplication,
            fixedValues: [11],
            position: .right,
            variableRange: 10...99
        )
        let engine = MathEngine(seed: "mult11", pattern: pattern)

        for problem in engine.generateBatch(count: 100) {
            XCTAssertEqual(problem.operation, .multiplication)
            XCTAssertEqual(problem.operandB, 11)
            XCTAssertTrue((10...99).contains(problem.operandA))
        }
    }

    func testFixedOperandLeftFromCandidateSet() {
        let pattern = ProblemPattern.fixedOperand(
            operation: .subtraction,
            fixedValues: [100, 1000],
            position: .left,
            variableRange: 11...89
        )
        let engine = MathEngine(seed: "round_sub", pattern: pattern)

        for problem in engine.generateBatch(count: 100) {
            XCTAssertTrue([100, 1000].contains(problem.operandA))
            XCTAssertTrue((11...89).contains(problem.operandB))
            XCTAssertGreaterThan(problem.correctAnswer, 0)
        }
    }

    func testTwoOperandSubtractionStaysNonNegative() {
        let pattern = ProblemPattern.twoOperand(
            operation: .subtraction,
            leftRange: 10...50,
            rightRange: 10...50
        )
        let engine = MathEngine(seed: "two_sub", pattern: pattern)
        for problem in engine.generateBatch(count: 200) {
            XCTAssertGreaterThanOrEqual(problem.correctAnswer, 0)
        }
    }

    func testSquareProducesEqualOperands() {
        let pattern = ProblemPattern.square(range: 41...59)
        let engine = MathEngine(seed: "sq", pattern: pattern)
        for problem in engine.generateBatch(count: 100) {
            XCTAssertEqual(problem.operandA, problem.operandB)
            XCTAssertTrue((41...59).contains(problem.operandA))
            XCTAssertEqual(problem.correctAnswer, problem.operandA * problem.operandA)
        }
    }

    func testSquareEndingInFive() {
        let pattern = ProblemPattern.squareEndingInFive(tensRange: 1...9)
        let engine = MathEngine(seed: "sq5", pattern: pattern)
        for problem in engine.generateBatch(count: 100) {
            XCTAssertEqual(problem.operandA % 10, 5, "Should end in 5")
            XCTAssertEqual(problem.operandA, problem.operandB)
        }
    }

    func testDivisorAlwaysDividesCleanly() {
        let pattern = ProblemPattern.divisor(divisors: [4, 5], quotientRange: 2...40)
        let engine = MathEngine(seed: "div", pattern: pattern)
        for problem in engine.generateBatch(count: 200) {
            XCTAssertEqual(problem.operation, .division)
            XCTAssertTrue([4, 5].contains(problem.operandB))
            XCTAssertEqual(problem.operandA % problem.operandB, 0, "Must divide evenly")
        }
    }

    func testPercentageYieldsIntegerResult() {
        let pattern = ProblemPattern.percentage(percents: [1, 5, 10, 25], multiplierRange: 1...50)
        let engine = MathEngine(seed: "pct", pattern: pattern)
        for problem in engine.generateBatch(count: 300) {
            XCTAssertEqual(problem.operation, .percentage)
            // p% of base must be exact: p * base divisible by 100.
            XCTAssertEqual((problem.operandA * problem.operandB) % 100, 0)
            XCTAssertEqual(problem.correctAnswer, problem.operandA * problem.operandB / 100)
        }
    }

    func testPatternGenerationIsDeterministic() {
        let pattern = ProblemPattern.fixedOperand(
            operation: .addition,
            fixedValues: [9],
            position: .right,
            variableRange: 10...99
        )
        let a = MathEngine(seed: "seed", pattern: pattern).generateBatch(count: 30)
        let b = MathEngine(seed: "seed", pattern: pattern).generateBatch(count: 30)
        let signature: (MathProblem) -> [Int] = { [$0.operandA, $0.operandB] }
        XCTAssertEqual(a.map(signature), b.map(signature))
    }

    func testEveryCatalogLessonHasAPattern() {
        for group in LessonCatalog.allGroups {
            for lesson in group.lessons {
                XCTAssertNotNil(lesson.pattern, "Lesson \(lesson.id) has no concept pattern")
            }
        }
    }

    func testEveryCatalogLessonGeneratesIntegerAnswers() {
        for group in LessonCatalog.allGroups {
            for lesson in group.lessons {
                guard let pattern = lesson.pattern else { continue }
                let engine = MathEngine(seed: lesson.id, pattern: pattern)
                for problem in engine.generateBatch(count: 50) {
                    // correctAnswer is Int; just assert it is well-defined and
                    // that division/percentage never blow up.
                    XCTAssertFalse(problem.displayText.isEmpty)
                    _ = problem.correctAnswer
                }
            }
        }
    }
}
