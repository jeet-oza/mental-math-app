//
//  PracticeViewModel.swift
//  Calcathon
//
//  ViewModel for individual lesson practice sessions.
//  Generates problems and tracks answers, exposing `isSessionComplete`,
//  `correctCount`, and `totalProblems` for the owning view to read.
//  The view is responsible for reporting the final result to
//  CurriculumViewModel (see PracticeView.handleCompletion).
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
    /// Second field, used only by problems that want a remainder alongside
    /// the quotient. Ignored for every other problem.
    @Published var userRemainderInput: String = ""
    @Published private(set) var feedbackMessage: String?
    @Published private(set) var isCorrectFeedback: Bool?
    /// True while a missed answer is on screen. A right answer rolls on by
    /// itself; a miss holds the question, the answer given and the answer
    /// wanted until the player taps Next, so there is time to read them.
    @Published private(set) var isAwaitingNext: Bool = false

    // MARK: - Answer Shape

    /// Whether the current problem wants a remainder as well as a quotient.
    var wantsRemainder: Bool {
        guard case .quotientRemainder = currentProblem?.answer else { return false }
        return true
    }

    /// Whether there is enough typed in to submit. A remainder problem needs
    /// both fields; everything else needs one. Nothing is submittable while a
    /// revealed answer is still being read.
    var canSubmit: Bool {
        guard !isAwaitingNext else { return false }
        let hasPrimary = !userInput.trimmingCharacters(in: .whitespaces).isEmpty
        guard wantsRemainder else { return hasPrimary }
        return hasPrimary && !userRemainderInput.trimmingCharacters(in: .whitespaces).isEmpty
    }

    // MARK: - Properties

    let lesson: Lesson
    /// The session's problems, pre-generated with no duplicate expressions.
    private let problems: [MathProblem]
    private var problemStartTime: Date = Date()
    private let difficulty: MathEngine.Difficulty

    /// Seconds a right answer's feedback shows before advancing. A miss has no
    /// clock on it — see `isAwaitingNext`.
    private let feedbackDuration: TimeInterval = 1.0

    /// Pending advance work, cancelled if the session is torn down early.
    private var pendingAdvance: DispatchWorkItem?

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

    /// Whether the session result is a passing score (≥ 70% correct).
    var isPassing: Bool {
        guard isSessionComplete, totalProblems > 0 else { return false }
        return Double(correctCount) / Double(totalProblems) >= 0.7
    }

    // MARK: - Initialization

    /// Creates a PracticeViewModel for a specific lesson.
    /// - Parameter lesson: The lesson to practice.
    init(lesson: Lesson) {
        self.lesson = lesson
        self.difficulty = lesson.difficulty
        let engine = MathEngine(
            seed: "\(lesson.id)_practice_\(UUID().uuidString)",
            difficulty: lesson.difficulty,
            operations: lesson.operations,
            pattern: lesson.pattern
        )
        let generated = Self.distinctProblems(count: lesson.practiceCount, from: engine)
        self.problems = generated
        // A concept with fewer distinct problems than `practiceCount` yields a
        // shorter (but repeat-free) session rather than showing the same one twice.
        self.totalProblems = generated.count
        advanceToNextProblem()
    }

    /// Draws up to `count` problems with no duplicate expressions from the engine.
    /// Bounded attempts keep it safe when the concept's pool is small.
    private static func distinctProblems(count: Int, from engine: MathEngine) -> [MathProblem] {
        var result: [MathProblem] = []
        var seen: Set<String> = []
        let maxAttempts = max(count * 20, 40)
        var attempts = 0
        while result.count < count && attempts < maxAttempts {
            attempts += 1
            let problem = engine.nextProblem()
            if seen.insert(problem.displayText).inserted {
                result.append(problem)
            }
        }
        return result
    }

    // MARK: - Actions

    /// Submits the user's answer for the current problem.
    func submitAnswer() {
        guard let problem = currentProblem, !isAwaitingNext else { return }
        let trimmed = userInput.trimmingCharacters(in: .whitespaces)
        // Nonsense is ignored outright rather than graded wrong, so a fumbled
        // keypad does not cost an attempt.
        guard problem.answer.isWellFormed(trimmed) else { return }

        let elapsed = Date().timeIntervalSince(problemStartTime)
        let isCorrect: Bool
        switch problem.answer {
        case let .quotientRemainder(quotient, remainder):
            // Both halves have to land; a right quotient with a wrong
            // remainder means the method was not carried through.
            guard let userQuotient = Int(trimmed),
                  let userRemainder = Int(userRemainderInput.trimmingCharacters(in: .whitespaces))
            else { return }
            isCorrect = userQuotient == quotient && userRemainder == remainder
        case .single, .rational, .decimal, .approximate:
            isCorrect = problem.answer.accepts(trimmed)
        }
        // Only whole-number answers survive the trip into `AnswerResult`;
        // fractions and approximations record as "not a plain number".
        let userAnswer = Int(trimmed)
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
        showFeedback(isCorrect: isCorrect, answer: problem.answer)
        if isCorrect {
            scheduleAdvance()
        } else {
            isAwaitingNext = true
        }
    }

    /// Skips the current problem.
    func skipProblem() {
        guard let problem = currentProblem, !isAwaitingNext else { return }

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
        showFeedback(isCorrect: false, answer: problem.answer)
        // A skip reveals the answer just as a miss does, so it waits too.
        isAwaitingNext = true
    }

    /// Moves past a revealed answer. Only the Next button calls this — right
    /// answers advance on their own.
    func advancePastFeedback() {
        guard isAwaitingNext else { return }
        clearFeedbackAndAdvance()
    }

    // MARK: - Private Helpers

    /// Schedules the move to the next problem after the feedback window,
    /// cancelling any previously scheduled advance.
    private func scheduleAdvance() {
        pendingAdvance?.cancel()
        let work = DispatchWorkItem { [weak self] in
            self?.clearFeedbackAndAdvance()
        }
        pendingAdvance = work
        DispatchQueue.main.asyncAfter(deadline: .now() + feedbackDuration, execute: work)
    }

    /// Advances to the next problem or ends the session.
    private func advanceToNextProblem() {
        guard problemNumber < totalProblems else {
            isSessionComplete = true
            return
        }

        currentProblem = problems[problemNumber]
        problemNumber += 1
        userInput = ""
        userRemainderInput = ""
        problemStartTime = Date()
    }

    /// Shows correct/incorrect feedback temporarily.
    private func showFeedback(isCorrect: Bool, answer: ProblemAnswer) {
        isCorrectFeedback = isCorrect
        feedbackMessage = isCorrect
            ? "Correct! ✓"
            : "Incorrect. The answer is \(answer.displayText)."
    }

    /// Clears feedback and moves to the next problem.
    private func clearFeedbackAndAdvance() {
        pendingAdvance?.cancel()
        pendingAdvance = nil
        feedbackMessage = nil
        isCorrectFeedback = nil
        isAwaitingNext = false
        advanceToNextProblem()
    }
}
