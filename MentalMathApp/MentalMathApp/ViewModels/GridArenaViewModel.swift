//
//  GridArenaViewModel.swift
//  MentalMathApp
//
//  Grid Arena ("Number Wordament"): globally-synchronized rounds on the shared
//  ArenaSchedule clock. Players trace adjacent-tile paths summing to a multiple
//  of 10; valid paths score and feed cumulative lifetime stats.
//

import Foundation
import Combine
import SwiftUI

/// A scoring path the player has found this round.
struct FoundGridPath: Identifiable, Equatable {
    let id = UUID()
    let positions: [GridPosition]
    let sum: Int
    let points: Int
    var isHundred: Bool { sum % 100 == 0 }
}

@MainActor
final class GridArenaViewModel: ObservableObject {

    // MARK: - Published State

    @Published private(set) var phase: ArenaPhase = .waiting
    @Published private(set) var board = GridBoard(values: Array(repeating: 0, count: 16))
    @Published private(set) var currentPath: [GridPosition] = []
    @Published private(set) var foundPaths: [FoundGridPath] = []
    @Published private(set) var score = 0
    @Published private(set) var remainingSeconds = 0
    @Published private(set) var nextRoundStartsIn = 0
    @Published private(set) var currentRoundIndex = 0
    @Published private(set) var leaderboard: [LeaderboardEntry] = []
    /// False during the post-round collection window; true once the final board is ready.
    @Published private(set) var leaderboardReady = false
    @Published private(set) var message: String?
    /// All multiple-of-100 combinations on the board (post-round), by points desc.
    @Published private(set) var solutionsHundreds: [GridSolution] = []
    /// All multiple-of-10 (not 100) combinations on the board, by points desc.
    @Published private(set) var solutionsTens: [GridSolution] = []

    // MARK: - Dependencies

    private var leaderboardService: LeaderboardService
    private var onRoundFinished: ((_ score: Int, _ paths: Int, _ longest: Int, _ hundreds: Int) -> Void)?
    private var playerId = "you"
    private var playerName = "You"

    // MARK: - Private

    private var syncTimer: AnyCancellable?
    private var foundKeys: Set<String> = []
    private var playedRoundIndex: Int?
    private var finalizedRoundIndex: Int?

    init(leaderboardService: LeaderboardService = LocalLeaderboardService(mode: .grid)) {
        self.leaderboardService = leaderboardService
    }

    /// Switches to networked multiplayer using the signed-in user's identity.
    func configureOnlinePlay(userId: String, displayName: String) {
        playerId = userId
        playerName = displayName
        leaderboardService = FirebaseLeaderboardService(collection: "gridRounds", mode: .grid)
    }

    /// Registers a handler invoked once when a round the player played ends.
    func onRoundComplete(_ handler: @escaping (Int, Int, Int, Int) -> Void) {
        onRoundFinished = handler
    }

    var currentPlayerId: String { playerId }

    /// Tile-set keys the player banked this round (to mark found solutions).
    var foundSolutionKeys: Set<String> { foundKeys }

    // MARK: - Computed (current selection)

    var currentSum: Int { GridScoring.sum(of: currentPath, on: board) }
    var currentIsValid: Bool { GridScoring.isValid(currentPath, on: board) }
    var currentPotentialPoints: Int {
        currentIsValid ? GridScoring.points(for: currentPath, on: board) : 0
    }

    // MARK: - Global Schedule

    func connect() {
        sync()
        syncTimer?.cancel()
        syncTimer = Timer.publish(every: 0.5, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in self?.sync() }
    }

    func disconnect() {
        syncTimer?.cancel()
        syncTimer = nil
    }

    private func sync() {
        switch ArenaSchedule.phase() {
        case let .playing(roundIndex, remaining):
            currentRoundIndex = roundIndex
            if phase != .playing || playedRoundIndex != roundIndex {
                beginRound(index: roundIndex)
            }
            remainingSeconds = remaining

        case let .intermission(nextRoundIndex, startsIn):
            currentRoundIndex = nextRoundIndex
            nextRoundStartsIn = startsIn
            remainingSeconds = 0
            if let played = playedRoundIndex, finalizedRoundIndex != played {
                finalize(roundIndex: played)
            } else if playedRoundIndex == nil {
                phase = .waiting
            }
        }
    }

    private func beginRound(index: Int) {
        board = GridBoard.generate(seed: "grid_arena_round_\(index)")
        currentPath.removeAll()
        foundPaths.removeAll()
        foundKeys.removeAll()
        solutionsHundreds.removeAll()
        solutionsTens.removeAll()
        leaderboard = []
        leaderboardReady = false
        score = 0
        message = nil
        playedRoundIndex = index
        phase = .playing
    }

