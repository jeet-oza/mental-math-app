//
//  GridArenaStatsTests.swift
//  MentalMathAppTests
//

import XCTest
@testable import MentalMathApp

final class GridArenaStatsTests: XCTestCase {

    func testRecordAccumulatesAndTracksMaxima() {
        var stats = GridArenaStats()
        stats.record(gameScore: 30, pathsFound: 4, longestPathThisGame: 3, hundredsThisGame: 1)
        stats.record(gameScore: 50, pathsFound: 6, longestPathThisGame: 5, hundredsThisGame: 2)

        XCTAssertEqual(stats.gamesPlayed, 2)
        XCTAssertEqual(stats.totalScore, 80)
        XCTAssertEqual(stats.bestGameScore, 50)
        XCTAssertEqual(stats.totalPathsFound, 10)
        XCTAssertEqual(stats.longestPath, 5)
        XCTAssertEqual(stats.hundredsFound, 3)
        XCTAssertEqual(stats.averageScore, 40)
    }

    func testMergeTakesElementWiseMax() {
        let a = GridArenaStats(gamesPlayed: 3, totalScore: 100, bestGameScore: 40,
                               totalPathsFound: 12, longestPath: 4, hundredsFound: 2)
        let b = GridArenaStats(gamesPlayed: 2, totalScore: 150, bestGameScore: 30,
                               totalPathsFound: 9, longestPath: 6, hundredsFound: 5)
        let merged = a.merged(with: b)
        XCTAssertEqual(merged.gamesPlayed, 3)
        XCTAssertEqual(merged.totalScore, 150)
        XCTAssertEqual(merged.bestGameScore, 40)
        XCTAssertEqual(merged.totalPathsFound, 12)
        XCTAssertEqual(merged.longestPath, 6)
        XCTAssertEqual(merged.hundredsFound, 5)
    }
}
