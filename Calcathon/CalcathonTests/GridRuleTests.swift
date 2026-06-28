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
            switch GridRule.makeRound(index: index).rule {
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

    func testTargetRoundsAreSolvableWithManySolutions() {
        for index in stride(from: 2, through: 32, by: 3) { // target rounds (index % 3 == 2)
            let (board, rule) = GridRule.makeRound(index: index)
            guard case let .target(t) = rule else { continue }
            XCTAssertTrue((50...100).contains(t), "round \(index): target \(t) should be in 50–100")
            XCTAssertTrue(board.values.allSatisfy { (1...20).contains($0) },
                          "round \(index): target board should use 1–20 tiles")
            let count = GridSolver.solutions(on: board, rule: rule,
                                             maxLength: GridRule.solverMaxLength).count
            XCTAssertGreaterThanOrEqual(count, GridRule.targetMinSolutions,
                                        "round \(index): target \(t) has only \(count) solutions")
        }
    }
}
