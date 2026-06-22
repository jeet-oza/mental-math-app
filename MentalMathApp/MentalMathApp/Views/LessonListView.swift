//
//  LessonListView.swift
//  MentalMathApp
//
//  Displays the individual lessons within a lesson group.
//

import SwiftUI

/// Shows all lessons in a group with completion status and navigation to trick/practice.
struct LessonListView: View {
    @EnvironmentObject var curriculumVM: CurriculumViewModel
    let group: LessonGroup

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(group.lessons) { lesson in
                    LessonRow(
                        lesson: lesson,
                        progress: curriculumVM.lessonProgress(
                            lessonId: lesson.id,
                            groupId: group.id
                        )
                    )
                }
            }
            .padding()
        }
        .navigationTitle(group.title)
        .background(Color.groupedBackground)
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
                    .foregroundStyle(isCompleted ? .green : .secondary)

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
                        .foregroundStyle(Color.brandPrimary)
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
                    .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
            )
        }
    }
}
