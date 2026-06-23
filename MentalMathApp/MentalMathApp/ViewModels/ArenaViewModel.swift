//
//  ArenaViewModel.swift
//  MentalMathApp
//
//  ViewModel for Arena Mode (Wordament-style multiplayer).
//  Manages the 90-second gameplay loop, problem progression,
//  scoring, and round state.
//

import Foundation
import Combine
import SwiftUI

/// The current phase of an arena session.
enum ArenaPhase: Equatable {
    case waiting      // Waiting for next round to start
    case playing      // Active 90-second gameplay
    case submitting   // Submitting score to server
    case leaderboard  // Viewing post-match results
}

/// Manages Arena Mode gameplay state.
@MainActor
final class ArenaViewModel: ObservableObject {

    // MARK: - Published State

    @Published private(set) var phase: ArenaPhase = .waiting
    @Published private(set) var currentProblem: MathProblem?
    @Published private(set) var remainingSeconds: Int = 90
    @Published private(set) var questionsAnswered: Int = 0
    @Published private(set) var correctCount: Int = 0
    @Published private(set) var totalScore: Int = 0
    @Published private(set) var answers: [AnswerResult] = []
    @Published private(set) var leaderboard: [LeaderboardEntry] = []
    @Published var userInput: String = ""
    @Published private(set) var feedbackMessage: String?
    @Published private(set) var isCorrectFeedback: Bool?
    /// Seconds until the next global round begins (used during intermission).
    @Published private(set) var nextRoundStartsIn: Int = 0
    /// The globally-synchronized index of the active or upcoming round.
    @Published private(set) var currentRoundIndex: Int = 0

    // MARK: - Properties

    private var engine: MathEngine?
    private var currentRound: ArenaRound?
    private var timer: AnyCancellable?
    private var syncTimer: AnyCancellable?
    private var problemStartTime: Date = Date()
    private let roundDuration: Int = 90

    /// Backend boundary for score submission and leaderboards.
    /// Defaults to offline play; `configureOnlinePlay` swaps in a networked
    /// service so real multiplayer works without changing this view model.
    private var leaderboardService: LeaderboardService

    /// Identity used for the player's leaderboard entry. Defaults to a local
    /// placeholder; set to the real user once signed in.
    private var playerId = "you"
    private var playerName = "You"

    // MARK: - Initialization

    init(leaderboardService: LeaderboardService = LocalLeaderboardService()) {
        self.leaderboardService = leaderboardService
    }

    /// The id used for the local player's leaderboard entry (for UI highlighting).
    var currentPlayerId: String { playerId }

    /// Switches to networked multiplayer using the signed-in user's identity.
    func configureOnlinePlay(userId: String, displayName: String) {
        playerId = userId
        playerName = displayName
        leaderboardService = FirebaseLeaderboardService()
    }

    /// The round index the player actually played this cycle (nil if they
    /// joined during intermission and have not played the current round).
    private var playedRoundIndex: Int?
    /// The round index whose results have already been finalized.
    private var finalizedRoundIndex: Int?

    // MARK: - Computed

    /// Accuracy as a percentage string.
    var accuracyText: String {
        guard questionsAnswered > 0 else { return "—" }
        let pct = Int((Double(correctCount) / Double(questionsAnswered)) * 100)
        return "\(pct)%"
    }

    /// Average time per question in seconds.
    var averageTimePerQuestion: Double {
        guard questionsAnswered > 0 else { return 0 }
        let roundLength = currentRound?.durationSeconds ?? roundDuration
        let totalElapsed = Double(roundLength - remainingSeconds)
        return totalElapsed / Double(questionsAnswered)
    }

    // MARK: - Global Schedule

    /// Begins following the global Arena schedule. Call when the view appears.
    /// Players cannot start their own game — everyone joins the same clock-driven
    /// round, so all devices play identical questions in lockstep.
    func connect() {
        sync()
        syncTimer?.cancel()
        syncTimer = Timer.publish(every: 0.5, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.sync()
            }
    }

