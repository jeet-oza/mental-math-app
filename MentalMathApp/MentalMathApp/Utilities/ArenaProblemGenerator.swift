//
//  ArenaProblemGenerator.swift
//  MentalMathApp
//
//  Deterministic problem generator for the Equation Arena. Produces a fixed
//  mix (same sequence for everyone via the round seed):
//   - Multiplication: 2-digit × 1-digit            (worth 10 points)
//   - Addition / Subtraction: up to 3-digit operands (5 pts if 3-digit, else 2)
//  Subtraction never yields a negative result. Division is not used in the Arena.
//

import Foundation

struct ArenaProblemGenerator {

    private var rng: SeededRandomNumberGenerator

    init(seed: String) {
        self.rng = SeededRandomNumberGenerator(seed: seed)
    }

    /// The next problem in the deterministic sequence.
    mutating func next() -> MathProblem {
        let operation = [MathOperation.addition, .subtraction, .multiplication][
            Int.random(in: 0..<3, using: &rng)
        ]

        switch operation {
        case .multiplication:
            // 2-digit × 1-digit.
            let a = Int.random(in: 10...99, using: &rng)
            let b = Int.random(in: 2...9, using: &rng)
            return MathProblem(operandA: a, operandB: b, operation: .multiplication)

        case .addition:
            let (a, b) = additivePair()
            return MathProblem(operandA: a, operandB: b, operation: .addition)

        case .subtraction:
            var (a, b) = additivePair()
            if a < b { swap(&a, &b) } // keep the result non-negative
            return MathProblem(operandA: a, operandB: b, operation: .subtraction)

        default:
            // Division/percentage are never generated in the Arena.
            let a = Int.random(in: 10...99, using: &rng)
            let b = Int.random(in: 10...99, using: &rng)
            return MathProblem(operandA: a, operandB: b, operation: .addition)
        }
    }

    /// A pair of operands for addition/subtraction: either both 2-digit or both
    /// 3-digit (so the point value is unambiguous).
    private mutating func additivePair() -> (Int, Int) {
        let threeDigit = Bool.random(using: &rng)
        let range = threeDigit ? 100...999 : 10...99
        return (Int.random(in: range, using: &rng), Int.random(in: range, using: &rng))
    }
}
