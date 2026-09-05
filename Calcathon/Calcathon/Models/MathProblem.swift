//
//  MathProblem.swift
//  Calcathon
//
//  Core model representing a single math problem.
//

import Foundation

/// What a problem expects back from the player.
///
/// Most problems want one number. Division taught by the Vedic methods works
/// on inexact division, so those want a quotient *and* a remainder — the two
/// coexist rather than one replacing the other.
enum ProblemAnswer: Equatable, Codable, Sendable {
    case single(Int)
    case quotientRemainder(quotient: Int, remainder: Int)
    /// An exact rational answer. Graded by value, so an unreduced fraction
    /// is still correct.
    case rational(Fraction)
    /// The same exact value, but read back in decimal. Graded identically —
    /// the split exists only so a decimal lesson does not answer "17/2" at a
    /// player who was asked about 8.5.
    case decimal(Fraction)
    /// An answer the taught method only reaches approximately — square and
    /// cube roots of numbers that are not perfect powers. Anything within
    /// `tolerance` counts.
    case approximate(value: Double, tolerance: Double)

    /// The headline number, used wherever a single value is enough (feedback
    /// text and legacy score summaries). Approximate and rational values round.
    var primary: Int {
        switch self {
        case let .single(value): return value
        case let .quotientRemainder(quotient, _): return quotient
        case let .rational(fraction), let .decimal(fraction):
            return fraction.numerator / fraction.denominator
        case let .approximate(value, _): return Int(value.rounded())
        }
    }

    /// How this answer reads back to the player, e.g. "14 r 2" or "7.07".
    var displayText: String {
        switch self {
        case let .single(value):
            return "\(value)"
        case let .quotientRemainder(quotient, remainder):
            return "\(quotient) r \(remainder)"
        case let .rational(fraction):
            return fraction.displayText
        case let .decimal(fraction):
            return fraction.decimalText
        case let .approximate(value, _):
            return String(format: "%.2f", value)
        }
    }

    /// Whether `input` is even the right *shape* to be an answer here —
    /// digits for a whole number, something fraction-like for a fraction.
    ///
    /// Kept separate from `accepts` so that typing nonsense is a no-op rather
    /// than a wrong answer: a player who fumbles the keypad should not burn
    /// an attempt.
    func isWellFormed(_ input: String) -> Bool {
        let trimmed = input.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return false }
        switch self {
        case .single, .quotientRemainder:
            return Int(trimmed) != nil
        case .rational, .decimal:
            return Fraction.parse(trimmed) != nil
        case .approximate:
            return (try? ExpressionEvaluator.evaluate(trimmed)) != nil
        }
    }

    /// Whether `input` is an acceptable answer. Each case decides for itself
    /// what "acceptable" means: exact for whole numbers, by value for
    /// fractions, within tolerance for approximations.
    func accepts(_ input: String) -> Bool {
        let trimmed = input.trimmingCharacters(in: .whitespaces)
        switch self {
        case let .single(value):
            return Int(trimmed) == value
        case .quotientRemainder:
            // Needs two fields, so the view model handles it directly.
            return false
        case let .rational(fraction), let .decimal(fraction):
            return Fraction.parse(trimmed) == fraction
        case let .approximate(value, tolerance):
            guard let entered = try? ExpressionEvaluator.evaluate(trimmed) else { return false }
            return abs(entered - value) <= tolerance
        }
    }
}

/// A math problem with two operands and an operation.
/// Conforms to Identifiable for use in SwiftUI lists and Equatable for testing.
struct MathProblem: Identifiable, Equatable, Codable, Sendable {
    let id: UUID
    let operandA: Int
    let operandB: Int
    /// Denominators for the two operands. Only meaningful when the operation
    /// `isFractional`; every other problem leaves them at 1, which makes
    /// `fractionA`/`fractionB` degrade to plain whole numbers.
    let denominatorA: Int
    let denominatorB: Int
    let operation: MathOperation

