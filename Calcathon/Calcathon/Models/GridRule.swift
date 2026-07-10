//
//  GridRule.swift
//  Calcathon
//
//  The scoring rule for a Grid Arena round. Each round rotates among a few
//  strategies (deterministic per round index, so everyone gets the same one):
//   - multiple(of: 10)  — the classic "sum to a multiple of 10"
//   - multiple(of: N)   — divisible-by-N (N in 6–20; 11–20 shows a mod hint per tile)
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
    static let funDivisors = Array(6...20)

    /// For "multiple" rounds with a hard-to-eyeball divisor (11–20), the
    /// quick-math hint shown on every tile: the tile's value mod the divisor,
    /// so players can add remainders instead of doing division in their head.
    /// Nil for easy divisors (6–10) and for target rounds.
    func modHint(forTileValue value: Int) -> Int? {
        guard case .multiple(let n) = self, (11...20).contains(n) else { return nil }
        return value % n
    }

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

    /// A target round: tiles 1–20 (capped below the target so every tile is
    /// smaller than the sum you're building), with a target in 10–30. Retries
    /// with a fresh target/board until a well-stocked one is found, falling
    /// back to the best available.
    private static func makeTargetRound(index: Int) -> (board: GridBoard, rule: GridRule) {
        var rng = SeededRandomNumberGenerator(seed: "grid_rule_\(index)")
        var best: (board: GridBoard, target: Int, count: Int)?

        for attempt in 0..<6 {
            let target = Int.random(in: 10...30, using: &rng)
            let maxTile = min(target - 1, 20)
            let board = GridBoard.generate(seed: "grid_target_\(index)_\(attempt)", range: 1...maxTile)
            let count = GridSolver.sumHistogram(on: board, maxLength: solverMaxLength)[target] ?? 0
            if count >= targetMinSolutions {
                return (board, .target(target))
            }
            if best == nil || count > best!.count {
                best = (board, target, count)
            }
        }

        let fallbackTarget = best?.target ?? 15
        let fallbackBoard = best?.board
            ?? GridBoard.generate(seed: "grid_target_\(index)_0", range: 1...(fallbackTarget - 1))
        return (fallbackBoard, .target(fallbackTarget))
    }
}
