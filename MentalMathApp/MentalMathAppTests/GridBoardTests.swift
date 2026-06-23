//
//  GridBoardTests.swift
//  MentalMathAppTests
//
//  Tests for Grid Arena board generation, adjacency, validation, and scoring.
//

import XCTest
@testable import MentalMathApp

final class GridBoardTests: XCTestCase {

    private func pos(_ r: Int, _ c: Int) -> GridPosition { GridPosition(row: r, col: c) }

    // MARK: - Generation

    func testBoardHasSixteenValuesInRange() {
        let board = GridBoard.generate(seed: "round_1")
        XCTAssertEqual(board.values.count, 16)
        XCTAssertTrue(board.values.allSatisfy { (1...99).contains($0) })
    }

    func testGenerationIsDeterministic() {
        XCTAssertEqual(GridBoard.generate(seed: "x").values,
                       GridBoard.generate(seed: "x").values)
        XCTAssertNotEqual(GridBoard.generate(seed: "x").values,
                          GridBoard.generate(seed: "y").values)
    }

    // MARK: - Adjacency

    func testAdjacencyIncludesDiagonals() {
        XCTAssertTrue(GridBoard.areAdjacent(pos(0, 0), pos(1, 1)))
        XCTAssertTrue(GridBoard.areAdjacent(pos(1, 1), pos(0, 1)))
        XCTAssertFalse(GridBoard.areAdjacent(pos(0, 0), pos(0, 2)))
        XCTAssertFalse(GridBoard.areAdjacent(pos(0, 0), pos(0, 0))) // same tile
    }

    // MARK: - Connectivity

    func testConnectedPathRejectsReuseAndGaps() {
        XCTAssertTrue(GridScoring.isConnected([pos(0, 0), pos(0, 1), pos(1, 1)]))
        XCTAssertFalse(GridScoring.isConnected([pos(0, 0), pos(0, 1), pos(0, 0)])) // reuse
        XCTAssertFalse(GridScoring.isConnected([pos(0, 0), pos(0, 2)]))            // gap
    }

    // MARK: - Validation & scoring

    func testValidityRequiresMultipleOfTenAndMinLength() {
        // Board where value = row*4+col+1 won't help; build a custom board.
        let board = GridBoard(values: [
            4, 6, 1, 1,
            1, 1, 1, 1,
            1, 1, 1, 1,
            1, 1, 1, 1
        ])
        // 4 + 6 = 10 → valid, adjacent
        XCTAssertTrue(GridScoring.isValid([pos(0, 0), pos(0, 1)], on: board))
        // single tile (10) — below min length
        let board2 = GridBoard(values: Array(repeating: 10, count: 16))
        XCTAssertFalse(GridScoring.isValid([pos(0, 0)], on: board2))
    }

    func testPointsFormulaAndHundredBonus() {
        // Path of 4 tiles summing to 100 → 4*5/2 = 10, + 20 bonus = 30
        let board = GridBoard(values: [
            25, 25, 1, 1,
            25, 25, 1, 1,
            1,  1,  1, 1,
            1,  1,  1, 1
        ])
        let square = [pos(0, 0), pos(0, 1), pos(1, 1), pos(1, 0)]
        XCTAssertTrue(GridScoring.isValid(square, on: board))
        XCTAssertEqual(GridScoring.sum(of: square, on: board), 100)
        XCTAssertEqual(GridScoring.points(for: square, on: board), 10 + 20)

        // Path of 3 tiles summing to 30 (mult of 10, not 100) → 3*4/2 = 6
        let board2 = GridBoard(values: [
            10, 10, 10, 1,
            1,  1,  1,  1,
            1,  1,  1,  1,
            1,  1,  1,  1
        ])
        let line = [pos(0, 0), pos(0, 1), pos(0, 2)]
        XCTAssertEqual(GridScoring.points(for: line, on: board2), 6)
    }

    func testKeyIsOrderIndependent() {
        let a = GridScoring.key(for: [pos(0, 0), pos(0, 1), pos(1, 1)])
        let b = GridScoring.key(for: [pos(1, 1), pos(0, 1), pos(0, 0)])
        XCTAssertEqual(a, b)
    }
}
