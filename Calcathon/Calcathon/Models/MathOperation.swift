//
//  MathOperation.swift
//  Calcathon
//
//  Defines the supported arithmetic operations.
//

import Foundation

/// Represents a type of arithmetic operation used in math problems.
enum MathOperation: String, CaseIterable, Codable, Sendable {
    case addition = "+"
    case subtraction = "−"
    case multiplication = "×"
    case division = "÷"
    case percentage = "%"
    case remainder = "mod"
    /// Division that need not come out exact — the answer is a quotient *and*
    /// a remainder. Displays like ordinary division; only the answer differs.
    case divisionWithRemainder = "÷r"
    case cube = "^3"
    case squareRoot = "sqrt"
    case cubeRoot = "cbrt"
    /// `a² − b²`, displayed with both squares intact so the shortcut
    /// `(a + b)(a − b)` is the thing being practised.
    case differenceOfSquares = "sq-diff"

    /// The four arithmetic operations used for random/Arena generation.
    /// Everything else is concept-only: those operations belong to specific
    /// lessons and must never appear in generic random generation.
    static var allCases: [MathOperation] {
        [.addition, .subtraction, .multiplication, .division]
    }

    /// Operations that take a single operand. `operandB` is unused for these,
    /// and they render as a prefix or suffix rather than as `a ∘ b`.
    var isUnary: Bool {
        switch self {
        case .cube, .squareRoot, .cubeRoot:
            return true
        default:
            return false
        }
    }

    /// Returns the display symbol for the operation. Raw values stay unique
    /// for stable `Codable` encoding, so the two are not always the same.
    var symbol: String {
        switch self {
        case .divisionWithRemainder: return "÷"
        case .cube: return "³"
        case .squareRoot: return "√"
        case .cubeRoot: return "∛"
        default: return rawValue
        }
    }

    /// Evaluates the operation on two integer operands.
    ///
    /// All problems in this app are integer-valued by construction
    /// (see `MathEngine`, which only generates evenly-divisible division
    /// problems), so the result is always an exact `Int`.
    /// - Parameters:
    ///   - lhs: Left-hand side operand.
    ///   - rhs: Right-hand side operand.
    /// - Returns: The integer result of applying the operation.
    ///   Division by zero returns 0 as a safe fallback.
    ///   Division that is not exact truncates toward zero.
    func evaluate(lhs: Int, rhs: Int) -> Int {
        switch self {
        case .addition:
            return lhs + rhs
        case .subtraction:
            return lhs - rhs
        case .multiplication:
            return lhs * rhs
        case .division:
            guard rhs != 0 else { return 0 }
            return lhs / rhs
        case .percentage:
            // lhs = percent, rhs = base. Patterns guarantee an exact result.
            return lhs * rhs / 100
        case .remainder:
            guard rhs != 0 else { return 0 }
            return lhs % rhs
        case .divisionWithRemainder:
            // The quotient is the primary answer; the remainder rides along in
            // `MathProblem.answer`.
            guard rhs != 0 else { return 0 }
            return lhs / rhs
        case .cube:
            return lhs * lhs * lhs
        case .squareRoot:
            // Patterns only ever generate perfect squares, so this is exact.
            return Int(Double(max(0, lhs)).squareRoot().rounded())
        case .cubeRoot:
            // Likewise: exact cubes only.
            return Int(cbrt(Double(lhs)).rounded())
        case .differenceOfSquares:
            return lhs * lhs - rhs * rhs
        }
    }
}
