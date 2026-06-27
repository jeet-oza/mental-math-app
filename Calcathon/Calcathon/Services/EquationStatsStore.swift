//
//  EquationStatsStore.swift
//  Calcathon
//
//  Offline-first store for cumulative Equation Arena stats: UserDefaults
//  cache mirrored to Firestore users/{uid} (field "equationStatsJSON").
//

import Foundation
import Combine
import FirebaseFirestore

protocol EquationStatsSyncing: Sendable {
    func fetch() async throws -> EquationArenaStats?
    func push(_ stats: EquationArenaStats) async throws
}

struct NoopEquationStatsSync: EquationStatsSyncing {
    func fetch() async throws -> EquationArenaStats? { nil }
    func push(_ stats: EquationArenaStats) async throws {}
}

struct FirestoreEquationStatsSync: EquationStatsSyncing {
    let uid: String

    private var document: DocumentReference {
        Firestore.firestore().collection("users").document(uid)
    }

    func fetch() async throws -> EquationArenaStats? {
        let snapshot = try await document.getDocument()
        guard
            let json = snapshot.data()?["equationStatsJSON"] as? String,
            let data = json.data(using: .utf8)
        else { return nil }
        return try JSONDecoder().decode(EquationArenaStats.self, from: data)
    }

    func push(_ stats: EquationArenaStats) async throws {
        let data = try JSONEncoder().encode(stats)
        let json = String(decoding: data, as: UTF8.self)
        try await document.setData(["equationStatsJSON": json], merge: true)
    }
}

@MainActor
final class EquationStatsStore: ObservableObject {

    @Published private(set) var stats: EquationArenaStats

    private let defaultsKey = "equation_arena_stats"
    private var sync: EquationStatsSyncing = NoopEquationStatsSync()
    private var isCloudSyncEnabled = false

    init() {
        if let data = UserDefaults.standard.data(forKey: defaultsKey),
           let decoded = try? JSONDecoder().decode(EquationArenaStats.self, from: data) {
            stats = decoded
        } else {
            stats = EquationArenaStats()
        }
    }

    func record(gameScore: Int, correct: Int, answered: Int) {
        // Don't count empty runs (joined but answered nothing).
        guard answered > 0 else { return }
        stats.record(gameScore: gameScore, correct: correct, answered: answered)
        save()
    }

    func enableCloudSync(uid: String) async {
        guard !isCloudSyncEnabled else { return }
        isCloudSyncEnabled = true
        sync = FirestoreEquationStatsSync(uid: uid)
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
        sync = NoopEquationStatsSync()
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
