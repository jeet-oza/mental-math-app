//
//  LessonModelTests.swift
//  CalcathonTests
//
//  Unit tests for Lesson, LessonGroup, and LessonProgress models.
//

import XCTest
@testable import Calcathon

final class LessonModelTests: XCTestCase {

    // MARK: - Test Fixtures

    private func makeSampleTrick() -> MathTrick {
        MathTrick(
            name: "Add 9 shortcut",
            steps: ["Add 10", "Subtract 1"],
            example: TrickExample(
                problem: "47 + 9",
                solution: "56",
                stepByStepExplanation: ["47 + 10 = 57", "57 - 1 = 56"]
            )
        )
    }

    private func makeSampleLesson(id: String = "add_9") -> Lesson {
        Lesson(
            id: id,
            title: "Adding 9",
            description: "Learn the shortcut for adding 9 to any number.",
            trick: makeSampleTrick(),
            operations: [.addition],
            difficulty: .easy,
            practiceCount: 10
        )
    }

    // MARK: - Lesson Tests

    func testLessonDefaultPracticeCount() {
        let lesson = Lesson(
            id: "test",
            title: "Test",
            description: "Test lesson",
            trick: makeSampleTrick(),
            operations: [.addition]
        )
        XCTAssertEqual(lesson.practiceCount, 10)
    }

    func testLessonCustomPracticeCount() {
        let lesson = Lesson(
            id: "test",
            title: "Test",
            description: "Test",
            trick: makeSampleTrick(),
            operations: [.addition],
            practiceCount: 20
        )
        XCTAssertEqual(lesson.practiceCount, 20)
    }

    // MARK: - LessonGroup Tests

    func testGroupIsLockedWhenRequirementSet() {
        let group = LessonGroup(
            id: "advanced",
            title: "Advanced",
            description: "Advanced tricks",
            iconName: "star.fill",
            lessons: [makeSampleLesson()],
            requiredGroupId: "basic"
        )
        XCTAssertTrue(group.isLocked)
    }

    func testGroupIsUnlockedByDefault() {
        let group = LessonGroup(
            id: "basic",
            title: "Basic",
            description: "Basic tricks",
            iconName: "star",
            lessons: [makeSampleLesson()]
        )
        XCTAssertFalse(group.isLocked)
    }

    func testGroupLessonCount() {
        let group = LessonGroup(
            id: "group",
            title: "Group",
            description: "Test",
            iconName: "star",
            lessons: [makeSampleLesson(id: "a"), makeSampleLesson(id: "b")]
        )
        XCTAssertEqual(group.lessonCount, 2)
    }

    // MARK: - LessonProgress Tests

    func testProgressStartsIncomplete() {
        let progress = LessonProgress(lessonId: "test")
        XCTAssertFalse(progress.isCompleted)
        XCTAssertEqual(progress.bestScore, 0)
        XCTAssertEqual(progress.attemptsCount, 0)
    }

    func testRecordAttemptUpdatesBestScore() {
        var progress = LessonProgress(lessonId: "test")
        progress.recordAttempt(score: 7)
        progress.recordAttempt(score: 5)
        progress.recordAttempt(score: 9)

        XCTAssertEqual(progress.bestScore, 9)
        XCTAssertEqual(progress.attemptsCount, 3)
    }

    func testMarkCompleted() {
        var progress = LessonProgress(lessonId: "test")
        progress.markCompleted()
        XCTAssertTrue(progress.isCompleted)
    }

    // MARK: - GroupProgress Tests

    func testGroupProgressCompletionPercentage() {
        var p1 = LessonProgress(lessonId: "a")
        p1.markCompleted()
        let p2 = LessonProgress(lessonId: "b")

        let groupProgress = GroupProgress(groupId: "group1", lessonProgresses: [p1, p2])

        XCTAssertEqual(groupProgress.completedCount, 1)
        XCTAssertEqual(groupProgress.completionPercentage, 0.5)
        XCTAssertFalse(groupProgress.isGroupCompleted)
    }

    func testGroupProgressFullyCompleted() {
        var p1 = LessonProgress(lessonId: "a")
        p1.markCompleted()
        var p2 = LessonProgress(lessonId: "b")
        p2.markCompleted()

        let groupProgress = GroupProgress(groupId: "group1", lessonProgresses: [p1, p2])

        XCTAssertTrue(groupProgress.isGroupCompleted)
        XCTAssertEqual(groupProgress.completionPercentage, 1.0)
    }

    func testEmptyGroupProgressPercentage() {
        let groupProgress = GroupProgress(groupId: "empty", lessonProgresses: [])
        XCTAssertEqual(groupProgress.completionPercentage, 0.0)
    }
}
