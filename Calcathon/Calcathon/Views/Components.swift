//
//  Components.swift
//  Calcathon
//
//  Small reusable card building blocks.
//

import SwiftUI

// MARK: - Card

/// A rounded card surface, matching the shadowed panels used elsewhere
/// (lesson group cards, settings, and result cards).
struct CardModifier: ViewModifier {
    var padding: CGFloat = 16

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.appBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.white.opacity(0.06), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.06), radius: 8, y: 4)
            )
    }
}

// MARK: - Page hierarchy

/// A compact purpose statement at the top of a main tab. It gives younger
/// learners an obvious starting point without turning the interface into a
/// character-driven kids theme.
struct PageHeroCard: View {
    let eyebrow: String
    let title: String
    let message: String
    let icon: String
    var accent: Color = .brandAccent

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 30, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 58, height: 58)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(accent.opacity(0.90))
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(eyebrow.uppercased())
                    .font(.caption2.bold())
                    .tracking(1.2)
                    .foregroundStyle(.white.opacity(0.70))
                Text(title)
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.78))
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(.brandGradient)
                .overlay(alignment: .topTrailing) {
                    Circle()
                        .fill(Color.white.opacity(0.08))
                        .frame(width: 110, height: 110)
                        .offset(x: 30, y: -35)
                }
        )
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .accessibilityElement(children: .combine)
    }
}

struct SectionHeading: View {
    let title: String
    let message: String?

    init(_ title: String, message: String? = nil) {
        self.title = title
        self.message = message
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.title3.bold())
            if let message {
                Text(message)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

extension View {
    /// Wraps the view in the standard card surface.
    func card(padding: CGFloat = 16) -> some View {
        modifier(CardModifier(padding: padding))
    }
}
