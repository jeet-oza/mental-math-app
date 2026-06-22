//
//  ProblemPattern.swift
//  MentalMathApp
//
//  Describes how to generate practice problems that match a specific
//  lesson's concept (e.g. "Adding 9" always produces `_ + 9`), rather
//  than generic random problems within a difficulty range.
//

import Foundation

/// A template for generating problems tied to a single taught concept.
///
/// One operand is "fixed" (chosen from `fixedValues`) and the other is
/// "variable" (drawn from `variableRange`). This guarantees that practice
/// for, say, "Multiply by 11" only ever produces `n × 11` problems.
struct ProblemPattern: Codable, Equatable, Sendable {

    /// Which side of the expression the fixed operand sits on.
    enum Position: String, Codable, Sendable {
        case left
        case right
    }

    let operation: MathOperation
    /// Candidate values for the fixed operand; one is chosen per problem.
    let fixedValues: [Int]
    /// Whether the fixed operand is the left or right operand.
    let fixedPosition: Position
    /// Inclusive range for the variable operand.
    let variableRange: ClosedRange<Int>

    /// Builds a single problem from this pattern using the given RNG.
    /// Deterministic for a given RNG state.
    func makeProblem<G: RandomNumberGenerator>(using rng: inout G) -> MathProblem {
        let fixed = fixedValues[Int.random(in: 0..<fixedValues.count, using: &rng)]
        let variable = Int.random(in: variableRange, using: &rng)
        let (a, b): (Int, Int) = fixedPosition == .left
            ? (fixed, variable)
            : (variable, fixed)
        return MathProblem(operandA: a, operandB: b, operation: operation)
    }
}
