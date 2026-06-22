//
//  ProblemPatternTests.swift
//  MentalMathAppTests
//
//  Verifies that pattern-based generation always matches the lesson concept.
//

import XCTest
@testable import MentalMathApp

final class ProblemPatternTests: XCTestCase {

    func testRightFixedOperandAlwaysPresent() {
        let pattern = ProblemPattern(
            operation: .multiplication,
            fixedValues: [11],
            fixedPosition: .right,
            variableRange: 10...99
        )
        let engine = MathEngine(seed: "mult11", pattern: pattern)

        for problem in engine.generateBatch(count: 100) {
            XCTAssertEqual(problem.operation, .multiplication)
            XCTAssertEqual(problem.operandB, 11, "Fixed operand must be 11 on the right")
            XCTAssertTrue((10...99).contains(problem.operandA))
        }
    }

    func testLeftFixedOperandFromCandidateSet() {
        let pattern = ProblemPattern(
            operation: .subtraction,
            fixedValues: [100, 1000],
            fixedPosition: .left,
            variableRange: 11...89
        )
        let engine = MathEngine(seed: "round_sub", pattern: pattern)

        for problem in engine.generateBatch(count: 100) {
            XCTAssertTrue([100, 1000].contains(problem.operandA))
            XCTAssertTrue((11...89).contains(problem.operandB))
            XCTAssertGreaterThan(problem.correctAnswer, 0, "Result should stay positive")
        }
    }

    func testPatternGenerationIsDeterministic() {
        let pattern = ProblemPattern(
            operation: .addition,
            fixedValues: [9],
            fixedPosition: .right,
            variableRange: 10...99
        )
        let a = MathEngine(seed: "seed", pattern: pattern).generateBatch(count: 30)
        let b = MathEngine(seed: "seed", pattern: pattern).generateBatch(count: 30)
        // MathProblem carries a unique id, so compare by value fields.
        let signature: (MathProblem) -> [Int] = { [$0.operandA, $0.operandB] }
        XCTAssertEqual(a.map(signature), b.map(signature))
    }

    func testCatalogLessonsAllMatchTheirConcept() {
        for group in LessonCatalog.allGroups {
            for lesson in group.lessons {
                guard let pattern = lesson.pattern else {
                    XCTFail("Lesson \(lesson.id) has no concept pattern")
                    continue
                }
                let engine = MathEngine(
                    seed: lesson.id,
                    difficulty: lesson.difficulty,
                    operations: lesson.operations,
                    pattern: pattern
                )
                for problem in engine.generateBatch(count: 50) {
                    XCTAssertEqual(problem.operation, pattern.operation)
                    let fixed = pattern.fixedPosition == .right
                        ? problem.operandB
                        : problem.operandA
                    XCTAssertTrue(
                        pattern.fixedValues.contains(fixed),
                        "Lesson \(lesson.id) produced off-concept problem \(problem.displayText)"
                    )
                }
            }
        }
    }
}
