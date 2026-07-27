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

    func testEvenTimesAlwaysEven() {
        let pattern = ProblemPattern.evenTimes(fixed: 6, evenRange: 12...98)
        let engine = MathEngine(seed: "even6", pattern: pattern)
        for problem in engine.generateBatch(count: 200) {
            XCTAssertEqual(problem.operation, .multiplication)
            XCTAssertEqual(problem.operandB, 6)
            XCTAssertEqual(problem.operandA % 2, 0, "left operand must be even")
            XCTAssertTrue((12...98).contains(problem.operandA))
        }
    }

    func testNearRoundSubtractionStaysNearBaseAndNonNegative() {
        let pattern = ProblemPattern.nearRound(
            operation: .subtraction, base: 100, offsetRange: 1...19, otherRange: 110...899)
        let engine = MathEngine(seed: "subNear100", pattern: pattern)
        for problem in engine.generateBatch(count: 200) {
            XCTAssertEqual(problem.operation, .subtraction)
            XCTAssertTrue((81...99).contains(problem.operandB), "subtrahend must sit just below 100")
            XCTAssertGreaterThanOrEqual(problem.operandA - problem.operandB, 0)
        }
    }

    func testNearRoundAdditionOperandNearBase() {
        let pattern = ProblemPattern.nearRound(
            operation: .addition, base: 100, offsetRange: 1...19, otherRange: 110...899)
        let engine = MathEngine(seed: "addNear100", pattern: pattern)
        for problem in engine.generateBatch(count: 200) {
            XCTAssertEqual(problem.operation, .addition)
            XCTAssertTrue((81...99).contains(problem.operandB), "addend must sit just below 100")
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

    func testNearHundredSameSideStaysClean() {
        let pattern = ProblemPattern.nearHundred(kinds: [.bothAbove, .bothBelow])
        let engine = MathEngine(seed: "near100", pattern: pattern)
        for problem in engine.generateBatch(count: 300) {
            XCTAssertEqual(problem.operation, .multiplication)
            XCTAssertTrue((91...109).contains(problem.operandA))
            XCTAssertTrue((91...109).contains(problem.operandB))
            XCTAssertNotEqual(problem.operandA, 100)
            XCTAssertNotEqual(problem.operandB, 100)

            let d1 = problem.operandA - 100
            let d2 = problem.operandB - 100
            // Both numbers sit on the same side of 100, and the cross term
            // stays a clean two digits (0..<100), so the "last two digits"
            // rule needs no carry or borrow.
            XCTAssertEqual(d1 > 0, d2 > 0, "Both numbers must be on the same side of 100")
            XCTAssertTrue((0..<100).contains(d1 * d2))
        }
    }

    func testNearHundredHardAlwaysCarriesOrCrosses() {
        let pattern = ProblemPattern.nearHundred(kinds: [.mixed, .carry])
        let engine = MathEngine(seed: "near100hard", pattern: pattern)
        for problem in engine.generateBatch(count: 300) {
            XCTAssertEqual(problem.operation, .multiplication)
            XCTAssertTrue((91...119).contains(problem.operandA))
            XCTAssertTrue((91...119).contains(problem.operandB))

            // Every problem is genuinely "tricky": either a crossover
            // (negative cross term → borrow) or a large cross term
            // (≥ 100 → carry into the base).
            let cross = (problem.operandA - 100) * (problem.operandB - 100)
            XCTAssertTrue(cross < 0 || cross >= 100,
                          "Hard lesson must require a borrow or a carry")
        }
    }

    func testCrosswiseCarryFreeNeverCarries() {
        let pattern = ProblemPattern.crosswise(kind: .carryFree)
        let engine = MathEngine(seed: "crosswise", pattern: pattern)
        for problem in engine.generateBatch(count: 300) {
            XCTAssertEqual(problem.operation, .multiplication)
            XCTAssertTrue((10...99).contains(problem.operandA))
            XCTAssertTrue((10...99).contains(problem.operandB))

            let (a, b) = (problem.operandA / 10, problem.operandA % 10)
            let (c, d) = (problem.operandB / 10, problem.operandB % 10)
            // Both right-hand columns must stay single-digit so the three
            // results can be read off without any carry.
            XCTAssertLessThan(b * d, 10, "units column must not carry")
            XCTAssertLessThan(a * d + b * c, 10, "crosswise column must not carry")
            // A zero digit would collapse a column and hide the method.
            XCTAssertGreaterThan(b, 0)
            XCTAssertGreaterThan(d, 0)
        }
    }

    func testCrosswiseCarryingAlwaysCarries() {
        let pattern = ProblemPattern.crosswise(kind: .carrying)
        let engine = MathEngine(seed: "crosswiseCarry", pattern: pattern)
        for problem in engine.generateBatch(count: 300) {
            XCTAssertEqual(problem.operation, .multiplication)
            XCTAssertTrue((11...99).contains(problem.operandA))
            XCTAssertTrue((11...99).contains(problem.operandB))

            let (a, b) = (problem.operandA / 10, problem.operandA % 10)
            let (c, d) = (problem.operandB / 10, problem.operandB % 10)
            XCTAssertTrue(b * d >= 10 || a * d + b * c >= 10,
                          "hard lesson must require a carry")
        }
    }

    func testCrosswiseColumnsReconstructTheProduct() {
        // The method itself: units + crosswise×10 + tens×100 is the product.
        for kind in [ProblemPattern.CrosswiseKind.carryFree, .carrying] {
            let engine = MathEngine(seed: "crosswiseMath", pattern: .crosswise(kind: kind))
            for problem in engine.generateBatch(count: 200) {
                let (a, b) = (problem.operandA / 10, problem.operandA % 10)
                let (c, d) = (problem.operandB / 10, problem.operandB % 10)
                let assembled = (a * c) * 100 + (a * d + b * c) * 10 + b * d
                XCTAssertEqual(assembled, problem.correctAnswer)
            }
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
