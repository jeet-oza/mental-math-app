//
//  GridStatsStore.swift
//  Calcathon
//
//  Offline-first store for cumulative Grid Arena stats: UserDefaults cache
//  mirrored to Firestore users/{uid} (field "gridStatsJSON").
//

import Foundation
import Combine
import FirebaseFirestore

/// Remote sync boundary for lifetime Grid Arena stats.
protocol GridStatsSyncing: Sendable {
    func fetch() async throws -> GridArenaStats?
    func push(_ stats: GridArenaStats) async throws
}

/// Offline no-op, used before sign-in.
struct NoopGridStatsSync: GridStatsSyncing {
    func fetch() async throws -> GridArenaStats? { nil }
    func push(_ stats: GridArenaStats) async throws {}
}

/// Firestore-backed sync, storing stats as a JSON blob on the user's document.
struct FirestoreGridStatsSync: GridStatsSyncing {
    let uid: String

    private var document: DocumentReference {
        Firestore.firestore().collection("users").document(uid)
    }

    func fetch() async throws -> GridArenaStats? {
        let snapshot = try await document.getDocument()
        guard
            let json = snapshot.data()?["gridStatsJSON"] as? String,
            let data = json.data(using: .utf8)
        else { return nil }
        return try JSONDecoder().decode(GridArenaStats.self, from: data)
    }

    func push(_ stats: GridArenaStats) async throws {
        let data = try JSONEncoder().encode(stats)
        let json = String(decoding: data, as: UTF8.self)
        try await document.setData(["gridStatsJSON": json], merge: true)
    }
}

/// Observable lifetime-stats store. UserDefaults is the always-on cache; the
/// cloud is mirrored when a user is signed in.
@MainActor
final class GridStatsStore: ObservableObject {

    @Published private(set) var stats: GridArenaStats

    private let defaultsKey = "grid_arena_stats"
    private var sync: GridStatsSyncing = NoopGridStatsSync()
    private var isCloudSyncEnabled = false

    init() {
        if let data = UserDefaults.standard.data(forKey: defaultsKey),
           let decoded = try? JSONDecoder().decode(GridArenaStats.self, from: data) {
            stats = decoded
        } else {
            stats = GridArenaStats()
        }
    }

    /// Folds a finished game's results into lifetime totals and persists.
    func record(gameScore: Int, pathsFound: Int, longestPathThisGame: Int, hundredsThisGame: Int) {
        stats.record(
            gameScore: gameScore,
            pathsFound: pathsFound,
            longestPathThisGame: longestPathThisGame,
            hundredsThisGame: hundredsThisGame
        )
        save()
    }

    /// Enables cloud sync for a signed-in user: pulls, merges, and pushes.
    func enableCloudSync(uid: String) async {
        guard !isCloudSyncEnabled else { return }
        isCloudSyncEnabled = true
        sync = FirestoreGridStatsSync(uid: uid)
        do {
            if let remote = try await sync.fetch() {
                stats = stats.merged(with: remote)
                save()
            } else {
                try await sync.push(stats)
            }
        } catch {
            // Offline-first: never block local play on a sync failure.
        }
    }

    func disableCloudSync() {
        sync = NoopGridStatsSync()
        isCloudSyncEnabled = false
    }

    private func save() {
        if let data = try? JSONEncoder().encode(stats) {
            UserDefaults.standard.set(data, forKey: defaultsKey)
        }
        let snapshot = stats
        let sync = sync
        Task { try? await sync.push(snapshot) }
    }
}
