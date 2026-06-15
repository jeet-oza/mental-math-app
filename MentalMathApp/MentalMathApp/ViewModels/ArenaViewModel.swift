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

    // MARK: - Properties

    private var engine: MathEngine?
    private var currentRound: ArenaRound?
    private var timer: AnyCancellable?
    private var problemStartTime: Date = Date()
    private let roundDuration: Int = 90

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
        let totalElapsed = Double(roundDuration - remainingSeconds)
        return totalElapsed / Double(questionsAnswered)
    }

    // MARK: - Round Lifecycle

    /// Starts a new arena round with the given parameters.
    /// In production, round data comes from Firebase. For offline/testing,
    /// a local round is generated.
    /// - Parameter round: The arena round configuration.
    func startRound(_ round: ArenaRound) {
        currentRound = round
        engine = MathEngine(
            seed: round.seed,
            difficulty: round.difficulty
        )

        // Reset state
        answers.removeAll()
        questionsAnswered = 0
        correctCount = 0
        totalScore = 0
        remainingSeconds = round.durationSeconds
        userInput = ""
        feedbackMessage = nil
        isCorrectFeedback = nil

        // Start gameplay
        phase = .playing
        advanceToNextProblem()
        startTimer()
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

        // In production, this would POST to Firebase.
        // For now, transition directly to leaderboard with local results.
        buildLocalLeaderboard()
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

    /// Builds a placeholder local leaderboard (single-player offline mode).
    private func buildLocalLeaderboard() {
        let accuracy = questionsAnswered > 0
            ? Double(correctCount) / Double(questionsAnswered)
            : 0
        leaderboard = [
            LeaderboardEntry(
                id: "you",
                username: "You",
                score: totalScore,
                accuracy: accuracy,
                rank: 1
            )
        ]
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
    }
}
