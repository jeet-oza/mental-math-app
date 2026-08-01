//
//  PracticeViewModelTests.swift
//  CalcathonTests
//
//  Unit tests for PracticeViewModel.
//

import XCTest
@testable import Calcathon

@MainActor
final class PracticeViewModelTests: XCTestCase {

    private func makeSampleLesson(practiceCount: Int = 5) -> Lesson {
        Lesson(
            id: "test_lesson",
            title: "Test",
            description: "Test lesson",
            trick: MathTrick(
                name: "Test Trick",
                steps: ["Step 1"],
                example: TrickExample(
                    problem: "1 + 1",
                    solution: "2",
                    stepByStepExplanation: ["1 + 1 = 2"]
                )
            ),
            operations: [.addition],
            difficulty: .easy,
            practiceCount: practiceCount
        )
    }

    // MARK: - Initialization Tests

    func testInitialState() {
        let vm = PracticeViewModel(lesson: makeSampleLesson())
        XCTAssertNotNil(vm.currentProblem)
        XCTAssertEqual(vm.problemNumber, 1)
        XCTAssertEqual(vm.totalProblems, 5)
        XCTAssertFalse(vm.isSessionComplete)
        XCTAssertTrue(vm.answers.isEmpty)
    }

    func testInitialAccuracyText() {
        let vm = PracticeViewModel(lesson: makeSampleLesson())
        XCTAssertEqual(vm.accuracyText, "—")
    }

    // MARK: - No-Repeat Tests

    func testLargePoolSessionKeepsFullLength() {
        // "Adding 9" draws from a large pool, so all 10 questions fit distinctly.
        let lesson = LessonCatalog.basicAdditionGroup.lessons.first { $0.id == "add_9" }!
        let vm = PracticeViewModel(lesson: lesson)
        XCTAssertEqual(vm.totalProblems, lesson.practiceCount)
    }

    func testTinyPoolSessionShrinksInsteadOfRepeating() {
        // Squares ending in 5 has only 9 distinct problems (15²…95²), so a
        // 10-question request must shrink to 9 rather than repeat one.
        let lesson = LessonCatalog.squaringShortcutsGroup.lessons.first { $0.id == "sq_ends5" }!
        let vm = PracticeViewModel(lesson: lesson)
        XCTAssertEqual(vm.totalProblems, 9)
    }

    // MARK: - Answer Submission Tests

    func testCorrectAnswerRecorded() {
        let vm = PracticeViewModel(lesson: makeSampleLesson())
        guard let problem = vm.currentProblem else {
            XCTFail("No problem available")
            return
        }

        vm.userInput = String(problem.correctAnswer)
        vm.submitAnswer()

        XCTAssertEqual(vm.answers.count, 1)
        XCTAssertTrue(vm.answers[0].isCorrect)
        XCTAssertEqual(vm.correctCount, 1)
    }

    func testIncorrectAnswerRecorded() {
        let vm = PracticeViewModel(lesson: makeSampleLesson())
        guard let problem = vm.currentProblem else {
            XCTFail("No problem available")
            return
        }

        vm.userInput = String(problem.correctAnswer + 999)
        vm.submitAnswer()

        XCTAssertEqual(vm.answers.count, 1)
        XCTAssertFalse(vm.answers[0].isCorrect)
        XCTAssertEqual(vm.correctCount, 0)
    }

    func testEmptyInputDoesNotSubmit() {
        let vm = PracticeViewModel(lesson: makeSampleLesson())
        vm.userInput = ""
        vm.submitAnswer()

        XCTAssertTrue(vm.answers.isEmpty)
    }

    func testNonNumericInputDoesNotSubmit() {
        let vm = PracticeViewModel(lesson: makeSampleLesson())
        vm.userInput = "abc"
        vm.submitAnswer()

        XCTAssertTrue(vm.answers.isEmpty)
    }

    // MARK: - Skip Tests

    func testSkipRecordsAsIncorrect() {
        let vm = PracticeViewModel(lesson: makeSampleLesson())
        vm.skipProblem()

        XCTAssertEqual(vm.answers.count, 1)
        XCTAssertFalse(vm.answers[0].isCorrect)
        XCTAssertTrue(vm.answers[0].isSkipped)
    }

