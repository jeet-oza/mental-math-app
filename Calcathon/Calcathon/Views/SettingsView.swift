//
//  SettingsView.swift
//  Calcathon
//
//  Local preferences, support, privacy, and progress controls.
//

import SwiftUI
import MessageUI

struct SettingsView: View {
    @EnvironmentObject private var curriculum: CurriculumViewModel
    @Environment(\.dismiss) private var dismiss

    @AppStorage("soundEnabled") private var soundEnabled = true
    @AppStorage("hapticsEnabled") private var hapticsEnabled = true

    @State private var showResetConfirm = false
    @State private var showMailCompose = false
    @State private var showMailUnavailable = false

    var body: some View {
        NavigationStack {
            ZStack {
                BrandBackground()
                ScrollView {
                    VStack(spacing: 20) {
                        localCard
                        progressCard
                        preferencesCard
                        legalCard
                        resetButton
                    }
                    .padding()
                }
            }
            .navigationTitle("Settings")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .confirmationDialog(
                "Reset all learning progress?",
                isPresented: $showResetConfirm,
                titleVisibility: .visible
            ) {
                Button("Reset Progress", role: .destructive) {
                    curriculum.resetAllProgress()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This clears lesson checkmarks and best scores stored on this device.")
            }
            .sheet(isPresented: $showMailCompose) {
                MailComposeView(
                    recipient: IssueReport.recipient,
                    subject: IssueReport.subject,
                    body: IssueReport.body()
                )
            }
            .alert("No Mail account set up", isPresented: $showMailUnavailable) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Email us directly at \(IssueReport.recipient) to report a problem.")
            }
        }
    }

    private var localCard: some View {
        VStack(spacing: 12) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 44))
                .foregroundStyle(Color.brandAccent)
            Text("No account needed")
                .font(.title2.bold())
                .foregroundStyle(.white)
            Text("Your learning progress stays on this device.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(.white.opacity(0.75))
        }
        .frame(maxWidth: .infinity)
        .card(padding: 20)
    }

    private var progressCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Learning Progress")
                .font(.headline)
                .foregroundStyle(.white)
            statRow("Lessons completed", "\(lessonsCompleted) / \(totalLessons)")
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
                linkRowLabel("Privacy", systemImage: "hand.raised.fill")
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

    private var resetButton: some View {
        Button(role: .destructive) {
            showResetConfirm = true
        } label: {
            Label("Reset Learning Progress", systemImage: "arrow.counterclockwise")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
        .tint(.red)
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
        } else if let url = IssueReport.mailtoURL(), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            showMailUnavailable = true
        }
    }

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
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
}
