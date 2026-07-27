//
//  PrivacyPolicyView.swift
//  Calcathon
//
//  In-app mirror of docs/privacy.html — keep the two in sync when data
//  collection changes.
//

import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        ZStack {
            BrandBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Effective date: \(Self.effectiveDate)")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))

                    Text("This policy explains how Trioza (\"we\") handles information in the Calcathon app.")
                        .foregroundStyle(.white.opacity(0.9))

                    section(icon: "person.badge.key.fill", title: "Information we collect") {
                        Text("""
                        **Account identifiers.** When you sign in, we create an account identified by a unique ID. If you use Sign in with Apple, we receive (optionally, if you choose) an email or Apple's private relay address; we do not request or store your real name. If you play as a Guest, an anonymous identifier is created on your device. Either way, your leaderboard display name is a randomly generated handle tied to your account ID, not your real name.

                        **Gameplay & progress data.** Lesson progress, practice/arena scores, lifetime statistics, and the display name shown on leaderboards.

                        **Diagnostics.** If the app crashes, we collect crash reports and basic device/diagnostic information (device model, OS version, app version) to fix problems.

                        We do not collect your contacts, location, or browsing activity, and we do not use your data for third-party advertising or cross-app tracking.
                        """)
                    }

                    section(icon: "gearshape.fill", title: "How we use it") {
                        Text("To provide the app's features (save progress across devices, show leaderboards), to operate and improve the app, and to diagnose crashes and bugs.")
                    }

                    section(icon: "cloud.fill", title: "Service providers") {
                        Text("We use Google Firebase (Authentication, Cloud Firestore, and Crashlytics) to authenticate users, store progress and scores, and collect crash diagnostics. Their handling of data is governed by Google's privacy policy.")
                    }

                    section(icon: "list.number", title: "Leaderboards") {
                        Text("Your chosen display name and round scores are visible to other players on the global leaderboard.")
                    }

                    section(icon: "trash.fill", title: "Data retention & deletion") {
                        Text("We keep your data while your account exists. You can delete your account and all associated data at any time from Profile → Delete Account in the app.")
                    }

                    section(icon: "figure.child", title: "Children's privacy") {
                        Text("The app is not directed to children under 13, and we do not knowingly collect personal information from them.")
                    }

                    section(icon: "clock.arrow.circlepath", title: "Changes") {
                        Text("We may update this policy; material changes will be reflected by a new effective date.")
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Privacy Policy")
        .navigationBarTitleDisplayMode(.inline)
    }

    private static let effectiveDate = "June 26, 2026"

    @ViewBuilder
    private func section(icon: String, title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(title, systemImage: icon)
                .font(.headline)
                .foregroundStyle(.white)
            content()
                .foregroundStyle(.white.opacity(0.9))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .card(padding: 16)
    }
}

#Preview {
    NavigationStack { PrivacyPolicyView() }
        .tint(Color.brandAccent)
}
