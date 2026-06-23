//
//  FirebaseLeaderboardService.swift
//  MentalMathApp
//
//  Real per-round Arena leaderboard backed by Cloud Firestore.
//
//  Layout: rounds/{roundIndex}/scores/{uid}. Each player writes only their own
//  score document; the leaderboard is a read of that round's scores. Sparse
//  rounds are padded with the same deterministic opponents used offline, so the
//  board still looks competitive at low player counts.
//

import Foundation
import FirebaseFirestore

struct FirebaseLeaderboardService: LeaderboardService {

    /// Top-level collection of rounds (e.g. "rounds" for equations,
    /// "gridRounds" for the grid mode) so the two arenas keep separate boards.
    let collection: String

    /// Minimum number of rows to show; real entries are padded with bots up to this.
    private let minimumRows = 8

    init(collection: String = "rounds") {
        self.collection = collection
    }

    private var db: Firestore { Firestore.firestore() }

    private func scoresCollection(forRound index: Int) -> CollectionReference {
        db.collection(collection).document("\(index)").collection("scores")
    }

    func submit(_ entry: LeaderboardEntry, forRound index: Int) async throws {
        try await scoresCollection(forRound: index).document(entry.id).setData([
            "username": entry.username,
            "score": entry.score,
            "accuracy": entry.accuracy,
            "updatedAt": FieldValue.serverTimestamp()
        ], merge: true)
    }

    func leaderboard(
        forRound index: Int,
        including player: LeaderboardEntry
    ) async throws -> [LeaderboardEntry] {
        let snapshot = try await scoresCollection(forRound: index).getDocuments()

        var entries: [LeaderboardEntry] = snapshot.documents.compactMap { doc in
            let data = doc.data()
            guard
                let username = data["username"] as? String,
                let score = data["score"] as? Int
            else { return nil }
            return LeaderboardEntry(
                id: doc.documentID,
                username: username,
                score: score,
                accuracy: data["accuracy"] as? Double ?? 0,
                rank: 0
            )
        }

        // Guarantee the player appears even before their write propagates.
        if !entries.contains(where: { $0.id == player.id }) {
            entries.append(player)
        }

        // Pad sparse rounds with deterministic opponents (same on every device).
        if entries.count < minimumRows {
            for bot in ArenaSchedule.opponents(forRound: index) {
                guard entries.count < minimumRows else { break }
                if !entries.contains(where: { $0.id == bot.id }) {
                    entries.append(bot)
                }
            }
        }

        return rankedLeaderboard(entries)
    }
}
