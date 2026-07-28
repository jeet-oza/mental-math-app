//
//  ProblemPattern.swift
//  Calcathon
//
//  Describes how to generate practice problems that match a specific
//  lesson's concept (e.g. "Adding 9" always produces `_ + 9`, "Squares
//  Ending in 5" always produces `n5 × n5`), rather than generic random
//  problems within a difficulty range.
//

import Foundation

/// A template for generating problems tied to a single taught concept.
///
/// Each case is a generation strategy. All cases produce integer-valued
/// problems by construction (clean division, exact percentages, etc.).
enum ProblemPattern: Codable, Equatable, Sendable {

    /// Which side of the expression the fixed operand sits on.
    enum Position: String, Codable, Sendable {
        case left
        case right
    }

    /// One operand is fixed (chosen from `fixedValues`), the other is variable.
    /// e.g. "Multiply by 11" → `n × 11`.
    case fixedOperand(
        operation: MathOperation,
        fixedValues: [Int],
        position: Position,
        variableRange: ClosedRange<Int>
    )

    /// Both operands vary within their own ranges.
    /// e.g. "Two-Digit × One-Digit" → `(10...99) × (2...9)`.
    /// Subtraction is kept non-negative by swapping operands when needed.
    case twoOperand(
        operation: MathOperation,
        leftRange: ClosedRange<Int>,
        rightRange: ClosedRange<Int>
    )

    /// A number squared: `n × n`, with `n` drawn from `range`.
    case square(range: ClosedRange<Int>)

    /// Squares of numbers ending in 5: `(10t + 5)²`, with `t` from `tensRange`.
    case squareEndingInFive(tensRange: ClosedRange<Int>)

    /// Which "base 100" situation a near-100 product falls into.
    enum NearHundredKind: String, Codable, Equatable, Sendable {
        /// `(100 + a) × (100 + b)` with small `a, b` → clean, no carry.
        case bothAbove
        /// `(100 − a) × (100 − b)` with small `a, b` → clean, no carry.
        case bothBelow
        /// One number above 100, one below → the cross term is negative,
        /// so the base has to borrow.
        case mixed
        /// Both far enough above 100 that the cross term reaches 100,
        /// so its hundreds carry into the base.
        case carry
    }

    /// Products of two numbers near 100, solved with the base-100 method.
    /// Each problem picks one kind from `kinds` (uniformly) and builds its
    /// operands accordingly. Same-side kinds keep the cross term in
    /// `0..<100` (no carry); `mixed` and `carry` deliberately break that.
    case nearHundred(kinds: [NearHundredKind])

    /// Which crosswise ("vertically and crosswise") situation a two-digit
    /// product falls into.
    enum CrosswiseKind: String, Codable, Equatable, Sendable {
        /// Every column lands below 10, so the three results can be read off
        /// directly — used to teach the shape of the method.
        case carryFree
        /// At least one column reaches 10, so a carry has to move left.
        case carrying
    }

    /// Two-digit × two-digit products solved column by column: units × units,
    /// the crosswise sum, then tens × tens.
    case crosswise(kind: CrosswiseKind)

    /// Three-digit × three-digit products, solved with the same crosswise
    /// idea widened to five columns. Every digit is 1–9, so no column
    /// collapses to a freebie.
    case crosswiseThreeDigit

    /// Products of two numbers sitting near a round `base` other than 100
    /// (50, 1000, …), both on the same side of it so the tail stays positive.
    /// Deviations are drawn from `deviationRange`.
    case nearBase(base: Int, deviationRange: ClosedRange<Int>)

    /// Products whose two numbers sit near *different* references — a small
    /// `base` (10) and a `multiple` of it (50) — so neither is near enough to a
    /// single base for the ordinary method. e.g. `8 × 53`. Both deviations are
    /// drawn from `deviationRange` and take either sign.
    case twoReference(base: Int, multiple: Int, deviationRange: ClosedRange<Int>)

