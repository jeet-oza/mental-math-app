//
//  MathOperationTests.swift
//  MentalMathAppTests
//
//  Unit tests for MathOperation enum.
//

import XCTest
@testable import MentalMathApp

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
        XCTAssertEqual(MathOperation.addition.evaluate(lhs: 3, rhs: 5), 8.0)
    }

    func testSubtractionEvaluation() {
        XCTAssertEqual(MathOperation.subtraction.evaluate(lhs: 10, rhs: 4), 6.0)
    }

    func testSubtractionNegativeResult() {
        XCTAssertEqual(MathOperation.subtraction.evaluate(lhs: 3, rhs: 7), -4.0)
    }

    func testMultiplicationEvaluation() {
        XCTAssertEqual(MathOperation.multiplication.evaluate(lhs: 6, rhs: 7), 42.0)
    }

    func testMultiplicationByZero() {
        XCTAssertEqual(MathOperation.multiplication.evaluate(lhs: 99, rhs: 0), 0.0)
    }

    func testDivisionEvaluation() {
        XCTAssertEqual(MathOperation.division.evaluate(lhs: 10, rhs: 2), 5.0)
    }

    func testDivisionByZeroReturnsSafeValue() {
        XCTAssertEqual(MathOperation.division.evaluate(lhs: 10, rhs: 0), 0.0)
    }

    func testDivisionWithRemainder() {
        XCTAssertEqual(MathOperation.division.evaluate(lhs: 7, rhs: 2), 3.5)
    }

    // MARK: - CaseIterable

    func testAllCasesCount() {
        XCTAssertEqual(MathOperation.allCases.count, 4)
    }
}
