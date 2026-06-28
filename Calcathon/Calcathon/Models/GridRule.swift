//
//  GridRule.swift
//  Calcathon
//
//  The scoring rule for a Grid Arena round. Each round rotates among a few
//  strategies (deterministic per round index, so everyone gets the same one):
//   - multiple(of: 10)  — the classic "sum to a multiple of 10"
//   - multiple(of: N)   — divisible-by-N (N chosen from a fun set, never 2/3/5)
//   - target(T)         — hit exactly T (always reachable on the board)
//
//  For "multiple" rules, higher multiples earn tier bonuses: ×2 at 5N, ×5 at 10N
//  (e.g. multiple of 11 → 55 is ×2, 110 is ×5).
//

import Foundation

enum GridRule: Equatable, Sendable {
    case multiple(of: Int)
    case target(Int)

    /// Tier multipliers applied to a path's base points.
    static let midMultiplier = 2   // at 5N
    static let highMultiplier = 5  // at 10N

    /// Divisors players find satisfying (excludes the trivial 2, 3, 5).
    static let funDivisors = [4, 6, 7, 8, 9, 11, 12]

    /// Whether a path sum satisfies this rule.
    func isSatisfied(by sum: Int) -> Bool {
        switch self {
        case .multiple(let n): return sum % n == 0
        case .target(let t): return sum == t
        }
    }

    /// Score multiplier for a satisfying sum (1×, 2×, or 5×).
    func multiplier(forSum sum: Int) -> Int {
        switch self {
        case .multiple(let n):
            if sum % (10 * n) == 0 { return Self.highMultiplier }
            if sum % (5 * n) == 0 { return Self.midMultiplier }
            return 1
        case .target:
            return 1
        }
    }

    /// Short rule shown above the grid.
    var headline: String {
        switch self {
        case .multiple(let n): return "Make a multiple of \(n)"
        case .target(let t): return "Hit exactly \(t)"
        }
    }

    /// Bonus-tier hint shown under the headline (nil for target rounds).
    var bonusNote: String? {
        switch self {
        case .multiple(let n): return "\(5 * n) = ×2   ·   \(10 * n) = ×5"
        case .target: return "Longer paths score more"
        }
    }

    // MARK: - Generation

    /// The rule for a round, rotating strategy by index. Target rounds derive a
    /// reachable target from the board so there's always at least one solution.
    static func rule(forRound index: Int, board: GridBoard) -> GridRule {
        var rng = SeededRandomNumberGenerator(seed: "grid_rule_\(index)")
        switch index % 3 {
        case 0:
            return .multiple(of: 10)
        case 1:
            let n = funDivisors[Int.random(in: 0..<funDivisors.count, using: &rng)]
            return .multiple(of: n)
        default:
            return .target(reachableTarget(on: board, using: &rng))
        }
    }

    /// Sum of a short, deterministic connected walk — guaranteed achievable.
    private static func reachableTarget(
        on board: GridBoard,
        using rng: inout SeededRandomNumberGenerator
    ) -> Int {
        let size = GridBoard.size
        var current = GridPosition(row: Int.random(in: 0..<size, using: &rng),
                                   col: Int.random(in: 0..<size, using: &rng))
        var path = [current]
        let length = Int.random(in: 2...3, using: &rng)
        while path.count < length {
            let neighbors = (-1...1).flatMap { dr in (-1...1).compactMap { dc -> GridPosition? in
                guard !(dr == 0 && dc == 0) else { return nil }
                let p = GridPosition(row: current.row + dr, col: current.col + dc)
                return GridBoard.isInBounds(p) && !path.contains(p) ? p : nil
            } }
            guard let next = neighbors.randomElement(using: &rng) else { break }
            path.append(next)
            current = next
        }
        return path.reduce(0) { $0 + board.value(at: $1) }
    }
}
