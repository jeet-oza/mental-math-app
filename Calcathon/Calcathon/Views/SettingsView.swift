//
//  SettingsView.swift
//  Calcathon
//
//  Profile + settings: identity, combined stats, sound/haptics preferences,
//  about, and account actions.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var auth: AuthService
    @EnvironmentObject var curriculum: CurriculumViewModel
    @EnvironmentObject var equationStats: EquationStatsStore
    @EnvironmentObject var gridStats: GridStatsStore
    @Environment(\.dismiss) private var dismiss

    @AppStorage("soundEnabled") private var soundEnabled = true
    @AppStorage("hapticsEnabled") private var hapticsEnabled = true

    @State private var showDeleteConfirm = false

    /// Hosted from /docs via GitHub Pages (enable Pages on the repo).
    private let privacyPolicyURL = URL(string: "https://jeet-oza.github.io/mental-math-app/privacy.html")!

    var body: some View {
        NavigationStack {
            List {
                profileSection
                statsSection
                preferencesSection
                aboutSection
                accountSection
                #if DEBUG
                debugSection
                #endif
            }
            .navigationTitle("Profile")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .alert("Delete Account?", isPresented: $showDeleteConfirm) {
                Button("Delete", role: .destructive) {
                    curriculum.disableCloudSync()
                    Task { await auth.deleteAccount() }
                    dismiss()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This permanently deletes your account and all saved progress. This can't be undone.")
            }
        }
    }

    private var profileSection: some View {
        Section {
            HStack(spacing: 16) {
                BrandMark(size: 56)
                VStack(alignment: .leading, spacing: 2) {
                    Text(auth.user?.displayName ?? "Player")
                        .font(.headline)
                    Text("Calcathon player")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.vertical, 4)
        }
    }

    private var statsSection: some View {
        Section("Your Stats") {
            statRow("Lessons completed", "\(lessonsCompleted) / \(totalLessons)")
            statRow("Equation games", "\(equationStats.stats.gamesPlayed)")
            statRow("Equation best", "\(equationStats.stats.bestGameScore)")
            statRow("Grid games", "\(gridStats.stats.gamesPlayed)")
            statRow("Grid best", "\(gridStats.stats.bestGameScore)")
        }
    }

    private var preferencesSection: some View {
        Section("Preferences") {
            Toggle("Sound", isOn: $soundEnabled)
            Toggle("Haptics", isOn: $hapticsEnabled)
        }
    }

    private var aboutSection: some View {
        Section("About") {
            Link(destination: privacyPolicyURL) {
                Label("Privacy Policy", systemImage: "hand.raised")
            }
            statRow("Version", appVersion)
        }
    }

    private var accountSection: some View {
        Section {
            Button {
                curriculum.disableCloudSync()
                auth.signOut()
                dismiss()
            } label: {
                Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
            }
            Button(role: .destructive) {
                showDeleteConfirm = true
            } label: {
                Label("Delete Account", systemImage: "trash")
            }
        }
    }

    #if DEBUG
    private var debugSection: some View {
        Section("Debug") {
            // Verifies Crashlytics: crash, then relaunch to upload the report.
            Button("Trigger Test Crash", role: .destructive) {
                fatalError("Test crash from Settings")
            }
        }
    }
    #endif

    // MARK: - Helpers

    private func statRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
            Spacer()
            Text(value).foregroundStyle(.secondary).monospacedDigit()
        }
    }

    private var lessonsCompleted: Int {
        curriculum.progressMap.values
            .flatMap(\.lessonProgresses)
            .filter(\.isCompleted)
            .count
    }

    private var totalLessons: Int {
        LessonCatalog.allGroups.reduce(0) { $0 + $1.lessons.count }
    }

    private var appVersion: String {
        let v = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let b = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(v) (\(b))"
    }
}
