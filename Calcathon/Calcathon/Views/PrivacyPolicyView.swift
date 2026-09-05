//
//  PrivacyPolicyView.swift
//  Calcathon
//
//  Plain-language privacy information for the local-only app.
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

                    Text("Calcathon is designed to work without an account or an internet connection.")
                        .foregroundStyle(.white.opacity(0.9))

                    section(icon: "hand.raised.fill", title: "Information we collect") {
                        Text("We do not ask for a name, email address, account, or username. Calcathon does not include advertising or cross-app tracking.")
                    }

                    section(icon: "iphone", title: "Data on your device") {
                        Text("Lesson progress and preferences are saved locally on this device so the app can remember them. They are not uploaded by Calcathon.")
                    }

                    section(icon: "trash.fill", title: "Data retention & deletion") {
                        Text("You can erase saved lesson progress at any time from Settings → Reset Learning Progress. Removing the app also removes its local data.")
                    }

                    section(icon: "figure.child", title: "Children's privacy") {
                        Text("Calcathon can be used by children because it does not request or collect personal information through an account or public profile.")
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

    private static let effectiveDate = "September 4, 2026"

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
