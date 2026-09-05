//
//  LearnTabView.swift
//  Calcathon
//
//  Learn Mode tab: displays lesson groups with progress and unlock state.
//

import SwiftUI

/// The Learn Mode tab showing grouped lessons with progress tracking.
struct LearnTabView: View {
    @EnvironmentObject var viewModel: CurriculumViewModel
    @State private var showSettings = false

    var body: some View {
        NavigationStack {
            ZStack {
                BrandBackground()

                ScrollView {
                    LazyVStack(spacing: 16) {
                        PageHeroCard(
                            eyebrow: "Learn at your pace",
                            title: "Small ideas. Big shortcuts.",
                            message: "Pick a skill, see why it works, then try it yourself.",
                            icon: "sparkles",
                            accent: .brandTeal
                        )

                        SectionHeading(
                            "Choose a skill",
                            message: "Every lesson is open—start wherever you are curious."
                        )

                        ForEach(Array(viewModel.lessonGroups.enumerated()), id: \.element.id) { index, group in
                            LessonGroupCard(
                                group: group,
                                completionPercentage: viewModel.completionPercentage(for: group.id),
                                position: index + 1
                            )
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Learn")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button { showSettings = true } label: {
                        Image(systemName: "gearshape.fill")
                    }
                    .accessibilityLabel(Text("Settings"))
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
        }
    }
}

/// Card displaying a lesson group with icon, progress bar, and lock state.
struct LessonGroupCard: View {
    let group: LessonGroup
    let completionPercentage: Double
    let position: Int

    var body: some View {
        NavigationLink(destination: LessonListView(group: group)) {
            HStack(spacing: 14) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: group.iconName)
                        .font(.title2.bold())
                        .foregroundStyle(position.isMultiple(of: 2) ? Color.brandTeal : Color.brandAccent)
                        .frame(width: 54, height: 54)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill((position.isMultiple(of: 2) ? Color.brandTeal : Color.brandAccent).opacity(0.14))
                        )

                    Text("\(position)")
                        .font(.caption2.bold())
                        .foregroundStyle(.white)
                        .frame(width: 20, height: 20)
                        .background(Circle().fill(Color.brandPrimary))
                        .offset(x: 5, y: -5)
                }

                // Title & Description
                VStack(alignment: .leading, spacing: 4) {
                    Text(group.title)
                        .font(.headline)
                        .foregroundStyle(.white)

                    Text("\(group.lessons.count) lessons • \(group.description)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)

                    // Progress bar
                    ProgressView(value: completionPercentage)
                        .tint(Color.brandAccent)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 5) {
                    Image(systemName: "chevron.right")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                    if completionPercentage > 0 {
                        Text(completionPercentage >= 1 ? "Done" : "Keep going")
                            .font(.caption2.bold())
                            .foregroundStyle(completionPercentage >= 1 ? Color.successGreen : Color.brandAccent)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.appBackground)
                    .overlay(alignment: .leading) {
                        Capsule()
                            .fill(position.isMultiple(of: 2) ? Color.brandTeal : Color.brandAccent)
                            .frame(width: 4)
                            .padding(.vertical, 16)
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.06), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.06), radius: 8, y: 4)
            )
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(
            "\(group.title). \(Int(completionPercentage * 100)) percent complete"
        ))
    }
}

#Preview {
    LearnTabView()
        .environmentObject(CurriculumViewModel())
}
