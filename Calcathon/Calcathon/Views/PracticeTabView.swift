//
//  PracticeTabView.swift
//  Calcathon
//
//  Practice Mode tab: a hub for drilling any unlocked concept directly,
//  without going through the Learn lesson flow.
//

import SwiftUI

/// Starts configurable timed sessions or a quick single-technique drill.
struct PracticeTabView: View {
    @EnvironmentObject var viewModel: CurriculumViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                BrandBackground()

                ScrollView {
                    LazyVStack(spacing: 18) {
                        PageHeroCard(
                            eyebrow: "Build confidence",
                            title: "Practice your way",
                            message: "Choose one shortcut or create a mixed, timed round.",
                            icon: "figure.run.circle.fill",
                            accent: .brandAccent
                        )

                        NavigationLink(destination: TimedPracticeSetupView()) {
                            timedPracticeCard
                        }
                        .buttonStyle(.plain)

                        SectionHeading(
                            "Practice one skill",
                            message: "Choose a category, then a 10-question set."
                        )

                        LazyVGrid(
                            columns: [GridItem(.adaptive(minimum: 145), spacing: 12)],
                            spacing: 12
                        ) {
                            ForEach(Array(viewModel.lessonGroups.enumerated()), id: \.element.id) { index, group in
                                NavigationLink(destination: PracticeGroupView(group: group)) {
                                    PracticeCategoryCard(group: group, alternateAccent: index.isMultiple(of: 2))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Practice")
        }
    }

    private var timedPracticeCard: some View {
        HStack(spacing: 14) {
            Image(systemName: "timer.circle.fill")
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 58, height: 58)
                .background(Circle().fill(Color.white.opacity(0.18)))

            VStack(alignment: .leading, spacing: 4) {
                Text("Start a speed round")
                    .font(.title3.bold())
                    .foregroundStyle(.white)
                Text("1–10 minutes • any mix • local stats")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.85))
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(.white.opacity(0.75))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.accentGradient)
                .shadow(color: Color.brandRust.opacity(0.20), radius: 12, y: 7)
        )
    }
}

private struct PracticeCategoryCard: View {
    let group: LessonGroup
    let alternateAccent: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: group.iconName)
                .font(.title2.bold())
                .foregroundStyle(alternateAccent ? Color.brandAccent : Color.brandTeal)
                .frame(width: 46, height: 46)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill((alternateAccent ? Color.brandAccent : Color.brandTeal).opacity(0.14))
                )

            Text(group.title)
                .font(.headline)
                .foregroundStyle(.primary)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack {
                Text("\(group.lessons.count) skills")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 118, alignment: .leading)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.appBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.06), radius: 8, y: 4)
        )
        .accessibilityElement(children: .combine)
    }
}

private struct PracticeGroupView: View {
    let group: LessonGroup

    var body: some View {
        ZStack {
            BrandBackground()

            ScrollView {
                LazyVStack(spacing: 12) {
                    PageHeroCard(
                        eyebrow: "10 questions each",
                        title: group.title,
                        message: group.description,
                        icon: group.iconName,
                        accent: .brandTeal
                    )

                    SectionHeading("Choose a technique")

                    ForEach(group.lessons) { lesson in
                        NavigationLink(destination: PracticeView(lesson: lesson)) {
                            PracticeLessonRow(lesson: lesson)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
        }
        .navigationTitle(group.title)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

/// A single tappable practice row.
private struct PracticeLessonRow: View {
    let lesson: Lesson

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "play.fill")
                .font(.caption.bold())
                .foregroundStyle(.white)
                .frame(width: 34, height: 34)
                .background(Circle().fill(Color.brandAccent))

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
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.appBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                )
        )
        .contentShape(Rectangle())
    }
}

#Preview {
    PracticeTabView()
        .environmentObject(CurriculumViewModel())
}
