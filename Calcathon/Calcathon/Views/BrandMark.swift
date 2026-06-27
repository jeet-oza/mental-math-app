//
//  BrandMark.swift
//  Calcathon
//
//  The Calcathon logo mark — a white "C" in an orange hexagon, matching the
//  app icon. Reused on the splash and onboarding.
//

import SwiftUI

/// A flat-top hexagon (honeycomb cell).
struct Hexagon: Shape {
    func path(in rect: CGRect) -> Path {
        let radius = min(rect.width, rect.height) / 2
        let center = CGPoint(x: rect.midX, y: rect.midY)
        var path = Path()
        for i in 0..<6 {
            let angle = CGFloat(i) * .pi / 3 // 0°, 60°, … (flat-top)
            let point = CGPoint(
                x: center.x + radius * cos(angle),
                y: center.y + radius * sin(angle)
            )
            if i == 0 { path.move(to: point) } else { path.addLine(to: point) }
        }
        path.closeSubpath()
        return path
    }
}

/// The brand mark: an "M" inside an orange hexagon.
struct BrandMark: View {
    var size: CGFloat = 140

    var body: some View {
        ZStack {
            Hexagon()
                .fill(.accentGradient)
                .frame(width: size, height: size)
                .shadow(color: .black.opacity(0.35), radius: size * 0.06, y: size * 0.03)
            Text("C")
                .font(.system(size: size * 0.55, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)
        }
        .accessibilityHidden(true)
    }
}
