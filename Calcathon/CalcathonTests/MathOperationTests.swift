//
//  MathOperationTests.swift
//  CalcathonTests
//
//  Unit tests for MathOperation enum.
//

import XCTest
@testable import Calcathon

final class MathOperationTests: XCTestCase {

    // MARK: - Symbol Tests

    func testAdditionSymbol() {
        XCTAssertEqual(MathOperation.addition.symbol, "+")
    }

    func testSubtractionSymbol() {
        XCTAssertEqual(MathOperation.subtraction.symbol, "−")
    }

    func testMultiplicationSymbol() {
        XCTAssertEqual(MathOperation.multiplication.symbol, "×")
    }

    func testDivisionSymbol() {
        XCTAssertEqual(MathOperation.division.symbol, "÷")
    }

    // MARK: - Evaluation Tests

    func testAdditionEvaluation() {
        XCTAssertEqual(MathOperation.addition.evaluate(lhs: 3, rhs: 5), 8)
    }

    func testSubtractionEvaluation() {
        XCTAssertEqual(MathOperation.subtraction.evaluate(lhs: 10, rhs: 4), 6)
    }

    func testSubtractionNegativeResult() {
        XCTAssertEqual(MathOperation.subtraction.evaluate(lhs: 3, rhs: 7), -4)
    }

    func testMultiplicationEvaluation() {
        XCTAssertEqual(MathOperation.multiplication.evaluate(lhs: 6, rhs: 7), 42)
    }

    func testMultiplicationByZero() {
        XCTAssertEqual(MathOperation.multiplication.evaluate(lhs: 99, rhs: 0), 0)
    }

    func testDivisionEvaluation() {
        XCTAssertEqual(MathOperation.division.evaluate(lhs: 10, rhs: 2), 5)
    }

    func testDivisionByZeroReturnsSafeValue() {
        XCTAssertEqual(MathOperation.division.evaluate(lhs: 10, rhs: 0), 0)
    }

    func testDivisionTruncatesTowardZero() {
        // Non-exact division truncates (the engine only ever generates
        // exact division problems, so this documents the fallback behavior).
        XCTAssertEqual(MathOperation.division.evaluate(lhs: 7, rhs: 2), 3)
    }

    func testPercentageEvaluation() {
        XCTAssertEqual(MathOperation.percentage.evaluate(lhs: 10, rhs: 80), 8)
        XCTAssertEqual(MathOperation.percentage.evaluate(lhs: 25, rhs: 80), 20)
    }

    func testRemainderEvaluation() {
        XCTAssertEqual(MathOperation.remainder.evaluate(lhs: 528, rhs: 7), 3)
        XCTAssertEqual(MathOperation.remainder.evaluate(lhs: 1234, rhs: 7), 2)
        XCTAssertEqual(MathOperation.remainder.evaluate(lhs: 49, rhs: 7), 0)
    }

    func testRemainderByZeroReturnsSafeValue() {
        XCTAssertEqual(MathOperation.remainder.evaluate(lhs: 10, rhs: 0), 0)
    }

    // MARK: - CaseIterable

    func testAllCasesCountExcludesConceptOnlyOperations() {
        // Percentage and remainder are concept-only: they belong to specific
        // lessons and must never appear in generic open-mix generation.
        XCTAssertEqual(MathOperation.allCases.count, 4)
        XCTAssertFalse(MathOperation.allCases.contains(.percentage))
        XCTAssertFalse(MathOperation.allCases.contains(.remainder))
    }
}
