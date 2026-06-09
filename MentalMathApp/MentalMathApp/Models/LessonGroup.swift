//
//  LessonGroup.swift
//  MentalMathApp
//
//  Model representing a group of related lessons.
//

import Foundation

/// A thematic group of lessons (e.g., "Basic Addition", "Multiplication Tricks").
/// Groups are displayed in Learn Mode and can be locked/unlocked based on progress.
struct LessonGroup: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    let description: String
    let iconName: String
    let lessons: [Lesson]
    let requiredGroupId: String?

    /// Whether this group is locked behind completing another group.
    var isLocked: Bool {
        requiredGroupId != nil
    }

    /// Total number of lessons in this group.
    var lessonCount: Int {
        lessons.count
    }

    /// Creates a LessonGroup.
    /// - Parameters:
    ///   - id: Unique identifier.
    ///   - title: Display title for the group.
    ///   - description: Brief description of what this group covers.
    ///   - iconName: SF Symbol name for display.
    ///   - lessons: The lessons contained in this group.
    ///   - requiredGroupId: ID of the group that must be completed first. Nil if unlocked by default.
    init(
        id: String,
        title: String,
        description: String,
        iconName: String,
        lessons: [Lesson],
        requiredGroupId: String? = nil
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.iconName = iconName
        self.lessons = lessons
        self.requiredGroupId = requiredGroupId
    }
}
