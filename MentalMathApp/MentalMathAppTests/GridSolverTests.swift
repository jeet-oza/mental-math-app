//
//  GridSolverTests.swift
//  MentalMathAppTests
//

import XCTest
@testable import MentalMathApp

final class GridSolverTests: XCTestCase {

    func testAllReturnedSolutionsAreValidAndDeduped() {
        let board = GridBoard.generate(seed: "solver_seed")
        let solutions = GridSolver.solutions(on: board, maxLength: 4)

        // Every solution sums to a multiple of 10 and is connected.
        for s in solutions {
            XCTAssertEqual(s.sum % 10, 0)
            XCTAssertTrue(GridScoring.isConnected(s.positions))
            XCTAssertEqual(s.points, GridScoring.points(for: s.positions, on: board))
        }
        // Deduped by tile-set key.
        XCTAssertEqual(Set(solutions.map(\.id)).count, solutions.count)
    }

    func testFindsKnownCombinations() {
        let board = GridBoard(values: [
            25, 25, 50, 1,
            25, 25, 1,  1,
            1,  1,  1,  1,
            1,  1,  1,  1
        ])
        let solutions = GridSolver.solutions(on: board, maxLength: 4)
        // The four 25s form a connected square summing to 100.
        XCTAssertTrue(solutions.contains { $0.sum == 100 && $0.values.allSatisfy { $0 == 25 } })
        // A multiple-of-10 (not 100) combo exists too: 25 + 25 = 50.
        XCTAssertTrue(solutions.contains { $0.sum == 50 })
    }
}
