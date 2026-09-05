//
//  TimedPractice.swift
//  Calcathon
//
//  Configuration and result types for local timed practice.
//

import Foundation

enum TimedPracticeMode: String, CaseIterable, Identifiable {
    case techniques = "Techniques"
    case open = "Open Mix"

    var id: Self { self }
}

struct OperandDigits: Equatable, Sendable {
    var first = 2
    var second = 1
}

struct TimedPracticePlan {
    let mode: TimedPracticeMode
    let durationMinutes: Int
    let lessons: [Lesson]
    let openOperations: [MathOperation]
    let digits: [MathOperation: OperandDigits]

    var isValid: Bool {
        switch mode {
        case .techniques: return !lessons.isEmpty
        case .open: return !openOperations.isEmpty
        }
    }
}

struct TimedPracticeAnswer: Equatable, Sendable {
    let isCorrect: Bool
    let isSkipped: Bool
    let elapsed: TimeInterval
}

enum TimedProblemFactory {
    static func problem<G: RandomNumberGenerator>(
        operation: MathOperation,
        digits: OperandDigits,
        using rng: inout G
    ) -> MathProblem {
        let firstRange = range(forDigits: digits.first)
        let secondRange = range(forDigits: digits.second)

        switch operation {
        case .addition:
            return MathProblem(
                operandA: Int.random(in: firstRange, using: &rng),
                operandB: Int.random(in: secondRange, using: &rng),
                operation: .addition
            )
        case .subtraction:
            var first = Int.random(in: firstRange, using: &rng)
            var second = Int.random(in: secondRange, using: &rng)
            if first < second { swap(&first, &second) }
            return MathProblem(operandA: first, operandB: second, operation: .subtraction)
        case .multiplication:
            return MathProblem(
                operandA: Int.random(in: firstRange, using: &rng),
                operandB: Int.random(in: secondRange, using: &rng),
                operation: .multiplication
            )
        case .division:
            // In open division, the requested sizes describe the answer and
            // divisor. Multiplying them guarantees a clean whole-number result.
            let quotient = Int.random(in: firstRange, using: &rng)
            let divisor = Int.random(in: secondRange, using: &rng)
            return MathProblem(operandA: quotient * divisor, operandB: divisor, operation: .division)
        default:
            preconditionFailure("Open practice only supports the four basic operations")
        }
    }

    static func range(forDigits count: Int) -> ClosedRange<Int> {
        let safeCount = min(max(count, 1), 4)
        if safeCount == 1 { return 1...9 }
        let lower = Int(pow(10.0, Double(safeCount - 1)))
        return lower...(lower * 10 - 1)
    }
}
