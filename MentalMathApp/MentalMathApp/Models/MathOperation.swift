//
//  MathOperation.swift
//  MentalMathApp
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

    /// The four arithmetic operations used for random/Arena generation.
    /// `.percentage` is intentionally excluded — it is only used by concept
    /// patterns, never by generic random generation.
    static var allCases: [MathOperation] {
        [.addition, .subtraction, .multiplication, .division]
    }

    /// Returns the display symbol for the operation.
    var symbol: String {
        rawValue
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
        }
    }
}
