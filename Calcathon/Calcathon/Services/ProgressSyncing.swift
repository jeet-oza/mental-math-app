//
//  ProgressSyncing.swift
//  Calcathon
//
//  Backend boundary for syncing curriculum progress to a user's cloud record.
//
//  CurriculumViewModel keeps UserDefaults as the always-on offline cache; this
//  layer mirrors that progress to Firestore `users/{uid}` so it survives
//  reinstalls and follows the user across devices. Offline-first: the app works
//  fully with NoopProgressSync (no network) and reconciles when sync is enabled.
//

import Foundation
import FirebaseFirestore

/// Reads and writes the user's progress to a remote store.
protocol ProgressSyncing: Sendable {
    /// Returns the remote progress, or nil if none exists yet.
    func fetch() async throws -> [String: GroupProgress]?
    /// Persists the latest merged progress remotely.
    func push(_ progress: [String: GroupProgress]) async throws
}

/// Offline implementation: no remote, used before a user is known.
struct NoopProgressSync: ProgressSyncing {
    func fetch() async throws -> [String: GroupProgress]? { nil }
    func push(_ progress: [String: GroupProgress]) async throws {}
}

/// Firestore-backed sync. Stores progress as a JSON blob on `users/{uid}` to
/// stay decoupled from Firestore's document schema.
struct FirestoreProgressSync: ProgressSyncing {
    let uid: String

    private var document: DocumentReference {
        Firestore.firestore().collection("users").document(uid)
    }

    func fetch() async throws -> [String: GroupProgress]? {
        let snapshot = try await document.getDocument()
        guard
            let json = snapshot.data()?["progressJSON"] as? String,
            let data = json.data(using: .utf8)
        else { return nil }
        return try JSONDecoder().decode([String: GroupProgress].self, from: data)
    }

    func push(_ progress: [String: GroupProgress]) async throws {
        let data = try JSONEncoder().encode(progress)
        let json = String(decoding: data, as: UTF8.self)
        try await document.setData(
            ["progressJSON": json, "updatedAt": FieldValue.serverTimestamp()],
            merge: true
        )
    }
}

/// Reconciles local and remote progress without losing the user's best work.
enum ProgressMerger {

    /// Merges two progress maps, keeping the strongest result per lesson:
    /// highest `bestScore`, highest `attemptsCount`, and completion if either says so.
    static func merge(
        local: [String: GroupProgress],
        remote: [String: GroupProgress]
    ) -> [String: GroupProgress] {
        var result = local

        for (groupId, remoteGroup) in remote {
            guard let localGroup = result[groupId] else {
                result[groupId] = remoteGroup
                continue
            }

            var lessons = localGroup.lessonProgresses
            for remoteLesson in remoteGroup.lessonProgresses {
                if let index = lessons.firstIndex(where: { $0.lessonId == remoteLesson.lessonId }) {
                    lessons[index] = mergeLesson(lessons[index], remoteLesson)
                } else {
                    lessons.append(remoteLesson)
                }
            }
            result[groupId] = GroupProgress(groupId: groupId, lessonProgresses: lessons)
        }

        return result
    }

    private static func mergeLesson(_ a: LessonProgress, _ b: LessonProgress) -> LessonProgress {
        var merged = a
        merged.bestScore = max(a.bestScore, b.bestScore)
        merged.attemptsCount = max(a.attemptsCount, b.attemptsCount)
        if a.isCompleted || b.isCompleted { merged.markCompleted() }
        return merged
    }
}
