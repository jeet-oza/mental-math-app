//
//  Fraction.swift
//  Calcathon
//
//  An exact rational value, for the lessons whose answers are not whole
//  numbers. Kept exact rather than converted to Double so that "2/6" and
//  "1/3" compare equal and a player is never marked wrong for leaving an
//  answer unreduced.
//

import Foundation

/// A rational number, always stored in lowest terms with the sign on the
/// numerator and a strictly positive denominator. Two fractions are equal
/// exactly when they represent the same value.
struct Fraction: Equatable, Codable, Sendable {
    let numerator: Int
    let denominator: Int

    /// Creates a fraction, reducing it and normalising the sign.
    /// A zero denominator collapses to 0/1 rather than trapping: patterns
    /// never generate one, and a crash is the wrong failure mode for a
    /// value type this far from the user.
    init(_ numerator: Int, _ denominator: Int) {
        guard denominator != 0 else {
            self.numerator = 0
            self.denominator = 1
            return
        }
        let sign = denominator < 0 ? -1 : 1
        let divisor = Self.greatestCommonDivisor(numerator, denominator)
        self.numerator = sign * numerator / divisor
        self.denominator = sign * denominator / divisor
    }

    /// A whole number as a fraction.
    init(_ whole: Int) {
        self.numerator = whole
        self.denominator = 1
    }

    /// Whether this is a whole number, i.e. renders without a slash.
    var isWhole: Bool { denominator == 1 }

    var doubleValue: Double { Double(numerator) / Double(denominator) }

    /// How the fraction reads back to the player: "3/4", or just "2" when
    /// the denominator has cancelled away.
    var displayText: String {
        isWhole ? "\(numerator)" : "\(numerator)/\(denominator)"
    }

    /// The same value written in decimal, trimmed of trailing zeros: 17/2 →
    /// "8.5", 3/1 → "3". Only meaningful for fractions that terminate, which
    /// is every fraction the decimal lessons produce.
    var decimalText: String {
        if isWhole { return "\(numerator)" }
        var text = String(format: "%.6f", doubleValue)
        while text.hasSuffix("0") { text.removeLast() }
        if text.hasSuffix(".") { text.removeLast() }
        return text
    }

    static func + (lhs: Fraction, rhs: Fraction) -> Fraction {
        Fraction(
            lhs.numerator * rhs.denominator + rhs.numerator * lhs.denominator,
            lhs.denominator * rhs.denominator
        )
    }

    static func - (lhs: Fraction, rhs: Fraction) -> Fraction {
        Fraction(
            lhs.numerator * rhs.denominator - rhs.numerator * lhs.denominator,
            lhs.denominator * rhs.denominator
        )
    }

    static func * (lhs: Fraction, rhs: Fraction) -> Fraction {
        Fraction(lhs.numerator * rhs.numerator, lhs.denominator * rhs.denominator)
    }

    static func / (lhs: Fraction, rhs: Fraction) -> Fraction {
        Fraction(lhs.numerator * rhs.denominator, lhs.denominator * rhs.numerator)
    }

    /// Parses "3/4", "-3/4", "5" or "0.75". The scientific keypad types "÷"
    /// rather than a slash, so both are accepted, and a decimal is accepted
    /// wherever a fraction is — 0.75 and 3/4 are the same number, so
    /// insisting on one form would fail a player who is not wrong.
    /// Whitespace is ignored. Returns nil for anything else, including a
    /// zero denominator.
    static func parse(_ input: String) -> Fraction? {
        let trimmed = input.filter { !$0.isWhitespace }
        guard !trimmed.isEmpty else { return nil }

        if let dot = trimmed.firstIndex(of: ".") {
            return parseDecimal(trimmed, at: dot)
        }
        guard let divide = trimmed.firstIndex(where: { $0 == "/" || $0 == "÷" }) else {
            return Int(trimmed).map(Fraction.init)
        }
        guard let numerator = Int(trimmed[trimmed.startIndex..<divide]),
              let denominator = Int(trimmed[trimmed.index(after: divide)...]),
              denominator != 0
        else { return nil }
        return Fraction(numerator, denominator)
    }

    /// "12.75" → 51/4. Split out because the sign has to be read off the
    /// whole part *before* it is dropped: "-0.5" has a negative sign but a
    /// whole part of zero, which carries no sign of its own.
    private static func parseDecimal(_ text: String, at dot: String.Index) -> Fraction? {
        let wholeText = String(text[text.startIndex..<dot])
        let fractionText = String(text[text.index(after: dot)...])

        guard !fractionText.isEmpty,
              fractionText.allSatisfy(\.isNumber),
              let fractionDigits = Int(fractionText)
        else { return nil }

        let isNegative = wholeText.hasPrefix("-")
        let magnitudeText = wholeText.drop { $0 == "-" || $0 == "+" }
        let whole = magnitudeText.isEmpty ? 0 : Int(magnitudeText)
        guard let whole, whole >= 0 else { return nil }

        var scale = 1
        for _ in 0..<fractionText.count { scale *= 10 }
        let numerator = whole * scale + fractionDigits
        return Fraction(isNegative ? -numerator : numerator, scale)
    }

    private static func greatestCommonDivisor(_ a: Int, _ b: Int) -> Int {
        var x = abs(a), y = abs(b)
        while y != 0 { (x, y) = (y, x % y) }
        return max(1, x)
    }
}
