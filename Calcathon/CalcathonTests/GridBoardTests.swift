//
//  GridBoardTests.swift
//  CalcathonTests
//
//  Tests for Grid Arena board generation, adjacency, validation, and scoring.
//

import XCTest
@testable import Calcathon

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
        XCTAssertTrue(GridScoring.isValid([pos(0, 0), pos(0, 1)], on: board, rule: .multiple(of: 10)))
        // single tile (10) — below min length
        let board2 = GridBoard(values: Array(repeating: 10, count: 16))
        XCTAssertFalse(GridScoring.isValid([pos(0, 0)], on: board2, rule: .multiple(of: 10)))
    }

    func testPointsFormulaAndMultipliers() {
        // Path of 4 tiles summing to 100 → 4*5/2 = 10, ×5 = 50
        let board = GridBoard(values: [
            25, 25, 1, 1,
            25, 25, 1, 1,
            1,  1,  1, 1,
            1,  1,  1, 1
        ])
        let square = [pos(0, 0), pos(0, 1), pos(1, 1), pos(1, 0)]
        XCTAssertTrue(GridScoring.isValid(square, on: board, rule: .multiple(of: 10)))
        XCTAssertEqual(GridScoring.sum(of: square, on: board), 100)
        XCTAssertEqual(GridScoring.points(for: square, on: board, rule: .multiple(of: 10)), 10 * 5)

        // Path summing to 50 (not 100) → ×2: 20 + 30, base 3 → 6
        let board50 = GridBoard(values: [
            20, 30, 1, 1,
            1,  1,  1, 1,
            1,  1,  1, 1,
            1,  1,  1, 1
        ])
        let pair = [pos(0, 0), pos(0, 1)]
        XCTAssertEqual(GridScoring.sum(of: pair, on: board50), 50)
        XCTAssertEqual(GridScoring.points(for: pair, on: board50, rule: .multiple(of: 10)), 3 * 2)

        // Path of 3 tiles summing to 30 (mult of 10, not 50/100) → 3*4/2 = 6
        let board2 = GridBoard(values: [
            10, 10, 10, 1,
            1,  1,  1,  1,
            1,  1,  1,  1,
            1,  1,  1,  1
        ])
        let line = [pos(0, 0), pos(0, 1), pos(0, 2)]
        XCTAssertEqual(GridScoring.points(for: line, on: board2, rule: .multiple(of: 10)), 6)
    }

    func testKeyIsOrderIndependent() {
        let board = GridBoard(values: [
            10, 20, 30, 1,
            40, 50, 60, 1,
            1,  1,  1,  1,
            1,  1,  1,  1
        ])
        let a = GridScoring.key(for: [pos(0, 0), pos(0, 1), pos(1, 1)], on: board)
        let b = GridScoring.key(for: [pos(1, 1), pos(0, 1), pos(0, 0)], on: board)
        XCTAssertEqual(a, b)
    }

    /// Two paths over different cells that hold the same numbers share a key,
    /// so a repeated board value can't be farmed for duplicate credit.
    func testKeyIsValueBasedNotCellBased() {
        let board = GridBoard(values: [
            85, 75, 75, 1,
            1,  1,  1,  1,
            1,  1,  1,  1,
            1,  1,  1,  1
        ])
        let first85plus75 = GridScoring.key(for: [pos(0, 0), pos(0, 1)], on: board)
        let second85plus75 = GridScoring.key(for: [pos(0, 0), pos(0, 2)], on: board)
        XCTAssertEqual(first85plus75, second85plus75)
    }
}
