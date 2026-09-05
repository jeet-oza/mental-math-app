import XCTest
@testable import Calcathon

@MainActor
final class TimedProblemFactoryTests: XCTestCase {
    func testDigitRangesMatchSelection() {
        var rng = SeededRandomNumberGenerator(seed: "digit-ranges")
        for _ in 0..<100 {
            let problem = TimedProblemFactory.problem(
                operation: .multiplication,
                digits: OperandDigits(first: 3, second: 2),
                using: &rng
            )
            XCTAssertTrue(100...999 ~= problem.operandA)
            XCTAssertTrue(10...99 ~= problem.operandB)
        }
    }

    func testOpenSubtractionNeverGoesNegative() {
        var rng = SeededRandomNumberGenerator(seed: "subtraction")
        for _ in 0..<100 {
            let problem = TimedProblemFactory.problem(
                operation: .subtraction,
                digits: OperandDigits(first: 1, second: 3),
                using: &rng
            )
            XCTAssertGreaterThanOrEqual(problem.correctAnswer, 0)
        }
    }

    func testDivisionUsesSelectedAnswerAndDivisorSizes() {
        var rng = SeededRandomNumberGenerator(seed: "division")
        for _ in 0..<100 {
            let problem = TimedProblemFactory.problem(
                operation: .division,
                digits: OperandDigits(first: 2, second: 1),
                using: &rng
            )
            XCTAssertTrue(10...99 ~= problem.correctAnswer)
            XCTAssertTrue(1...9 ~= problem.operandB)
            XCTAssertEqual(problem.operandA % problem.operandB, 0)
        }
    }
}

@MainActor
final class TimedPracticeViewModelTests: XCTestCase {
    private var openPlan: TimedPracticePlan {
        TimedPracticePlan(
            mode: .open,
            durationMinutes: 1,
            lessons: [],
            openOperations: [.addition],
            digits: [.addition: OperandDigits(first: 1, second: 1)]
        )
    }

    func testSessionReportsQuestionsPerMinute() {
        let viewModel = TimedPracticeViewModel(plan: openPlan)
        let start = Date(timeIntervalSince1970: 1_000)
        viewModel.start(now: start)

        let answer = try! XCTUnwrap(viewModel.currentProblem?.answer.displayText)
        viewModel.userInput = answer
        viewModel.submitAnswer(now: start.addingTimeInterval(2))
        viewModel.updateClock(now: start.addingTimeInterval(60))

        XCTAssertTrue(viewModel.isComplete)
        XCTAssertEqual(viewModel.answeredCount, 1)
        XCTAssertEqual(viewModel.correctCount, 1)
        XCTAssertEqual(viewModel.questionsPerMinute, 1, accuracy: 0.001)
        XCTAssertEqual(viewModel.correctPerMinute, 1, accuracy: 0.001)
    }

    func testSkippedQuestionsAreReportedButNotCountedAsSolved() {
        let viewModel = TimedPracticeViewModel(plan: openPlan)
        let start = Date(timeIntervalSince1970: 2_000)
        viewModel.start(now: start)
        viewModel.skip(now: start.addingTimeInterval(1))
        viewModel.updateClock(now: start.addingTimeInterval(60))

        XCTAssertEqual(viewModel.skippedCount, 1)
        XCTAssertEqual(viewModel.answeredCount, 0)
        XCTAssertEqual(viewModel.questionsPerMinute, 0, accuracy: 0.001)
    }

    func testTechniqueModeUsesOnlySelectedLesson() {
        let lesson = LessonCatalog.basicAdditionGroup.lessons[0]
        let plan = TimedPracticePlan(
            mode: .techniques,
            durationMinutes: 1,
            lessons: [lesson],
            openOperations: [],
            digits: [:]
        )
        let viewModel = TimedPracticeViewModel(plan: plan)

        viewModel.start(now: Date(timeIntervalSince1970: 3_000))

        XCTAssertEqual(viewModel.currentLesson?.id, lesson.id)
        XCTAssertEqual(viewModel.currentProblem?.operation, .addition)
    }

    func testIncorrectAnswerStaysAvailableForCorrection() {
        let viewModel = TimedPracticeViewModel(plan: openPlan)
        let start = Date(timeIntervalSince1970: 4_000)
        viewModel.start(now: start)

        let firstProblem = try! XCTUnwrap(viewModel.currentProblem)
        viewModel.userInput = "\(firstProblem.answer.primary + 1)"
        viewModel.submitAnswer(now: start.addingTimeInterval(2))

        XCTAssertEqual(viewModel.currentProblem?.id, firstProblem.id)
        XCTAssertTrue(viewModel.isAwaitingCorrection)
        XCTAssertFalse(viewModel.isAwaitingNext)
        XCTAssertEqual(viewModel.answeredCount, 1)
        XCTAssertEqual(viewModel.correctCount, 0)

        viewModel.userInput = firstProblem.answer.displayText
        viewModel.submitAnswer(now: start.addingTimeInterval(4))

        XCTAssertFalse(viewModel.isAwaitingCorrection)
        XCTAssertTrue(viewModel.isAwaitingNext)
        XCTAssertEqual(viewModel.revealedAnswerText, firstProblem.answer.displayText)
        XCTAssertEqual(viewModel.currentProblem?.id, firstProblem.id)

        viewModel.advance(now: start.addingTimeInterval(5))
        XCTAssertNotEqual(viewModel.currentProblem?.id, firstProblem.id)
    }

    func testMovingOnAfterAMissDoesNotDoubleCountIt() {
        let viewModel = TimedPracticeViewModel(plan: openPlan)
        let start = Date(timeIntervalSince1970: 5_000)
        viewModel.start(now: start)

        let problem = try! XCTUnwrap(viewModel.currentProblem)
        viewModel.userInput = "\(problem.answer.primary + 1)"
        viewModel.submitAnswer(now: start.addingTimeInterval(1))
        viewModel.skip(now: start.addingTimeInterval(2))

        XCTAssertEqual(viewModel.answeredCount, 1)
        XCTAssertEqual(viewModel.skippedCount, 0)
    }
}
