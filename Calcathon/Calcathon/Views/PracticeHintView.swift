//
//  PracticeHintView.swift
//  Calcathon
//
//  Optional, progressively revealed help for regular and timed practice.
//

import SwiftUI

struct PracticeHintView: View {
    let lesson: Lesson?
    let problem: MathProblem
    @Binding var level: Int

    private let maximumLevel = 3

    var body: some View {
        VStack(spacing: 10) {
            if level == 0 {
                Button { revealNext() } label: {
                    Label("Need a hint?", systemImage: "lightbulb")
                        .font(.subheadline.bold())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 11)
                        .foregroundStyle(Color.brandAccent)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.brandAccent.opacity(0.10))
                        )
                }
            } else {
                hintCard
            }
        }
        .animation(.spring(response: 0.32), value: level)
    }

    private var hintCard: some View {
        VStack(alignment: .leading, spacing: 11) {
            HStack {
                Label(hintTitle, systemImage: hintIcon)
                    .font(.subheadline.bold())
                    .foregroundStyle(Color.brandAccent)
                Spacer()
                Text("Hint \(level) of \(maximumLevel)")
                    .font(.caption2.bold())
                    .foregroundStyle(.secondary)
            }

            hintContent

            if level < maximumLevel {
                Button { revealNext() } label: {
                    Label("Show another hint", systemImage: "plus.circle")
                        .font(.caption.bold())
                }
                .foregroundStyle(Color.brandAccent)
                .frame(minHeight: 32)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.appBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.brandAccent.opacity(0.35), lineWidth: 1)
                )
        )
        .transition(.opacity.combined(with: .move(edge: .top)))
    }

    @ViewBuilder
    private var hintContent: some View {
        switch level {
        case 1:
            Text(strategyCue)
                .font(.subheadline)
                .fixedSize(horizontal: false, vertical: true)
        case 2:
            VStack(alignment: .leading, spacing: 7) {
                ForEach(methodReminders, id: \.self) { reminder in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "arrow.turn.down.right")
                            .font(.caption.bold())
                            .foregroundStyle(Color.brandAccent)
                            .frame(width: 18, height: 18)
                        Text(reminder)
                            .font(.subheadline)
                    }
                }
            }
        default:
            similarExample
        }
    }

    @ViewBuilder
    private var similarExample: some View {
        if let example = lesson?.trick.examples.first {
            VStack(alignment: .leading, spacing: 8) {
                Text("Try the same idea on this example:")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                WorkedExampleVisualView(example: example, compact: true)
            }
        } else {
            VStack(alignment: .leading, spacing: 8) {
                Text("Try the same setup on a smaller example:")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                WorkedExampleVisualView(example: openPracticeExample, compact: true)
            }
        }
    }

    private var hintTitle: String {
        switch level {
        case 1: return "Spot the idea"
        case 2: return "Use the method"
        default: return "See a similar example"
        }
    }

    private var hintIcon: String {
        switch level {
        case 1: return "eye.fill"
        case 2: return "arrow.triangle.branch"
        default: return "rectangle.and.pencil.and.ellipsis"
        }
    }

    private var strategyCue: String {
        if let lesson {
            return "Look for “\(lesson.trick.name)”. Start by noticing which numbers are easiest to work with."
        }
        switch problem.operation {
        case .addition:
            return "Look for a friendly ten or hundred. Break one addend apart if that makes the sum easier."
        case .subtraction:
            return "Look at the distance between the numbers. Counting up can be easier than taking away."
        case .multiplication:
            return "Break one factor into place values, then combine the smaller products."
        case .division, .divisionWithRemainder:
            return "Ask: what number multiplied by the divisor gets to the dividend?"
        default:
            return "Name the relationship first, then choose the smallest step you can solve confidently."
        }
    }

    private var methodReminders: [String] {
        if let lesson {
            return Array(lesson.trick.steps.prefix(3)).map(Self.cleanPresentationLabel)
        }
        switch problem.operation {
        case .addition:
            return ["Line up the place values.", "Combine ones, then tens, then hundreds.", "Check whether regrouping makes a new ten."]
        case .subtraction:
            return ["Line up the place values.", "Work from ones toward the left.", "Regroup one ten or hundred only when you need it."]
        case .multiplication:
            return ["Write the factors one above the other.", "Split the lower factor into place values.", "Add the partial products."]
        case .division, .divisionWithRemainder:
            return ["Put the divisor outside the bracket.", "Estimate a quotient digit.", "Multiply back to check it fits."]
        default:
            return ["Use the operation shown in the question.", "Keep each small result visible.", "Estimate once to check your final size."]
        }
    }

    private var openPracticeExample: TrickExample {
        switch problem.operation {
        case .addition:
            return TrickExample(problem: "27 + 15", solution: "42", stepByStepExplanation: [])
        case .subtraction:
            return TrickExample(problem: "52 − 18", solution: "34", stepByStepExplanation: [])
        case .multiplication:
            return TrickExample(problem: "23 × 4", solution: "92", stepByStepExplanation: [])
        case .division, .divisionWithRemainder:
            return TrickExample(problem: "84 ÷ 7", solution: "12", stepByStepExplanation: [])
        default:
            return TrickExample(problem: problem.displayText, solution: "Use the relationship", stepByStepExplanation: [])
        }
    }

    private func revealNext() {
        guard level < maximumLevel else { return }
        level += 1
    }

    private static func cleanPresentationLabel(_ text: String) -> String {
        text.replacingOccurrences(
            of: #"^Step\s+\d+\s*:\s*"#,
            with: "",
            options: .regularExpression
        )
    }
}
