//
//  LearnTabView.swift
//  MentalMathApp
//
//  Learn Mode tab: displays lesson groups with progress and unlock state.
//

import SwiftUI

/// The Learn Mode tab showing grouped lessons with progress tracking.
struct LearnTabView: View {
    @EnvironmentObject var viewModel: CurriculumViewModel
    @EnvironmentObject var auth: AuthService

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(viewModel.lessonGroups) { group in
                        LessonGroupCard(
                            group: group,
                            isUnlocked: viewModel.isGroupUnlocked(group),
                            completionPercentage: viewModel.completionPercentage(for: group.id)
                        )
                    }
                }
                .padding()
            }
            .navigationTitle("Learn")
            .background(Color.groupedBackground)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        if let name = auth.user?.displayName {
                            Text("Signed in as \(name)")
                        }
                        Button(role: .destructive) {
                            viewModel.disableCloudSync()
                            auth.signOut()
                        } label: {
                            Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                        }
                    } label: {
                        Image(systemName: "person.crop.circle")
                    }
                }
            }
        }
    }
}

/// Card displaying a lesson group with icon, progress bar, and lock state.
struct LessonGroupCard: View {
    let group: LessonGroup
    let isUnlocked: Bool
    let completionPercentage: Double

    var body: some View {
        NavigationLink(destination: LessonListView(group: group)) {
            HStack(spacing: 16) {
                // Icon
                Image(systemName: group.iconName)
                    .font(.title)
                    .foregroundStyle(isUnlocked ? Color.brandAccent : .gray)
                    .frame(width: 48, height: 48)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(isUnlocked
                                  ? Color.brandAccent.opacity(0.18)
                                  : Color.gray.opacity(0.1))
                    )

                // Title & Description
                VStack(alignment: .leading, spacing: 4) {
                    Text(group.title)
                        .font(.headline)
                        .foregroundStyle(isUnlocked ? .white : .secondary)

                    Text(group.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)

                    // Progress bar
                    if isUnlocked {
                        ProgressView(value: completionPercentage)
                            .tint(Color.brandAccent)
                    }
                }

                Spacer()

                // Lock icon
                if !isUnlocked {
                    Image(systemName: "lock.fill")
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.appBackground)
                    .shadow(color: .black.opacity(0.06), radius: 8, y: 4)
            )
        }
        .buttonStyle(.plain)
        .disabled(!isUnlocked)
    }
}

#Preview {
    LearnTabView()
        .environmentObject(CurriculumViewModel())
}
