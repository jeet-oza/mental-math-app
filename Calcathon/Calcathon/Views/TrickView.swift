//
//  TrickView.swift
//  Calcathon
//
//  Displays the mental math trick explanation before practice begins.
//

import SwiftUI

/// Shows the trick name, step-by-step instructions, and a worked example.
/// User taps "Start Practice" to begin the quiz.
struct TrickView: View {
    @EnvironmentObject private var curriculumVM: CurriculumViewModel
    @Environment(\.dismiss) private var dismiss

    let lesson: Lesson

    @State private var showSkipConfirmation = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Trick header
                trickHeader

                // Steps
                stepsSection

                // Worked example(s)
                examplesSection

                // Start practice button
                startPracticeButton

                // Skip option for players who already know the trick
                if !isLessonCompleted {
                    skipButton
                }
            }
            .padding()
        }
        .navigationTitle(lesson.title)
        .background(Color.groupedBackground)
    }

    // MARK: - Skip Support

    /// The group that contains this lesson, used to record progress.
    private var enclosingGroup: LessonGroup? {
        curriculumVM.lessonGroups.first { group in
            group.lessons.contains { $0.id == lesson.id }
        }
    }

    /// Whether this lesson is already marked complete.
    private var isLessonCompleted: Bool {
        guard let groupId = enclosingGroup?.id else { return false }
        return curriculumVM.lessonProgress(
            lessonId: lesson.id,
            groupId: groupId
        )?.isCompleted ?? false
    }

    /// Marks the lesson complete and returns to the lesson list. Skipping every
    /// lesson in a group unlocks the next category, same as practicing them.
    private func skipLesson() {
        guard let groupId = enclosingGroup?.id else { return }
        curriculumVM.skipLesson(lessonId: lesson.id, groupId: groupId)
        dismiss()
    }

    // MARK: - Subviews

    private var trickHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(lesson.trick.name, systemImage: "lightbulb.fill")
                .font(.title2.bold())
                .foregroundStyle(Color.brandAccent)

            Text(lesson.description)
                .font(.body)
                .foregroundStyle(.secondary)
        }
    }

    private var stepsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("How it works")
                .font(.headline)

            ForEach(Array(lesson.trick.steps.enumerated()), id: \.offset) { index, step in
                HStack(alignment: .top, spacing: 12) {
                    Text("\(index + 1)")
                        .font(.caption.bold())
                        .foregroundStyle(.white)
                        .frame(width: 24, height: 24)
                        .background(Circle().fill(Color.brandPrimary))

                    Text(step)
                        .font(.body)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.appBackground)
                .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
        )
    }

    private var examplesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(lesson.trick.examples.count > 1 ? "Examples" : "Example")
                .font(.headline)

            ForEach(Array(lesson.trick.examples.enumerated()), id: \.offset) { _, example in
                exampleCard(example)
            }
        }
    }

    private func exampleCard(_ example: TrickExample) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Problem
            Text(example.problem)
                .font(.title.monospaced())
                .foregroundStyle(Color.brandAccent)

            // Step-by-step
            ForEach(example.stepByStepExplanation, id: \.self) { step in
                Text(step)
                    .font(.body.monospaced())
                    .foregroundStyle(.secondary)
            }

            // Answer
            HStack {
                Text("= \(example.solution)")
                    .font(.title2.bold().monospaced())
                    .foregroundStyle(.green)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.appBackground)
                .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
        )
    }

    private var startPracticeButton: some View {
        NavigationLink(destination: PracticeView(lesson: lesson)) {
            Text("Start Practice")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .foregroundStyle(.white)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(.accentGradient)
                )
        }
        .padding(.top, 8)
    }

    private var skipButton: some View {
        Button {
            showSkipConfirmation = true
        } label: {
            Text("I already know this — Skip")
                .font(.subheadline.bold())
                .frame(maxWidth: .infinity)
                .padding()
                .foregroundStyle(Color.brandAccent)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.brandPrimary, lineWidth: 2)
                )
        }
        .confirmationDialog(
            "Skip practice for this lesson?",
            isPresented: $showSkipConfirmation,
            titleVisibility: .visible
        ) {
            Button("Mark as Known") { skipLesson() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This marks the lesson complete so you can move on. "
                 + "Finish every lesson in this group to unlock the next category.")
        }
    }
}

#Preview {
    NavigationStack {
        TrickView(lesson: LessonCatalog.basicAdditionGroup.lessons[0])
    }
    .environmentObject(CurriculumViewModel())
}