    /// `ab × ac` where the tens digits match and the units digits sum to 10,
    /// e.g. `43 × 47`. Products split cleanly into `t(t+1) | u(10−u)`.
    case sameTensUnitsSumTen(tensRange: ClosedRange<Int>)

    /// Products of two numbers straddling a midpoint, `m − g` and `m + g`, so
    /// the pair collapses to `m² − g²`. The midpoint is always a round number
    /// or one ending in 5, because the method is only a shortcut if `m²` is
    /// itself easy.
    case midpointProduct(midpointRange: ClosedRange<Int>, gapRange: ClosedRange<Int>)

    /// Products of two numbers near a small round `anchor` (10, 20, 30 …),
    /// solved as `a(a + c + d) + cd`. Unlike `nearBase`, the two deviations
    /// take independent signs: the anchor method handles a mixed pair without
    /// a special case, which is most of why it is worth learning.
    case anchorProduct(anchors: [Int], deviationRange: ClosedRange<Int>)

    /// A small multiplier times an even number, which rebalances into an
    /// easier pair by doubling one side and halving the other.
    case doubleAndHalve(smallRange: ClosedRange<Int>, evenRange: ClosedRange<Int>)

    /// Squares of numbers sitting one either side of a multiple of ten, i.e.
    /// ending in 1 or 9, so the neighbouring round square carries the work.
    case squareAdjacentToRound(tensRange: ClosedRange<Int>)

    /// Squares of numbers within `deviationRange` of a round `base`,
    /// e.g. base 100 → 91…109. The base itself is never generated.
    case squareNearBase(base: Int, deviationRange: ClosedRange<Int>)

    /// Exact division by 9 whose dividend's digits sum to exactly 9. That
    /// keeps every running sum below 10, so the method needs no carrying and
    /// the remainder always lands on 9 (i.e. "add 1 to the quotient").
    case divideByNine(quotientRange: ClosedRange<Int>)

    /// `n mod divisor`, found with the divisor's place-value cycle rather
    /// than by dividing.
    case remainder(divisor: Int, range: ClosedRange<Int>)

    /// Cubes of numbers sitting `deviationRange` *above* a round `base`, solved
    /// with the Yavadunam method. Below-base cubes are excluded on purpose:
    /// their last part is negative, and the borrow that fixes it buries the
    /// method the lesson is teaching.
    case cubeNearBase(base: Int, deviationRange: ClosedRange<Int>)

    /// Cubes of numbers drawn straight from `range`, for the general method.
    case cube(range: ClosedRange<Int>)

    /// Square roots of perfect squares: `n²` with `n` drawn from `range`.
    case perfectSquareRoot(range: ClosedRange<Int>)

    /// Cube roots of exact cubes: `n³` with `n` drawn from `range`.
    case exactCubeRoot(range: ClosedRange<Int>)

    /// Square roots of numbers that are *not* perfect squares, answered to
    /// within a tolerance. Perfect squares are filtered out: they belong to
    /// `perfectSquareRoot`, where the answer is exact.
    case approximateSquareRoot(range: ClosedRange<Int>)

    /// Cube roots of numbers that are not exact cubes. Same reasoning.
    case approximateCubeRoot(range: ClosedRange<Int>)

    /// `a² − b²`, solved as `(a + b)(a − b)`. `a` comes from `range` and `b`
    /// sits `gapRange` below it, so the difference is always positive.
    case differenceOfSquares(range: ClosedRange<Int>, gapRange: ClosedRange<Int>)

    /// Which side of the base a division method's divisor sits on.
    enum DivisorSide: String, Codable, Equatable, Sendable {
        /// Just below (88, 97) — the Nikhilam case, where the complement is added.
        case below
        /// Just above (104, 123) — the Paravartya case, where it is subtracted.
        case above
    }

