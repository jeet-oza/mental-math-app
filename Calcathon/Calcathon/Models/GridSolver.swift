//
//  GridSolver.swift
//  Calcathon
//
//  Enumerates all scoring paths on a board (like Wordament's post-round
//  "solutions" list), filtered by the round's rule.
//

import Foundation

/// A scoring combination found on the board.
struct GridSolution: Identifiable, Equatable, Sendable {
    let id: String          // canonical tile-set key (also dedupe id)
    let positions: [GridPosition]
    let values: [Int]
    let sum: Int
    let points: Int

    /// e.g. "25 + 25 + 50 = 100"
    var expression: String {
        values.map(String.init).joined(separator: " + ") + " = \(sum)"
    }
}

enum GridSolver {

    /// All distinct paths satisfying the rule up to `maxLength` tiles,
    /// deduplicated by tile set. Bounded length keeps enumeration tractable.
    static func solutions(on board: GridBoard, rule: GridRule, maxLength: Int = 5) -> [GridSolution] {
        var byKey: [String: GridSolution] = [:]
        var path: [GridPosition] = []

        func dfs(_ current: GridPosition) {
            path.append(current)
            defer { path.removeLast() }

            if path.count >= GridScoring.minimumLength {
                let sum = GridScoring.sum(of: path, on: board)
                if rule.isSatisfied(by: sum) {
                    let key = GridScoring.key(for: path)
                    if byKey[key] == nil {
                        byKey[key] = GridSolution(
                            id: key,
                            positions: path,
                            values: path.map { board.value(at: $0) },
                            sum: sum,
                            points: GridScoring.points(for: path, on: board, rule: rule)
                        )
                    }
                }
            }

            guard path.count < maxLength else { return }
            for neighbor in neighbors(of: current) where !path.contains(neighbor) {
                dfs(neighbor)
            }
        }

        for row in 0..<GridBoard.size {
            for col in 0..<GridBoard.size {
                dfs(GridPosition(row: row, col: col))
            }
        }

        return Array(byKey.values)
    }

    /// Count of distinct tile-set paths (deduped) for each achievable sum,
    /// up to `maxLength` tiles. Used to choose a target with enough solutions.
    static func sumHistogram(on board: GridBoard, maxLength: Int) -> [Int: Int] {
        var counted = Set<String>()
        var histogram: [Int: Int] = [:]
        var path: [GridPosition] = []

        func dfs(_ current: GridPosition) {
            path.append(current)
            defer { path.removeLast() }

            if path.count >= GridScoring.minimumLength {
                let key = GridScoring.key(for: path)
                if counted.insert(key).inserted {
                    histogram[GridScoring.sum(of: path, on: board), default: 0] += 1
                }
            }
            guard path.count < maxLength else { return }
            for neighbor in neighbors(of: current) where !path.contains(neighbor) {
                dfs(neighbor)
            }
        }

        for row in 0..<GridBoard.size {
            for col in 0..<GridBoard.size {
                dfs(GridPosition(row: row, col: col))
            }
        }
        return histogram
    }

    private static func neighbors(of p: GridPosition) -> [GridPosition] {
        var result: [GridPosition] = []
        for dr in -1...1 {
            for dc in -1...1 where !(dr == 0 && dc == 0) {
                let n = GridPosition(row: p.row + dr, col: p.col + dc)
                if GridBoard.isInBounds(n) { result.append(n) }
            }
        }
        return result
    }
}
