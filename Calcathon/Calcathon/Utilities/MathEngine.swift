//
//  MathEngine.swift
//  Calcathon
//
//  Deterministic, seed-based math problem generator.
//  Given the same seed, always produces the identical sequence of problems.
//  Determinism keeps lesson and timed-practice generation testable.
//

import Foundation

/// Generates a deterministic, infinite sequence of math problems from a seed string.
/// Thread-safe: create one instance per session/round.
final class MathEngine {

    // MARK: - Properties

    private var rng: SeededRandomNumberGenerator
    private let operations: [MathOperation]
    private let difficulty: Difficulty
    private let pattern: ProblemPattern?
    private var questionIndex: Int = 0

    // MARK: - Difficulty

    /// Defines operand ranges for each difficulty tier.
    enum Difficulty: Codable, Sendable {
        case easy
        case medium
        case hard

        /// The range of values for operands at this difficulty.
        var operandRange: ClosedRange<Int> {
            switch self {
            case .easy:
                return 1...12
            case .medium:
                return 10...99
            case .hard:
                return 50...999
            }
        }
    }

    // MARK: - Initialization

    /// Creates a new MathEngine.
    /// - Parameters:
    ///   - seed: A string seed for deterministic problem generation.
    ///   - difficulty: The difficulty tier controlling operand ranges.
    ///   - operations: The set of operations to include. Defaults to all four.
    ///   - pattern: An optional concept pattern. When provided, every problem
    ///     is generated from the pattern instead of generic random operands.
    init(
        seed: String,
        difficulty: Difficulty = .easy,
        operations: [MathOperation] = MathOperation.allCases,
        pattern: ProblemPattern? = nil
    ) {
        self.rng = SeededRandomNumberGenerator(seed: seed)
        self.difficulty = difficulty
        self.operations = operations
        self.pattern = pattern
    }

    // MARK: - Problem Generation

    /// Generates the next problem in the deterministic sequence.
    /// - Returns: The next `MathProblem`.
    func nextProblem() -> MathProblem {
        questionIndex += 1

        // Concept-based generation: every problem matches the lesson's trick.
        if let pattern {
            return pattern.makeProblem(using: &rng)
        }

        let operation = operations[Int.random(in: 0..<operations.count, using: &rng)]
        var operandA = Int.random(in: difficulty.operandRange, using: &rng)
        var operandB = Int.random(in: difficulty.operandRange, using: &rng)

        adjustOperandsForOperation(operation, a: &operandA, b: &operandB)

        return MathProblem(operandA: operandA, operandB: operandB, operation: operation)
    }

    /// Generates a batch of problems.
    /// - Parameter count: Number of problems to generate.
    /// - Returns: An array of `MathProblem` in deterministic order.
    func generateBatch(count: Int) -> [MathProblem] {
        (0..<count).map { _ in nextProblem() }
    }

    /// Resets the engine to the beginning of the sequence for the same seed.
    /// - Parameter seed: The seed string to reset with.
    func reset(seed: String) {
        rng = SeededRandomNumberGenerator(seed: seed)
        questionIndex = 0
    }

    /// The number of problems generated so far.
    var currentIndex: Int {
        questionIndex
    }

    // MARK: - Private Helpers

    /// Adjusts operands to ensure clean answers for division
    /// and that subtraction doesn't produce negative results for easy/medium.
    private func adjustOperandsForOperation(
        _ operation: MathOperation,
        a: inout Int,
        b: inout Int
    ) {
        switch operation {
        case .division:
            // Ensure clean integer division: make a = b * quotient
            b = max(b, 1) // prevent division by zero
            let quotient = Int.random(in: 2...12, using: &rng)
            a = b * quotient

        case .subtraction:
            // Ensure a >= b so result is non-negative for easy/medium
            if difficulty != .hard && a < b {
                swap(&a, &b)
            }

        default:
            break
        }
    }
}
