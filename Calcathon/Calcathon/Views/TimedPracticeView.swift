//
//  TimedPracticeView.swift
//  Calcathon
//
//  Fast, local practice with a user-selected duration and question mix.
//

import Combine
import SwiftUI

struct TimedPracticeView: View {
    @StateObject private var viewModel: TimedPracticeViewModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedField: AnswerField?
    @State private var hintLevel = 0

    private let clock = Timer.publish(every: 0.2, on: .main, in: .common).autoconnect()

    private enum AnswerField: Hashable { case answer, remainder }

    init(plan: TimedPracticePlan) {
        _viewModel = StateObject(wrappedValue: TimedPracticeViewModel(plan: plan))
    }

    var body: some View {
        ZStack {
            BrandBackground()
            if viewModel.isComplete {
                resultsView
            } else {
                practiceView
            }
        }
        .navigationTitle(viewModel.isComplete ? "Results" : "Timed Practice")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .onAppear { viewModel.start() }
        .onReceive(clock) { viewModel.updateClock(now: $0) }
        .onChange(of: viewModel.currentProblem?.id) { _, _ in
            hintLevel = 0
        }
        .onChange(of: hintLevel) { _, newLevel in
            if newLevel > 0 { focusedField = nil }
        }
    }

    private var practiceView: some View {
        ScrollView {
            VStack(spacing: 22) {
                sessionHeader

                if let lesson = viewModel.currentLesson {
                    Label(lesson.title, systemImage: "lightbulb.fill")
                        .font(.caption.bold())
                        .foregroundStyle(Color.brandAccent)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(Capsule().fill(Color.brandAccent.opacity(0.12)))
                } else if let operation = viewModel.currentProblem?.operation {
                    Text(operation.title)
                        .font(.caption.bold())
                        .foregroundStyle(Color.brandAccent)
                }

                if let problem = viewModel.currentProblem {
                    MathProblemVisualView(
                        problem: problem,
                        answerText: viewModel.revealedAnswerText,
                        compact: true
                    )
                        .padding(.horizontal)
                        .background(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(Color.appBackground.opacity(0.72))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                                )
                        )
                        .transition(.scale.combined(with: .opacity))
                        .id(problem.id)

                    PracticeHintView(
                        lesson: viewModel.currentLesson,
                        problem: problem,
                        level: $hintLevel
                    )
                }

                if let message = viewModel.feedbackMessage {
                    feedbackBanner(message)
                }

                answerEntry
                actionButtons

                Text("Accuracy first. Speed grows as the strategy becomes familiar.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
        .scrollDismissesKeyboard(.interactively)
    }

    private var sessionHeader: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text("TIME LEFT")
                    .font(.caption2.bold())
                    .foregroundStyle(.secondary)
                Text(viewModel.timeText)
                    .font(.system(.title2, design: .rounded).bold())
                    .monospacedDigit()
                    .foregroundStyle(viewModel.secondsRemaining <= 10 ? .red : Color.brandAccent)
            }
            Spacer()
            headerStat(value: "\(viewModel.answeredCount)", label: "Answered")
            headerStat(value: "\(viewModel.correctCount)", label: "First try")
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.appBackground))
    }

    private func headerStat(value: String, label: String) -> some View {
        VStack(spacing: 3) {
            Text(value).font(.title2.bold()).monospacedDigit()
            Text(label).font(.caption2).foregroundStyle(.secondary)
        }
        .frame(minWidth: 64)
    }

    @ViewBuilder
    private var answerEntry: some View {
        if viewModel.answerMode == .expression {
            VStack(spacing: 12) {
                Text(viewModel.userInput.isEmpty ? "Your answer" : viewModel.userInput)
                    .font(.title2.monospaced())
                    .foregroundStyle(viewModel.userInput.isEmpty ? .secondary : .primary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(answerBackground)
                ScientificKeypad(expression: $viewModel.userInput, isCompact: true)
            }
        } else if viewModel.wantsRemainder {
            HStack(spacing: 12) {
                numberField("Quotient", text: $viewModel.userInput, field: .answer)
                numberField("Remainder", text: $viewModel.userRemainderInput, field: .remainder)
            }
        } else {
            numberField("Your answer", text: $viewModel.userInput, field: .answer)
        }
    }

    private func numberField(_ prompt: String, text: Binding<String>, field: AnswerField) -> some View {
        TextField(prompt, text: text)
            .font(.title2)
            #if os(iOS)
            .keyboardType(.numberPad)
            #endif
            .focused($focusedField, equals: field)
            .multilineTextAlignment(.center)
            .padding()
            .background(answerBackground)
    }

    private var answerBackground: some View {
        RoundedRectangle(cornerRadius: 14)
            .fill(Color.appBackground)
            .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
    }

    private var actionButtons: some View {
        Group {
            if viewModel.isAwaitingNext {
                Button {
                    viewModel.advance()
                    focusedField = nil
                } label: {
                    Label("Next question", systemImage: "arrow.right")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundStyle(.white)
                        .background(RoundedRectangle(cornerRadius: 14).fill(.accentGradient))
                }
            } else {
                HStack(spacing: 14) {
                    Button { viewModel.skip() } label: {
                        Text(viewModel.isAwaitingCorrection ? "Move on" : "Skip")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundStyle(Color.brandAccent)
                            .background(RoundedRectangle(cornerRadius: 14).stroke(Color.brandPrimary, lineWidth: 2))
                    }

                    Button {
                        viewModel.submitAnswer()
                        focusedField = nil
                    } label: {
                        Text(viewModel.isAwaitingCorrection ? "Correct it" : "Check")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundStyle(.white)
                            .background(RoundedRectangle(cornerRadius: 14).fill(.accentGradient))
                    }
                    .disabled(!viewModel.canSubmit)
                }
            }
        }
    }

    private func feedbackBanner(_ message: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: viewModel.isCorrectFeedback == true
                  ? "checkmark.circle.fill"
                  : viewModel.isCorrectFeedback == false ? "arrow.right.circle.fill" : "forward.fill")
            Text(message)
        }
        .font(.subheadline.bold())
        .foregroundStyle(viewModel.isCorrectFeedback == true ? .green : .secondary)
        .padding(.horizontal, 14)
        .padding(.vertical, 9)
        .background(Capsule().fill(Color.appBackground))
    }

    private var resultsView: some View {
        ScrollView {
            VStack(spacing: 24) {
                Image(systemName: "timer.circle.fill")
                    .font(.system(size: 76))
                    .foregroundStyle(Color.brandAccent)

                VStack(spacing: 6) {
                    Text("Time's up!")
                        .font(.largeTitle.bold())
                    Text(resultEncouragement)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                VStack(spacing: 0) {
                    resultRow("Questions per minute", String(format: "%.1f", viewModel.questionsPerMinute), icon: "speedometer")
                    Divider()
                    resultRow("Correct per minute", String(format: "%.1f", viewModel.correctPerMinute), icon: "checkmark.circle")
                    Divider()
                    resultRow("Correct on first try", "\(viewModel.correctCount) / \(viewModel.answeredCount)", icon: "star")
                    Divider()
                    resultRow("First-try accuracy", viewModel.accuracyText, icon: "scope")
                    if viewModel.skippedCount > 0 {
                        Divider()
                        resultRow("Skipped", "\(viewModel.skippedCount)", icon: "forward")
                    }
                }
                .background(RoundedRectangle(cornerRadius: 18).fill(Color.appBackground))

                VStack(spacing: 12) {
                    Button {
                        focusedField = nil
                        viewModel.restart()
                    } label: {
                        Label("Practice Again", systemImage: "arrow.clockwise")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundStyle(.white)
                            .background(RoundedRectangle(cornerRadius: 14).fill(.accentGradient))
                    }

                    Button("Change Practice") { dismiss() }
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundStyle(Color.brandAccent)
                }
            }
            .padding()
        }
    }

    private func resultRow(_ label: String, _ value: String, icon: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(Color.brandAccent)
                .frame(width: 24)
            Text(label)
            Spacer()
            Text(value)
                .font(.headline.monospacedDigit())
        }
        .padding()
    }

    private var resultEncouragement: String {
        if viewModel.answeredCount == 0 { return "Warm up and try once more—you've got this." }
        if viewModel.accuracy >= 0.9 { return "Fast and accurate. Fantastic work!" }
        if viewModel.accuracy >= 0.7 { return "Strong run. A little more practice will make it feel automatic." }
        return "You challenged yourself. Try again and watch your score grow."
    }
}
