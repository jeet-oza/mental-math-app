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

    func testCrosswiseThreeDigitUsesNonZeroDigits() {
        let engine = MathEngine(seed: "crosswise3", pattern: .crosswiseThreeDigit)
        for problem in engine.generateBatch(count: 200) {
            XCTAssertEqual(problem.operation, .multiplication)
            for operand in [problem.operandA, problem.operandB] {
                XCTAssertTrue((111...999).contains(operand))
                // A zero digit would collapse a column into a freebie.
                XCTAssertNotEqual(operand / 100 % 10, 0)
                XCTAssertNotEqual(operand / 10 % 10, 0)
                XCTAssertNotEqual(operand % 10, 0)
            }
        }
    }

    func testNearBaseKeepsBothOperandsOnTheSameSide() {
        for (base, deviations) in [(50, 1...8), (1000, 1...19)] {
            let pattern = ProblemPattern.nearBase(base: base, deviationRange: deviations)
            let engine = MathEngine(seed: "base\(base)", pattern: pattern)
            for problem in engine.generateBatch(count: 200) {
                XCTAssertEqual(problem.operation, .multiplication)
                let d1 = problem.operandA - base
                let d2 = problem.operandB - base
                XCTAssertEqual(d1 > 0, d2 > 0, "both operands must sit on the same side of \(base)")
                XCTAssertTrue(deviations.contains(abs(d1)))
                XCTAssertTrue(deviations.contains(abs(d2)))
                // Same side means the tail (the deviations multiplied) is
                // positive, so the method never needs a borrow.
                XCTAssertGreaterThan(d1 * d2, 0)
            }
        }
    }

    func testSameTensUnitsSumTenMatchesTheShortcut() {
        let pattern = ProblemPattern.sameTensUnitsSumTen(tensRange: 1...9)
        let engine = MathEngine(seed: "sameTens", pattern: pattern)
        for problem in engine.generateBatch(count: 200) {
            let t = problem.operandA / 10
            let u = problem.operandA % 10
            XCTAssertEqual(problem.operandB / 10, t, "tens digits must match")
            XCTAssertEqual(u + problem.operandB % 10, 10, "units must sum to 10")
            // The taught rule: T×(T+1) then the units product, padded to two.
            XCTAssertEqual(problem.correctAnswer, t * (t + 1) * 100 + u * (10 - u))
        }
    }

    func testSquareNearBaseStaysInRangeAndSkipsTheBase() {
        let pattern = ProblemPattern.squareNearBase(base: 100, deviationRange: 1...9)
        let engine = MathEngine(seed: "sqNear100", pattern: pattern)
        for problem in engine.generateBatch(count: 200) {
            XCTAssertEqual(problem.operandA, problem.operandB)
            XCTAssertTrue((91...109).contains(problem.operandA))
            XCTAssertNotEqual(problem.operandA, 100, "the base itself is not a puzzle")
            // The taught rule: (n + d) × base + d².
            let d = problem.operandA - 100
            XCTAssertEqual(problem.correctAnswer, (problem.operandA + d) * 100 + d * d)
        }
    }

    func testDivideByNineIsExactAndCarryFree() {
        let pattern = ProblemPattern.divideByNine(quotientRange: 12...99)
        let engine = MathEngine(seed: "div9", pattern: pattern)
        for problem in engine.generateBatch(count: 200) {
            XCTAssertEqual(problem.operation, .division)
            XCTAssertEqual(problem.operandB, 9)
            XCTAssertEqual(problem.operandA % 9, 0, "must divide exactly")

            // Digits summing to 9 is what keeps every running sum below 10 and
            // makes the remainder land on 9 every time, so the lesson's final
            // "add 1" step always applies.
            var digits: [Int] = [], value = problem.operandA
            while value > 0 { digits.append(value % 10); value /= 10 }
            XCTAssertEqual(digits.reduce(0, +), 9)

            var running = 0
            for digit in digits.reversed() {
                running += digit
                XCTAssertLessThanOrEqual(running, 9, "no running sum may carry")
            }
        }
    }

    func testRemainderMatchesTheCycleWeights() {
        let pattern = ProblemPattern.remainder(divisor: 7, range: 100...9999)
        let engine = MathEngine(seed: "mod7", pattern: pattern)
        let weights = [1, 3, 2, 6, 4, 5] // place values mod 7, from the right

        for problem in engine.generateBatch(count: 300) {
            XCTAssertEqual(problem.operation, .remainder)
            XCTAssertEqual(problem.operandB, 7)
            XCTAssertTrue((0...6).contains(problem.correctAnswer))
            XCTAssertEqual(problem.correctAnswer, problem.operandA % 7)

            // The taught method must agree with the real remainder.
            var total = 0, value = problem.operandA, place = 0
            while value > 0 {
                total += (value % 10) * weights[place % weights.count]
                value /= 10
                place += 1
            }
            XCTAssertEqual(total % 7, problem.correctAnswer)
        }
    }

    func testMultiplyByNinesSplitsIntoTwoHalves() {
        // The lesson's rule: n × 99 is (n − 1) followed by (100 − n), and the
        // same shape with 1000 for 999. It only holds while n stays below the
        // round number, which is what the variable range guarantees.
        let pattern = ProblemPattern.fixedOperand(
            operation: .multiplication, fixedValues: [99, 999], position: .right, variableRange: 11...99)
        let engine = MathEngine(seed: "mult99", pattern: pattern)

        for problem in engine.generateBatch(count: 200) {
            let n = problem.operandA
            let round = problem.operandB + 1 // 100 or 1000
            XCTAssertTrue([99, 999].contains(problem.operandB))
            XCTAssertLessThan(n, round, "the complement half needs n below the round number")
            XCTAssertEqual(problem.correctAnswer, (n - 1) * round + (round - n))
        }
    }

    func testDuplexReproducesAnySquare() {
        // The taught columns: tens², then 2 × tens × units, then units².
        let engine = MathEngine(seed: "sqAny", pattern: .square(range: 21...99))
        for problem in engine.generateBatch(count: 200) {
            XCTAssertEqual(problem.operandA, problem.operandB)
            let (t, u) = (problem.operandA / 10, problem.operandA % 10)
            XCTAssertEqual(problem.correctAnswer, t * t * 100 + 2 * t * u * 10 + u * u)
        }
    }

    func testCastingOutNinesMatchesTheRemainder() {
        let pattern = ProblemPattern.remainder(divisor: 9, range: 100...9999)
        let engine = MathEngine(seed: "mod9", pattern: pattern)

        for problem in engine.generateBatch(count: 300) {
            XCTAssertEqual(problem.operation, .remainder)
            XCTAssertEqual(problem.operandB, 9)

            // Repeated digit-summing must land on the true remainder — with the
            // wrinkle the lesson calls out: a digital root of 9 means 0.
            var value = problem.operandA
            while value > 9 {
                var sum = 0, rest = value
                while rest > 0 { sum += rest % 10; rest /= 10 }
                value = sum
            }
            XCTAssertEqual(value == 9 ? 0 : value, problem.correctAnswer)
        }
    }

    // MARK: - Powers & Roots

    func testPerfectSquareRootIsExact() {
        let engine = MathEngine(seed: "sqrt", pattern: .perfectSquareRoot(range: 11...99))
        for problem in engine.generateBatch(count: 200) {
            XCTAssertEqual(problem.operation, .squareRoot)
            XCTAssertEqual(problem.correctAnswer * problem.correctAnswer, problem.operandA)
            XCTAssertTrue((11...99).contains(problem.correctAnswer))
            XCTAssertEqual(problem.displayText, "√\(problem.operandA)")
        }
    }

    func testExactCubeRootIsExactAndLastDigitDeterminesTheRoot() {
        // The lesson leans entirely on cube endings being unique, so that has
        // to hold for every number the pattern can produce.
        let endings = [0: 0, 1: 1, 8: 2, 7: 3, 4: 4, 5: 5, 6: 6, 3: 7, 2: 8, 9: 9]
        let engine = MathEngine(seed: "cbrt", pattern: .exactCubeRoot(range: 11...99))
        for problem in engine.generateBatch(count: 300) {
            XCTAssertEqual(problem.operation, .cubeRoot)
            let root = problem.correctAnswer
            XCTAssertEqual(root * root * root, problem.operandA)
            XCTAssertEqual(endings[problem.operandA % 10], root % 10,
                           "cube ending must pin down the root's last digit")
        }
    }

    func testCubeNearBaseStaysAboveTheBase() {
        let engine = MathEngine(seed: "cubeNear", pattern: .cubeNearBase(base: 100, deviationRange: 1...9))
        for problem in engine.generateBatch(count: 200) {
            XCTAssertEqual(problem.operation, .cube)
            XCTAssertTrue((101...109).contains(problem.operandA),
                          "below-base cubes are excluded: their last part goes negative")
            XCTAssertEqual(problem.correctAnswer, problem.operandA * problem.operandA * problem.operandA)

            // The taught parts: (n + 2d) | 3d² | d³, in hundreds-of-hundreds.
            let d = problem.operandA - 100
            XCTAssertEqual(
                problem.correctAnswer,
                (problem.operandA + 2 * d) * 10_000 + 3 * d * d * 100 + d * d * d)
        }
    }

    func testDifferenceOfSquaresMatchesSumTimesDifference() {
        let pattern = ProblemPattern.differenceOfSquares(range: 21...99, gapRange: 2...12)
        let engine = MathEngine(seed: "sqDiff", pattern: pattern)
        for problem in engine.generateBatch(count: 200) {
            XCTAssertEqual(problem.operation, .differenceOfSquares)
            let (a, b) = (problem.operandA, problem.operandB)
            XCTAssertGreaterThan(a, b, "the larger square must come first")
            XCTAssertGreaterThan(b, 0)
            XCTAssertEqual(problem.correctAnswer, (a + b) * (a - b))
            XCTAssertEqual(problem.displayText, "\(a)² − \(b)²")
        }
    }

    // MARK: - Division With Remainder

    func testNearBaseDivisionAlwaysLeavesARemainder() {
        for side in [ProblemPattern.DivisorSide.below, .above] {
            let pattern = ProblemPattern.nearBaseDivision(
                base: 100, side: side, offsetRange: 2...12, quotientRange: 11...49)
            let engine = MathEngine(seed: "nearDiv\(side)", pattern: pattern)

            for problem in engine.generateBatch(count: 200) {
                XCTAssertEqual(problem.operation, .divisionWithRemainder)
                let divisor = problem.operandB
                XCTAssertEqual(side == .below, divisor < 100)

                guard case let .quotientRemainder(quotient, remainder) = problem.answer else {
                    return XCTFail("must answer with a quotient and a remainder")
                }
                // A zero remainder would let a player skip the method's last
                // step and still be right.
                XCTAssertGreaterThan(remainder, 0)
                XCTAssertLessThan(remainder, divisor)
                XCTAssertEqual(divisor * quotient + remainder, problem.operandA)
            }
        }
    }

    func testFlagDivisionAlwaysLeavesARemainder() {
        let pattern = ProblemPattern.flagDivision(divisorRange: 21...79, quotientRange: 11...79)
        let engine = MathEngine(seed: "flag", pattern: pattern)
        for problem in engine.generateBatch(count: 300) {
            XCTAssertEqual(problem.operation, .divisionWithRemainder)
            guard case let .quotientRemainder(quotient, remainder) = problem.answer else {
                return XCTFail("must answer with a quotient and a remainder")
            }
            XCTAssertTrue((21...79).contains(problem.operandB))
            XCTAssertGreaterThan(remainder, 0)
            XCTAssertLessThan(remainder, problem.operandB)
            XCTAssertEqual(problem.operandB * quotient + remainder, problem.operandA)
        }
    }

    func testElevenCheckMatchesTheAlternatingSum() {
        let engine = MathEngine(seed: "mod11", pattern: .remainder(divisor: 11, range: 100...9999))
        for problem in engine.generateBatch(count: 300) {
            XCTAssertEqual(problem.operandB, 11)

            var total = 0, value = problem.operandA, sign = 1
            while value > 0 {
                total += sign * (value % 10)
                value /= 10
                sign = -sign
            }
            // The lesson's fix-up: a negative alternating sum gets 11 added.
            XCTAssertEqual((total % 11 + 11) % 11, problem.correctAnswer)
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

    /// The whole point of the two-reference method is that the operands are
    /// too far apart to share a base, so each must stay near its own — and
    /// both sides of each reference have to show up, since a negative
    /// deviation is the case the lesson exists to teach.
    func testTwoReferenceStaysNearItsOwnReference() {
        let pattern = ProblemPattern.twoReference(base: 10, multiple: 50, deviationRange: 1...4)
        let engine = MathEngine(seed: "tworef", pattern: pattern)
        var sawSmallBelow = false, sawSmallAbove = false
        var sawLargeBelow = false, sawLargeAbove = false

        for problem in engine.generateBatch(count: 300) {
            XCTAssertEqual(problem.operation, .multiplication)
            XCTAssertTrue((6...14).contains(problem.operandA), "small operand must stay near 10")
            XCTAssertTrue((46...54).contains(problem.operandB), "large operand must stay near 50")
            XCTAssertNotEqual(problem.operandA, 10, "a zero deviation makes the method trivial")
            XCTAssertNotEqual(problem.operandB, 50, "a zero deviation makes the method trivial")

            if problem.operandA < 10 { sawSmallBelow = true } else { sawSmallAbove = true }
            if problem.operandB < 50 { sawLargeBelow = true } else { sawLargeAbove = true }
        }

        XCTAssertTrue(sawSmallBelow && sawSmallAbove, "both sides of the base must occur")
        XCTAssertTrue(sawLargeBelow && sawLargeAbove, "both sides of the multiple must occur")
    }

    /// Both factoring lessons teach "split it into two easy ones", so every
    /// multiplier and divisor they can generate has to actually split that way.
    /// A prime slipping into either list would leave the problem unsolvable by
    /// the method being taught.
    func testFactoringLessonsOnlyGenerateSplittableOperands() {
        func splitsIntoSingleDigitFactors(_ n: Int) -> Bool {
            (2...9).contains { a in n % a == 0 && (2...9).contains(n / a) }
        }

        for lessonId in ["mult_factors", "div_factors"] {
            guard let lesson = catalogLesson(id: lessonId), let pattern = lesson.pattern else {
                return XCTFail("\(lessonId) is missing from the catalog")
            }
            let engine = MathEngine(seed: lessonId, pattern: pattern)
            for problem in engine.generateBatch(count: 200) {
                XCTAssertTrue(
                    splitsIntoSingleDigitFactors(problem.operandB),
                    "\(lessonId) generated \(problem.operandB), which has no single-digit factor pair"
                )
            }
        }
    }

    /// Dividing by factors only works cleanly when the division is exact, and
    /// the lesson never shows a remainder.
    func testDivideByFactorsIsAlwaysExact() {
        guard let pattern = catalogLesson(id: "div_factors")?.pattern else {
            return XCTFail("div_factors is missing from the catalog")
        }
        let engine = MathEngine(seed: "divfactors", pattern: pattern)
        for problem in engine.generateBatch(count: 200) {
            XCTAssertEqual(problem.operation, .division)
            XCTAssertEqual(problem.operandA % problem.operandB, 0, "must divide evenly")
        }
    }

    private func catalogLesson(id: String) -> Lesson? {
        LessonCatalog.allGroups.lazy.flatMap(\.lessons).first { $0.id == id }
    }

    /// The midpoint method is only a shortcut if the centre square is one the
    /// player can already do, so the midpoint has to land on a multiple of 5
    /// and the two operands must sit symmetrically either side of it.
    func testMidpointProductIsSymmetricAboutAnEasySquare() {
        let pattern = ProblemPattern.midpointProduct(midpointRange: 20...90, gapRange: 2...8)
        let engine = MathEngine(seed: "midpoint", pattern: pattern)
        for problem in engine.generateBatch(count: 300) {
            let sum = problem.operandA + problem.operandB
            XCTAssertEqual(sum % 2, 0, "operands must share a midpoint")
            let midpoint = sum / 2
            XCTAssertEqual(midpoint % 5, 0, "midpoint must be a multiple of 5 to be worth squaring")

            let gap = midpoint - problem.operandA
            XCTAssertTrue((2...8).contains(gap))
            XCTAssertEqual(
                problem.correctAnswer, midpoint * midpoint - gap * gap,
                "the identity m² − g² must actually hold"
            )
        }
    }

    /// The anchor method's selling point is that a mixed pair needs no special
    /// case, so both same-side and opposite-side pairs have to be generated.
    func testAnchorProductCoversMixedAndSameSidePairs() {
        let anchors = [20, 30, 40, 60, 70]
        let pattern = ProblemPattern.anchorProduct(anchors: anchors, deviationRange: 1...5)
        let engine = MathEngine(seed: "anchor", pattern: pattern)
        var sawSameSide = false, sawMixed = false

        for problem in engine.generateBatch(count: 300) {
            guard let anchor = anchors.min(by: {
                abs($0 - problem.operandA) < abs($1 - problem.operandA)
            }) else { return XCTFail("no anchors") }

            let c = problem.operandA - anchor
            let d = problem.operandB - anchor
            XCTAssertNotEqual(c, 0, "a zero deviation makes the method trivial")
            XCTAssertNotEqual(d, 0, "a zero deviation makes the method trivial")
            XCTAssertEqual(
                problem.correctAnswer, anchor * (anchor + c + d) + c * d,
                "the identity a(a + c + d) + cd must actually hold"
            )

            if c.signum() == d.signum() { sawSameSide = true } else { sawMixed = true }
        }

        XCTAssertTrue(sawSameSide && sawMixed, "both same-side and mixed pairs must occur")
    }

    /// Halving the larger operand has to leave a whole number, or the taught
    /// step cannot be carried out at all.
    func testDoubleAndHalveAlwaysHasAnEvenSide() {
        let pattern = ProblemPattern.doubleAndHalve(smallRange: 3...9, evenRange: 12...48)
        let engine = MathEngine(seed: "doublehalve", pattern: pattern)
        for problem in engine.generateBatch(count: 200) {
            XCTAssertEqual(problem.operandB % 2, 0, "the halved side must be even")
            XCTAssertTrue((12...48).contains(problem.operandB))
            XCTAssertTrue((3...9).contains(problem.operandA))
            XCTAssertEqual(
                problem.correctAnswer, (problem.operandA * 2) * (problem.operandB / 2),
                "doubling and halving must leave the product unchanged"
            )
        }
    }

    /// This lesson leans on the neighbouring round square, which only exists
    /// if the number ends in 1 or 9.
    func testSquareAdjacentToRoundEndsInOneOrNine() {
        let pattern = ProblemPattern.squareAdjacentToRound(tensRange: 2...9)
        let engine = MathEngine(seed: "sqadjacent", pattern: pattern)
        var sawBelow = false, sawAbove = false

        for problem in engine.generateBatch(count: 200) {
            XCTAssertEqual(problem.operandA, problem.operandB, "must be a square")
            let units = problem.operandA % 10
            XCTAssertTrue(units == 1 || units == 9, "\(problem.operandA) is not next to a round number")
            if units == 9 { sawBelow = true } else { sawAbove = true }
        }

        XCTAssertTrue(sawBelow && sawAbove, "both the up and down cases must occur")
    }

    /// The two-digit ÷ 9 lesson teaches a quotient *and* a remainder, and its
    /// worked correction step only exists when the digits can sum past 9.
    func testDivideByNineWithRemainderStaysTwoDigit() {
        guard let pattern = catalogLesson(id: "div_9_remainder")?.pattern else {
            return XCTFail("div_9_remainder is missing from the catalog")
        }
        let engine = MathEngine(seed: "div9r", pattern: pattern)
        var sawCorrectionCase = false

        for problem in engine.generateBatch(count: 300) {
            XCTAssertEqual(problem.operation, .divisionWithRemainder)
            XCTAssertEqual(problem.operandB, 9)
            XCTAssertTrue((10...99).contains(problem.operandA), "must stay a two-digit dividend")

            // The taught shortcut: tens digit is the quotient, digit sum the
            // remainder, before any correction.
            let tens = problem.operandA / 10
            let digitSum = tens + problem.operandA % 10
            if digitSum >= 9 { sawCorrectionCase = true }
            XCTAssertEqual(
                problem.operandA, 9 * tens + digitSum,
                "the shortcut must reconstruct the dividend"
            )
        }

        XCTAssertTrue(sawCorrectionCase, "the remainder-too-big case must occur")
    }

    /// Every fraction problem must read as a genuine fraction — a numerator
    /// at or above its denominator would be a whole number in disguise — and
    /// the answer must match the arithmetic the lesson teaches.
    func testFractionOperandsAreProperAndCorrectlyAnswered() {
        let operations: [MathOperation] = [
            .fractionAddition, .fractionSubtraction,
            .fractionMultiplication, .fractionDivision
        ]
        for operation in operations {
            let pattern = ProblemPattern.fractionOperands(operation: operation, denominatorRange: 3...9)
            let engine = MathEngine(seed: operation.rawValue, pattern: pattern)
            for problem in engine.generateBatch(count: 200) {
                XCTAssertTrue((3...9).contains(problem.denominatorA))
                XCTAssertTrue((3...9).contains(problem.denominatorB))
                XCTAssertTrue(
                    problem.operandA > 0 && problem.operandA < problem.denominatorA,
                    "\(problem.displayText) is not a proper fraction"
                )
                XCTAssertTrue(
                    problem.operandB > 0 && problem.operandB < problem.denominatorB,
                    "\(problem.displayText) is not a proper fraction"
                )
                XCTAssertEqual(
                    problem.answer,
                    .rational(operation.evaluate(lhs: problem.fractionA, rhs: problem.fractionB)),
                    "wrong answer for \(problem.displayText)"
                )
            }
        }
    }

    /// Crossing is the whole method, so a shared denominator would let the
    /// player add straight across and never learn it.
    func testAddedAndSubtractedFractionsNeverShareADenominator() {
        for operation in [MathOperation.fractionAddition, .fractionSubtraction] {
            let pattern = ProblemPattern.fractionOperands(operation: operation, denominatorRange: 3...9)
            let engine = MathEngine(seed: "cross\(operation.rawValue)", pattern: pattern)
            for problem in engine.generateBatch(count: 300) {
                XCTAssertNotEqual(
                    problem.denominatorA, problem.denominatorB,
                    "\(problem.displayText) needs no crossing"
                )
            }
        }
    }

    /// Nothing else in the app produces a negative answer, and the method is
    /// identical either way, so subtraction is always ordered larger first.
    func testSubtractedFractionsStayPositive() {
        let pattern = ProblemPattern.fractionOperands(operation: .fractionSubtraction, denominatorRange: 3...9)
        let engine = MathEngine(seed: "fracsub", pattern: pattern)
        for problem in engine.generateBatch(count: 300) {
            guard case let .rational(result) = problem.answer else {
                return XCTFail("expected a rational answer")
            }
            XCTAssertGreaterThan(result.numerator, 0, "\(problem.displayText) went negative")
        }
    }

    /// Fraction lessons must ask for the scientific keypad, which is the only
    /// one with a division key — otherwise the answer cannot be typed at all.
    func testFractionLessonsUseTheExpressionKeypad() {
        for lesson in LessonCatalog.fractionsGroup.lessons {
            XCTAssertEqual(
                lesson.answerMode, .expression,
                "\(lesson.id) cannot type a fraction on the plain digit pad"
            )
        }
    }

    /// The estimation lessons are the only ones where a correct application
    /// of the taught method can still miss the true value. So the grader has
    /// to accept what the method actually produces: run one Newton step off
    /// the nearest whole root, exactly as the lesson describes, and require
    /// that answer to pass. A tolerance tighter than the method's own error
    /// would fail players who did everything right.
    func testEstimationMethodAlwaysSatisfiesItsOwnGrader() {
        func nearestRootEstimate(of n: Int, power: Int) -> Double {
            let value = Double(n)
            let guess = (power == 2 ? value.squareRoot() : cbrt(value)).rounded()
            let slope = power == 2 ? 2 * guess : 3 * guess * guess
            return guess + (value - pow(guess, Double(power))) / slope
        }

        for (lessonId, power) in [("root_square_estimate", 2), ("root_cube_estimate", 3)] {
            guard let pattern = catalogLesson(id: lessonId)?.pattern else {
                return XCTFail("\(lessonId) is missing from the catalog")
            }
            let engine = MathEngine(seed: lessonId, pattern: pattern)
            for problem in engine.generateBatch(count: 400) {
                let estimate = nearestRootEstimate(of: problem.operandA, power: power)
                XCTAssertTrue(
                    problem.answer.accepts(String(format: "%.2f", estimate)),
                    "\(problem.displayText): the method gives \(estimate), which its own grader rejects"
                )
            }
        }
    }

    /// A perfect square belongs to the exact lesson, where the answer is a
    /// whole number — generating one here would teach the wrong thing.
    func testApproximateRootsAreNeverExact() {
        let squares = ProblemPattern.approximateSquareRoot(range: 10...500)
        for problem in MathEngine(seed: "approxsq", pattern: squares).generateBatch(count: 300) {
            let root = Int(Double(problem.operandA).squareRoot().rounded())
            XCTAssertNotEqual(root * root, problem.operandA, "\(problem.operandA) is a perfect square")
        }

        let cubes = ProblemPattern.approximateCubeRoot(range: 100...9999)
        for problem in MathEngine(seed: "approxcb", pattern: cubes).generateBatch(count: 300) {
            let root = Int(cbrt(Double(problem.operandA)).rounded())
            XCTAssertNotEqual(root * root * root, problem.operandA, "\(problem.operandA) is an exact cube")
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
