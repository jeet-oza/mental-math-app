//
//  SettingsView.swift
//  Calcathon
//
//  Profile + settings: identity, combined stats, sound/haptics preferences,
//  legal/support links, and account actions.
//

import SwiftUI
import MessageUI

struct SettingsView: View {
    @EnvironmentObject var auth: AuthService
    @EnvironmentObject var curriculum: CurriculumViewModel
    @EnvironmentObject var equationStats: EquationStatsStore
    @EnvironmentObject var gridStats: GridStatsStore
    @Environment(\.dismiss) private var dismiss

    @AppStorage("soundEnabled") private var soundEnabled = true
    @AppStorage("hapticsEnabled") private var hapticsEnabled = true

    @State private var showDeleteConfirm = false
    @State private var showMailCompose = false
    @State private var showMailUnavailable = false

    var body: some View {
        NavigationStack {
            ZStack {
                BrandBackground()
                ScrollView {
                    VStack(spacing: 20) {
                        profileCard
                        statsCard
                        preferencesCard
                        legalCard
                        accountActions
                        #if DEBUG
                        debugCard
                        #endif
                    }
                    .padding()
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
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
            .sheet(isPresented: $showMailCompose) {
                MailComposeView(
                    recipient: IssueReport.recipient,
                    subject: IssueReport.subject,
                    body: IssueReport.body(uid: auth.user?.uid)
                )
            }
            .alert("No Mail account set up", isPresented: $showMailUnavailable) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Email us directly at \(IssueReport.recipient) to report a problem.")
            }
        }
    }

    private var profileCard: some View {
        VStack(spacing: 12) {
            AvatarView(name: auth.user?.displayName ?? "Player", size: 72)
            Text(auth.user?.displayName ?? "Player")
                .font(.title2.bold())
                .foregroundStyle(.white)
            Text("Calcathon player")
                .font(.subheadline)
                .foregroundStyle(Color.brandAccent)
        }
        .frame(maxWidth: .infinity)
        .card(padding: 20)
    }

    private var statsCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Your Stats").font(.headline).foregroundStyle(.white)
            statRow("Lessons completed", "\(lessonsCompleted) / \(totalLessons)")
            statRow("Equation games", "\(equationStats.stats.gamesPlayed)")
            statRow("Equation best", "\(equationStats.stats.bestGameScore)")
            statRow("Grid games", "\(gridStats.stats.gamesPlayed)")
            statRow("Grid best", "\(gridStats.stats.bestGameScore)")
        }
        .card()
    }

    private var preferencesCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Preferences").font(.headline).foregroundStyle(.white)
            Toggle("Sound", isOn: $soundEnabled).tint(Color.brandAccent)
            Toggle("Haptics", isOn: $hapticsEnabled).tint(Color.brandAccent)
        }
        .foregroundStyle(.white)
        .card()
    }

    private var legalCard: some View {
        VStack(spacing: 0) {
            NavigationLink { PrivacyPolicyView() } label: {
                linkRowLabel("Privacy Policy", systemImage: "hand.raised.fill")
            }
            Divider().overlay(Color.hairline)
            Button(action: reportProblemTapped) {
                linkRowLabel("Report a Problem", systemImage: "exclamationmark.bubble.fill")
            }
            Divider().overlay(Color.hairline)
            HStack {
                Label("Version", systemImage: "info.circle")
                Spacer()
                Text(appVersion).foregroundStyle(.white.opacity(0.6))
            }
            .foregroundStyle(.white)
            .padding()
        }
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.appBackground)
                .shadow(color: .black.opacity(0.06), radius: 8, y: 4)
        )
    }

    private func linkRowLabel(_ title: String, systemImage: String) -> some View {
        HStack {
            Label(title, systemImage: systemImage).foregroundStyle(.white)
            Spacer()
            Image(systemName: "chevron.right").foregroundStyle(.white.opacity(0.5))
        }
        .padding()
    }

    private func reportProblemTapped() {
        if MFMailComposeViewController.canSendMail() {
            showMailCompose = true
        } else if let url = IssueReport.mailtoURL(uid: auth.user?.uid), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            showMailUnavailable = true
        }
    }

    private var accountActions: some View {
        VStack(spacing: 12) {
            Button {
                curriculum.disableCloudSync()
                auth.signOut()
                dismiss()
            } label: {
                Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .tint(Color.brandAccent)

            Button(role: .destructive) {
                showDeleteConfirm = true
            } label: {
                Label("Delete Account", systemImage: "trash")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .tint(.red)
        }
    }

    #if DEBUG
    private var debugCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Debug").font(.headline).foregroundStyle(.white)
            // Verifies Crashlytics: crash, then relaunch to upload the report.
            Button("Trigger Test Crash", role: .destructive) {
                fatalError("Test crash from Settings")
            }
        }
        .card()
    }
    #endif

    // MARK: - Helpers

    private func statRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label).foregroundStyle(.white.opacity(0.85))
            Spacer()
            Text(value).foregroundStyle(.white.opacity(0.6)).monospacedDigit()
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
