//
//  CurriculumViewModel.swift
//  Calcathon
//
//  ViewModel for Learn Mode. Manages lesson groups, progress tracking,
//  and unlocking logic for the grouped curriculum.
//

import Combine
import Foundation
import SwiftUI

/// Manages the Learn Mode curriculum state.
/// Handles group/lesson selection, progress persistence, and unlock gating.
@MainActor
final class CurriculumViewModel: ObservableObject {

    // MARK: - Published State

    @Published private(set) var lessonGroups: [LessonGroup]
    @Published private(set) var progressMap: [String: GroupProgress] = [:]
    @Published var selectedGroup: LessonGroup?
    @Published var selectedLesson: Lesson?

    // MARK: - Private

    private let progressKey = "curriculum_progress"

    /// Remote sync boundary. Defaults to offline; replaced once a user signs in.
    private var sync: ProgressSyncing = NoopProgressSync()
    private var isCloudSyncEnabled = false

    // MARK: - Initialization

    init(groups: [LessonGroup] = LessonCatalog.allGroups) {
        self.lessonGroups = groups
        loadProgress()
    }

    // MARK: - Cloud Sync

    /// Enables cloud sync for the signed-in user: pulls remote progress, merges
    /// it with the local cache (keeping the strongest result per lesson), and
    /// pushes the reconciled result back. Safe to call once per session.
    func enableCloudSync(uid: String) async {
        guard !isCloudSyncEnabled else { return }
        isCloudSyncEnabled = true
        sync = FirestoreProgressSync(uid: uid)

        do {
            if let remote = try await sync.fetch() {
                progressMap = ProgressMerger.merge(local: progressMap, remote: remote)
                reconcileWithCatalog() // merge can reintroduce lessons the catalog dropped
                saveProgress() // persists locally and pushes the merged result
            } else {
                // First time on the cloud — seed it with whatever we have locally.
                try await sync.push(progressMap)
            }
        } catch {
            // Stay offline-first: a sync failure must never block local play.
        }
    }

    /// Disables cloud sync (e.g. on sign-out) and reverts to local-only.
    func disableCloudSync() {
        sync = NoopProgressSync()
        isCloudSyncEnabled = false
    }

    // MARK: - Group Unlock Logic

    /// Checks whether a lesson group is unlocked for the user.
    /// - Parameter group: The group to check.
    /// - Returns: True if the group has no prerequisite or its prerequisite is completed.
    func isGroupUnlocked(_ group: LessonGroup) -> Bool {
        guard let requiredId = group.requiredGroupId else { return true }
        return progressMap[requiredId]?.isGroupCompleted ?? false
    }

    /// Returns the completion percentage for a group.
    /// - Parameter groupId: The group identifier.
    /// - Returns: A value between 0.0 and 1.0.
    func completionPercentage(for groupId: String) -> Double {
        progressMap[groupId]?.completionPercentage ?? 0.0
    }

    // MARK: - Lesson Progress

    /// Records a completed practice attempt for a lesson.
    /// - Parameters:
    ///   - lessonId: The lesson that was practiced.
    ///   - groupId: The group containing the lesson.
    ///   - score: Number of correct answers.
    ///   - total: Total number of practice problems.
    func recordLessonAttempt(
        lessonId: String,
        groupId: String,
        score: Int,
        total: Int
    ) {
        ensureGroupProgress(groupId: groupId)

        guard var groupProgress = progressMap[groupId],
              let index = groupProgress.lessonProgresses.firstIndex(
                  where: { $0.lessonId == lessonId }
              ) else { return }

        groupProgress.lessonProgresses[index].recordAttempt(score: score)

        if isPassingScore(score: score, total: total) {
            groupProgress.lessonProgresses[index].markCompleted()
        }

        progressMap[groupId] = groupProgress
        saveProgress()
    }

    /// Marks a lesson complete without a practice session, for players who
    /// already know the trick. This counts toward group completion exactly
    /// like a passing score, so skipping every lesson in a group unlocks the
    /// next category. Leaves `bestScore` and `attemptsCount` untouched —
    /// a skip isn't a practice attempt.
    /// - Parameters:
    ///   - lessonId: The lesson the user chose to skip.
    ///   - groupId: The group containing the lesson.
    func skipLesson(lessonId: String, groupId: String) {
        ensureGroupProgress(groupId: groupId)

        guard var groupProgress = progressMap[groupId],
              let index = groupProgress.lessonProgresses.firstIndex(
                  where: { $0.lessonId == lessonId }
              ) else { return }

        groupProgress.lessonProgresses[index].markCompleted()
        progressMap[groupId] = groupProgress
        saveProgress()
    }

