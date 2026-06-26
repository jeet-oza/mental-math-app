//
//  ArenaTabView.swift
//  MentalMathApp
//
//  Arena Mode tab: Wordament-style 90-second multiplayer gameplay.
//

import SwiftUI

/// Equation Arena content (hosted by ArenaContainerView, which owns the
/// navigation chrome and mode picker).
struct ArenaTabView: View {
    @EnvironmentObject var viewModel: ArenaViewModel

    var body: some View {
        ZStack {
            Color.groupedBackground
                .ignoresSafeArea()

            switch viewModel.phase {
            case .waiting:
                ArenaWaitingView(
                    secondsUntilStart: viewModel.nextRoundStartsIn,
                    roundNumber: viewModel.currentRoundIndex
                )

            case .playing:
                ArenaPlayingView()
                    .environmentObject(viewModel)

            case .submitting:
                ProgressView("Submitting score...")
                    .font(.headline)

            case .leaderboard:
                ArenaLeaderboardView()
                    .environmentObject(viewModel)
            }
        }
        .onAppear { viewModel.connect() }
        .onDisappear { viewModel.disconnect() }
    }
}

// MARK: - Waiting Phase

/// Pre-game lobby. All players join the same clock-driven round, so this
/// screen counts down to the next global start rather than offering a button.
struct ArenaWaitingView: View {
    let secondsUntilStart: Int
    let roundNumber: Int

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Icon
            Image(systemName: "flame.fill")
                .font(.system(size: 64))
                .foregroundStyle(Color.brandAccent)
                .symbolEffect(.pulse, options: .repeating)

            // Title
            VStack(spacing: 8) {
                Text("Math Arena")
                    .font(.largeTitle.bold())

                Text("Everyone plays the same questions,\nstarting at the same time.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            // Countdown to next round
            VStack(spacing: 6) {
                Text("Next round starts in")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("\(secondsUntilStart)s")
                    .font(.system(size: 56, weight: .heavy, design: .rounded).monospacedDigit())
                    .foregroundStyle(Color.brandAccent)
                    .contentTransition(.numericText())
                Text("Round #\(roundNumber + 1)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 8)

            // How it works
            VStack(alignment: .leading, spacing: 12) {
                infoRow(icon: "clock.fill", text: "90 seconds per round")
                infoRow(icon: "multiply.circle.fill", text: "Multiplication = 10 pts")
                infoRow(icon: "plusminus.circle.fill", text: "3-digit ± = 5 pts · 2-digit ± = 2 pts")
                infoRow(icon: "bolt.fill", text: "Answer fast for up to +10 bonus")
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.appBackground)
                    .shadow(color: .black.opacity(0.06), radius: 8, y: 4)
            )

            Spacer()
        }
        .padding()
    }

    private func infoRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(Color.brandAccent)
                .frame(width: 24)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Playing Phase

/// Active gameplay view with timer, problem, and input.
struct ArenaPlayingView: View {
    @EnvironmentObject var viewModel: ArenaViewModel

    var body: some View {
        VStack(spacing: 14) {
            // Timer and stats
            arenaHeader

            Spacer(minLength: 4)

            // Problem
            if let problem = viewModel.currentProblem {
                problemDisplay(problem)
            }

            // Answer being typed
            answerDisplay

            // Feedback
            if let feedback = viewModel.feedbackMessage {
                feedbackBanner(feedback)
            }

            Spacer(minLength: 4)

            // Skip + custom keypad
            inputSection

            // Live stats
            liveStats
        }
        .padding()
    }

    private var answerDisplay: some View {
        Text(viewModel.userInput.isEmpty ? "?" : viewModel.userInput)
            .font(.system(size: 40, weight: .bold, design: .rounded).monospacedDigit())
            .foregroundStyle(viewModel.userInput.isEmpty ? .secondary : Color.brandAccent)
            .frame(maxWidth: .infinity)
            .frame(height: 64)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.appBackground)
                    .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
            )
            .accessibilityLabel(Text("Your answer"))
            .accessibilityValue(Text(viewModel.userInput.isEmpty ? "empty" : viewModel.userInput))
    }

