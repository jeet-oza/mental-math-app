//
//  TimedPracticeViewModel.swift
//  Calcathon
//

import Combine
import Foundation

@MainActor
final class TimedPracticeViewModel: ObservableObject {
    @Published private(set) var currentProblem: MathProblem?
    @Published private(set) var currentLesson: Lesson?
    @Published private(set) var secondsRemaining: Int
    @Published private(set) var answers: [TimedPracticeAnswer] = []
    @Published private(set) var isComplete = false
    @Published private(set) var feedbackMessage: String?
    @Published private(set) var isCorrectFeedback: Bool?
    @Published private(set) var isAwaitingCorrection = false
    @Published private(set) var isAwaitingNext = false
    @Published var userInput = ""
    @Published var userRemainderInput = ""

    let plan: TimedPracticePlan

    private var endDate: Date?
    private var problemStartDate = Date()
    private var techniqueEngines: [String: MathEngine] = [:]
    private var rng = SystemRandomNumberGenerator()

    init(plan: TimedPracticePlan) {
        self.plan = plan
        secondsRemaining = plan.durationMinutes * 60
    }

    var answeredCount: Int { answers.filter { !$0.isSkipped }.count }
    var correctCount: Int { answers.filter(\.isCorrect).count }
    var skippedCount: Int { answers.filter(\.isSkipped).count }

    var accuracy: Double {
        guard answeredCount > 0 else { return 0 }
        return Double(correctCount) / Double(answeredCount)
    }

    var accuracyText: String {
        answeredCount == 0 ? "—" : "\(Int((accuracy * 100).rounded()))%"
    }

    var questionsPerMinute: Double {
        Double(answeredCount) / Double(max(plan.durationMinutes, 1))
    }

    var correctPerMinute: Double {
        Double(correctCount) / Double(max(plan.durationMinutes, 1))
    }

    var timeText: String {
        String(format: "%d:%02d", secondsRemaining / 60, secondsRemaining % 60)
    }

    var wantsRemainder: Bool {
        guard case .quotientRemainder = currentProblem?.answer else { return false }
        return true
    }

    var answerMode: AnswerInputMode { currentLesson?.answerMode ?? .integer }

    var canSubmit: Bool {
        let primary = userInput.trimmingCharacters(in: .whitespaces)
        guard !primary.isEmpty else { return false }
        return !wantsRemainder || !userRemainderInput.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var revealedAnswerText: String? {
        isAwaitingNext ? currentProblem?.answer.displayText : nil
    }

    func start(now: Date = Date()) {
        guard endDate == nil, !isComplete, plan.isValid else { return }
        endDate = now.addingTimeInterval(TimeInterval(plan.durationMinutes * 60))
        nextProblem(now: now)
    }

    func updateClock(now: Date = Date()) {
        guard let endDate, !isComplete else { return }
        secondsRemaining = max(0, Int(ceil(endDate.timeIntervalSince(now))))
        if now >= endDate { finish() }
    }

    func submitAnswer(now: Date = Date()) {
        guard let problem = currentProblem, !isComplete else { return }
        let input = userInput.trimmingCharacters(in: .whitespaces)
        guard problem.answer.isWellFormed(input) else { return }

        let isCorrect: Bool
        switch problem.answer {
        case let .quotientRemainder(quotient, remainder):
            guard let enteredQuotient = Int(input),
                  let enteredRemainder = Int(userRemainderInput.trimmingCharacters(in: .whitespaces))
            else { return }
            isCorrect = enteredQuotient == quotient && enteredRemainder == remainder
        case .single, .rational, .decimal, .approximate:
            isCorrect = problem.answer.accepts(input)
        }

        if isAwaitingCorrection {
            isCorrectFeedback = isCorrect
            if isCorrect {
                feedbackMessage = "Corrected—nice recovery!"
                isAwaitingCorrection = false
                isAwaitingNext = true
                Feedback.correct()
            } else {
                feedbackMessage = "Try once more. Open another hint if you need it."
                Feedback.incorrect()
            }
            userInput = ""
            userRemainderInput = ""
            return
        }

        answers.append(TimedPracticeAnswer(
            isCorrect: isCorrect,
            isSkipped: false,
            elapsed: now.timeIntervalSince(problemStartDate)
        ))
        isCorrectFeedback = isCorrect
        if isCorrect {
            feedbackMessage = "Nice!"
            Feedback.correct()
            nextProblem(now: now)
        } else {
            feedbackMessage = "Not yet—use a hint, then correct it."
            isAwaitingCorrection = true
            userInput = ""
            userRemainderInput = ""
            Feedback.incorrect()
        }
    }

    func skip(now: Date = Date()) {
        guard currentProblem != nil, !isComplete else { return }
        if !isAwaitingCorrection, !isAwaitingNext {
            answers.append(TimedPracticeAnswer(
                isCorrect: false,
                isSkipped: true,
                elapsed: now.timeIntervalSince(problemStartDate)
            ))
        }
        feedbackMessage = "Skipped"
        isCorrectFeedback = nil
        nextProblem(now: now)
    }

    func advance(now: Date = Date()) {
        guard isAwaitingNext else { return }
        nextProblem(now: now)
    }

    func restart(now: Date = Date()) {
        answers = []
        isComplete = false
        feedbackMessage = nil
        isCorrectFeedback = nil
        isAwaitingCorrection = false
        isAwaitingNext = false
        userInput = ""
        userRemainderInput = ""
        secondsRemaining = plan.durationMinutes * 60
        endDate = nil
        techniqueEngines = [:]
        start(now: now)
    }

    private func nextProblem(now: Date) {
        isAwaitingCorrection = false
        isAwaitingNext = false
        switch plan.mode {
        case .techniques:
            guard let lesson = plan.lessons.randomElement(using: &rng) else {
                finish()
                return
            }
            currentLesson = lesson
            let engine: MathEngine
            if let existing = techniqueEngines[lesson.id] {
                engine = existing
            } else {
                engine = MathEngine(
                    seed: "\(lesson.id)_timed_\(UUID().uuidString)",
                    difficulty: lesson.difficulty,
                    operations: lesson.operations,
                    pattern: lesson.pattern
                )
                techniqueEngines[lesson.id] = engine
            }
            currentProblem = engine.nextProblem()

        case .open:
            guard let operation = plan.openOperations.randomElement(using: &rng) else {
                finish()
                return
            }
            currentLesson = nil
            currentProblem = TimedProblemFactory.problem(
                operation: operation,
                digits: plan.digits[operation] ?? OperandDigits(),
                using: &rng
            )
        }

        userInput = ""
        userRemainderInput = ""
        problemStartDate = now
    }

    private func finish() {
        isComplete = true
        secondsRemaining = 0
        currentProblem = nil
        currentLesson = nil
        isAwaitingCorrection = false
        isAwaitingNext = false
        endDate = nil
    }
}
