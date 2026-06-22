//
//  PracticeView.swift
//  MentalMathApp
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

            Spacer()

            // Input and actions
            inputSection

            // Score bar
            scoreBar
        }
        .padding()
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
                .foregroundStyle(Color.brandPrimary)
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
            // Text field
            TextField("Your answer", text: $viewModel.userInput)
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

            // Action buttons
            HStack(spacing: 16) {
                Button(action: viewModel.skipProblem) {
                    Text("Skip")
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
                    Text("Submit")
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

    private var scoreBar: some View {
        HStack {
            Label("\(viewModel.correctCount)", systemImage: "checkmark.circle.fill")
                .foregroundStyle(.green)
            Spacer()
            Label("\(viewModel.totalScore) pts", systemImage: "star.fill")
                .foregroundStyle(Color.brandPrimary)
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
                            .fill(.brandGradient)
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
