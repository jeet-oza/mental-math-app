//
//  GridBoard.swift
//  MentalMathApp
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
    static func generate(seed: String) -> GridBoard {
        var rng = SeededRandomNumberGenerator(seed: seed)
        let values = (0..<(size * size)).map { _ in Int.random(in: 1...99, using: &rng) }
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
    /// Bonus awarded when a path sums to a multiple of 100.
    static let hundredBonus = 20
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

    /// Whether a path is a valid scoring path (connected, ≥ min length, sum % 10 == 0).
    static func isValid(_ path: [GridPosition], on board: GridBoard) -> Bool {
        guard path.count >= minimumLength, isConnected(path) else { return false }
        return sum(of: path, on: board) % 10 == 0
    }

    /// Points for a valid path: n(n+1)/2, plus a bonus if the sum is a multiple of 100.
    static func points(for path: [GridPosition], on board: GridBoard) -> Int {
        let n = path.count
        var points = n * (n + 1) / 2
        if sum(of: path, on: board) % 100 == 0 { points += hundredBonus }
        return points
    }

    /// A canonical key for a path's tile set, so the same tiles can't be farmed
    /// repeatedly within a round (order-independent).
    static func key(for path: [GridPosition]) -> String {
        path.map { "\($0.row)\($0.col)" }.sorted().joined(separator: "-")
    }
}
