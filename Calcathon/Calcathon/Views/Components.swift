//
//  Components.swift
//  Calcathon
//
//  Small reusable building blocks for the card-based Profile screen.
//

import SwiftUI

// MARK: - Card

/// A rounded card surface, matching the shadowed panels used elsewhere
/// (lesson group cards, arena result cards).
struct CardModifier: ViewModifier {
    var padding: CGFloat = 16

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.appBackground)
                    .shadow(color: .black.opacity(0.06), radius: 8, y: 4)
            )
    }
}

extension View {
    /// Wraps the view in the standard card surface.
    func card(padding: CGFloat = 16) -> some View {
        modifier(CardModifier(padding: padding))
    }
}

// MARK: - Avatar

/// A circular monogram avatar with the brand gradient, for players without
/// a profile photo.
struct AvatarView: View {
    let name: String
    var size: CGFloat = 40

    private var initials: String {
        let parts = name.split(separator: " ")
        let letters = parts.prefix(2).compactMap { $0.first }
        let result = String(letters).uppercased()
        return result.isEmpty ? "?" : result
    }

    var body: some View {
        Circle()
            .fill(.brandGradient)
            .frame(width: size, height: size)
            .overlay(
                Text(initials)
                    .font(.system(size: size * 0.4, weight: .semibold))
                    .foregroundStyle(.white)
            )
    }
}
