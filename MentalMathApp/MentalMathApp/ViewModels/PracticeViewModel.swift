//
//  PracticeViewModel.swift
//  MentalMathApp
//
//  ViewModel for individual lesson practice sessions.
//  Generates problems, tracks answers, and reports results back to CurriculumViewModel.
//

import Foundation
import Combine
import SwiftUI

/// Manages the state of a single practice session within a lesson.
@MainActor
final class PracticeViewModel: ObservableObject {

    // MARK: - Published State

    @Published private(set) var currentProblem: MathProblem?
    @Published private(set) var problemNumber: Int = 0
    @Published private(set) var totalProblems: Int
    @Published private(set) var answers: [AnswerResult] = []
    @Published private(set) var isSessionComplete: Bool = false
    @Published var userInput: String = ""
    @Published private(set) var feedbackMessage: String?
    @Published private(set) var isCorrectFeedback: Bool?

    // MARK: - Properties

    let lesson: Lesson
    private let engine: MathEngine
    private var problemStartTime: Date = Date()
    private let difficulty: MathEngine.Difficulty

    // MARK: - Computed

    /// Number of correct answers so far.
    var correctCount: Int {
        answers.filter { $0.isCorrect }.count
    }

    /// Current score total.
    var totalScore: Int {
        ScoreCalculator.totalScore(from: answers)
    }

    /// Accuracy as a percentage string, e.g. "80%".
    var accuracyText: String {
        guard !answers.isEmpty else { return "—" }
        let pct = Int((Double(correctCount) / Double(answers.count)) * 100)
        return "\(pct)%"
    }

    /// Whether the session result is a passing score.
    var isPassing: Bool {
        guard isSessionComplete else { return false }
        return ScoreCalculator.calculatePoints(isCorrect: true, timeElapsed: 0, difficulty: .easy) > 0
            && Double(correctCount) / Double(totalProblems) >= 0.7
    }

    // MARK: - Initialization

    /// Creates a PracticeViewModel for a specific lesson.
    /// - Parameter lesson: The lesson to practice.
    init(lesson: Lesson) {
        self.lesson = lesson
        self.totalProblems = lesson.practiceCount
        self.difficulty = lesson.difficulty
        self.engine = MathEngine(
            seed: "\(lesson.id)_practice_\(UUID().uuidString)",
            difficulty: lesson.difficulty,
            operations: lesson.operations
        )
        advanceToNextProblem()
    }

    // MARK: - Actions

    /// Submits the user's answer for the current problem.
    func submitAnswer() {
        guard let problem = currentProblem,
              let userAnswer = Int(userInput.trimmingCharacters(in: .whitespaces))
        else { return }

        let elapsed = Date().timeIntervalSince(problemStartTime)
        let isCorrect = userAnswer == problem.correctAnswer
        let points = ScoreCalculator.calculatePoints(
            isCorrect: isCorrect,
            timeElapsed: elapsed,
            difficulty: difficulty
        )

        let result = AnswerResult(
            problemIndex: problemNumber - 1,
            isCorrect: isCorrect,
            isSkipped: false,
            userAnswer: userAnswer,
            correctAnswer: problem.correctAnswer,
            timeElapsed: elapsed,
            pointsEarned: points
        )

        answers.append(result)
        showFeedback(isCorrect: isCorrect, correctAnswer: problem.correctAnswer)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.clearFeedbackAndAdvance()
        }
    }

    /// Skips the current problem.
    func skipProblem() {
        guard let problem = currentProblem else { return }

        let elapsed = Date().timeIntervalSince(problemStartTime)
        let result = AnswerResult(
            problemIndex: problemNumber - 1,
            isCorrect: false,
            isSkipped: true,
            userAnswer: nil,
            correctAnswer: problem.correctAnswer,
            timeElapsed: elapsed,
            pointsEarned: ScoreCalculator.skipPenalty
        )

        answers.append(result)
        showFeedback(isCorrect: false, correctAnswer: problem.correctAnswer)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.clearFeedbackAndAdvance()
        }
    }

    // MARK: - Private Helpers

    /// Advances to the next problem or ends the session.
    private func advanceToNextProblem() {
        guard problemNumber < totalProblems else {
            isSessionComplete = true
            return
        }

        currentProblem = engine.nextProblem()
        problemNumber += 1
        userInput = ""
        problemStartTime = Date()
    }

    /// Shows correct/incorrect feedback temporarily.
    private func showFeedback(isCorrect: Bool, correctAnswer: Int) {
        isCorrectFeedback = isCorrect
        feedbackMessage = isCorrect
            ? "Correct! ✓"
            : "Incorrect. The answer is \(correctAnswer)."
    }

    /// Clears feedback and moves to the next problem.
    private func clearFeedbackAndAdvance() {
        feedbackMessage = nil
        isCorrectFeedback = nil
        advanceToNextProblem()
    }
}
