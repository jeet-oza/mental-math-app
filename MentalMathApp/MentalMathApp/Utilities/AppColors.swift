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
}
