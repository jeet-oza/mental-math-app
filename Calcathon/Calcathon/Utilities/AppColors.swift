//
//  AppColors.swift
//  Calcathon
//
//  Cross-platform color definitions for iOS, macOS, and visionOS.
//

import SwiftUI

extension Color {
    /// Deep navy screen background (Wordament-style — never white).
    static let groupedBackground = Color(red: 0.039, green: 0.094, blue: 0.184)  // #0A182F
    /// Slightly lighter navy for cards and panels.
    static let appBackground = Color(red: 0.086, green: 0.161, blue: 0.298)       // #162A4C
    /// Maroon panel accent used for headers/bands, like Wordament.
    static let brandMaroon = Color(red: 0.318, green: 0.067, blue: 0.110)         // #51111C

    // MARK: - Brand Palette (Sophisticated Earthy)

    /// Primary brand color — a deep cobalt/indigo blue.
    static let brandPrimary = Color(red: 0.118, green: 0.251, blue: 0.686)   // #1E40AF
    /// Secondary blue used to give the primary gradient depth.
    static let brandSecondary = Color(red: 0.145, green: 0.388, blue: 0.922) // #2563EB
    /// Warm accent — burnt orange, for calls-to-action and highlights.
    static let brandAccent = Color(red: 0.909, green: 0.498, blue: 0.141)    // #E87F24
    /// Deeper warm accent — rust.
    static let brandRust = Color(red: 0.812, green: 0.294, blue: 0.0)        // #CF4B00
    /// Warm neutral background option.
    static let brandBeige = Color(red: 0.961, green: 0.937, blue: 0.902)     // #F5EFE6

    /// Faint separator on dark card surfaces (dividers, borders).
    static let hairline = Color.white.opacity(0.10)
}

extension ShapeStyle where Self == LinearGradient {
    /// Deep blue gradient for primary surfaces.
    static var brandGradient: LinearGradient {
        LinearGradient(
            colors: [Color.brandPrimary, Color.brandSecondary],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// Warm burnt-orange→rust gradient for the main "Play" call-to-action.
    static var accentGradient: LinearGradient {
        LinearGradient(
            colors: [Color.brandAccent, Color.brandRust],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// Deep navy screen gradient used as the app-wide background.
    static var navyBackground: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.055, green: 0.122, blue: 0.235),  // #0E1F3C
                Color(red: 0.024, green: 0.063, blue: 0.137)   // #061023
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

/// Full-bleed navy gradient background for any screen.
struct BrandBackground: View {
    var body: some View {
        LinearGradient.navyBackground.ignoresSafeArea()
    }
}
