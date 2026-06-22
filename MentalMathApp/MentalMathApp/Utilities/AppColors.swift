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

    // MARK: - Brand Palette

    /// Primary brand color — a deep indigo used for accents, icons, and tints.
    static let brandPrimary = Color(red: 0.36, green: 0.31, blue: 0.86)
    /// Secondary brand color — a vivid violet that pairs with the primary.
    static let brandSecondary = Color(red: 0.61, green: 0.35, blue: 0.91)
    /// Accent used for positive/highlight moments — a fresh teal.
    static let brandAccent = Color(red: 0.0, green: 0.71, blue: 0.62)
}

extension ShapeStyle where Self == LinearGradient {
    /// Diagonal indigo→violet gradient for primary call-to-action surfaces.
    static var brandGradient: LinearGradient {
        LinearGradient(
            colors: [Color.brandPrimary, Color.brandSecondary],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
