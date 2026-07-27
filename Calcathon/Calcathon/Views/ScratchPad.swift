//
//  ScratchPad.swift
//  Calcathon
//
//  A freehand scribble surface for working out carries and partial products.
//  Nothing drawn here is ever read as an answer — it is the on-screen
//  equivalent of the margin of a page.
//

import SwiftUI

/// A single freehand stroke: the points the finger passed through, in order.
struct ScratchStroke: Identifiable, Equatable {
    let id = UUID()
    var points: [CGPoint]
}

/// A drawing surface sized by its container. Strokes are held by the parent so
/// it can clear them when the problem changes.
struct ScratchPad: View {
    @Binding var strokes: [ScratchStroke]

    /// Tracks whether the current drag is extending a stroke already started,
    /// so `onChanged` appends instead of beginning a new one every frame.
    @State private var isDrawing = false

    private let inkWidth: CGFloat = 2.5

    var body: some View {
        ZStack(alignment: .topTrailing) {
            canvas
            controls
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.appBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.hairline, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var canvas: some View {
        Canvas { context, _ in
            for stroke in strokes {
                context.stroke(
                    path(for: stroke),
                    with: .color(Color.brandBeige),
                    style: StrokeStyle(lineWidth: inkWidth, lineCap: .round, lineJoin: .round)
                )
            }
        }
        .contentShape(Rectangle())
        .gesture(
            // minimumDistance 0 so a single tap leaves a dot.
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    if isDrawing, !strokes.isEmpty {
                        strokes[strokes.count - 1].points.append(value.location)
                    } else {
                        strokes.append(ScratchStroke(points: [value.location]))
                        isDrawing = true
                    }
                }
                .onEnded { _ in isDrawing = false }
        )
        .accessibilityLabel(Text("Scratch pad"))
        .accessibilityHint(Text("Draw here to work out the problem. This is not your answer."))
    }

    /// A tap produces a one-point stroke, which has no line to draw — give it a
    /// dot instead so the mark still shows up.
    private func path(for stroke: ScratchStroke) -> Path {
        guard let first = stroke.points.first else { return Path() }
        if stroke.points.count == 1 {
            return Path(ellipseIn: CGRect(
                x: first.x - inkWidth / 2,
                y: first.y - inkWidth / 2,
                width: inkWidth,
                height: inkWidth
            ))
        }
        var path = Path()
        path.addLines(stroke.points)
        return path
    }

    private var controls: some View {
        HStack(spacing: 4) {
            Button {
                if !strokes.isEmpty { strokes.removeLast() }
            } label: {
                Image(systemName: "arrow.uturn.backward")
                    .padding(8)
            }
            .accessibilityLabel(Text("Undo last stroke"))

            Button {
                strokes.removeAll()
            } label: {
                Image(systemName: "trash")
                    .padding(8)
            }
            .accessibilityLabel(Text("Clear scratch pad"))
        }
        .font(.footnote)
        .foregroundStyle(.secondary)
        .disabled(strokes.isEmpty)
        .padding(4)
    }
}

#Preview {
    ScratchPad(strokes: .constant([]))
        .frame(height: 220)
        .padding()
        .background(Color.groupedBackground)
}
