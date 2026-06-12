//
//  ArenaRoundTests.swift
//  MentalMathAppTests
//
//  Unit tests for Arena mode models.
//

import XCTest
@testable import MentalMathApp

final class ArenaRoundTests: XCTestCase {

    // MARK: - ArenaRound Tests

    func testRoundIsActiveWithinDuration() {
        let start = Date()
        let round = ArenaRound(
            roundId: "r1",
            seed: "test",
            difficulty: .easy,
            durationSeconds: 90,
            startTimestamp: start
        )
        // Check at 45 seconds in (midway)
        let midpoint = start.addingTimeInterval(45)
        XCTAssertTrue(round.isActive(at: midpoint))
    }

    func testRoundIsNotActiveAfterExpiry() {
        let start = Date()
        let round = ArenaRound(
            roundId: "r1",
            seed: "test",
            difficulty: .easy,
            durationSeconds: 90,
            startTimestamp: start
        )
        let afterExpiry = start.addingTimeInterval(91)
        XCTAssertFalse(round.isActive(at: afterExpiry))
    }

    func testRoundIsNotActiveBeforeStart() {
        let start = Date()
        let round = ArenaRound(
            roundId: "r1",
            seed: "test",
            difficulty: .easy,
            durationSeconds: 90,
            startTimestamp: start
        )
        let beforeStart = start.addingTimeInterval(-5)
        XCTAssertFalse(round.isActive(at: beforeStart))
    }

    func testRemainingSecondsAtMidpoint() {
        let start = Date()
        let round = ArenaRound(
            roundId: "r1",
            seed: "test",
            difficulty: .easy,
            durationSeconds: 90,
            startTimestamp: start
        )
        let midpoint = start.addingTimeInterval(30)
        XCTAssertEqual(round.remainingSeconds(at: midpoint), 60)
    }

    func testRemainingSecondsAtExpiry() {
        let start = Date()
        let round = ArenaRound(
            roundId: "r1",
            seed: "test",
            difficulty: .easy,
            durationSeconds: 90,
            startTimestamp: start
        )
        let afterExpiry = start.addingTimeInterval(100)
        XCTAssertEqual(round.remainingSeconds(at: afterExpiry), 0)
    }

    // MARK: - ArenaScore Tests

    func testAccuracyCalculation() {
        let score = ArenaScore(
            roundId: "r1",
            userId: "u1",
            totalScore: 500,
            correctCount: 8,
            skippedCount: 2,
            totalAttempted: 10,
            timeTakenSeconds: 80
        )
        XCTAssertEqual(score.accuracy, 0.8)
    }

    func testAccuracyWithZeroAttempts() {
        let score = ArenaScore(
            roundId: "r1",
            userId: "u1",
            totalScore: 0,
            correctCount: 0,
            skippedCount: 0,
            totalAttempted: 0,
            timeTakenSeconds: 0
        )
        XCTAssertEqual(score.accuracy, 0)
    }

    func testAverageTimePerCorrect() {
        let score = ArenaScore(
            roundId: "r1",
            userId: "u1",
            totalScore: 300,
            correctCount: 6,
            skippedCount: 0,
            totalAttempted: 6,
            timeTakenSeconds: 60
        )
        XCTAssertEqual(score.averageTimePerCorrect, 10.0)
    }

    func testAverageTimePerCorrectZeroCorrect() {
        let score = ArenaScore(
            roundId: "r1",
            userId: "u1",
            totalScore: 0,
            correctCount: 0,
            skippedCount: 5,
            totalAttempted: 5,
            timeTakenSeconds: 30
        )
        XCTAssertEqual(score.averageTimePerCorrect, 0)
    }
}
