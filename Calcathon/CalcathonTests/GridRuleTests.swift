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

    /// A target round has to be reachable plenty of ways, or players stare at
    /// a board with nothing to find. The bounds come from `GridRule` rather
    /// than being written out here: this test previously hard-coded a range
    /// the generator did not use, so it failed on every round while looking
    /// like it was checking something real.
    func testTargetRoundsAreSolvableWithManySolutions() {
        for index in stride(from: 2, through: 32, by: 3) { // target rounds (index % 3 == 2)
            let (board, rule) = GridRule.makeRound(index: index)
            guard case let .target(t) = rule else {
                return XCTFail("round \(index) should be a target round, got \(rule)")
            }
            XCTAssertTrue(
                GridRule.targetRange.contains(t),
                "round \(index): target \(t) is outside \(GridRule.targetRange)"
            )
            XCTAssertTrue(
                board.values.allSatisfy { GridRule.targetTileRange.contains($0) },
                "round \(index): board uses tiles outside \(GridRule.targetTileRange)"
            )
            let count = GridSolver.solutions(on: board, rule: rule,
                                             maxLength: GridRule.solverMaxLength).count
            XCTAssertGreaterThanOrEqual(count, GridRule.targetMinSolutions,
                                        "round \(index): target \(t) has only \(count) solutions")
        }
    }

    /// The guarantee is meant to hold for every round, not just the first few,
    /// and the generator now picks the target from the board's own reachable
    /// sums — so a shortfall would mean the selection logic is wrong rather
    /// than that one seed was unlucky.
    func testTargetGuaranteeHoldsAcrossManyRounds() {
        for index in stride(from: 2, through: 122, by: 3) {
            let (board, rule) = GridRule.makeRound(index: index)
            guard case let .target(t) = rule else { continue }
            let count = GridSolver.sumHistogram(
                on: board, maxLength: GridRule.solverMaxLength
            )[t] ?? 0
            XCTAssertGreaterThanOrEqual(
                count, GridRule.targetMinSolutions,
                "round \(index): target \(t) has only \(count) solutions"
            )
        }
    }

    /// Same seed, same round, for everyone — the whole Arena depends on it.
    func testTargetRoundsAreDeterministic() {
        for index in stride(from: 2, through: 20, by: 3) {
            let first = GridRule.makeRound(index: index)
            let second = GridRule.makeRound(index: index)
            XCTAssertEqual(first.board, second.board, "round \(index) board drifted")
            XCTAssertEqual(first.rule, second.rule, "round \(index) rule drifted")
        }
    }
}
