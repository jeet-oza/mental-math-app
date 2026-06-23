//
//  ArenaTabView.swift
//  MentalMathApp
//
//  Arena Mode tab: Wordament-style 90-second multiplayer gameplay.
//

import SwiftUI

/// The Arena Mode tab with waiting, playing, and leaderboard phases.
struct ArenaTabView: View {
    @EnvironmentObject var viewModel: ArenaViewModel

    var body: some View {
        NavigationStack {
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
            .navigationTitle("Arena")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
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
                .foregroundStyle(Color.brandPrimary)
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
                    .foregroundStyle(Color.brandPrimary)
                    .contentTransition(.numericText())
                Text("Round #\(roundNumber + 1)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 8)

            // How it works
            VStack(alignment: .leading, spacing: 12) {
                infoRow(icon: "clock.fill", text: "90 seconds per round")
                infoRow(icon: "bolt.fill", text: "Faster answers = bonus points")
                infoRow(icon: "forward.fill", text: "Skip questions with no penalty")
                infoRow(icon: "chart.bar.fill", text: "Compete on the leaderboard")
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
                .foregroundStyle(Color.brandPrimary)
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
        VStack(spacing: 20) {
            // Timer and stats
            arenaHeader

            Spacer()

            // Problem
            if let problem = viewModel.currentProblem {
                problemDisplay(problem)
            }

            // Feedback
            if let feedback = viewModel.feedbackMessage {
                feedbackBanner(feedback)
            }

            Spacer()

            // Input
            inputSection

            // Live stats
            liveStats
        }
        .padding()
    }

    private var arenaHeader: some View {
        HStack {
            // Timer
            HStack(spacing: 4) {
                Image(systemName: "clock.fill")
                    .foregroundStyle(viewModel.remainingSeconds <= 10 ? .red : Color.brandPrimary)
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
                .foregroundStyle(Color.brandPrimary)
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
            TextField("Answer", text: $viewModel.userInput)
                .font(.title2)
                #if os(iOS)
                .keyboardType(.numberPad)
                #endif
                .multilineTextAlignment(.center)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.appBackground)
                        .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
                )

            HStack(spacing: 16) {
                Button(action: viewModel.skipProblem) {
                    Label("Skip", systemImage: "forward.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundStyle(Color.brandPrimary)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.brandPrimary, lineWidth: 2)
                        )
                }

                Button(action: viewModel.submitAnswer) {
                    Label("Submit", systemImage: "arrow.right.circle.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundStyle(.white)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.brandGradient)
                        )
                }
                .disabled(viewModel.userInput.trimmingCharacters(in: .whitespaces).isEmpty)
            }
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

/// Post-match leaderboard and results.
struct ArenaLeaderboardView: View {
    @EnvironmentObject var viewModel: ArenaViewModel

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Result title
            Text("Round Complete!")
                .font(.largeTitle.bold())

            // Score
            VStack(spacing: 8) {
                Text("\(viewModel.totalScore)")
                    .font(.system(size: 56, weight: .heavy, design: .rounded))
                    .foregroundStyle(Color.brandPrimary)
                Text("points")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }

            // Stats
            HStack(spacing: 32) {
                statColumn(label: "Correct", value: "\(viewModel.correctCount)")
                statColumn(label: "Answered", value: "\(viewModel.questionsAnswered)")
                statColumn(label: "Accuracy", value: viewModel.accuracyText)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.appBackground)
                    .shadow(color: .black.opacity(0.06), radius: 8, y: 4)
            )

            // Leaderboard
            if !viewModel.leaderboard.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Leaderboard")
                        .font(.headline)

                    ForEach(viewModel.leaderboard) { entry in
                        let isYou = entry.id == viewModel.currentPlayerId
                        HStack {
                            Text("#\(entry.rank)")
                                .font(.headline.monospacedDigit())
                                .frame(width: 40)
                            Text(entry.username)
                                .font(isYou ? .body.bold() : .body)
                            Spacer()
                            Text("\(entry.score) pts")
                                .font(.headline.monospacedDigit())
                                .foregroundStyle(Color.brandPrimary)
                        }
                        .padding(.vertical, 6)
                        .padding(.horizontal, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(isYou ? Color.brandPrimary.opacity(0.12) : .clear)
                        )
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.appBackground)
                        .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
                )
            }

            Spacer()

            // Auto-advance: the next global round starts on the shared clock.
            VStack(spacing: 4) {
                Text("Next round starts in")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("\(viewModel.nextRoundStartsIn)s")
                    .font(.title.bold().monospacedDigit())
                    .foregroundStyle(Color.brandPrimary)
                    .contentTransition(.numericText())
            }
        }
        .padding()
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