    /// Inexact division by a divisor near a power of ten, answered as a
    /// quotient and a remainder. `dividendRange` is the multiplier applied to
    /// the divisor before a remainder is sprinkled on, which keeps the
    /// quotient in a sane range whatever the divisor.
    case nearBaseDivision(
        base: Int,
        side: DivisorSide,
        offsetRange: ClosedRange<Int>,
        quotientRange: ClosedRange<Int>
    )

    /// Inexact division by an arbitrary two-digit divisor, for the general
    /// (flag) method. Answered as a quotient and a remainder.
    case flagDivision(divisorRange: ClosedRange<Int>, quotientRange: ClosedRange<Int>)

    /// An even operand (drawn from `evenRange`) times a fixed value, e.g.
    /// "even × 6" → the left operand is always even.
    case evenTimes(fixed: Int, evenRange: ClosedRange<Int>)

    /// Add or subtract a number sitting just below a round `base` (e.g. 96 or
    /// 983, near 100 / 1000): the near operand is `base − offset` with `offset`
    /// drawn from `offsetRange`, and the other operand comes from `otherRange`.
    /// e.g. "Subtract Near 100" → `n − 96`, solved as `n − 100 + 4`.
    case nearRound(
        operation: MathOperation,
        base: Int,
        offsetRange: ClosedRange<Int>,
        otherRange: ClosedRange<Int>
    )

    /// A round power of ten minus a number with the same digit count, e.g.
    /// `10000 − 3767`, solved by complementing each digit rather than
    /// borrowing across the zeros. The subtrahend always fills every place,
    /// so no digit is a freebie.
    case complementFromRound(bases: [Int])

    /// Clean division `a ÷ d` where `d` is a chosen divisor and `a = d × q`.
    case divisor(divisors: [Int], quotientRange: ClosedRange<Int>)

    /// A pair of proper fractions, for the four fraction operations. Both
    /// numerators sit strictly below their denominator, so every problem
    /// reads as a genuine fraction rather than a disguised whole number.
    ///
    /// Addition and subtraction force the two denominators apart — sharing
    /// one would remove the crossing step the lesson exists to teach — and
    /// subtraction orders the pair so the answer stays positive.
    case fractionOperands(operation: MathOperation, denominatorRange: ClosedRange<Int>)

    /// `p%` of a base value, where the base is chosen so the result is exact.
    case percentage(percents: [Int], multiplierRange: ClosedRange<Int>)

    /// Raising or lowering a base by `p%`, with the base chosen so the change
    /// lands on a whole number.
    case percentageChange(percents: [Int], multiplierRange: ClosedRange<Int>, increase: Bool)

    /// A product of two decimals, each with one or two places. Stored as
    /// fractions over powers of ten, so the answer stays exact and the
    /// player can type it either way.
    case decimalProduct(digitRange: ClosedRange<Int>, placeRange: ClosedRange<Int>)

    /// A three-digit by two-digit product wanted only to the right ballpark.
    /// The second operand starts at 40: below that, rounding it to the
    /// nearest ten moves it by enough to blow past any sane tolerance.
    case estimateProduct(leftRange: ClosedRange<Int>, rightRange: ClosedRange<Int>)

