//
//  Lesson.swift
//  MentalMathApp
//
//  Model representing a single lesson in Learn Mode.
//

import Foundation

/// A single lesson that teaches a specific mental math trick,
/// followed by practice problems to reinforce it.
struct Lesson: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    let description: String
    let trick: MathTrick
    let operations: [MathOperation]
    let difficulty: MathEngine.Difficulty
    let practiceCount: Int

    /// Example: "Multiply by 11", "Squaring numbers ending in 5"
    init(
        id: String,
        title: String,
        description: String,
        trick: MathTrick,
        operations: [MathOperation],
        difficulty: MathEngine.Difficulty = .easy,
        practiceCount: Int = 10
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.trick = trick
        self.operations = operations
        self.difficulty = difficulty
        self.practiceCount = practiceCount
    }
}

/// A mental math trick with step-by-step explanation.
struct MathTrick: Codable, Equatable {
    let name: String
    let steps: [String]
    let example: TrickExample
}

/// A worked example showing a trick applied to a specific problem.
struct TrickExample: Codable, Equatable {
    let problem: String
    let solution: String
    let stepByStepExplanation: [String]
}
