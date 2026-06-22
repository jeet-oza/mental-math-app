//
//  PracticeTabView.swift
//  MentalMathApp
//
//  Practice Mode tab: a hub for drilling any unlocked concept directly,
//  without going through the Learn lesson flow.
//

import SwiftUI

/// Lists every unlocked lesson concept and lets the user jump straight into
/// a concept-matched practice session.
struct PracticeTabView: View {
    @EnvironmentObject var viewModel: CurriculumViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(viewModel.lessonGroups) { group in
                        if viewModel.isGroupUnlocked(group) {
                            PracticeGroupSection(group: group)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Practice")
            .background(Color.groupedBackground)
        }
    }
}

/// A section of practice-able lessons for one unlocked group.
private struct PracticeGroupSection: View {
    let group: LessonGroup

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(group.title, systemImage: group.iconName)
                .font(.headline)
                .foregroundStyle(.orange)

            ForEach(group.lessons) { lesson in
                NavigationLink(destination: PracticeView(lesson: lesson)) {
                    PracticeLessonRow(lesson: lesson)
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.appBackground)
                .shadow(color: .black.opacity(0.06), radius: 8, y: 4)
        )
    }
}

/// A single tappable practice row.
private struct PracticeLessonRow: View {
    let lesson: Lesson

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(lesson.title)
                    .font(.subheadline.bold())
                    .foregroundStyle(.primary)
                Text(lesson.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Spacer()
            Image(systemName: "play.circle.fill")
                .font(.title3)
                .foregroundStyle(.orange)
        }
        .padding(.vertical, 6)
        .contentShape(Rectangle())
    }
}

#Preview {
    PracticeTabView()
        .environmentObject(CurriculumViewModel())
}
