//
//  ExpressionEvaluator.swift
//  Calcathon
//
//  Numerically evaluates the expressions built on the scientific keypad, so an
//  answer like "√2÷2" can be checked against an expected value without the app
//  having to reason about symbols. Comparison is by value, which means a player
//  may write an answer any way they like as long as it comes out the same.
//
//  No lesson uses this yet — trigonometry is the first that will.
//

import Foundation

/// A recursive-descent evaluator for the small grammar the keypad can produce:
///
///     expr    := term (("+" | "−") term)*
///     term    := factor (("×" | "÷") factor)*
///     factor  := unary ("^" factor)?          // right-associative
///     unary   := "−" unary | "√" unary | "∛" unary | primary
///     primary := number | "π" | "(" expr ")"
///
enum ExpressionEvaluator {

    enum EvaluationError: Error, Equatable {
        case empty
        case unexpectedCharacter(Character)
        case unbalancedParentheses
        case trailingInput
    }

    /// How close two answers must be to count as the same. Generous enough to
    /// absorb the rounding a player does by hand, tight enough that genuinely
    /// different answers never collide.
    static let tolerance = 1e-6

    /// Evaluates `input`, or throws if it is not well formed.
    static func evaluate(_ input: String) throws -> Double {
        var parser = Parser(input: Array(input.filter { !$0.isWhitespace }))
        guard !parser.isAtEnd else { throw EvaluationError.empty }
        let value = try parser.parseExpression()
        guard parser.isAtEnd else { throw EvaluationError.trailingInput }
        return value
    }

    /// Whether `input` evaluates to `expected`. A malformed expression is
    /// simply wrong rather than an error the player has to interpret.
    static func matches(_ input: String, expected: Double) -> Bool {
        guard let value = try? evaluate(input) else { return false }
        return abs(value - expected) <= tolerance
    }

    // MARK: - Parser

    private struct Parser {
        let input: [Character]
        var index = 0

        var isAtEnd: Bool { index >= input.count }
        private var current: Character? { isAtEnd ? nil : input[index] }

        private mutating func consume(_ character: Character) -> Bool {
            guard current == character else { return false }
            index += 1
            return true
        }

        mutating func parseExpression() throws -> Double {
            var value = try parseTerm()
            while let op = current, op == "+" || op == "−" || op == "-" {
                index += 1
                let rhs = try parseTerm()
                value = (op == "+") ? value + rhs : value - rhs
            }
            return value
        }

        private mutating func parseTerm() throws -> Double {
            var value = try parseFactor()
            while let op = current, op == "×" || op == "*" || op == "÷" || op == "/" {
                index += 1
                let rhs = try parseFactor()
                value = (op == "×" || op == "*") ? value * rhs : value / rhs
            }
            return value
        }

        private mutating func parseFactor() throws -> Double {
            let base = try parseUnary()
            // Right-associative, so 2^3^2 is 2^(3^2).
            guard consume("^") else { return base }
            return pow(base, try parseFactor())
        }

        private mutating func parseUnary() throws -> Double {
            if consume("−") || consume("-") { return -(try parseUnary()) }
            if consume("√") { return (try parseUnary()).squareRoot() }
            if consume("∛") { return cbrt(try parseUnary()) }
            return try parsePrimary()
        }

        private mutating func parsePrimary() throws -> Double {
            if consume("π") { return .pi }

            if consume("(") {
                let value = try parseExpression()
                guard consume(")") else { throw EvaluationError.unbalancedParentheses }
                return value
            }

            var digits = ""
            while let character = current, character.isNumber || character == "." {
                digits.append(character)
                index += 1
            }
            guard let value = Double(digits) else {
                throw current.map(EvaluationError.unexpectedCharacter) ?? .empty
            }
            return value
        }
    }
}
