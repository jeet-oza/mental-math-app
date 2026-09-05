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

    /// Which answer field holds the keyboard, so drawing on the pad can let it go.
    @FocusState private var focusedField: AnswerField?

    /// Whether the scientific keypad is up. It costs real estate the way the
    /// system keyboard does, so it plays by the same rule: a touch on the
    /// scratch pad puts it away, a tap on the answer bar brings it back.
    @State private var isKeypadUp = true
    /// Help is revealed in small layers and starts fresh for every question.
    @State private var hintLevel = 0

    private enum AnswerField: Hashable {
        case answer, remainder
    }

    init(lesson: Lesson) {
        _viewModel = StateObject(wrappedValue: PracticeViewModel(lesson: lesson))
    }

    var body: some View {
        ZStack {
            BrandBackground()

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
        .onAppear {
            // A pad remembered from last time means the player wants room to
            // write, so the keypad starts down; the answer bar calls it back.
            if isScratchPadVisible { isKeypadUp = false }
        }
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(!viewModel.isSessionComplete)
        #endif
    }

    // MARK: - Practice Content

    private var practiceContent: some View {
        // The pad and a keypad together want every point they can get, so the
        // gaps close up whenever the pad is out.
        VStack(spacing: isScratchPadVisible ? 12 : 24) {
            // Progress header
            progressHeader

            Spacer(minLength: 0)

            // Problem display
            if let problem = viewModel.currentProblem {
                problemDisplay(problem)

                PracticeHintView(
                    lesson: viewModel.lesson,
                    problem: problem,
                    level: $hintLevel
                )
            }

            // Feedback
            if let feedback = viewModel.feedbackMessage {
                feedbackBanner(feedback)
            }

            if isScratchPadVisible {
                ScratchPad(strokes: $scratchStrokes, onDrawingBegan: dismissKeypad)
                    .frame(
                        minHeight: isKeypadShowing ? 80 : 140,
                        maxHeight: isKeypadShowing ? 132 : nil
                    )
            } else {
                Spacer(minLength: 0)
            }

            // Input and actions
            inputSection

            // Score bar
            scoreBar
        }
        .padding()
        .onChange(of: viewModel.currentProblem?.id) { _, _ in
            scratchStrokes.removeAll()
            hintLevel = 0
        }
        .onChange(of: hintLevel) { _, newLevel in
            if newLevel > 0 { dismissKeypad() }
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

            Button(action: toggleScratchPad) {
                Image(systemName: isScratchPadVisible ? "pencil.circle.fill" : "pencil.circle")
                    .font(.title3)
                    .foregroundStyle(isScratchPadVisible ? Color.brandAccent : .secondary)
            }
            .accessibilityLabel(Text(isScratchPadVisible ? "Hide scratch pad" : "Show scratch pad"))
        }
    }

    private func problemDisplay(_ problem: MathProblem) -> some View {
        MathProblemVisualView(problem: problem, compact: isScratchPadVisible)
            .padding(.horizontal)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.appBackground.opacity(0.70))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(Color.white.opacity(0.06), lineWidth: 1)
                    )
            )
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

            // Action buttons. A revealed answer stays put until Next is
            // pressed, so there is no clock on reading it.
            if viewModel.isAwaitingNext {
                nextButton
            } else {
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
    }

    private var nextButton: some View {
        Button(action: viewModel.advancePastFeedback) {
            Text("Next")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .foregroundStyle(.white)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.accentGradient)
                )
        }
        .accessibilityHint(Text("Moves on to the next question"))
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
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.appBackground)
                    .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
            )
    }

    /// Expression lessons get a read-only display plus the scientific keypad —
    /// the system keyboard cannot type √ or π. The display doubles as the way
    /// back to the keypad once the scratch pad has sent it away, so the answer
    /// so far stays on screen either way.
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
                .contentShape(Rectangle())
                .onTapGesture(perform: raiseKeypad)
                .accessibilityLabel(Text("Your answer: \(viewModel.userInput)"))
                .accessibilityHint(Text(isKeypadUp ? "" : "Double tap to show the keypad"))

            if isKeypadUp {
                // Shorter keys when the pad is out — the two of them share a
                // screen that fits neither at full height.
                ScientificKeypad(expression: $viewModel.userInput, isCompact: isScratchPadVisible)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
    }

    private var scoreBar: some View {
        HStack {
            Label("\(viewModel.correctCount)", systemImage: "checkmark.circle.fill")
                .foregroundStyle(Color.successGreen)
            Spacer()
            Label("\(viewModel.totalScore) pts", systemImage: "star.fill")
                .foregroundStyle(Color.brandAccent)
        }
        .font(.footnote)
        .padding(.horizontal)
    }

    // MARK: - Keypad

    /// True when either keypad — the system number pad or the scientific one —
    /// is taking up the bottom of the screen.
    private var isKeypadShowing: Bool {
        viewModel.lesson.answerMode == .expression ? isKeypadUp : focusedField != nil
    }

    /// Touching the scratch pad is the player asking for room to write, so
    /// whichever keypad is up steps aside.
    private func dismissKeypad() {
        focusedField = nil
        guard isKeypadUp else { return }
        withAnimation(.spring(response: 0.3)) { isKeypadUp = false }
    }

    /// Tapping the answer bar calls the keypad back — the counterpart to
    /// tapping a text field, which the system handles on its own.
    private func raiseKeypad() {
        guard !isKeypadUp else { return }
        withAnimation(.spring(response: 0.3)) { isKeypadUp = true }
    }

    /// Opening the pad hands the screen over to writing; closing it hands the
    /// screen back to the keypad.
    private func toggleScratchPad() {
        let willShow = !isScratchPadVisible
        if willShow { focusedField = nil }
        withAnimation(.spring(response: 0.3)) {
            isScratchPadVisible = willShow
            isKeypadUp = !willShow
        }
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
