//
//  ArenaScheduleTests.swift
//  CalcathonTests
//
//  Verifies the wall-clock-derived global Arena schedule.
//

import XCTest
@testable import Calcathon

final class ArenaScheduleTests: XCTestCase {

    private func date(secondsAfterEpoch offset: Int) -> Date {
        ArenaSchedule.epoch.addingTimeInterval(Double(offset))
    }

    func testStartOfCycleIsPlayingFullDuration() {
        guard case let .playing(index, remaining) = ArenaSchedule.phase(at: date(secondsAfterEpoch: 0)) else {
            return XCTFail("Expected playing at cycle start")
        }
        XCTAssertEqual(index, 0)
        XCTAssertEqual(remaining, ArenaSchedule.playDuration)
    }

    func testMidPlayHasReducedRemaining() {
        guard case let .playing(_, remaining) = ArenaSchedule.phase(at: date(secondsAfterEpoch: 30)) else {
            return XCTFail("Expected playing mid-round")
        }
        XCTAssertEqual(remaining, ArenaSchedule.playDuration - 30)
    }

    func testAfterPlayWindowIsIntermission() {
        guard case let .intermission(nextIndex, startsIn) = ArenaSchedule.phase(at: date(secondsAfterEpoch: 100)) else {
            return XCTFail("Expected intermission after 90s")
        }
        XCTAssertEqual(nextIndex, 1)
        XCTAssertEqual(startsIn, ArenaSchedule.cycle - 100)
    }

    func testRoundIndexAdvancesEveryCycle() {
        guard case let .playing(index, _) = ArenaSchedule.phase(at: date(secondsAfterEpoch: ArenaSchedule.cycle * 5 + 10)) else {
            return XCTFail("Expected playing in 6th round")
        }
        XCTAssertEqual(index, 5)
    }

    func testSeedIsStablePerRound() {
        XCTAssertEqual(ArenaSchedule.seed(forRound: 7), ArenaSchedule.seed(forRound: 7))
        XCTAssertNotEqual(ArenaSchedule.seed(forRound: 7), ArenaSchedule.seed(forRound: 8))
    }

    func testOpponentsDeterministicPerRound() {
        let a = ArenaSchedule.opponents(forRound: 3, mode: .equation)
        let b = ArenaSchedule.opponents(forRound: 3, mode: .equation)
        XCTAssertEqual(a, b)
        XCTAssertFalse(a.isEmpty)
    }

    func testEquationAndGridBotsDiffer() {
        let eq = ArenaSchedule.opponents(forRound: 5, mode: .equation)
        let grid = ArenaSchedule.opponents(forRound: 5, mode: .grid)
        XCTAssertNotEqual(eq.map(\.score), grid.map(\.score))
    }

    func testBotScoresAreInRealisticRanges() {
        // Equation: 3–20 solves, each base 3..12 × up to 1.6 → ≤ 19 per solve.
        for bot in ArenaSchedule.opponents(forRound: 1, mode: .equation) {
            XCTAssertGreaterThanOrEqual(bot.score, 3 * 3)
            XCTAssertLessThanOrEqual(bot.score, 20 * 19)
        }
        // Grid: 5–35 solves, each ≤ 15 (len 5), doubled → ≤ 30 per solve.
        for bot in ArenaSchedule.opponents(forRound: 1, mode: .grid) {
            XCTAssertGreaterThanOrEqual(bot.score, 5 * 3)
            XCTAssertLessThanOrEqual(bot.score, 35 * 30)
        }
    }
}
