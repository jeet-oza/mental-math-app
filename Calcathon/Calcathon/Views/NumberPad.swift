//
//  NumberPad.swift
//  Calcathon
//
//  Custom on-screen numeric keypad for the Equation Arena — faster and more
//  stable than the system keyboard for the timed, speed-based loop.
//

import SwiftUI

struct NumberPad: View {
    let onDigit: (Int) -> Void
    let onDelete: () -> Void
    let onSubmit: () -> Void
    var submitDisabled: Bool = false

    private let rows = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
    private let spacing: CGFloat = 10

    var body: some View {
        VStack(spacing: spacing) {
            ForEach(rows, id: \.self) { row in
                HStack(spacing: spacing) {
                    ForEach(row, id: \.self) { digit in
                        digitKey(digit)
                    }
                }
            }
            HStack(spacing: spacing) {
                deleteKey
                digitKey(0)
                submitKey
            }
        }
    }

    private func digitKey(_ digit: Int) -> some View {
        Button { onDigit(digit) } label: {
            Text("\(digit)")
                .font(.title.bold().monospacedDigit())
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.appBackground))
        }
        .accessibilityLabel(Text("\(digit)"))
    }

    private var deleteKey: some View {
        Button(action: onDelete) {
            Image(systemName: "delete.left.fill")
                .font(.title3)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.appBackground))
        }
        .accessibilityLabel(Text("Delete"))
    }

    private var submitKey: some View {
        Button(action: onSubmit) {
            Image(systemName: "checkmark")
                .font(.title3.bold())
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(submitDisabled ? AnyShapeStyle(Color.gray.opacity(0.4)) : AnyShapeStyle(.accentGradient))
                )
        }
        .disabled(submitDisabled)
        .accessibilityLabel(Text("Submit"))
    }
}
