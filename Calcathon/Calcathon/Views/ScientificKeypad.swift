//
//  ScientificKeypad.swift
//  Calcathon
//
//  The keypad for lessons whose answers are expressions rather than plain
//  whole numbers. Keys are declared per-lesson so a player is only ever shown
//  symbols that can appear in the answer they are being asked for.
//
//  No lesson uses this yet — trigonometry is the first that will. Adding a
//  function row (sin, cos, tan) means adding cases to `Key` and listing them
//  in a `KeySet`; nothing else has to change.
//

import SwiftUI

/// One key on the scientific keypad.
enum ScientificKey: Hashable {
    case digit(Int)
    case decimalPoint
    case symbol(String)   // √, ∛, π, ^, (, ), ÷, ×, −, +
    case delete
    case clear

    /// What the key types into the expression. Nil for the editing keys.
    var insertion: String? {
        switch self {
        case let .digit(value): return "\(value)"
        case .decimalPoint: return "."
        case let .symbol(text): return text
        case .delete, .clear: return nil
        }
    }

    var label: String {
        switch self {
        case let .digit(value): return "\(value)"
        case .decimalPoint: return "."
        case let .symbol(text): return text
        case .delete: return "⌫"
        case .clear: return "C"
        }
    }
}

/// The symbol rows a lesson wants. Digits, delete and clear are always present.
struct ScientificKeySet: Equatable {
    /// Symbol keys, laid out one array per row.
    let symbolRows: [[String]]

    /// Roots, fractions and constants — enough for surd-shaped answers such as
    /// `√2÷2`. This is the set trigonometry will start from.
    static let roots = ScientificKeySet(symbolRows: [
        ["√", "∛", "π", "^"],
        ["(", ")", "÷", "−"]
    ])
}

/// A keypad that appends tokens to an expression string.
struct ScientificKeypad: View {
    @Binding var expression: String
    var keySet: ScientificKeySet = .roots

    private let spacing: CGFloat = 8

    var body: some View {
        VStack(spacing: spacing) {
            ForEach(Array(keySet.symbolRows.enumerated()), id: \.offset) { _, row in
                HStack(spacing: spacing) {
                    ForEach(row, id: \.self) { symbol in
                        key(.symbol(symbol), tint: Color.brandAccent)
                    }
                }
            }

            ForEach([[1, 2, 3], [4, 5, 6], [7, 8, 9]], id: \.self) { row in
                HStack(spacing: spacing) {
                    ForEach(row, id: \.self) { digit in
                        key(.digit(digit))
                    }
                }
            }

            HStack(spacing: spacing) {
                key(.decimalPoint)
                key(.digit(0))
                key(.delete)
            }
        }
    }

    private func key(_ key: ScientificKey, tint: Color = .primary) -> some View {
        Button {
            apply(key)
        } label: {
            Text(key.label)
                .font(.title3.bold())
                .foregroundStyle(tint)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(RoundedRectangle(cornerRadius: 10).fill(Color.appBackground))
        }
        .accessibilityLabel(Text(accessibilityName(for: key)))
    }

    private func apply(_ key: ScientificKey) {
        switch key {
        case .delete:
            if !expression.isEmpty { expression.removeLast() }
        case .clear:
            expression.removeAll()
        default:
            if let insertion = key.insertion { expression.append(insertion) }
        }
    }

    private func accessibilityName(for key: ScientificKey) -> String {
        switch key {
        case .delete: return "Delete"
        case .clear: return "Clear"
        case .decimalPoint: return "Decimal point"
        case let .digit(value): return "\(value)"
        case let .symbol(text):
            switch text {
            case "√": return "Square root"
            case "∛": return "Cube root"
            case "π": return "Pi"
            case "^": return "To the power of"
            case "(": return "Open bracket"
            case ")": return "Close bracket"
            case "÷": return "Divided by"
            case "−": return "Minus"
            default: return text
            }
        }
    }
}

#Preview {
    ScientificKeypad(expression: .constant("√2÷2"))
        .padding()
        .background(Color.groupedBackground)
}
