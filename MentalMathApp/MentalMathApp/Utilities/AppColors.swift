//
//  AppColors.swift
//  MentalMathApp
//
//  Cross-platform color definitions for iOS, macOS, and visionOS.
//

import SwiftUI

extension Color {
    #if canImport(UIKit)
    static let groupedBackground = Color(UIColor.systemGroupedBackground)
    static let appBackground = Color(UIColor.systemBackground)
    #elseif canImport(AppKit)
    static let groupedBackground = Color(NSColor.windowBackgroundColor)
    static let appBackground = Color(NSColor.controlBackgroundColor)
    #endif

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
}
