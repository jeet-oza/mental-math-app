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

    /// Path length the solver enumerates (also used for solution display).
    static let solverMaxLength = 6
    /// Target rounds aim for at least this many distinct solutions.
    static let targetMinSolutions = 20

    /// Builds the board and rule for a round together (deterministic per index).
    /// Strategy rotates: multiple-of-10, divisible-by-N, then target sum — and
    /// target rounds use a small-number board engineered to have many solutions.
    static func makeRound(index: Int) -> (board: GridBoard, rule: GridRule) {
        var rng = SeededRandomNumberGenerator(seed: "grid_rule_\(index)")
        switch index % 3 {
        case 0:
            return (GridBoard.generate(seed: "grid_arena_round_\(index)"), .multiple(of: 10))
        case 1:
            let board = GridBoard.generate(seed: "grid_arena_round_\(index)")
            let n = funDivisors[Int.random(in: 0..<funDivisors.count, using: &rng)]
            return (board, .multiple(of: n))
        default:
            return makeTargetRound(index: index)
        }
    }

    /// A target round: tiles 1–20, with a target in 50–100 that has the most
    /// solutions (and at least `targetMinSolutions`). Retries the board until a
    /// well-stocked target is found, falling back to the best available.
    private static func makeTargetRound(index: Int) -> (board: GridBoard, rule: GridRule) {
        var best: (board: GridBoard, target: Int, count: Int)?

        for attempt in 0..<6 {
            let board = GridBoard.generate(seed: "grid_target_\(index)_\(attempt)", range: 1...20)
            let histogram = GridSolver.sumHistogram(on: board, maxLength: solverMaxLength)

            // Pick the in-range sum with the most solutions (tiebreak: smaller).
            if let target = (50...100).sorted(by: {
                let c0 = histogram[$0] ?? 0, c1 = histogram[$1] ?? 0
                return c0 != c1 ? c0 > c1 : $0 < $1
            }).first {
                let count = histogram[target] ?? 0
                if count >= targetMinSolutions {
                    return (board, .target(target))
                }
                if best == nil || count > best!.count {
                    best = (board, target, count)
                }
            }
        }

        let fallback = best ?? (GridBoard.generate(seed: "grid_target_\(index)_0", range: 1...20), 60, 0)
        return (fallback.board, .target(fallback.target))
    }
}
