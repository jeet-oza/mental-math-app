//
//  TrickView.swift
//  MentalMathApp
//
//  Displays the mental math trick explanation before practice begins.
//

import SwiftUI

/// Shows the trick name, step-by-step instructions, and a worked example.
/// User taps "Start Practice" to begin the quiz.
struct TrickView: View {
    let lesson: Lesson

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Trick header
                trickHeader

                // Steps
                stepsSection

                // Worked example
                exampleSection

                // Start practice button
                startPracticeButton
            }
            .padding()
        }
        .navigationTitle(lesson.title)
        .background(Color(.systemGroupedBackground))
    }

    // MARK: - Subviews

    private var trickHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(lesson.trick.name, systemImage: "lightbulb.fill")
                .font(.title2.bold())
                .foregroundStyle(.orange)

            Text(lesson.description)
                .font(.body)
                .foregroundStyle(.secondary)
        }
    }

    private var stepsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("How it works")
                .font(.headline)

            ForEach(Array(lesson.trick.steps.enumerated()), id: \.offset) { index, step in
                HStack(alignment: .top, spacing: 12) {
                    Text("\(index + 1)")
                        .font(.caption.bold())
                        .foregroundStyle(.white)
                        .frame(width: 24, height: 24)
                        .background(Circle().fill(.orange))

                    Text(step)
                        .font(.body)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
        )
    }

    private var exampleSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Example")
                .font(.headline)

            // Problem
            Text(lesson.trick.example.problem)
                .font(.title.monospaced())
                .foregroundStyle(.orange)

            // Step-by-step
            ForEach(lesson.trick.example.stepByStepExplanation, id: \.self) { step in
                Text(step)
                    .font(.body.monospaced())
                    .foregroundStyle(.secondary)
            }

            // Answer
            HStack {
                Text("= \(lesson.trick.example.solution)")
                    .font(.title2.bold().monospaced())
                    .foregroundStyle(.green)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
        )
    }

    private var startPracticeButton: some View {
        NavigationLink(destination: PracticeView(lesson: lesson)) {
            Text("Start Practice")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .foregroundStyle(.white)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(.orange)
                )
        }
        .padding(.top, 8)
    }
}

#Preview {
    NavigationStack {
        TrickView(lesson: LessonCatalog.basicAdditionGroup.lessons[0])
    }
}
