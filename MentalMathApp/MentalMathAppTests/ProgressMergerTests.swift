//
//  ProgressMergerTests.swift
//  MentalMathAppTests
//
//  Verifies local/remote progress reconciliation keeps the strongest result.
//

import XCTest
@testable import MentalMathApp

final class ProgressMergerTests: XCTestCase {

    private func lesson(_ id: String, score: Int, attempts: Int, completed: Bool) -> LessonProgress {
        var p = LessonProgress(lessonId: id)
        p.bestScore = score
        p.attemptsCount = attempts
        if completed { p.markCompleted() }
        return p
    }

    func testKeepsHigherScoreAndAttemptsAndCompletion() {
        let local = ["g": GroupProgress(groupId: "g", lessonProgresses: [
            lesson("a", score: 8, attempts: 3, completed: false)
        ])]
        let remote = ["g": GroupProgress(groupId: "g", lessonProgresses: [
            lesson("a", score: 5, attempts: 7, completed: true)
        ])]

        let merged = ProgressMerger.merge(local: local, remote: remote)
        let a = merged["g"]!.lessonProgresses.first { $0.lessonId == "a" }!
        XCTAssertEqual(a.bestScore, 8)      // local higher
        XCTAssertEqual(a.attemptsCount, 7)  // remote higher
        XCTAssertTrue(a.isCompleted)        // remote completed
    }

    func testAddsRemoteOnlyGroupsAndLessons() {
        let local = ["g1": GroupProgress(groupId: "g1", lessonProgresses: [
            lesson("a", score: 1, attempts: 1, completed: false)
        ])]
        let remote = [
            "g1": GroupProgress(groupId: "g1", lessonProgresses: [
                lesson("b", score: 2, attempts: 1, completed: false)
            ]),
            "g2": GroupProgress(groupId: "g2", lessonProgresses: [
                lesson("c", score: 9, attempts: 2, completed: true)
            ])
        ]

        let merged = ProgressMerger.merge(local: local, remote: remote)
        XCTAssertEqual(Set(merged["g1"]!.lessonProgresses.map(\.lessonId)), ["a", "b"])
        XCTAssertNotNil(merged["g2"])
        XCTAssertTrue(merged["g2"]!.lessonProgresses.first!.isCompleted)
    }

    func testEmptyRemoteKeepsLocalUnchanged() {
        let local = ["g": GroupProgress(groupId: "g", lessonProgresses: [
            lesson("a", score: 4, attempts: 2, completed: true)
        ])]
        let merged = ProgressMerger.merge(local: local, remote: [:])
        XCTAssertEqual(merged, local)
    }
}
