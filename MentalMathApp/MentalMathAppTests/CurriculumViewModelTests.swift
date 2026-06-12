//
//  CurriculumViewModelTests.swift
//  MentalMathAppTests
//
//  Unit tests for CurriculumViewModel.
//

import XCTest
@testable import MentalMathApp

@MainActor
final class CurriculumViewModelTests: XCTestCase {

    private var viewModel: CurriculumViewModel!

    override func setUp() {
        super.setUp()
        // Clear any persisted progress before each test
        UserDefaults.standard.removeObject(forKey: "curriculum_progress")
        viewModel = CurriculumViewModel()
    }

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: "curriculum_progress")
        viewModel = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func testInitialGroupsLoaded() {
        XCTAssertEqual(viewModel.lessonGroups.count, LessonCatalog.allGroups.count)
    }

    func testInitialProgressCreatedForAllGroups() {
        for group in viewModel.lessonGroups {
            XCTAssertNotNil(viewModel.progressMap[group.id])
        }
    }

    // MARK: - Unlock Logic Tests

    func testFirstGroupIsUnlocked() {
        let firstGroup = viewModel.lessonGroups[0]
        XCTAssertTrue(viewModel.isGroupUnlocked(firstGroup))
    }

    func testSecondGroupIsLockedInitially() {
        let secondGroup = viewModel.lessonGroups[1]
        XCTAssertFalse(viewModel.isGroupUnlocked(secondGroup))
    }

    func testSecondGroupUnlocksAfterFirstCompleted() {
        let firstGroup = viewModel.lessonGroups[0]

        // Complete all lessons in the first group
        for lesson in firstGroup.lessons {
            viewModel.recordLessonAttempt(
                lessonId: lesson.id,
                groupId: firstGroup.id,
                score: 10,
                total: 10
            )
        }

        let secondGroup = viewModel.lessonGroups[1]
        XCTAssertTrue(viewModel.isGroupUnlocked(secondGroup))
    }

    // MARK: - Progress Recording Tests

    func testRecordAttemptUpdatesScore() {
        let group = viewModel.lessonGroups[0]
        let lesson = group.lessons[0]

        viewModel.recordLessonAttempt(
            lessonId: lesson.id,
            groupId: group.id,
            score: 7,
            total: 10
        )

        let progress = viewModel.lessonProgress(
            lessonId: lesson.id,
            groupId: group.id
        )
        XCTAssertEqual(progress?.bestScore, 7)
        XCTAssertEqual(progress?.attemptsCount, 1)
    }

    func testPassingScoreMarksCompleted() {
        let group = viewModel.lessonGroups[0]
        let lesson = group.lessons[0]

        viewModel.recordLessonAttempt(
            lessonId: lesson.id,
            groupId: group.id,
            score: 8,
            total: 10
        )

        let progress = viewModel.lessonProgress(
            lessonId: lesson.id,
            groupId: group.id
        )
        XCTAssertTrue(progress?.isCompleted ?? false)
    }

    func testFailingScoreDoesNotComplete() {
        let group = viewModel.lessonGroups[0]
        let lesson = group.lessons[0]

        viewModel.recordLessonAttempt(
            lessonId: lesson.id,
            groupId: group.id,
            score: 5,
            total: 10
        )

        let progress = viewModel.lessonProgress(
            lessonId: lesson.id,
            groupId: group.id
        )
        XCTAssertFalse(progress?.isCompleted ?? true)
    }

    // MARK: - Passing Score Threshold Tests

    func testIsPassingScoreAt70Percent() {
        XCTAssertTrue(viewModel.isPassingScore(score: 7, total: 10))
    }

    func testIsPassingScoreBelow70Percent() {
        XCTAssertFalse(viewModel.isPassingScore(score: 6, total: 10))
    }

    func testIsPassingScoreWithZeroTotal() {
        XCTAssertFalse(viewModel.isPassingScore(score: 0, total: 0))
    }

    // MARK: - Completion Percentage Tests

    func testCompletionPercentageInitiallyZero() {
        let group = viewModel.lessonGroups[0]
        XCTAssertEqual(viewModel.completionPercentage(for: group.id), 0.0)
    }

    func testCompletionPercentageAfterPartialCompletion() {
        let group = viewModel.lessonGroups[0]
        let firstLesson = group.lessons[0]

        viewModel.recordLessonAttempt(
            lessonId: firstLesson.id,
            groupId: group.id,
            score: 10,
            total: 10
        )

        let expected = 1.0 / Double(group.lessons.count)
        XCTAssertEqual(
            viewModel.completionPercentage(for: group.id),
            expected,
            accuracy: 0.01
        )
    }

    // MARK: - Reset Tests

    func testResetClearsAllProgress() {
        let group = viewModel.lessonGroups[0]
        let lesson = group.lessons[0]

        viewModel.recordLessonAttempt(
            lessonId: lesson.id,
            groupId: group.id,
            score: 10,
            total: 10
        )

        viewModel.resetAllProgress()

        let progress = viewModel.lessonProgress(
            lessonId: lesson.id,
            groupId: group.id
        )
        XCTAssertEqual(progress?.bestScore, 0)
        XCTAssertFalse(progress?.isCompleted ?? true)
    }
}