    /// Builds a single problem from this pattern using the given RNG.
    /// Deterministic for a given RNG state.
    func makeProblem<G: RandomNumberGenerator>(using rng: inout G) -> MathProblem {
        switch self {
        case let .fixedOperand(operation, fixedValues, position, variableRange):
            let fixed = fixedValues[Int.random(in: 0..<fixedValues.count, using: &rng)]
            let variable = Int.random(in: variableRange, using: &rng)
            let (a, b): (Int, Int) = position == .left
                ? (fixed, variable)
                : (variable, fixed)
            return MathProblem(operandA: a, operandB: b, operation: operation)

        case let .twoOperand(operation, leftRange, rightRange):
            var a = Int.random(in: leftRange, using: &rng)
            var b = Int.random(in: rightRange, using: &rng)
            if operation == .subtraction && a < b { swap(&a, &b) }
            return MathProblem(operandA: a, operandB: b, operation: operation)

        case let .square(range):
            let n = Int.random(in: range, using: &rng)
            return MathProblem(operandA: n, operandB: n, operation: .multiplication)

        case let .squareEndingInFive(tensRange):
            let t = Int.random(in: tensRange, using: &rng)
            let n = t * 10 + 5
            return MathProblem(operandA: n, operandB: n, operation: .multiplication)

        case let .nearHundred(kinds):
            let kind = kinds[Int.random(in: 0..<kinds.count, using: &rng)]
            switch kind {
            case .bothAbove:
                let a = Int.random(in: 1...9, using: &rng)
                let b = Int.random(in: 1...9, using: &rng)
                return MathProblem(operandA: 100 + a, operandB: 100 + b, operation: .multiplication)
            case .bothBelow:
                let a = Int.random(in: 1...9, using: &rng)
                let b = Int.random(in: 1...9, using: &rng)
                return MathProblem(operandA: 100 - a, operandB: 100 - b, operation: .multiplication)
            case .mixed:
                let a = Int.random(in: 1...9, using: &rng)   // distance above 100
                let b = Int.random(in: 1...9, using: &rng)   // distance below 100
                return MathProblem(operandA: 100 + a, operandB: 100 - b, operation: .multiplication)
            case .carry:
                let a = Int.random(in: 11...19, using: &rng)
                let b = Int.random(in: 11...19, using: &rng)
                return MathProblem(operandA: 100 + a, operandB: 100 + b, operation: .multiplication)
            }

        case let .crosswise(kind):
            // Operands are `ab × cd`, i.e. (10a + b) × (10c + d). The method's
            // three columns are b×d (units), a×d + b×c (crosswise), a×c (tens).
            switch kind {
            case .carryFree:
                // Pick the digits so both right-hand columns stay under 10.
                // a×c can be anything: it's the leading column, nothing to
                // carry into.
                let b = Int.random(in: 1...3, using: &rng)
                let d = Int.random(in: 1...3, using: &rng)     // b×d ≤ 9
                let a = Int.random(in: 1...((9 - b) / d), using: &rng)  // leaves room for b×c
                let c = Int.random(in: 1...((9 - a * d) / b), using: &rng)
                return MathProblem(operandA: a * 10 + b, operandB: c * 10 + d, operation: .multiplication)

            case .carrying:
                // Random two-digit pairs, rejecting the rare ones where no
                // column reaches 10 — this lesson is about the carry.
                for _ in 0..<16 {
                    let a = Int.random(in: 1...9, using: &rng)
                    let b = Int.random(in: 1...9, using: &rng)
                    let c = Int.random(in: 1...9, using: &rng)
                    let d = Int.random(in: 1...9, using: &rng)
                    if b * d >= 10 || a * d + b * c >= 10 {
                        return MathProblem(operandA: a * 10 + b, operandB: c * 10 + d, operation: .multiplication)
                    }
                }
                return MathProblem(operandA: 47, operandB: 63, operation: .multiplication)
            }

        case .crosswiseThreeDigit:
            func threeDigit() -> Int {
                (100 * Int.random(in: 1...9, using: &rng))
                    + (10 * Int.random(in: 1...9, using: &rng))
                    + Int.random(in: 1...9, using: &rng)
            }
            return MathProblem(operandA: threeDigit(), operandB: threeDigit(), operation: .multiplication)

        case let .nearBase(base, deviationRange):
            // Both numbers land on the same side of the base, so the tail
            // (the two deviations multiplied) stays positive and no borrow
            // is ever needed.
            let above = Bool.random(using: &rng)
            let d1 = Int.random(in: deviationRange, using: &rng)
            let d2 = Int.random(in: deviationRange, using: &rng)
            let sign = above ? 1 : -1
            return MathProblem(
                operandA: base + sign * d1,
                operandB: base + sign * d2,
                operation: .multiplication
            )

        case let .twoReference(base, multiple, deviationRange):
            // Either number may sit above or below its own reference — the
            // method carries the sign through, and half the value of the
            // lesson is that a negative deviation is not a special case.
            func deviation() -> Int {
                let size = Int.random(in: deviationRange, using: &rng)
                return Bool.random(using: &rng) ? size : -size
            }
            return MathProblem(
                operandA: base + deviation(),
                operandB: multiple + deviation(),
                operation: .multiplication
            )

        case let .sameTensUnitsSumTen(tensRange):
            let t = Int.random(in: tensRange, using: &rng)
            let u = Int.random(in: 1...9, using: &rng)
            return MathProblem(
                operandA: t * 10 + u,
                operandB: t * 10 + (10 - u),
                operation: .multiplication
            )

        case let .midpointProduct(midpointRange, gapRange):
            // Midpoints land on a multiple of 5 so the square at the centre is
            // one the player already has a shortcut for.
            let steps = midpointRange.lowerBound / 5 ... midpointRange.upperBound / 5
            let midpoint = Int.random(in: steps, using: &rng) * 5
            let gap = Int.random(in: gapRange, using: &rng)
            return MathProblem(
                operandA: midpoint - gap,
                operandB: midpoint + gap,
                operation: .multiplication
            )

        case let .anchorProduct(anchors, deviationRange):
            let anchor = anchors[Int.random(in: 0..<anchors.count, using: &rng)]
            func deviation() -> Int {
                let size = Int.random(in: deviationRange, using: &rng)
                return Bool.random(using: &rng) ? size : -size
            }
            return MathProblem(
                operandA: anchor + deviation(),
                operandB: anchor + deviation(),
                operation: .multiplication
            )

        case let .doubleAndHalve(smallRange, evenRange):
            let small = Int.random(in: smallRange, using: &rng)
            // Pick an even value the same way `evenTimes` does: halve the
            // range, draw, then double.
            let half = Int.random(in: (evenRange.lowerBound + 1) / 2 ... evenRange.upperBound / 2, using: &rng)
            return MathProblem(operandA: small, operandB: half * 2, operation: .multiplication)

        case let .squareAdjacentToRound(tensRange):
            let tens = Int.random(in: tensRange, using: &rng)
            let n = Bool.random(using: &rng) ? tens * 10 + 1 : tens * 10 - 1
            return MathProblem(operandA: n, operandB: n, operation: .multiplication)

        case let .squareNearBase(base, deviationRange):
            let d = Int.random(in: deviationRange, using: &rng)
            let n = Bool.random(using: &rng) ? base + d : base - d
            return MathProblem(operandA: n, operandB: n, operation: .multiplication)

        case let .divideByNine(quotientRange):
            // Keep only the quotients whose dividend digits sum to 9 — those
            // are exactly the ones the running-sum method handles carry-free.
            for _ in 0..<64 {
                let q = Int.random(in: quotientRange, using: &rng)
                if Self.digitSum(q * 9) == 9 {
                    return MathProblem(operandA: q * 9, operandB: 9, operation: .division)
                }
            }
            return MathProblem(operandA: 117, operandB: 9, operation: .division)

        case let .remainder(divisor, range):
            let n = Int.random(in: range, using: &rng)
            return MathProblem(operandA: n, operandB: divisor, operation: .remainder)

        case let .cubeNearBase(base, deviationRange):
            let n = base + Int.random(in: deviationRange, using: &rng)
            return MathProblem(operandA: n, operandB: n, operation: .cube)

        case let .cube(range):
            let n = Int.random(in: range, using: &rng)
            return MathProblem(operandA: n, operandB: n, operation: .cube)

        case let .perfectSquareRoot(range):
            let n = Int.random(in: range, using: &rng)
            return MathProblem(operandA: n * n, operandB: n, operation: .squareRoot)

        case let .exactCubeRoot(range):
            let n = Int.random(in: range, using: &rng)
            return MathProblem(operandA: n * n * n, operandB: n, operation: .cubeRoot)

        case let .approximateSquareRoot(range):
            for _ in 0..<64 {
                let n = Int.random(in: range, using: &rng)
                let root = Int(Double(n).squareRoot().rounded())
                if root * root != n {
                    return MathProblem(operandA: n, operandB: 0, operation: .approximateSquareRoot)
                }
            }
            return MathProblem(operandA: 50, operandB: 0, operation: .approximateSquareRoot)

        case let .approximateCubeRoot(range):
            for _ in 0..<64 {
                let n = Int.random(in: range, using: &rng)
                let root = Int(cbrt(Double(n)).rounded())
                if root * root * root != n {
                    return MathProblem(operandA: n, operandB: 0, operation: .approximateCubeRoot)
                }
            }
            return MathProblem(operandA: 200, operandB: 0, operation: .approximateCubeRoot)

        case let .differenceOfSquares(range, gapRange):
            let a = Int.random(in: range, using: &rng)
            let gap = Int.random(in: gapRange, using: &rng)
            // Keep b positive so the shortcut stays a plain two-number product.
            let b = max(1, a - gap)
            return MathProblem(operandA: a, operandB: b, operation: .differenceOfSquares)

        case let .nearBaseDivision(base, side, offsetRange, quotientRange):
            let offset = Int.random(in: offsetRange, using: &rng)
            let divisor = side == .below ? base - offset : base + offset
            let quotient = Int.random(in: quotientRange, using: &rng)
            // A non-zero remainder is the whole point of these methods, so
            // draw one strictly inside the divisor.
            let remainder = Int.random(in: 1..<divisor, using: &rng)
            return MathProblem(
                operandA: divisor * quotient + remainder,
                operandB: divisor,
                operation: .divisionWithRemainder
            )

        case let .flagDivision(divisorRange, quotientRange):
            let divisor = Int.random(in: divisorRange, using: &rng)
            let quotient = Int.random(in: quotientRange, using: &rng)
            let remainder = Int.random(in: 1..<divisor, using: &rng)
            return MathProblem(
                operandA: divisor * quotient + remainder,
                operandB: divisor,
                operation: .divisionWithRemainder
            )

        case let .evenTimes(fixed, evenRange):
            // Pick an even value in the range: choose a half, then double it.
            let half = Int.random(in: (evenRange.lowerBound + 1) / 2 ... evenRange.upperBound / 2, using: &rng)
            return MathProblem(operandA: half * 2, operandB: fixed, operation: .multiplication)

        case let .nearRound(operation, base, offsetRange, otherRange):
            let near = base - Int.random(in: offsetRange, using: &rng) // e.g. 100 − 4 = 96
            let other = Int.random(in: otherRange, using: &rng)
            if operation == .subtraction {
                // Keep the result non-negative (otherRange sits above the near value).
                let (a, b) = other >= near ? (other, near) : (near, other)
                return MathProblem(operandA: a, operandB: b, operation: .subtraction)
            }
            return MathProblem(operandA: other, operandB: near, operation: operation)

        case let .complementFromRound(bases):
            let base = bases[Int.random(in: 0..<bases.count, using: &rng)]
            // Draw from base/10 upwards so every place has a real digit —
            // a leading zero would hand the player a free column.
            let subtrahend = Int.random(in: (base / 10)..<base, using: &rng)
            return MathProblem(operandA: base, operandB: subtrahend, operation: .subtraction)

        case let .divisor(divisors, quotientRange):
            let d = divisors[Int.random(in: 0..<divisors.count, using: &rng)]
            let q = Int.random(in: quotientRange, using: &rng)
            return MathProblem(operandA: d * q, operandB: d, operation: .division)

        case let .fractionOperands(operation, denominatorRange):
            func properFraction() -> (numerator: Int, denominator: Int) {
                let denominator = Int.random(in: denominatorRange, using: &rng)
                return (Int.random(in: 1..<denominator, using: &rng), denominator)
            }

            var first = properFraction()
            var second = properFraction()

            if operation == .fractionAddition || operation == .fractionSubtraction {
                // Matching denominators would let the player add straight
                // across and never cross, so redraw until they differ.
                for _ in 0..<16 where first.denominator == second.denominator {
                    second = properFraction()
                }
                if first.denominator == second.denominator {
                    second.denominator = denominatorRange.contains(second.denominator + 1)
                        ? second.denominator + 1
                        : second.denominator - 1
                    second.numerator = min(second.numerator, second.denominator - 1)
                }
            }

            if operation == .fractionSubtraction {
                // Different denominators can still hold the same value
                // (2/4 and 3/6), which would subtract to zero — a legal but
                // useless problem. Nudge one numerator until they differ.
                for _ in 0..<16 where first.numerator * second.denominator
                    == second.numerator * first.denominator {
                    second.numerator = second.numerator > 1
                        ? second.numerator - 1
                        : second.numerator + 1
                }
                // Keep the answer positive: the app has no notion of a
                // negative result anywhere else, and the method is the same.
                if first.numerator * second.denominator
                    < second.numerator * first.denominator {
                    swap(&first, &second)
                }
            }

            return MathProblem(
                operandA: first.numerator,
                operandB: second.numerator,
                operation: operation,
                denominatorA: first.denominator,
                denominatorB: second.denominator
            )

        case let .percentage(percents, multiplierRange):
            let p = percents[Int.random(in: 0..<percents.count, using: &rng)]
            // Smallest base step that keeps `p% of base` an integer.
            let step = 100 / Self.gcd(p, 100)
            let base = step * Int.random(in: multiplierRange, using: &rng)
            return MathProblem(operandA: p, operandB: base, operation: .percentage)

        case let .percentageChange(percents, multiplierRange, increase):
            let p = percents[Int.random(in: 0..<percents.count, using: &rng)]
            let step = 100 / Self.gcd(p, 100)
            let base = step * Int.random(in: multiplierRange, using: &rng)
            return MathProblem(
                operandA: p,
                operandB: base,
                operation: increase ? .percentageIncrease : .percentageDecrease
            )

        case let .decimalProduct(digitRange, placeRange):
            func scale() -> Int {
                var value = 1
                for _ in 0..<Int.random(in: placeRange, using: &rng) { value *= 10 }
                return value
            }
            // Reject digits ending in 0: "2.0 × 3.4" would put the decimal
            // point question the lesson asks about back into trivial
            // territory.
            func digits() -> Int {
                for _ in 0..<16 {
                    let n = Int.random(in: digitRange, using: &rng)
                    if n % 10 != 0 { return n }
                }
                return digitRange.lowerBound | 1
            }
            return MathProblem(
                operandA: digits(),
                operandB: digits(),
                operation: .decimalMultiplication,
                denominatorA: scale(),
                denominatorB: scale()
            )

        case let .estimateProduct(leftRange, rightRange):
            return MathProblem(
                operandA: Int.random(in: leftRange, using: &rng),
                operandB: Int.random(in: rightRange, using: &rng),
                operation: .estimateProduct
            )
        }
    }

    private static func digitSum(_ n: Int) -> Int {
        var value = abs(n), sum = 0
        while value > 0 { sum += value % 10; value /= 10 }
        return sum
    }

    private static func gcd(_ a: Int, _ b: Int) -> Int {
        var x = a, y = b
        while y != 0 { (x, y) = (y, x % y) }
        return max(1, abs(x))
    }
}
