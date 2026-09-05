//
//  TrickView.swift
//  Calcathon
//
//  Displays the mental math trick explanation before practice begins.
//

import SwiftUI

/// Shows the trick as a visual idea and one or more worked examples.
/// User taps "Start Practice" to begin the quiz.
struct TrickView: View {
    @EnvironmentObject private var curriculumVM: CurriculumViewModel
    @Environment(\.dismiss) private var dismiss

    let lesson: Lesson

    @State private var showSkipConfirmation = false

    var body: some View {
        ZStack {
            BrandBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    trickHeader

                    ideaSection

                    examplesSection

                    startPracticeButton

                    if !isLessonCompleted {
                        skipButton
                    }
                }
                .padding()
            }
        }
        .navigationTitle(lesson.title)
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

    /// Marks the lesson complete and returns to the lesson list.
    private func skipLesson() {
        guard let groupId = enclosingGroup?.id else { return }
        curriculumVM.skipLesson(lessonId: lesson.id, groupId: groupId)
        dismiss()
    }

    // MARK: - Subviews

    private var trickHeader: some View {
        PageHeroCard(
            eyebrow: "Mental math shortcut",
            title: lesson.trick.name,
            message: lesson.description,
            icon: "lightbulb.max.fill",
            accent: .brandAccent
        )
    }

    private var ideaSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeading("The big idea", message: "Follow one connected path—there are no steps to memorize by number.")

            ForEach(Array(lesson.trick.steps.enumerated()), id: \.offset) { index, step in
                HStack(alignment: .top, spacing: 12) {
                    VStack(spacing: 0) {
                        Circle()
                            .fill(index == 0 ? Color.brandAccent : Color.brandTeal)
                            .frame(width: 11, height: 11)
                        if index < lesson.trick.steps.count - 1 {
                            Rectangle()
                                .fill(Color.white.opacity(0.14))
                                .frame(width: 2, height: 32)
                        }
                    }
                    .frame(width: 18)

                    Text(cleanPresentationLabel(step))
                        .font(.body)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .card()
    }

    private var examplesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeading("See it in action", message: "The layout matches how the numbers relate on paper.")

            ForEach(Array(lesson.trick.examples.enumerated()), id: \.offset) { _, example in
                exampleCard(example)
            }
        }
    }

    private func exampleCard(_ example: TrickExample) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            WorkedExampleVisualView(example: example)
                .frame(maxWidth: .infinity)
                .padding(.bottom, 4)

            ForEach(explanationLines(for: example), id: \.self) { line in
                HStack(alignment: .firstTextBaseline, spacing: 10) {
                    Image(systemName: "arrow.turn.down.right")
                        .font(.caption.bold())
                        .foregroundStyle(Color.brandTeal)
                        .frame(width: 18)
                    Text(line)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .card()
    }

    /// Older lesson data contains presentation labels such as "Step 2:".
    /// Strip those labels at the view boundary so the catalog can stay focused
    /// on the mathematical wording while the UI presents one connected idea.
    private func explanationLines(for example: TrickExample) -> [String] {
        example.stepByStepExplanation.compactMap { raw in
            if raw.range(of: #"^Answer\s*:"#, options: .regularExpression) != nil {
                return nil
            }
            return raw.replacingOccurrences(
                of: #"^Step\s+\d+\s*:\s*"#,
                with: "",
                options: .regularExpression
            )
        }
    }

    private func cleanPresentationLabel(_ text: String) -> String {
        text.replacingOccurrences(
            of: #"^Step\s+\d+\s*:\s*"#,
            with: "",
            options: .regularExpression
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
            Text("This marks the lesson as already known. You can still practice it any time.")
        }
    }
}

#Preview {
    NavigationStack {
        TrickView(lesson: LessonCatalog.basicAdditionGroup.lessons[0])
    }
    .environmentObject(CurriculumViewModel())
}