    /// Stops following the schedule. Call when the view disappears.
    func disconnect() {
        syncTimer?.cancel()
        syncTimer = nil
    }

    /// Reconciles local state with the global schedule.
    private func sync() {
        switch ArenaSchedule.phase() {
        case let .playing(roundIndex, remaining):
            currentRoundIndex = roundIndex
            if phase != .playing || playedRoundIndex != roundIndex {
                beginScheduledRound(index: roundIndex)
            }
            remainingSeconds = remaining

        case let .intermission(nextRoundIndex, startsIn):
            currentRoundIndex = nextRoundIndex
            nextRoundStartsIn = startsIn
            remainingSeconds = 0

            if let played = playedRoundIndex, finalizedRoundIndex != played {
                // The round the player just competed in has ended: show results.
                finalize(roundIndex: played)
            } else if playedRoundIndex == nil {
                // Joined mid-intermission with nothing played yet.
                phase = .waiting
            }
        }
    }

    /// Starts the gameplay for a clock-scheduled round (no internal countdown;
    /// `remainingSeconds` is driven by `sync()` from the shared clock).
    private func beginScheduledRound(index: Int) {
        let round = ArenaRound(
            roundId: "arena_\(index)",
            seed: ArenaSchedule.seed(forRound: index),
            difficulty: ArenaSchedule.difficulty(forRound: index),
            durationSeconds: ArenaSchedule.playDuration,
            startTimestamp: Date()
        )
        configureRound(round)
        playedRoundIndex = index
        phase = .playing
    }

    /// Builds the leaderboard (computer opponents + the player) and shows results.
    private func finalize(roundIndex: Int) {
        timer?.cancel()
        timer = nil
        finalizedRoundIndex = roundIndex
        loadLeaderboard(forRound: roundIndex)
        phase = .leaderboard
    }

    // MARK: - Round Lifecycle

    /// Starts a new arena round with the given parameters.
    /// In production, round data comes from Firebase. For offline/testing,
    /// a local round is generated.
    /// - Parameter round: The arena round configuration.
    func startRound(_ round: ArenaRound) {
        configureRound(round)
        phase = .playing
        startTimer()
    }

    /// Resets gameplay state and prepares the engine for a round, without
    /// changing phase or starting a timer. Shared by manual and scheduled play.
    private func configureRound(_ round: ArenaRound) {
        currentRound = round
        engine = MathEngine(
            seed: round.seed,
            difficulty: round.difficulty
        )

        answers.removeAll()
        questionsAnswered = 0
        correctCount = 0
        totalScore = 0
        remainingSeconds = round.durationSeconds
        userInput = ""
        feedbackMessage = nil
        isCorrectFeedback = nil

        advanceToNextProblem()
    }

    /// Starts a quick local round for offline play or testing.
    /// - Parameters:
    ///   - seed: Optional seed (defaults to timestamp-based).
    ///   - difficulty: Difficulty level.
    func startLocalRound(
        seed: String? = nil,
        difficulty: MathEngine.Difficulty = .easy
    ) {
        let roundSeed = seed ?? "local_\(Int(Date().timeIntervalSince1970))"
        let round = ArenaRound(
            roundId: UUID().uuidString,
            seed: roundSeed,
            difficulty: difficulty,
            durationSeconds: roundDuration,
            startTimestamp: Date()
        )
        startRound(round)
    }

    // MARK: - Player Actions

    /// Submits the user's answer for the current problem.
    func submitAnswer() {
        guard phase == .playing,
              let problem = currentProblem,
              let userAnswer = Int(userInput.trimmingCharacters(in: .whitespaces))
        else { return }

        let elapsed = Date().timeIntervalSince(problemStartTime)
        let isCorrect = userAnswer == problem.correctAnswer
        let difficulty = currentRound?.difficulty ?? .easy
        let points = ScoreCalculator.calculatePoints(
            isCorrect: isCorrect,
            timeElapsed: elapsed,
            difficulty: difficulty
        )

        recordAnswer(
            isCorrect: isCorrect,
            isSkipped: false,
            userAnswer: userAnswer,
            correctAnswer: problem.correctAnswer,
            elapsed: elapsed,
            points: points
        )

        showFeedback(isCorrect: isCorrect, correctAnswer: problem.correctAnswer)
        advanceToNextProblem()
    }

