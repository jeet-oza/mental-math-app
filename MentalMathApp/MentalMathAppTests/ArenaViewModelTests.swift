//
//  ArenaViewModelTests.swift
//  MentalMathAppTests
//
//  Unit tests for ArenaViewModel.
//

import XCTest
@testable import MentalMathApp

@MainActor
final class ArenaViewModelTests: XCTestCase {

    private var viewModel: ArenaViewModel!

    override func setUp() {
        super.setUp()
        viewModel = ArenaViewModel()
    }

    override func tearDown() {
        viewModel.reset()
        viewModel = nil
        super.tearDown()
    }

    // MARK: - Initial State Tests

    func testInitialPhaseIsWaiting() {
        XCTAssertEqual(viewModel.phase, .waiting)
    }

    func testInitialScoreIsZero() {
        XCTAssertEqual(viewModel.totalScore, 0)
    }

    func testInitialAccuracyText() {
        XCTAssertEqual(viewModel.accuracyText, "—")
    }

    // MARK: - Round Start Tests

    func testStartLocalRoundSetsPlayingPhase() {
        viewModel.startLocalRound(seed: "test_seed")
        XCTAssertEqual(viewModel.phase, .playing)
    }

    func testStartLocalRoundSetsDuration() {
        viewModel.startLocalRound(seed: "test_seed")
        XCTAssertEqual(viewModel.remainingSeconds, 90)
    }

    func testStartLocalRoundGeneratesProblem() {
        viewModel.startLocalRound(seed: "test_seed")
        XCTAssertNotNil(viewModel.currentProblem)
    }

    func testStartRoundResetsState() {
        viewModel.startLocalRound(seed: "seed_1")

        // Answer one question
        if let problem = viewModel.currentProblem {
            viewModel.userInput = String(problem.correctAnswer)
            viewModel.submitAnswer()
        }

        // Start a new round
        viewModel.startLocalRound(seed: "seed_2")
        XCTAssertEqual(viewModel.questionsAnswered, 0)
        XCTAssertEqual(viewModel.totalScore, 0)
        XCTAssertTrue(viewModel.answers.isEmpty)
    }

    // MARK: - Keypad Input Tests

    func testInputDigitsBuildAnswer() {
        viewModel.startLocalRound(seed: "input")
        viewModel.inputDigit(4)
        viewModel.inputDigit(2)
        XCTAssertEqual(viewModel.userInput, "42")
    }

    func testDeleteInputRemovesLastDigit() {
        viewModel.startLocalRound(seed: "input")
        viewModel.inputDigit(4)
        viewModel.inputDigit(2)
        viewModel.deleteInput()
        XCTAssertEqual(viewModel.userInput, "4")
    }

    func testInputIgnoredWhenNotPlaying() {
        viewModel.inputDigit(5) // still waiting
        XCTAssertEqual(viewModel.userInput, "")
    }

    // MARK: - Answer Submission Tests

    func testCorrectAnswerIncrementsScore() {
        viewModel.startLocalRound(seed: "answer_test")
        guard let problem = viewModel.currentProblem else {
            XCTFail("No problem generated")
            return
        }

        viewModel.userInput = String(problem.correctAnswer)
        viewModel.submitAnswer()

        XCTAssertEqual(viewModel.correctCount, 1)
        XCTAssertEqual(viewModel.questionsAnswered, 1)
        XCTAssertGreaterThan(viewModel.totalScore, 0)
    }

    func testIncorrectAnswerDoesNotIncrementScore() {
        viewModel.startLocalRound(seed: "wrong_test")
        guard let problem = viewModel.currentProblem else {
            XCTFail("No problem generated")
            return
        }

        viewModel.userInput = String(problem.correctAnswer + 999)
        viewModel.submitAnswer()

        XCTAssertEqual(viewModel.correctCount, 0)
        XCTAssertEqual(viewModel.questionsAnswered, 1)
        XCTAssertEqual(viewModel.totalScore, 0)
    }

    func testAnswerAdvancesToNextProblem() {
        viewModel.startLocalRound(seed: "advance_test")
        let firstProblem = viewModel.currentProblem

        viewModel.userInput = "0"
        viewModel.submitAnswer()

        XCTAssertNotEqual(viewModel.currentProblem?.displayText, firstProblem?.displayText)
    }

    func testEmptyInputDoesNotSubmit() {
        viewModel.startLocalRound(seed: "empty_test")
        viewModel.userInput = ""
        viewModel.submitAnswer()

        XCTAssertEqual(viewModel.questionsAnswered, 0)
    }

    func testCannotSubmitWhileWaiting() {
        viewModel.userInput = "42"
        viewModel.submitAnswer()

        XCTAssertEqual(viewModel.questionsAnswered, 0)
    }

    // MARK: - Skip Tests

    func testSkipAdvancesToNextProblem() {
        viewModel.startLocalRound(seed: "skip_test")
        let firstProblem = viewModel.currentProblem

        viewModel.skipProblem()

        XCTAssertNotEqual(viewModel.currentProblem?.displayText, firstProblem?.displayText)
        XCTAssertEqual(viewModel.questionsAnswered, 1)
        XCTAssertEqual(viewModel.correctCount, 0)
    }

    func testSkipRecordsAsIncorrect() {
        viewModel.startLocalRound(seed: "skip_record")
        viewModel.skipProblem()

        XCTAssertFalse(viewModel.answers[0].isCorrect)
        XCTAssertTrue(viewModel.answers[0].isSkipped)
    }

    // MARK: - Determinism Tests

    func testSameSeedSameFirstProblem() {
        let vm1 = ArenaViewModel()
        let vm2 = ArenaViewModel()

        vm1.startLocalRound(seed: "determinism_test")
        vm2.startLocalRound(seed: "determinism_test")

        XCTAssertEqual(vm1.currentProblem?.displayText, vm2.currentProblem?.displayText)
    }

    // MARK: - Reset Tests

    func testResetClearsAllState() {
        viewModel.startLocalRound(seed: "reset_test")
        viewModel.userInput = "42"
        viewModel.submitAnswer()
        viewModel.reset()

        XCTAssertEqual(viewModel.phase, .waiting)
        XCTAssertNil(viewModel.currentProblem)
        XCTAssertEqual(viewModel.questionsAnswered, 0)
        XCTAssertEqual(viewModel.totalScore, 0)
        XCTAssertTrue(viewModel.answers.isEmpty)
        XCTAssertTrue(viewModel.leaderboard.isEmpty)
    }

    // MARK: - Accuracy Tests

    func testAccuracyAfterMixedAnswers() {
        viewModel.startLocalRound(seed: "accuracy_test")

        // Answer 2 correct, 1 incorrect
        for i in 0..<3 {
            guard let problem = viewModel.currentProblem else { break }
            if i < 2 {
                viewModel.userInput = String(problem.correctAnswer)
            } else {
                viewModel.userInput = String(problem.correctAnswer + 999)
            }
            viewModel.submitAnswer()
        }

        XCTAssertEqual(viewModel.accuracyText, "66%")
    }
}
