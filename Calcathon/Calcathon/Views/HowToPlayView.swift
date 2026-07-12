//
//  HowToPlayView.swift
//  Calcathon
//
//  Mode-specific "How to Play" sheet, shown the first time a player joins
//  Equation Arena or Grid Arena, and reopenable anytime from the landing
//  screen for a refresher.
//

import SwiftUI

struct HowToPlayStep: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let body: String
}

struct HowToPlaySheet: View {
    let icon: String
    let title: String
    let subtitle: String
    let steps: [HowToPlayStep]
    var buttonTitle: String = "Let's Play"
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            BrandBackground()

            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 24) {
                        VStack(spacing: 12) {
                            Image(systemName: icon)
                                .font(.system(size: 48))
                                .foregroundStyle(Color.brandAccent)
                            Text(title)
                                .font(.system(size: 28, weight: .heavy, design: .rounded))
                                .foregroundStyle(.white)
                            Text(subtitle)
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.7))
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 24)

                        VStack(spacing: 14) {
                            ForEach(steps) { step in
                                stepRow(step)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                }

                Button(action: onDismiss) {
                    Text(buttonTitle)
                        .font(.title3.bold())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .foregroundStyle(.white)
                        .background(RoundedRectangle(cornerRadius: 28).fill(.accentGradient))
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
            }
        }
    }

    private func stepRow(_ step: HowToPlayStep) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: step.icon)
                .font(.title2)
                .foregroundStyle(Color.brandAccent)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 4) {
                Text(step.title)
                    .font(.headline)
                    .foregroundStyle(.white)
                Text(step.body)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.75))
            }

            Spacer(minLength: 0)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.06))
        )
    }
}

// MARK: - Mode content

extension HowToPlaySheet {
    static func equationArena(buttonTitle: String = "Let's Play", onDismiss: @escaping () -> Void) -> HowToPlaySheet {
        HowToPlaySheet(
            icon: "flame.fill",
            title: "Equation Arena",
            subtitle: "Solve as many equations as you can before time runs out.",
            steps: [
                HowToPlayStep(icon: "clock.fill", title: "90 seconds, non-stop",
                              body: "A new equation appears the instant you answer. Keep going until the timer hits zero."),
                HowToPlayStep(icon: "square.grid.2x2.fill", title: "Type your answer",
                              body: "Use the keypad to enter your answer, then submit. Stuck? Skip it — there's no penalty."),
                HowToPlayStep(icon: "bolt.fill", title: "Build a streak",
                              body: "Consecutive correct answers raise your score multiplier, up to 2×."),
                HowToPlayStep(icon: "trophy.fill", title: "Everyone plays together",
                              body: "All players get the same equations, starting at the same time. Check the leaderboard once the round ends.")
            ],
            buttonTitle: buttonTitle,
            onDismiss: onDismiss
        )
    }

    static func gridArena(buttonTitle: String = "Let's Play", onDismiss: @escaping () -> Void) -> HowToPlaySheet {
        HowToPlaySheet(
            icon: "square.grid.3x3.fill",
            title: "Number Grid",
            subtitle: "Trace paths of tiles that satisfy each round's rule.",
            steps: [
                HowToPlayStep(icon: "hand.draw.fill", title: "Drag across tiles",
                              body: "Trace a path of 2 or more adjacent tiles — including diagonals. Lift your finger to bank it."),
                HowToPlayStep(icon: "checkmark.seal.fill", title: "Satisfy the rule",
                              body: "Each round shows a rule above the grid, like \"make a multiple of 10\" or \"hit exactly 24.\" Your path's sum has to match it."),
                HowToPlayStep(icon: "star.fill", title: "Chase the bonus tiers",
                              body: "Hitting a higher multiple of the rule scores a ×2 or ×5 bonus. Longer paths score more too."),
                HowToPlayStep(icon: "arrow.triangle.2.circlepath", title: "Find them all",
                              body: "Every valid combination only counts once — keep tracing new paths until time runs out.")
            ],
            buttonTitle: buttonTitle,
            onDismiss: onDismiss
        )
    }
}
