//
//  SeededRandomNumberGenerator.swift
//  MentalMathApp
//
//  A deterministic random number generator seeded from a string.
//  Uses a simple but effective linear congruential generator (LCG)
//  to ensure identical sequences across all devices for the same seed.
//

import Foundation

/// A deterministic pseudo-random number generator conforming to `RandomNumberGenerator`.
/// Given the same seed string, always produces the identical sequence of random values.
struct SeededRandomNumberGenerator: RandomNumberGenerator {

    private var state: UInt64

    /// Creates a seeded RNG from a string.
    /// The string is hashed to produce a stable 64-bit seed.
    /// - Parameter seed: Any string value (e.g., a round identifier).
    init(seed: String) {
        // Use a FNV-1a hash for a stable, well-distributed 64-bit seed
        self.state = Self.fnv1aHash(seed)
    }

    /// Generates the next random UInt64 in the deterministic sequence.
    /// Uses the SplitMix64 algorithm for high-quality distribution.
    mutating func next() -> UInt64 {
        state &+= 0x9e3779b97f4a7c15
        var z = state
        z = (z ^ (z >> 30)) &* 0xbf58476d1ce4e5b9
        z = (z ^ (z >> 27)) &* 0x94d049bb133111eb
        return z ^ (z >> 31)
    }

    // MARK: - Private

    /// FNV-1a hash for stable string-to-UInt64 conversion.
    private static func fnv1aHash(_ string: String) -> UInt64 {
        var hash: UInt64 = 0xcbf29ce484222325 // FNV offset basis
        let prime: UInt64 = 0x100000001b3       // FNV prime
        for byte in string.utf8 {
            hash ^= UInt64(byte)
            hash &*= prime
        }
        return hash
    }
}