    private var arenaHeader: some View {
        HStack {
            // Timer
            HStack(spacing: 4) {
                Image(systemName: "clock.fill")
                    .foregroundStyle(viewModel.remainingSeconds <= 10 ? .red : Color.brandAccent)
                Text("\(viewModel.remainingSeconds)s")
                    .font(.title2.bold().monospacedDigit())
                    .foregroundStyle(viewModel.remainingSeconds <= 10 ? .red : .primary)
            }

            Spacer()

            // Questions answered
            Text("Q: \(viewModel.questionsAnswered)")
                .font(.headline.monospacedDigit())
                .foregroundStyle(.secondary)

            Spacer()

            // Score
            Text("\(viewModel.totalScore) pts")
                .font(.headline.monospacedDigit())
                .foregroundStyle(Color.brandAccent)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.appBackground)
                .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
        )
    }

    private func problemDisplay(_ problem: MathProblem) -> some View {
        Text(problem.displayText)
            .font(.system(size: 56, weight: .bold, design: .rounded))
            .foregroundStyle(.primary)
            .transition(.asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .leading).combined(with: .opacity)
            ))
            .animation(.spring(response: 0.25), value: viewModel.questionsAnswered)
            .id(viewModel.questionsAnswered)
    }

    private func feedbackBanner(_ message: String) -> some View {
        Text(message)
            .font(.headline)
            .foregroundStyle(viewModel.isCorrectFeedback == true ? .green : .red)
            .transition(.scale)
    }

    private var inputSection: some View {
        VStack(spacing: 12) {
            Button(action: viewModel.skipProblem) {
                Label("Skip", systemImage: "forward.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .foregroundStyle(Color.brandAccent)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.brandAccent, lineWidth: 2)
                    )
            }

            NumberPad(
                onDigit: { viewModel.inputDigit($0) },
                onDelete: { viewModel.deleteInput() },
                onSubmit: { viewModel.submitAnswer() },
                submitDisabled: viewModel.userInput.isEmpty
            )
        }
    }

    private var liveStats: some View {
        HStack {
            Label("\(viewModel.correctCount) correct", systemImage: "checkmark.circle.fill")
                .font(.caption)
                .foregroundStyle(.green)
            Spacer()
            Label(viewModel.accuracyText, systemImage: "target")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal)
    }
}

// MARK: - Leaderboard Phase

/// Post-match results: Wordament-style Results | Leaderboards tabs.
struct ArenaLeaderboardView: View {
    @EnvironmentObject var viewModel: ArenaViewModel
    @State private var tab: ResultsTab = .results

    var body: some View {
        VStack(spacing: 12) {
            // Countdown to the next global round (Wordament header).
            Text("Next game in 0:\(String(format: "%02d", viewModel.nextRoundStartsIn))")
                .font(.headline.monospacedDigit())
                .foregroundStyle(Color.brandAccent)

            // The leaderboard tab only appears once the final board is ready.
            if viewModel.leaderboardReady {
                Picker("View", selection: $tab) {
                    ForEach(ResultsTab.allCases) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
            }

            ScrollView {
                VStack(spacing: 20) {
                    if viewModel.leaderboardReady && tab == .leaderboards {
                        LeaderboardTableView(
                            entries: viewModel.leaderboard,
                            playerId: viewModel.currentPlayerId
                        )
                    } else {
                        resultsContent
                        if !viewModel.leaderboardReady {
                            collectingNotice
                        }
                    }
                }
                .padding()
            }
        }
        // When the final board lands, jump straight to the leaderboard.
        .onChange(of: viewModel.leaderboardReady) { _, ready in
            if ready { tab = .leaderboards }
        }
    }

    /// Shown under the results while scores are still being collected.
    private var collectingNotice: some View {
        HStack(spacing: 8) {
            ProgressView()
            Text("Final standings in \(secondsUntilReady)s…")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
    }

    private var secondsUntilReady: Int {
        max(0, viewModel.nextRoundStartsIn - (ArenaSchedule.intermission - ArenaSchedule.leaderboardDelaySeconds))
    }

    private var resultsContent: some View {
        VStack(spacing: 20) {
            VStack(spacing: 4) {
                Text("\(viewModel.totalScore)")
                    .font(.system(size: 52, weight: .heavy, design: .rounded))
                    .foregroundStyle(Color.brandAccent)
                Text("points").font(.subheadline).foregroundStyle(.secondary)
            }

            HStack(spacing: 32) {
                statColumn(label: "Correct", value: "\(viewModel.correctCount)")
                statColumn(label: "Answered", value: "\(viewModel.questionsAnswered)")
                statColumn(label: "Accuracy", value: viewModel.accuracyText)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.appBackground)
                    .shadow(color: .black.opacity(0.06), radius: 8, y: 4)
            )

            if !viewModel.attempts.isEmpty {
                attemptsCard
            }
        }
    }

    private var attemptsCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Your Equations")
                .font(.headline)

            ForEach(viewModel.attempts) { attempt in
                HStack(spacing: 10) {
                    Image(systemName: attempt.isCorrect ? "checkmark.circle.fill"
                          : (attempt.isSkipped ? "forward.circle.fill" : "xmark.circle.fill"))
                        .foregroundStyle(attempt.isCorrect ? .green
                                         : (attempt.isSkipped ? .secondary : .red))

                    Text(attempt.problem)
                        .font(.subheadline.monospacedDigit())

                    Spacer()

                    if attempt.isSkipped {
                        Text("skipped").font(.caption).foregroundStyle(.secondary)
                    } else if attempt.isCorrect {
                        Text("= \(attempt.correctAnswer)")
                            .font(.subheadline.monospacedDigit())
                            .foregroundStyle(.green)
                    } else {
                        Text("\(attempt.userAnswer.map(String.init) ?? "—") (✗ \(attempt.correctAnswer))")
                            .font(.subheadline.monospacedDigit())
                            .foregroundStyle(.red)
                    }
                }
                .padding(.vertical, 3)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.appBackground)
                .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
        )
    }

    private func statColumn(label: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2.bold())
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    ArenaTabView()
        .environmentObject(ArenaViewModel())
}
