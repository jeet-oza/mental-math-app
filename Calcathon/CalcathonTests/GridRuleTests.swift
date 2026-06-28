//
//  GridRuleTests.swift
//  CalcathonTests
//

import XCTest
@testable import Calcathon

final class GridRuleTests: XCTestCase {

    func testMultipleValidityAndTiers() {
        let rule = GridRule.multiple(of: 11)
        XCTAssertTrue(rule.isSatisfied(by: 22))
        XCTAssertFalse(rule.isSatisfied(by: 23))
        XCTAssertEqual(rule.multiplier(forSum: 22), 1)    // multiple of 11
        XCTAssertEqual(rule.multiplier(forSum: 55), 2)    // 5 × 11
        XCTAssertEqual(rule.multiplier(forSum: 110), 5)   // 10 × 11
    }

    func testTargetValidity() {
        let rule = GridRule.target(47)
        XCTAssertTrue(rule.isSatisfied(by: 47))
        XCTAssertFalse(rule.isSatisfied(by: 48))
        XCTAssertEqual(rule.multiplier(forSum: 47), 1)
    }

    func testRotatesAndNeverPicksTrivialDivisors() {
        var sawMultiple10 = false, sawDivisor = false, sawTarget = false
        for index in 0..<30 {
            let board = GridBoard.generate(seed: "grid_arena_round_\(index)")
            switch GridRule.rule(forRound: index, board: board) {
            case .multiple(let n) where n == 10: sawMultiple10 = true
            case .multiple(let n):
                sawDivisor = true
                XCTAssertFalse([2, 3, 5].contains(n), "must not use trivial divisor \(n)")
                XCTAssertTrue(GridRule.funDivisors.contains(n))
            case .target: sawTarget = true
            }
        }
        XCTAssertTrue(sawMultiple10 && sawDivisor && sawTarget, "all strategies should appear")
    }

    func testTargetIsReachableOnBoard() {
        for index in stride(from: 2, through: 32, by: 3) { // target rounds (index % 3 == 2)
            let board = GridBoard.generate(seed: "grid_arena_round_\(index)")
            guard case let .target(t) = GridRule.rule(forRound: index, board: board) else { continue }
            let solutions = GridSolver.solutions(on: board, rule: .target(t), maxLength: 5)
            XCTAssertFalse(solutions.isEmpty, "target \(t) (round \(index)) should be reachable")
        }
    }
}