    func testSkipUserAnswerIsNil() {
        let vm = PracticeViewModel(lesson: makeSampleLesson())
        vm.skipProblem()

        XCTAssertNil(vm.answers[0].userAnswer)
    }

    // MARK: - Score Tests

    func testTotalScoreStartsAtZero() {
        let vm = PracticeViewModel(lesson: makeSampleLesson())
        XCTAssertEqual(vm.totalScore, 0)
    }

    func testTotalScoreIncreasesOnCorrectAnswer() {
        let vm = PracticeViewModel(lesson: makeSampleLesson())
        guard let problem = vm.currentProblem else { return }

        vm.userInput = String(problem.correctAnswer)
        vm.submitAnswer()

        XCTAssertGreaterThan(vm.totalScore, 0)
    }

    // MARK: - Feedback Tests

    func testFeedbackShownAfterSubmit() {
        let vm = PracticeViewModel(lesson: makeSampleLesson())
        guard let problem = vm.currentProblem else { return }

        vm.userInput = String(problem.correctAnswer)
        vm.submitAnswer()

        XCTAssertNotNil(vm.feedbackMessage)
        XCTAssertEqual(vm.isCorrectFeedback, true)
    }

    func testIncorrectFeedbackShowsAnswer() {
        let vm = PracticeViewModel(lesson: makeSampleLesson())
        guard let problem = vm.currentProblem else { return }

        vm.userInput = String(problem.correctAnswer + 999)
        vm.submitAnswer()

        XCTAssertNotNil(vm.feedbackMessage)
        XCTAssertEqual(vm.isCorrectFeedback, false)
        XCTAssertTrue(vm.feedbackMessage?.contains(String(problem.correctAnswer)) ?? false)
    }

    // MARK: - Waiting on Next

    func testMissHoldsTheQuestionUntilNext() {
        let vm = PracticeViewModel(lesson: makeSampleLesson())
        guard let problem = vm.currentProblem else { return }

        vm.userInput = String(problem.correctAnswer + 999)
        vm.submitAnswer()

        XCTAssertTrue(vm.isAwaitingNext)
        XCTAssertEqual(vm.problemNumber, 1)
        XCTAssertEqual(vm.currentProblem?.id, problem.id)
        XCTAssertFalse(vm.canSubmit)
    }

    func testCorrectAnswerDoesNotWaitOnNext() {
        let vm = PracticeViewModel(lesson: makeSampleLesson())
        guard let problem = vm.currentProblem else { return }

        vm.userInput = String(problem.correctAnswer)
        vm.submitAnswer()

        XCTAssertFalse(vm.isAwaitingNext)
    }

    func testNextMovesOnAndClearsFeedback() {
        let vm = PracticeViewModel(lesson: makeSampleLesson())
        guard let problem = vm.currentProblem else { return }

        vm.userInput = String(problem.correctAnswer + 999)
        vm.submitAnswer()
        vm.advancePastFeedback()

        XCTAssertFalse(vm.isAwaitingNext)
        XCTAssertNil(vm.feedbackMessage)
        XCTAssertNil(vm.isCorrectFeedback)
        XCTAssertEqual(vm.problemNumber, 2)
        XCTAssertEqual(vm.userInput, "")
    }

    func testSkipWaitsOnNext() {
        let vm = PracticeViewModel(lesson: makeSampleLesson())
        vm.skipProblem()

        XCTAssertTrue(vm.isAwaitingNext)
        XCTAssertEqual(vm.problemNumber, 1)
    }

    func testSecondSubmitIgnoredWhileAnswerIsRevealed() {
        let vm = PracticeViewModel(lesson: makeSampleLesson())
        guard let problem = vm.currentProblem else { return }

        vm.userInput = String(problem.correctAnswer + 999)
        vm.submitAnswer()
        vm.userInput = String(problem.correctAnswer)
        vm.submitAnswer()
        vm.skipProblem()

        XCTAssertEqual(vm.answers.count, 1)
    }

    func testNextDoesNothingWithoutARevealedAnswer() {
        let vm = PracticeViewModel(lesson: makeSampleLesson())
        vm.advancePastFeedback()

        XCTAssertEqual(vm.problemNumber, 1)
        XCTAssertTrue(vm.answers.isEmpty)
    }
}
