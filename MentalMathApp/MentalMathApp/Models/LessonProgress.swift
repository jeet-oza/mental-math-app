//
//  LessonProgress.swift
//  MentalMathApp
//
//  Tracks user progress through lessons and groups.
//

import Foundation

/// Tracks completion status for a single lesson.
struct LessonProgress: Codable, Equatable {
    let lessonId: String
    var isCompleted: Bool
    var bestScore: Int
    var attemptsCount: Int

    init(lessonId: String) {
        self.lessonId = lessonId
        self.isCompleted = false
        self.bestScore = 0
        self.attemptsCount = 0
    }

    /// Records a practice attempt.
    /// - Parameter score: The score achieved (e.g., correct answers out of total).
    mutating func recordAttempt(score: Int) {
        attemptsCount += 1
        bestScore = max(bestScore, score)
    }

    /// Marks the lesson as completed.
    mutating func markCompleted() {
        isCompleted = true
    }
}

/// Tracks completion for an entire lesson group.
struct GroupProgress: Codable, Equatable {
    let groupId: String
    var lessonProgresses: [LessonProgress]

    /// Whether all lessons in the group are completed.
    var isGroupCompleted: Bool {
        lessonProgresses.allSatisfy { $0.isCompleted }
    }

    /// Number of completed lessons.
    var completedCount: Int {
        lessonProgresses.filter { $0.isCompleted }.count
    }

    /// Completion percentage (0.0 to 1.0).
    var completionPercentage: Double {
        guard !lessonProgresses.isEmpty else { return 0 }
        return Double(completedCount) / Double(lessonProgresses.count)
    }
}
