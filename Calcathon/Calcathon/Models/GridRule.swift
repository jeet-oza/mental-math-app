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
    /// Target rounds guarantee at least this many distinct solutions.
    static let targetMinSolutions = 20
    /// Targets a round may pick from.
    ///
    /// Matched to how long a path actually is: with tiles of 1–20 and paths
    /// of 2–6, a typical path lands in the fifties or sixties. Targets much
    /// below that are only reachable by two- or three-tile paths, which is
    /// why they had so few solutions.
    static let targetRange = 50...100
    /// Tile values used on target boards.
    static let targetTileRange = 1...20

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

    /// A target round: a board of 1–20 tiles, and a target the board can
    /// actually reach many ways.
    ///
    /// The target is chosen *from* the board rather than guessed and checked.
    /// Building the sum histogram first and then picking among the sums that
    /// already clear `targetMinSolutions` makes the guarantee hold by
    /// construction; the old order — pick a target, hope the board suits it —
    /// missed on most rounds and then shipped the near miss anyway.
    private static func makeTargetRound(index: Int) -> (board: GridBoard, rule: GridRule) {
        var rng = SeededRandomNumberGenerator(seed: "grid_rule_\(index)")
        var best: (board: GridBoard, target: Int, count: Int)?

        for attempt in 0..<6 {
            let board = GridBoard.generate(
                seed: "grid_target_\(index)_\(attempt)", range: targetTileRange
            )
            let histogram = GridSolver.sumHistogram(on: board, maxLength: solverMaxLength)

            let viable = targetRange.filter { (histogram[$0] ?? 0) >= targetMinSolutions }
            if !viable.isEmpty {
                return (board, .target(viable[Int.random(in: 0..<viable.count, using: &rng)]))
            }

            // Nothing clears the bar on this board — remember its best sum in
            // case every attempt comes up short.
            if let richest = targetRange.max(by: { (histogram[$0] ?? 0) < (histogram[$1] ?? 0) }),
               best == nil || (histogram[richest] ?? 0) > best!.count {
                best = (board, richest, histogram[richest] ?? 0)
            }
        }

        // Unreached in practice: every sampled round finds viable targets on
        // the first attempt. Kept so generation cannot fail outright.
        let fallback = best ?? (
            GridBoard.generate(seed: "grid_target_\(index)_0", range: targetTileRange),
            targetRange.lowerBound,
            0
        )
        return (fallback.board, .target(fallback.target))
    }
}
