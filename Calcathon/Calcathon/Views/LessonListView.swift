//
//  LessonListView.swift
//  Calcathon
//
//  Displays the individual lessons within a lesson group.
//

import SwiftUI

/// Shows all lessons in a group with completion status and navigation to trick/practice.
struct LessonListView: View {
    @EnvironmentObject var curriculumVM: CurriculumViewModel
    @Environment(\.dismiss) private var dismiss
    let group: LessonGroup

    @State private var showSkipConfirmation = false

    var body: some View {
        ZStack {
            BrandBackground()

            ScrollView {
                LazyVStack(spacing: 12) {
                    PageHeroCard(
                        eyebrow: "Choose any lesson",
                        title: group.title,
                        message: group.description,
                        icon: group.iconName,
                        accent: .brandTeal
                    )

                    ForEach(group.lessons) { lesson in
                        LessonRow(
                            lesson: lesson,
                            progress: curriculumVM.lessonProgress(
                                lessonId: lesson.id,
                                groupId: group.id
                            )
                        )
                    }

                    // Let experienced learners mark a whole category as known.
                    if !isGroupCompleted {
                        skipGroupButton
                    }
                }
                .padding()
            }
        }
        .navigationTitle(group.title)
    }

    // MARK: - Skip Category

    /// Whether every lesson in this group is already complete.
    private var isGroupCompleted: Bool {
        curriculumVM.completionPercentage(for: group.id) >= 1.0
    }

    private var skipGroupButton: some View {
        Button {
            showSkipConfirmation = true
        } label: {
            Label("I know all these — Skip category", systemImage: "checkmark.circle")
                .font(.subheadline.bold())
                .frame(maxWidth: .infinity)
                .padding()
                .foregroundStyle(Color.brandAccent)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.brandPrimary, lineWidth: 2)
                )
        }
        .padding(.top, 4)
        .confirmationDialog(
            "Skip practice for this category?",
            isPresented: $showSkipConfirmation,
            titleVisibility: .visible
        ) {
            Button("Mark All as Known") {
                curriculumVM.skipGroup(groupId: group.id)
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This marks every lesson here as already known. They remain available to practice.")
        }
    }
}

/// A single lesson row showing title, description, and completion state.
struct LessonRow: View {
    let lesson: Lesson
    let progress: LessonProgress?

    private var isCompleted: Bool {
        progress?.isCompleted ?? false
    }

    var body: some View {
        NavigationLink(destination: TrickView(lesson: lesson)) {
            HStack(spacing: 12) {
                // Completion indicator
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(isCompleted ? Color.successGreen : .secondary)

                VStack(alignment: .leading, spacing: 2) {
                    Text(lesson.title)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Text(lesson.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                if let best = progress?.bestScore, best > 0 {
                    Text("Best: \(best)")
                        .font(.caption2)
                        .foregroundStyle(Color.brandAccent)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.brandPrimary.opacity(0.12))
                        )
                }

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.appBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.06), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
            )
        }
    }
}
