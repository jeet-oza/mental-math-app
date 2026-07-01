//
//  GridBoard.swift
//  Calcathon
//
//  Model + scoring for the Grid Arena (a "Number Wordament").
//
//  A 4x4 board of numbers 1–99 is generated deterministically from a round
//  seed so every player faces the same board. Players trace continuous paths
//  of adjacent tiles; a path scores if its sum is a multiple of 10.
//

import Foundation

/// A coordinate on the grid.
struct GridPosition: Hashable, Codable, Sendable {
    let row: Int
    let col: Int
}

/// A 4x4 board of numbers, stored row-major.
struct GridBoard: Equatable, Sendable {
    static let size = 4

    /// 16 values in row-major order.
    let values: [Int]

    /// The number at a position.
    func value(at position: GridPosition) -> Int {
        values[position.row * Self.size + position.col]
    }

    /// Deterministic board for a seed (same seed → same board for everyone).
    /// `range` controls the tile values (smaller ranges yield more combinations
    /// that reach a given target sum).
    static func generate(seed: String, range: ClosedRange<Int> = 1...99) -> GridBoard {
        var rng = SeededRandomNumberGenerator(seed: seed)
        let values = (0..<(size * size)).map { _ in Int.random(in: range, using: &rng) }
        return GridBoard(values: values)
    }

    /// Two distinct positions are adjacent if they touch (incl. diagonals).
    static func areAdjacent(_ a: GridPosition, _ b: GridPosition) -> Bool {
        let dr = abs(a.row - b.row)
        let dc = abs(a.col - b.col)
        return dr <= 1 && dc <= 1 && !(dr == 0 && dc == 0)
    }

    /// Whether a position is on the board.
    static func isInBounds(_ p: GridPosition) -> Bool {
        (0..<size).contains(p.row) && (0..<size).contains(p.col)
    }
}

/// Validation and scoring rules for Grid Arena paths.
enum GridScoring {
    /// Minimum number of tiles a path must contain.
    static let minimumLength = 2

    /// Whether the ordered positions form a continuous, non-repeating path.
    static func isConnected(_ path: [GridPosition]) -> Bool {
        guard Set(path).count == path.count else { return false } // no reuse
        guard path.allSatisfy(GridBoard.isInBounds) else { return false }
        guard path.count >= 2 else { return path.count == 1 }
        for i in 1..<path.count where !GridBoard.areAdjacent(path[i - 1], path[i]) {
            return false
        }
        return true
    }

    /// Sum of the numbers along a path.
    static func sum(of path: [GridPosition], on board: GridBoard) -> Int {
        path.reduce(0) { $0 + board.value(at: $1) }
    }

    /// Whether a path is valid under the round's rule (connected, ≥ min length,
    /// and its sum satisfies the rule).
    static func isValid(_ path: [GridPosition], on board: GridBoard, rule: GridRule) -> Bool {
        guard path.count >= minimumLength, isConnected(path) else { return false }
        return rule.isSatisfied(by: sum(of: path, on: board))
    }

    /// Points for a valid path: n(n+1)/2, scaled by the rule's tier multiplier.
    static func points(for path: [GridPosition], on board: GridBoard, rule: GridRule) -> Int {
        let n = path.count
        let base = n * (n + 1) / 2
        return base * rule.multiplier(forSum: sum(of: path, on: board))
    }

    /// A canonical key for the multiset of *values* on a path, so a combination
    /// counts once no matter which tiles produced it. When a number repeats on
    /// the board (e.g. two 75s), 85 + 75 is the same solution whichever 75 is
    /// chosen — order-independent and cell-independent.
    static func key(for path: [GridPosition], on board: GridBoard) -> String {
        path.map { board.value(at: $0) }.sorted().map(String.init).joined(separator: "-")
    }
}
