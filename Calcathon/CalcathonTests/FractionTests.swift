//
//  FractionTests.swift
//  CalcathonTests
//
//  Covers the exact-rational answer type: reduction, arithmetic, parsing the
//  forms the two keypads can produce, and the grading rule that an unreduced
//  answer is still right.
//

import XCTest
@testable import Calcathon

final class FractionTests: XCTestCase {

    // MARK: - Normalisation

    func testReducesToLowestTerms() {
        XCTAssertEqual(Fraction(6, 8), Fraction(3, 4))
        XCTAssertEqual(Fraction(100, 25), Fraction(4, 1))
    }

    func testSignMovesToTheNumerator() {
        let fraction = Fraction(3, -4)
        XCTAssertEqual(fraction.numerator, -3)
        XCTAssertEqual(fraction.denominator, 4)
        XCTAssertEqual(Fraction(-3, -4), Fraction(3, 4))
    }

    /// A zero denominator is unreachable from any pattern, but a value type
    /// this far from the user should not trap if one ever arrives.
    func testZeroDenominatorCollapsesToZero() {
        XCTAssertEqual(Fraction(5, 0), Fraction(0, 1))
    }

    func testWholeNumbersRenderWithoutASlash() {
        XCTAssertEqual(Fraction(4, 2).displayText, "2")
        XCTAssertEqual(Fraction(3, 4).displayText, "3/4")
        XCTAssertTrue(Fraction(8, 4).isWhole)
    }

    // MARK: - Arithmetic

    func testAdditionAndSubtraction() {
        XCTAssertEqual(Fraction(2, 3) + Fraction(1, 5), Fraction(13, 15))
        XCTAssertEqual(Fraction(3, 4) - Fraction(1, 4), Fraction(1, 2))
        // Crossing zero must keep the sign on the numerator.
        XCTAssertEqual(Fraction(1, 4) - Fraction(3, 4), Fraction(-1, 2))
    }

    func testMultiplicationAndDivision() {
        XCTAssertEqual(Fraction(2, 3) * Fraction(3, 4), Fraction(1, 2))
        XCTAssertEqual(Fraction(2, 3) / Fraction(4, 9), Fraction(3, 2))
    }

    // MARK: - Parsing

    func testParsesBothDivisionSymbols() {
        // The plain pad types "/", the scientific pad types "÷".
        XCTAssertEqual(Fraction.parse("3/4"), Fraction(3, 4))
        XCTAssertEqual(Fraction.parse("3÷4"), Fraction(3, 4))
        XCTAssertEqual(Fraction.parse(" 3 / 4 "), Fraction(3, 4))
    }

    func testParsesWholeNumbersAndNegatives() {
        XCTAssertEqual(Fraction.parse("5"), Fraction(5, 1))
        XCTAssertEqual(Fraction.parse("-3/4"), Fraction(-3, 4))
    }

    func testRejectsMalformedInput() {
        XCTAssertNil(Fraction.parse(""))
        XCTAssertNil(Fraction.parse("3/"))
        XCTAssertNil(Fraction.parse("3/0"))
        XCTAssertNil(Fraction.parse("abc"))
    }

    // MARK: - Grading

    /// The whole reason answers are kept exact rather than as Doubles: a
    /// player who does not reduce is still right.
    func testUnreducedAnswersAreAccepted() {
        let answer = ProblemAnswer.rational(Fraction(1, 2))
        XCTAssertTrue(answer.accepts("1/2"))
        XCTAssertTrue(answer.accepts("2/4"))
        XCTAssertTrue(answer.accepts("50/100"))
        XCTAssertFalse(answer.accepts("1/3"))
    }

    func testApproximateAnswersAcceptAnythingInTolerance() {
        let answer = ProblemAnswer.approximate(value: 7.0710678, tolerance: 0.05)
        XCTAssertTrue(answer.accepts("7.07"))
        XCTAssertTrue(answer.accepts("7.1"))
        XCTAssertFalse(answer.accepts("7.2"))
        XCTAssertFalse(answer.accepts("7"))
    }

    /// Approximate answers go through the expression evaluator, so a player
    /// may type the expression they reasoned with rather than its value.
    func testApproximateAnswersAcceptExpressions() {
        let answer = ProblemAnswer.approximate(value: 7.0710678, tolerance: 0.05)
        XCTAssertTrue(answer.accepts("√50"))
        XCTAssertFalse(answer.accepts("not a number"))
    }

    func testExactAnswersStillGradeExactly() {
        XCTAssertTrue(ProblemAnswer.single(42).accepts("42"))
        XCTAssertTrue(ProblemAnswer.single(42).accepts(" 42 "))
        XCTAssertFalse(ProblemAnswer.single(42).accepts("43"))
    }

    // MARK: - Problem wiring

    func testFractionProblemBuildsARationalAnswer() {
        let problem = MathProblem(
            operandA: 2, operandB: 1, operation: .fractionAddition,
            denominatorA: 3, denominatorB: 5
        )
        XCTAssertEqual(problem.displayText, "2/3 + 1/5")
        XCTAssertEqual(problem.answer, .rational(Fraction(13, 15)))
    }

    func testApproximateRootProblemBuildsAToleranceAnswer() {
        let problem = MathProblem(operandA: 50, operandB: 0, operation: .approximateSquareRoot)
        XCTAssertEqual(problem.displayText, "√50")
        guard case let .approximate(value, tolerance) = problem.answer else {
            return XCTFail("expected an approximate answer")
        }
        XCTAssertEqual(value, 50.0.squareRoot(), accuracy: 1e-9)
        XCTAssertEqual(tolerance, 0.05)
    }

    /// Every existing lesson leaves the denominators at 1, so nothing that
    /// worked before should have changed shape.
    func testIntegerProblemsAreUnaffected() {
        let problem = MathProblem(operandA: 12, operandB: 5, operation: .multiplication)
        XCTAssertEqual(problem.denominatorA, 1)
        XCTAssertEqual(problem.denominatorB, 1)
        XCTAssertEqual(problem.answer, .single(60))
        XCTAssertEqual(problem.displayText, "12 × 5")
    }
}
