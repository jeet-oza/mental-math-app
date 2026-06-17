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

    /// Returns the display symbol for the operation.
    var symbol: String {
        rawValue
    }

    /// Evaluates the operation on two integer operands.
    /// - Parameters:
    ///   - lhs: Left-hand side operand.
    ///   - rhs: Right-hand side operand.
    /// - Returns: The result of applying the operation.
    func evaluate(lhs: Int, rhs: Int) -> Double {
        switch self {
        case .addition:
            return Double(lhs + rhs)
        case .subtraction:
            return Double(lhs - rhs)
        case .multiplication:
            return Double(lhs * rhs)
        case .division:
            guard rhs != 0 else { return 0 }
            return Double(lhs) / Double(rhs)
        }
    }
}
