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

    /// Clean division `a ÷ d` where `d` is a chosen divisor and `a = d × q`.
    case divisor(divisors: [Int], quotientRange: ClosedRange<Int>)

    /// `p%` of a base value, where the base is chosen so the result is exact.
    case percentage(percents: [Int], multiplierRange: ClosedRange<Int>)

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

        case let .divisor(divisors, quotientRange):
            let d = divisors[Int.random(in: 0..<divisors.count, using: &rng)]
            let q = Int.random(in: quotientRange, using: &rng)
            return MathProblem(operandA: d * q, operandB: d, operation: .division)

        case let .percentage(percents, multiplierRange):
            let p = percents[Int.random(in: 0..<percents.count, using: &rng)]
            // Smallest base step that keeps `p% of base` an integer.
            let step = 100 / Self.gcd(p, 100)
            let base = step * Int.random(in: multiplierRange, using: &rng)
            return MathProblem(operandA: p, operandB: base, operation: .percentage)
        }
    }

    private static func gcd(_ a: Int, _ b: Int) -> Int {
        var x = a, y = b
        while y != 0 { (x, y) = (y, x % y) }
        return max(1, abs(x))
    }
}