    /// Marks every lesson in a group complete at once, for players who already
    /// know all of its tricks. Completing the group this way unlocks the next
    /// category, same as practicing through it. Leaves scores and attempt
    /// counts untouched — skips aren't practice attempts.
    /// - Parameter groupId: The group to skip in full.
    func skipGroup(groupId: String) {
        ensureGroupProgress(groupId: groupId)

        guard var groupProgress = progressMap[groupId] else { return }

        for index in groupProgress.lessonProgresses.indices {
            groupProgress.lessonProgresses[index].markCompleted()
        }
        progressMap[groupId] = groupProgress
        saveProgress()
    }

    /// Determines if a score qualifies as passing (≥ 70%).
    /// - Parameters:
    ///   - score: Correct answers.
    ///   - total: Total problems.
    /// - Returns: True if the score is at least 70%.
    func isPassingScore(score: Int, total: Int) -> Bool {
        guard total > 0 else { return false }
        return Double(score) / Double(total) >= 0.7
    }

    /// Returns the progress for a specific lesson.
    /// - Parameters:
    ///   - lessonId: The lesson identifier.
    ///   - groupId: The group containing the lesson.
    /// - Returns: The lesson's progress, or nil if not found.
    func lessonProgress(lessonId: String, groupId: String) -> LessonProgress? {
        progressMap[groupId]?.lessonProgresses.first { $0.lessonId == lessonId }
    }

    // MARK: - Persistence

    /// Saves all progress to UserDefaults and mirrors it to the cloud.
    private func saveProgress() {
        if let data = try? JSONEncoder().encode(progressMap) {
            UserDefaults.standard.set(data, forKey: progressKey)
        }
        // Fire-and-forget remote push; offline-first means we never block on it.
        let snapshot = progressMap
        let sync = sync
        Task { try? await sync.push(snapshot) }
    }

    /// Loads progress from UserDefaults, then reconciles it with the current
    /// catalog so newly-added lessons appear and removed ones don't linger.
    private func loadProgress() {
        if let data = UserDefaults.standard.data(forKey: progressKey),
           let decoded = try? JSONDecoder().decode(
               [String: GroupProgress].self, from: data
           ) {
            progressMap = decoded
        }
        reconcileWithCatalog()
    }

    /// Brings every group's progress in line with the current catalog. Safe to
    /// run against an empty map (creates defaults) or a stale one (adds/prunes).
    private func reconcileWithCatalog() {
        for group in lessonGroups {
            ensureGroupProgress(groupId: group.id)
        }
    }

    /// Ensures the group's progress matches the current catalog: adds entries
    /// for lessons that don't have one yet and drops entries for lessons that no
    /// longer exist, while preserving progress for lessons that carry over.
    ///
    /// This keeps completion (and therefore unlock gating) correct when the
    /// catalog changes between app versions — e.g. a lesson added to a group the
    /// user already had saved progress for would otherwise never get a progress
    /// entry, so finishing it could never mark it (or the group) complete.
    private func ensureGroupProgress(groupId: String) {
        guard let group = lessonGroups.first(where: { $0.id == groupId }) else { return }

        let existing = progressMap[groupId]?.lessonProgresses ?? []
        let byId = Dictionary(existing.map { ($0.lessonId, $0) }, uniquingKeysWith: { first, _ in first })
        let reconciled = group.lessons.map { byId[$0.id] ?? LessonProgress(lessonId: $0.id) }

        if progressMap[groupId]?.lessonProgresses != reconciled {
            progressMap[groupId] = GroupProgress(groupId: groupId, lessonProgresses: reconciled)
        }
    }

    /// Resets all progress (useful for testing or user request).
    func resetAllProgress() {
        progressMap.removeAll()
        UserDefaults.standard.removeObject(forKey: progressKey)
        reconcileWithCatalog()
    }
}
