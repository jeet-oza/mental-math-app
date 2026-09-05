//
//  MathVisualizationView.swift
//  Calcathon
//
//  Operation-matched math layouts used by lessons, hints, and practice.
//

import SwiftUI

/// Keeps the mathematical notation visible while arranging it in the form a
/// learner would use on paper. The visual changes with the operation instead
/// of applying one decorative treatment to every kind of question.
struct MathProblemVisualView: View {
    let problem: MathProblem
    var answerText: String? = nil
    var compact = false

    var body: some View {
        Group {
            switch problem.operation {
            case .addition, .subtraction, .multiplication, .decimalMultiplication:
                verticalArithmetic
            case .division, .divisionWithRemainder:
                divisionLayout
            case .fractionAddition, .fractionSubtraction,
                 .fractionMultiplication, .fractionDivision:
                fractionLayout
            case .percentage, .percentageIncrease, .percentageDecrease:
                percentageLayout
            default:
                naturalLayout
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, compact ? 8 : 14)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(problem.displayText) equals \(answerText ?? "unknown")")
    }

    private var verticalArithmetic: some View {
        VStack(spacing: compact ? 4 : 7) {
            VStack(alignment: .trailing, spacing: 1) {
                Text(firstOperandText)
                HStack(spacing: compact ? 10 : 16) {
                    Text(problem.operation.symbol)
                        .foregroundStyle(Color.brandAccent)
                    Text(secondOperandText)
                }
                Rectangle()
                    .fill(Color.brandAccent)
                    .frame(height: compact ? 2 : 3)
                Text(answerText ?? "?")
                    .foregroundStyle(answerText == nil ? Color.secondary : Color.successGreen)
                    .padding(.top, 2)
            }
            .font(.system(
                size: compact ? 30 : 42,
                weight: .bold,
                design: .monospaced
            ))
            .fixedSize()

            Text(problem.displayText)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var divisionLayout: some View {
        VStack(spacing: 8) {
            HStack(alignment: .bottom, spacing: 7) {
                Text("\(problem.operandB)")
                    .padding(.bottom, 2)

                VStack(alignment: .leading, spacing: 2) {
                    Text(answerText ?? "?")
                        .foregroundStyle(answerText == nil ? Color.secondary : Color.successGreen)
                        .frame(maxWidth: .infinity, alignment: .center)
                    HStack(spacing: 0) {
                        Rectangle()
                            .fill(Color.brandAccent)
                            .frame(width: 3)
                        Text("\(problem.operandA)")
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .overlay(alignment: .top) {
                                Rectangle().fill(Color.brandAccent).frame(height: 3)
                            }
                    }
                }
            }
            .font(.system(size: compact ? 28 : 38, weight: .bold, design: .monospaced))
            .fixedSize()

            Text(problem.displayText)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var fractionLayout: some View {
        VStack(spacing: 10) {
            HStack(spacing: compact ? 12 : 18) {
                FractionToken(fraction: problem.fractionA, compact: compact)
                Text(problem.operation.symbol)
                    .font(.title2.bold())
                    .foregroundStyle(Color.brandAccent)
                FractionToken(fraction: problem.fractionB, compact: compact)
                Text("=")
                    .foregroundStyle(.secondary)
                Text(answerText ?? "?")
                    .font(.system(size: compact ? 25 : 32, weight: .bold, design: .rounded))
                    .foregroundStyle(answerText == nil ? Color.secondary : Color.successGreen)
            }

            Text(problem.displayText)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var percentageLayout: some View {
        VStack(spacing: 10) {
            HStack(alignment: .firstTextBaseline, spacing: 7) {
                Text("\(problem.operandA)%")
                    .font(.system(size: compact ? 28 : 38, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.brandAccent)
                Text(percentageRelationship)
                    .font(.headline)
                    .foregroundStyle(.secondary)
                Text("\(problem.operandB)")
                    .font(.system(size: compact ? 28 : 38, weight: .bold, design: .rounded))
            }

            GeometryReader { geometry in
                let fraction = min(max(Double(problem.operandA) / 100, 0), 1)
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.white.opacity(0.10))
                    Capsule()
                        .fill(.brandGradient)
                        .frame(width: geometry.size.width * fraction)
                }
            }
            .frame(maxWidth: 260)
            .frame(height: 12)

            HStack(spacing: 7) {
                Text(problem.displayText)
                Text("=")
                Text(answerText ?? "?")
                    .foregroundStyle(answerText == nil ? Color.secondary : Color.successGreen)
            }
            .font(.subheadline.bold())
        }
    }

    private var naturalLayout: some View {
        HStack(spacing: 10) {
            Text(problem.displayText)
                .foregroundStyle(.primary)
            Text("=")
                .foregroundStyle(.secondary)
            Text(answerText ?? "?")
                .foregroundStyle(answerText == nil ? Color.secondary : Color.successGreen)
        }
        .font(.system(size: compact ? 28 : 40, weight: .bold, design: .rounded))
        .minimumScaleFactor(0.6)
        .lineLimit(1)
    }

    private var firstOperandText: String {
        problem.operation == .decimalMultiplication
            ? problem.fractionA.decimalText
            : "\(problem.operandA)"
    }

    private var secondOperandText: String {
        problem.operation == .decimalMultiplication
            ? problem.fractionB.decimalText
            : "\(problem.operandB)"
    }

    private var percentageRelationship: String {
        switch problem.operation {
        case .percentageIncrease: return "more than"
        case .percentageDecrease: return "less than"
        default: return "of"
        }
    }
}

private struct FractionToken: View {
    let fraction: Fraction
    let compact: Bool

    var body: some View {
        VStack(spacing: 2) {
            Text("\(fraction.numerator)")
            Rectangle().fill(Color.primary).frame(width: compact ? 30 : 38, height: 2)
            Text("\(fraction.denominator)")
        }
        .font(.system(size: compact ? 20 : 25, weight: .bold, design: .rounded))
    }
}

/// Worked examples use the same paper layout as practice when the source text
/// is a simple arithmetic expression, and retain their natural notation for
/// special techniques such as roots and percentages.
struct WorkedExampleVisualView: View {
    let example: TrickExample
    var compact = false

    var body: some View {
        if let equation = ParsedStackedEquation(problem: example.problem) {
            VStack(spacing: 6) {
                VStack(alignment: .trailing, spacing: 2) {
                    Text(equation.top)
                    HStack(spacing: compact ? 10 : 14) {
                        Text(equation.symbol).foregroundStyle(Color.brandAccent)
                        Text(equation.bottom)
                    }
                    Rectangle().fill(Color.brandAccent).frame(height: 2)
                    Text(example.solution)
                        .foregroundStyle(Color.successGreen)
                        .padding(.top, 2)
                }
                .font(.system(size: compact ? 26 : 36, weight: .bold, design: .monospaced))
                .fixedSize()

                Text(example.problem)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("\(example.problem) equals \(example.solution)")
        } else {
            VStack(spacing: compact ? 5 : 8) {
                Text(example.problem)
                    .foregroundStyle(Color.brandAccent)
                Image(systemName: "arrow.down")
                    .font(.subheadline.bold())
                    .foregroundStyle(.secondary)
                Text(example.solution)
                    .foregroundStyle(Color.successGreen)
            }
            .font(.system(size: compact ? 23 : 29, weight: .bold, design: .rounded))
            .minimumScaleFactor(0.65)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
        }
    }
}

private struct ParsedStackedEquation {
    let top: String
    let bottom: String
    let symbol: String

    init?(problem: String) {
        for candidate in ["×", "+", "−", "-"] {
            let parts = problem.components(separatedBy: candidate)
            guard parts.count == 2 else { continue }
            let left = parts[0].trimmingCharacters(in: .whitespaces)
            let right = parts[1].trimmingCharacters(in: .whitespaces)
            guard Self.looksLikeNumber(left), Self.looksLikeNumber(right) else { continue }
            top = left
            bottom = right
            symbol = candidate == "-" ? "−" : candidate
            return
        }
        return nil
    }

    private static func looksLikeNumber(_ value: String) -> Bool {
        guard !value.isEmpty else { return false }
        let allowed = CharacterSet(charactersIn: "0123456789.,/ ")
        return value.unicodeScalars.allSatisfy(allowed.contains)
    }
}
