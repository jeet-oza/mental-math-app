//
//  MathProblem.swift
//  MentalMathApp
//
//  Core model representing a single math problem.
//

import Foundation

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

    /// Human-readable string for display, e.g. "12 × 5".
    var displayText: String {
        "\(operandA) \(operation.symbol) \(operandB)"
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