    var fractionA: Fraction { Fraction(operandA, denominatorA) }
    var fractionB: Fraction { Fraction(operandB, denominatorB) }

    /// The correct answer for this problem, as a whole number. Only sound for
    /// the integer operations — see `answer`, which is the honest form.
    var correctAnswer: Int {
        operation.evaluate(lhs: operandA, rhs: operandB)
    }

    /// What the player must supply: one number, a quotient and a remainder,
    /// a fraction, or a value within a tolerance.
    var answer: ProblemAnswer {
        if operation.isFractional {
            let result = operation.evaluate(lhs: fractionA, rhs: fractionB)
            return operation.showsAsDecimal ? .decimal(result) : .rational(result)
        }
        if operation == .estimateProduct {
            // A fifth of the answer, not a fixed amount: rounding both
            // operands to the nearest ten is off by up to 15% over the range
            // this lesson generates, so anything tighter would fail a player
            // who estimated exactly as taught.
            let value = Double(correctAnswer)
            return .approximate(value: value, tolerance: abs(value) * 0.2)
        }
        if let tolerance = operation.tolerance {
            let value = operation == .approximateSquareRoot
                ? Double(max(0, operandA)).squareRoot()
                : cbrt(Double(operandA))
            return .approximate(value: value, tolerance: tolerance)
        }
        guard operation == .divisionWithRemainder, operandB != 0 else {
            return .single(correctAnswer)
        }
        return .quotientRemainder(
            quotient: operandA / operandB,
            remainder: operandA % operandB
        )
    }

    /// Human-readable string for display, e.g. "12 × 5", "10% of 80", "√5329".
    var displayText: String {
        switch operation {
        case .percentage:
            return "\(operandA)% of \(operandB)"
        case .estimateProduct:
            return "\(operandA) × \(operandB), roughly"
        case .repeatingBlock:
            return "\(operandA)/\(operandB) — repeating digits"
        case .percentageIncrease:
            return "\(operandB) up \(operandA)%"
        case .percentageDecrease:
            return "\(operandB) down \(operandA)%"
        case .cube:
            return "\(operandA)³"
        case .squareRoot, .cubeRoot, .approximateSquareRoot, .approximateCubeRoot:
            return "\(operation.symbol)\(operandA)"
        case .differenceOfSquares:
            return "\(operandA)² − \(operandB)²"
        case .fractionAddition, .fractionSubtraction,
             .fractionMultiplication, .fractionDivision:
            return "\(fractionA.displayText) \(operation.symbol) \(fractionB.displayText)"
        case .decimalMultiplication:
            return "\(fractionA.decimalText) × \(fractionB.decimalText)"
        default:
            return "\(operandA) \(operation.symbol) \(operandB)"
        }
    }

    /// Creates a MathProblem with auto-generated UUID.
    /// - Parameters:
    ///   - operandA: The first number.
    ///   - operandB: The second number.
    ///   - operation: The arithmetic operation to perform.
    init(
        operandA: Int,
        operandB: Int,
        operation: MathOperation,
        denominatorA: Int = 1,
        denominatorB: Int = 1
    ) {
        self.id = UUID()
        self.operandA = operandA
        self.operandB = operandB
        self.denominatorA = denominatorA
        self.denominatorB = denominatorB
        self.operation = operation
    }

    /// Creates a MathProblem with a specific UUID (useful for deterministic seeded generation).
    /// - Parameters:
    ///   - id: A predetermined UUID.
    ///   - operandA: The first number.
    ///   - operandB: The second number.
    ///   - operation: The arithmetic operation to perform.
    init(
        id: UUID,
        operandA: Int,
        operandB: Int,
        operation: MathOperation,
        denominatorA: Int = 1,
        denominatorB: Int = 1
    ) {
        self.id = id
        self.operandA = operandA
        self.operandB = operandB
        self.denominatorA = denominatorA
        self.denominatorB = denominatorB
        self.operation = operation
    }
}