    /// Skips the current problem and moves to the next one immediately.
    func skipProblem() {
        guard phase == .playing, let problem = currentProblem else { return }

        let elapsed = Date().timeIntervalSince(problemStartTime)
        recordAnswer(
            isCorrect: false,
            isSkipped: true,
            userAnswer: nil,
            correctAnswer: problem.correctAnswer,
            elapsed: elapsed,
            points: ScoreCalculator.skipPenalty
        )

        advanceToNextProblem()
    }

    // MARK: - Timer

    /// Starts the countdown timer.
    private func startTimer() {
        timer?.cancel()
        timer = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }

    /// Handles each timer tick.
    private func tick() {
        guard remainingSeconds > 0 else {
            endRound()
            return
        }
        remainingSeconds -= 1
        if remainingSeconds == 0 {
            endRound()
        }
    }

    /// Ends the current round and transitions to submission/leaderboard.
    private func endRound() {
        timer?.cancel()
        timer = nil
        phase = .submitting
        loadLeaderboard(forRound: currentRoundIndex)
        phase = .leaderboard
    }

    // MARK: - Private Helpers

    /// Records an answer result and updates running totals.
    private func recordAnswer(
        isCorrect: Bool,
        isSkipped: Bool,
        userAnswer: Int?,
        correctAnswer: Int,
        elapsed: Double,
        points: Int
    ) {
        let result = AnswerResult(
            problemIndex: questionsAnswered,
            isCorrect: isCorrect,
            isSkipped: isSkipped,
            userAnswer: userAnswer,
            correctAnswer: correctAnswer,
            timeElapsed: elapsed,
            pointsEarned: points
        )

        answers.append(result)
        questionsAnswered += 1
        if isCorrect { correctCount += 1 }
        totalScore += points
    }

    /// Advances to the next problem in the deterministic sequence.
    private func advanceToNextProblem() {
        currentProblem = engine?.nextProblem()
        userInput = ""
        problemStartTime = Date()
        feedbackMessage = nil
        isCorrectFeedback = nil
    }

    /// Shows feedback briefly (arena mode clears immediately on next problem).
    private func showFeedback(isCorrect: Bool, correctAnswer: Int) {
        isCorrectFeedback = isCorrect
        feedbackMessage = isCorrect
            ? "✓ +\(answers.last?.pointsEarned ?? 0)"
            : "✗ Answer: \(correctAnswer)"
    }

    /// Submits the player's result and loads the round leaderboard through the
    /// leaderboard service (offline opponents today, real players once a
    /// networked service is wired in).
    private func loadLeaderboard(forRound index: Int) {
        let accuracy = questionsAnswered > 0
            ? Double(correctCount) / Double(questionsAnswered)
            : 0
        let player = LeaderboardEntry(
            id: playerId,
            username: playerName,
            score: totalScore,
            accuracy: accuracy,
            rank: 0
        )

        let service = leaderboardService
        Task { [weak self] in
            try? await service.submit(player, forRound: index)
            if let entries = try? await service.leaderboard(forRound: index, including: player) {
                self?.leaderboard = entries
            }
        }
    }

    /// Resets the arena to the waiting state.
    func reset() {
        timer?.cancel()
        timer = nil
        phase = .waiting
        currentProblem = nil
        answers.removeAll()
        questionsAnswered = 0
        correctCount = 0
        totalScore = 0
        remainingSeconds = roundDuration
        userInput = ""
        feedbackMessage = nil
        isCorrectFeedback = nil
        leaderboard.removeAll()
        playedRoundIndex = nil
        finalizedRoundIndex = nil
        nextRoundStartsIn = 0
    }
}
