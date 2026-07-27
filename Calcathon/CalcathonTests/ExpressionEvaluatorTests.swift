//
//  ExpressionEvaluatorTests.swift
//  CalcathonTests
//
//  The evaluator backs the scientific keypad. No lesson uses it yet, so these
//  tests are the only thing holding it to its contract until trigonometry
//  arrives.
//

import XCTest
@testable import Calcathon

final class ExpressionEvaluatorTests: XCTestCase {

    private func value(_ input: String) throws -> Double {
        try ExpressionEvaluator.evaluate(input)
    }

    func testPlainArithmetic() throws {
        XCTAssertEqual(try value("2+3"), 5, accuracy: 1e-9)
        XCTAssertEqual(try value("10−4"), 6, accuracy: 1e-9)
        XCTAssertEqual(try value("6×7"), 42, accuracy: 1e-9)
        XCTAssertEqual(try value("9÷2"), 4.5, accuracy: 1e-9)
    }

    func testPrecedenceAndParentheses() throws {
        XCTAssertEqual(try value("2+3×4"), 14, accuracy: 1e-9)
        XCTAssertEqual(try value("(2+3)×4"), 20, accuracy: 1e-9)
        XCTAssertEqual(try value("2×(3+4)÷7"), 2, accuracy: 1e-9)
    }

    func testExponentIsRightAssociative() throws {
        // 2^(3^2) = 512, not (2^3)^2 = 64.
        XCTAssertEqual(try value("2^3^2"), 512, accuracy: 1e-9)
    }

    func testRootsAndPi() throws {
        XCTAssertEqual(try value("√9"), 3, accuracy: 1e-9)
        XCTAssertEqual(try value("∛27"), 3, accuracy: 1e-9)
        XCTAssertEqual(try value("π"), .pi, accuracy: 1e-9)
        XCTAssertEqual(try value("√2÷2"), 0.7071067811, accuracy: 1e-6)
    }

    func testUnaryMinus() throws {
        XCTAssertEqual(try value("−5"), -5, accuracy: 1e-9)
        XCTAssertEqual(try value("3×−2"), -6, accuracy: 1e-9)
    }

    func testDecimals() throws {
        XCTAssertEqual(try value("0.5+0.25"), 0.75, accuracy: 1e-9)
    }

    func testWhitespaceIsIgnored() throws {
        XCTAssertEqual(try value(" 2 + 3 "), 5, accuracy: 1e-9)
    }

    // MARK: - Failure Cases

    func testEmptyInputThrows() {
        XCTAssertThrowsError(try value(""))
        XCTAssertThrowsError(try value("   "))
    }

    func testUnbalancedParenthesesThrow() {
        XCTAssertThrowsError(try value("(2+3"))
    }

    func testTrailingGarbageThrows() {
        XCTAssertThrowsError(try value("2+3)"))
    }

    func testDanglingOperatorThrows() {
        XCTAssertThrowsError(try value("2+"))
    }

    // MARK: - Matching

    func testMatchesComparesByValueNotSpelling() {
        // The point of evaluating rather than string-comparing: a player may
        // write the answer any way that comes out the same.
        XCTAssertTrue(ExpressionEvaluator.matches("√2÷2", expected: 0.5 * 2.0.squareRoot()))
        XCTAssertTrue(ExpressionEvaluator.matches("1÷√2", expected: 0.5 * 2.0.squareRoot()))
        XCTAssertTrue(ExpressionEvaluator.matches("0.5", expected: 0.5))
        XCTAssertTrue(ExpressionEvaluator.matches("1÷2", expected: 0.5))
    }

    func testMatchesRejectsWrongValues() {
        XCTAssertFalse(ExpressionEvaluator.matches("0.6", expected: 0.5))
    }

    func testMalformedInputIsWrongRatherThanFatal() {
        XCTAssertFalse(ExpressionEvaluator.matches("√√", expected: 0))
        XCTAssertFalse(ExpressionEvaluator.matches("", expected: 0))
    }
}
