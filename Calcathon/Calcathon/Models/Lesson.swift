//
//  Lesson.swift
//  Calcathon
//
//  Model representing a single lesson in Learn Mode.
//

import Foundation

/// How a lesson collects its answer, and therefore which keypad it shows.
///
/// The keypad only ever offers the keys a lesson can actually use, so a
/// player is never presented with symbols that cannot appear in the answer.
enum AnswerInputMode: String, Codable, Equatable, Sendable {
    /// Whole numbers on the plain digit pad. Covers every lesson today,
    /// including the quotient-and-remainder division ones — those take two
    /// whole numbers, not a different kind of value.
    case integer
    /// A symbolic expression assembled on the scientific keypad — roots,
    /// fractions, π, exponents. No lesson uses this yet; trigonometry is the
    /// first that will. It is wired end to end so a lesson can opt in by
    /// setting this one field.
    case expression
}

/// A single lesson that teaches a specific mental math trick,
/// followed by practice problems to reinforce it.
struct Lesson: Identifiable, Codable, Equatable, Sendable {
    let id: String
    let title: String
    let description: String
    let trick: MathTrick
    let operations: [MathOperation]
    let difficulty: MathEngine.Difficulty
    let practiceCount: Int
    /// Generates practice problems matching this lesson's concept.
    /// When nil, practice falls back to generic random generation.
    let pattern: ProblemPattern?
    /// Which keypad this lesson's answers are typed on.
    let answerMode: AnswerInputMode

    /// Example: "Multiply by 11", "Squaring numbers ending in 5"
    init(
        id: String,
        title: String,
        description: String,
        trick: MathTrick,
        operations: [MathOperation],
        difficulty: MathEngine.Difficulty = .easy,
        practiceCount: Int = 10,
        pattern: ProblemPattern? = nil,
        answerMode: AnswerInputMode = .integer
    ) {
        self.answerMode = answerMode
        self.id = id
        self.title = title
        self.description = description
        self.trick = trick
        self.operations = operations
        self.difficulty = difficulty
        self.practiceCount = practiceCount
        self.pattern = pattern
    }
}

/// A mental math trick with step-by-step explanation.
struct MathTrick: Codable, Equatable, Sendable {
    let name: String
    let steps: [String]
    /// One or more worked examples. Always contains at least one.
    let examples: [TrickExample]

    init(name: String, steps: [String], examples: [TrickExample]) {
        self.name = name
        self.steps = steps
        self.examples = examples
    }

    /// Convenience for the common single-example trick.
    init(name: String, steps: [String], example: TrickExample) {
        self.init(name: name, steps: steps, examples: [example])
    }
}

/// A worked example showing a trick applied to a specific problem.
struct TrickExample: Codable, Equatable, Sendable {
    let problem: String
    let solution: String
    let stepByStepExplanation: [String]
}
