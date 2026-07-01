//
//  CurriculumViewModelTests.swift
//  CalcathonTests
//
//  Unit tests for CurriculumViewModel.
//

import XCTest
@testable import Calcathon

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

    // MARK: - Catalog Reconciliation Tests

    /// Persists a progress map to the same key CurriculumViewModel loads from.
    private func persist(_ map: [String: GroupProgress]) {
        let data = try! JSONEncoder().encode(map)
        UserDefaults.standard.set(data, forKey: "curriculum_progress")
    }

    private func completed(_ lessonId: String) -> LessonProgress {
        var p = LessonProgress(lessonId: lessonId)
        p.markCompleted()
        return p
    }

    func testLoadAddsProgressEntriesForNewLessons() {
        // Simulate a save from an older app version that only knew one lesson
        // of the first group. The lesson added since must get an entry so it
        // can be completed (and gate the next group correctly).
        let group = LessonCatalog.basicAdditionGroup
        let firstLessonId = group.lessons[0].id
        persist([group.id: GroupProgress(
            groupId: group.id,
            lessonProgresses: [completed(firstLessonId)]
        )])

        let vm = CurriculumViewModel()

        for lesson in group.lessons {
            XCTAssertNotNil(
                vm.lessonProgress(lessonId: lesson.id, groupId: group.id),
                "\(lesson.id) should have a progress entry after reconciliation"
            )
        }
        // Only one of the group's lessons was complete, so the group is not
        // finished and the next group stays locked.
        XCTAssertFalse(vm.isGroupUnlocked(vm.lessonGroups[1]))
    }

    func testNewLessonCanBeCompletedAfterReconciliation() {
        let group = LessonCatalog.basicAdditionGroup
        persist([group.id: GroupProgress(
            groupId: group.id,
            lessonProgresses: [completed(group.lessons[0].id)]
        )])

        let vm = CurriculumViewModel()
        let newLesson = group.lessons[1]
        vm.recordLessonAttempt(lessonId: newLesson.id, groupId: group.id, score: 10, total: 10)

        XCTAssertTrue(
            vm.lessonProgress(lessonId: newLesson.id, groupId: group.id)?.isCompleted ?? false
        )
    }

    func testLoadPrunesOrphanedLessonProgress() {
        // An older save had an extra lesson that no longer exists and was never
        // completed. It must be dropped so it can't block group completion.
        let group = LessonCatalog.basicAdditionGroup
        var lessons = group.lessons.map { completed($0.id) }
        lessons.append(LessonProgress(lessonId: "removed_lesson")) // incomplete orphan
        persist([group.id: GroupProgress(groupId: group.id, lessonProgresses: lessons)])

        let vm = CurriculumViewModel()

        XCTAssertNil(vm.lessonProgress(lessonId: "removed_lesson", groupId: group.id))
        // With the orphan gone and all real lessons complete, the next group unlocks.
        XCTAssertTrue(vm.isGroupUnlocked(vm.lessonGroups[1]))
    }

    // MARK: - Skip Lesson Tests

    func testSkipLessonMarksCompleted() {
        let group = viewModel.lessonGroups[0]
        let lesson = group.lessons[0]

        viewModel.skipLesson(lessonId: lesson.id, groupId: group.id)

        let progress = viewModel.lessonProgress(
            lessonId: lesson.id,
            groupId: group.id
        )
        XCTAssertTrue(progress?.isCompleted ?? false)
    }

    func testSkipLessonDoesNotCountAsAttempt() {
        let group = viewModel.lessonGroups[0]
        let lesson = group.lessons[0]

        viewModel.skipLesson(lessonId: lesson.id, groupId: group.id)

        let progress = viewModel.lessonProgress(
            lessonId: lesson.id,
            groupId: group.id
        )
        XCTAssertEqual(progress?.attemptsCount, 0)
        XCTAssertEqual(progress?.bestScore, 0)
    }

    func testSkippingAllLessonsUnlocksNextGroup() {
        let firstGroup = viewModel.lessonGroups[0]

        for lesson in firstGroup.lessons {
            viewModel.skipLesson(lessonId: lesson.id, groupId: firstGroup.id)
        }

        let secondGroup = viewModel.lessonGroups[1]
        XCTAssertTrue(viewModel.isGroupUnlocked(secondGroup))
    }

    func testSkipGroupCompletesEveryLesson() {
        let group = viewModel.lessonGroups[0]

        viewModel.skipGroup(groupId: group.id)

        for lesson in group.lessons {
            let progress = viewModel.lessonProgress(
                lessonId: lesson.id,
                groupId: group.id
            )
            XCTAssertTrue(progress?.isCompleted ?? false)
        }
        XCTAssertEqual(viewModel.completionPercentage(for: group.id), 1.0, accuracy: 0.001)
    }

    func testSkipGroupUnlocksNextGroup() {
        let firstGroup = viewModel.lessonGroups[0]

        viewModel.skipGroup(groupId: firstGroup.id)

        let secondGroup = viewModel.lessonGroups[1]
        XCTAssertTrue(viewModel.isGroupUnlocked(secondGroup))
    }

    func testSkipGroupDoesNotCountAsAttempts() {
        let group = viewModel.lessonGroups[0]

        viewModel.skipGroup(groupId: group.id)

        for lesson in group.lessons {
            let progress = viewModel.lessonProgress(
                lessonId: lesson.id,
                groupId: group.id
            )
            XCTAssertEqual(progress?.attemptsCount, 0)
            XCTAssertEqual(progress?.bestScore, 0)
        }
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
