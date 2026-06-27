//
//  OnboardingView.swift
//  MentalMathApp
//
//  First-run walkthrough shown once before sign-in, explaining the modes —
//  especially the Grid mechanic, which isn't obvious.
//

import SwiftUI

struct OnboardingView: View {
    let onComplete: () -> Void

    @State private var page = 0

    private struct Page: Identifiable {
        let id = UUID()
        let icon: String
        let title: String
        let body: String
    }

    private let pages: [Page] = [
        Page(icon: "hexagon.fill",
             title: "MathHive",
             body: "Learn the tricks, then race the clock against players worldwide."),
        Page(icon: "book.fill",
             title: "Learn",
             body: "Bite-size lessons teach shortcuts for addition, multiplication, squaring, division, and percentages."),
        Page(icon: "flame.fill",
             title: "Equation Arena",
             body: "Answer as many as you can in 90 seconds. Multiplication is worth 10 points, and fast answers earn a time bonus."),
        Page(icon: "square.grid.3x3.fill",
             title: "Number Grid",
             body: "Drag across adjacent tiles so they add up to a multiple of 10. Longer paths score more — and multiples of 100 earn a bonus.")
    ]

    var body: some View {
        ZStack {
            BrandBackground()

            VStack(spacing: 0) {
                TabView(selection: $page) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, item in
                        pageView(item).tag(index)
                    }
                }
                #if os(iOS)
                .tabViewStyle(.page(indexDisplayMode: .always))
                #endif

                Button(action: advance) {
                    Text(page == pages.count - 1 ? "Get Started" : "Next")
                        .font(.title3.bold())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .foregroundStyle(.white)
                        .background(RoundedRectangle(cornerRadius: 28).fill(.accentGradient))
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 32)
            }
        }
    }

    private func pageView(_ item: Page) -> some View {
        VStack(spacing: 24) {
            Spacer()
            if item.icon == "hexagon.fill" {
                HiveMark(size: 130)
            } else {
                Image(systemName: item.icon)
                    .font(.system(size: 80))
                    .foregroundStyle(Color.brandAccent)
            }
            Text(item.title)
                .font(.system(size: 34, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)
            Text(item.body)
                .font(.body)
                .foregroundStyle(.white.opacity(0.85))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Spacer()
        }
    }

    private func advance() {
        if page < pages.count - 1 {
            withAnimation { page += 1 }
        } else {
            onComplete()
        }
    }
}
