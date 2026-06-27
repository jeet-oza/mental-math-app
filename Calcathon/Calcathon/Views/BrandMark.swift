//
//  BrandMark.swift
//  Calcathon
//
//  The Calcathon logo mark — the app icon presented as a rounded tile.
//  Reused on the splash and onboarding so the in-app logo matches the icon.
//

import SwiftUI

struct BrandMark: View {
    var size: CGFloat = 140

    var body: some View {
        Image("AppLogo")
            .resizable()
            .interpolation(.high)
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: size * 0.225, style: .continuous))
            .shadow(color: .black.opacity(0.35), radius: size * 0.06, y: size * 0.03)
            .accessibilityHidden(true)
    }
}
