//
//  PracticeView.swift
//  Calcathon
//
//  The practice quiz view for a lesson. Shows problems one at a time
//  with answer input, skip, and feedback.
//

import SwiftUI

/// Practice session view: displays math problems, accepts answers,
/// and shows results when the session is complete.
struct PracticeView: View {
    @StateObject private var viewModel: PracticeViewModel
    @EnvironmentObject var curriculumVM: CurriculumViewModel
    @Environment(\.dismiss) private var dismiss

    /// Whether the scribble pad is showing. Remembered across sessions so a
    /// player who works things out on paper doesn't re-open it every question.
    @AppStorage("practice_scratchpad_visible") private var isScratchPadVisible = false

    /// Cleared whenever the problem changes — each question starts on a
    /// blank pad.
    @State private var scratchStrokes: [ScratchStroke] = []

    init(lesson: Lesson) {
        _viewModel = StateObject(wrappedValue: PracticeViewModel(lesson: lesson))
    }

    var body: some View {
        ZStack {
            Color.groupedBackground
                .ignoresSafeArea()

            if viewModel.isSessionComplete {
                PracticeResultsView(
                    viewModel: viewModel,
                    onDone: handleCompletion
                )
            } else {
                practiceContent
            }
        }
        .navigationTitle("Practice")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(!viewModel.isSessionComplete)
        #endif
    }

    // MARK: - Practice Content

    private var practiceContent: some View {
        VStack(spacing: 24) {
            // Progress header
            progressHeader

            Spacer()

            // Problem display
            if let problem = viewModel.currentProblem {
                problemDisplay(problem)
            }

            // Feedback
            if let feedback = viewModel.feedbackMessage {
                feedbackBanner(feedback)
            }

            if isScratchPadVisible {
                ScratchPad(strokes: $scratchStrokes)
                    .frame(minHeight: 140)
            } else {
                Spacer()
            }

            // Input and actions
            inputSection

            // Score bar
            scoreBar
        }
        .padding()
        .onChange(of: viewModel.currentProblem?.id) { _, _ in
            scratchStrokes.removeAll()
        }
    }

    // MARK: - Subviews

    private var progressHeader: some View {
        HStack {
            Text("Question \(viewModel.problemNumber) of \(viewModel.totalProblems)")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer()

            Text(viewModel.accuracyText)
                .font(.subheadline.bold())
                .foregroundStyle(Color.brandAccent)

            Button {
                withAnimation(.spring(response: 0.3)) {
                    isScratchPadVisible.toggle()
                }
            } label: {
                Image(systemName: isScratchPadVisible ? "pencil.circle.fill" : "pencil.circle")
                    .font(.title3)
                    .foregroundStyle(isScratchPadVisible ? Color.brandAccent : .secondary)
            }
            .accessibilityLabel(Text(isScratchPadVisible ? "Hide scratch pad" : "Show scratch pad"))
        }
    }

    private func problemDisplay(_ problem: MathProblem) -> some View {
        VStack(spacing: 8) {
            Text(problem.displayText)
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)

            Text("= ?")
                .font(.title)
                .foregroundStyle(.secondary)
        }
        .transition(.scale.combined(with: .opacity))
        .animation(.spring(response: 0.3), value: problem.id)
    }

    private func feedbackBanner(_ message: String) -> some View {
        Text(message)
            .font(.headline)
            .foregroundStyle(viewModel.isCorrectFeedback == true ? .green : .red)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill((viewModel.isCorrectFeedback == true ? Color.green : Color.red)
                        .opacity(0.12))
            )
            .transition(.scale.combined(with: .opacity))
            .animation(.spring(response: 0.3), value: viewModel.feedbackMessage)
    }

    private var inputSection: some View {
        VStack(spacing: 12) {
            answerFields

            // Action buttons
            HStack(spacing: 16) {
                Button(action: viewModel.skipProblem) {
                    Text("Skip")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundStyle(Color.brandAccent)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.brandPrimary, lineWidth: 2)
                        )
                }

                Button(action: viewModel.submitAnswer) {
                    Text("Submit")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundStyle(.white)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.accentGradient)
                        )
                }
                .disabled(!viewModel.canSubmit)
            }
        }
    }

    /// The answer entry, shaped by what the lesson asks for: an expression
    /// built on the scientific keypad, a quotient and a remainder, or a single
    /// whole number.
    @ViewBuilder
    private var answerFields: some View {
        if viewModel.lesson.answerMode == .expression {
            expressionField
        } else if viewModel.wantsRemainder {
            HStack(spacing: 12) {
                numberField("Quotient", text: $viewModel.userInput)
                numberField("Remainder", text: $viewModel.userRemainderInput)
            }
        } else {
            numberField("Your answer", text: $viewModel.userInput)
        }
    }

    private func numberField(_ prompt: String, text: Binding<String>) -> some View {
        TextField(prompt, text: text)
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
    }

    /// Expression lessons get a read-only display plus the scientific keypad —
    /// the system keyboard cannot type √ or π.
    private var expressionField: some View {
        VStack(spacing: 12) {
            Text(viewModel.userInput.isEmpty ? " " : viewModel.userInput)
                .font(.title2.monospaced())
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.appBackground)
                        .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
                )
                .accessibilityLabel(Text("Your answer: \(viewModel.userInput)"))

            ScientificKeypad(expression: $viewModel.userInput)
        }
    }

    private var scoreBar: some View {
        HStack {
            Label("\(viewModel.correctCount)", systemImage: "checkmark.circle.fill")
                .foregroundStyle(.green)
            Spacer()
            Label("\(viewModel.totalScore) pts", systemImage: "star.fill")
                .foregroundStyle(Color.brandAccent)
        }
        .font(.footnote)
        .padding(.horizontal)
    }

    // MARK: - Actions

    private func handleCompletion() {
        // Report results to the curriculum
        let group = curriculumVM.lessonGroups.first { group in
            group.lessons.contains { $0.id == viewModel.lesson.id }
        }
        if let groupId = group?.id {
            curriculumVM.recordLessonAttempt(
                lessonId: viewModel.lesson.id,
                groupId: groupId,
                score: viewModel.correctCount,
                total: viewModel.totalProblems
            )
        }
        dismiss()
    }
}

/// Displays the results after completing a practice session.
struct PracticeResultsView: View {
    let viewModel: PracticeViewModel
    let onDone: () -> Void

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Result icon
            Image(systemName: viewModel.isPassing ? "checkmark.seal.fill" : "xmark.seal.fill")
                .font(.system(size: 72))
                .foregroundStyle(viewModel.isPassing ? .green : .red)

            // Title
            Text(viewModel.isPassing ? "Great job!" : "Keep practicing!")
                .font(.title.bold())

            // Stats
            VStack(spacing: 16) {
                statRow(label: "Correct", value: "\(viewModel.correctCount)/\(viewModel.totalProblems)")
                statRow(label: "Accuracy", value: viewModel.accuracyText)
                statRow(label: "Total Score", value: "\(viewModel.totalScore)")
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.appBackground)
                    .shadow(color: .black.opacity(0.06), radius: 8, y: 4)
            )

            Spacer()

            // Done button
            Button(action: onDone) {
                Text("Done")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundStyle(.white)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(.accentGradient)
                    )
            }
        }
        .padding()
    }

    private func statRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.headline)
                .foregroundStyle(.primary)
        }
    }
}