    private func finalize(roundIndex: Int) {
        finalizedRoundIndex = roundIndex
        let longest = foundPaths.map(\.positions.count).max() ?? 0
        let hundreds = foundPaths.filter(\.isHundred).count
        onRoundFinished?(score, foundPaths.count, longest, hundreds)
        loadLeaderboard(forRound: roundIndex)
        computeSolutions()
        phase = .leaderboard
    }

    /// Enumerates every scoring combination on the board for the results screen.
    private func computeSolutions() {
        let board = self.board
        Task { [weak self] in
            let all = GridSolver.solutions(on: board)
            let hundreds = all.filter(\.isHundred).sorted { $0.points > $1.points }
            let tens = all.filter { !$0.isHundred }.sorted { $0.points > $1.points }
            await MainActor.run {
                self?.solutionsHundreds = hundreds
                self?.solutionsTens = tens
            }
        }
    }

    // MARK: - Player Interaction

    /// Handles a tap on a tile: start, extend, or undo the current path.
    func tapTile(_ position: GridPosition) {
        guard phase == .playing else { return }
        message = nil

        if currentPath.isEmpty {
            currentPath = [position]
        } else if currentPath.last == position {
            currentPath.removeLast() // tapping the tip undoes it
        } else if currentPath.contains(position) {
            return // can't reuse a tile mid-path
        } else if GridBoard.areAdjacent(currentPath.last!, position) {
            currentPath.append(position)
        }
    }

    func clearPath() {
        currentPath.removeAll()
        message = nil
    }

    /// Drag-trace: called as the finger moves over a tile. Extends the path,
    /// or backtracks if the finger returns to the previous tile.
    func dragEntered(_ position: GridPosition) {
        guard phase == .playing else { return }
        if currentPath.isEmpty {
            currentPath = [position]
            message = nil
            return
        }
        if currentPath.last == position { return }
        // Finger moved back onto the previous tile → undo the last step.
        if currentPath.count >= 2, currentPath[currentPath.count - 2] == position {
            currentPath.removeLast()
            return
        }
        if currentPath.contains(position) { return }
        if GridBoard.areAdjacent(currentPath.last!, position) {
            currentPath.append(position)
        }
    }

    /// Drag-trace ended (finger lifted): bank the path if it scores, else
    /// clear it silently (Wordament-style — no nag for non-scoring traces).
    func endDrag() {
        guard phase == .playing else { return }
        if currentPath.count >= GridScoring.minimumLength, currentIsValid {
            submitPath()
        } else {
            currentPath.removeAll()
        }
    }

    /// Validates and banks the current path if it scores and is new.
    func submitPath() {
        guard phase == .playing else { return }
        guard currentPath.count >= GridScoring.minimumLength else {
            message = "Select at least \(GridScoring.minimumLength) tiles"
            return
        }
        guard currentIsValid else {
            message = "Sum \(currentSum) isn't a multiple of 10"
            return
        }
        let key = GridScoring.key(for: currentPath)
        guard !foundKeys.contains(key) else {
            message = "Already found those tiles"
            clearPath()
            return
        }

        let points = GridScoring.points(for: currentPath, on: board)
        let found = FoundGridPath(positions: currentPath, sum: currentSum, points: points)
        foundKeys.insert(key)
        foundPaths.insert(found, at: 0)
        score += points
        message = found.isHundred ? "+\(points) — multiple of 100!" : "+\(points)"
        currentPath.removeAll()
        Feedback.correct()
    }

    // MARK: - Leaderboard

    private func loadLeaderboard(forRound index: Int) {
        let player = LeaderboardEntry(
            id: playerId,
            username: playerName,
            score: score,
            accuracy: 0,
            rank: 0
        )
        // Hide the leaderboard during the collection window.
        leaderboard = []
        leaderboardReady = false

        // Submit now, wait for the collection window, then publish the final
        // board (all players + bots) at once.
        let service = leaderboardService
        Task { [weak self] in
            try? await service.submit(player, forRound: index)
            try? await Task.sleep(for: .seconds(Double(ArenaSchedule.leaderboardDelaySeconds)))
            let entries = (try? await service.leaderboard(forRound: index, including: player))
                ?? rankedLeaderboard(ArenaSchedule.opponents(forRound: index, mode: .grid) + [player])
            self?.leaderboard = entries
            self?.leaderboardReady = true
        }
    }
}
