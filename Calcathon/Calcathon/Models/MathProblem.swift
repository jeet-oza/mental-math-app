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

    /// The headline number, used wherever a single value is enough (feedback
    /// text, Arena scoring).
    var primary: Int {
        switch self {
        case let .single(value): return value
        case let .quotientRemainder(quotient, _): return quotient
        }
    }

    /// How this answer reads back to the player, e.g. "14 r 2".
    var displayText: String {
        switch self {
        case let .single(value):
            return "\(value)"
        case let .quotientRemainder(quotient, remainder):
            return "\(quotient) r \(remainder)"
        }
    }
}

/// A math problem with two operands and an operation.
/// Conforms to Identifiable for use in SwiftUI lists and Equatable for testing.
struct MathProblem: Identifiable, Equatable, Codable, Sendable {
    let id: UUID
    let operandA: Int
    let operandB: Int
    let operation: MathOperation

    /// The correct answer for this problem.
    var correctAnswer: Int {
        operation.evaluate(lhs: operandA, rhs: operandB)
    }

    /// What the player must supply: one number, or a quotient and a remainder.
    var answer: ProblemAnswer {
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
        case .cube:
            return "\(operandA)³"
        case .squareRoot, .cubeRoot:
            return "\(operation.symbol)\(operandA)"
        case .differenceOfSquares:
            return "\(operandA)² − \(operandB)²"
        default:
            return "\(operandA) \(operation.symbol) \(operandB)"
        }
    }

    /// Creates a MathProblem with auto-generated UUID.
    /// - Parameters:
    ///   - operandA: The first number.
    ///   - operandB: The second number.
    ///   - operation: The arithmetic operation to perform.
    init(operandA: Int, operandB: Int, operation: MathOperation) {
        self.id = UUID()
        self.operandA = operandA
        self.operandB = operandB
        self.operation = operation
    }

    /// Creates a MathProblem with a specific UUID (useful for deterministic seeded generation).
    /// - Parameters:
    ///   - id: A predetermined UUID.
    ///   - operandA: The first number.
    ///   - operandB: The second number.
    ///   - operation: The arithmetic operation to perform.
    init(id: UUID, operandA: Int, operandB: Int, operation: MathOperation) {
        self.id = id
        self.operandA = operandA
        self.operandB = operandB
        self.operation = operation
    }
}
