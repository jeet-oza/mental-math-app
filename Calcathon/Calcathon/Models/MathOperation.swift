//
//  MathOperation.swift
//  Calcathon
//
//  Defines the supported arithmetic operations.
//

import Foundation

/// Represents a type of arithmetic operation used in math problems.
enum MathOperation: String, CaseIterable, Codable, Sendable {
    case addition = "+"
    case subtraction = "−"
    case multiplication = "×"
    case division = "÷"
    case percentage = "%"
    case remainder = "mod"
    /// Division that need not come out exact — the answer is a quotient *and*
    /// a remainder. Displays like ordinary division; only the answer differs.
    case divisionWithRemainder = "÷r"
    case cube = "^3"
    case squareRoot = "sqrt"
    case cubeRoot = "cbrt"
    /// `a² − b²`, displayed with both squares intact so the shortcut
    /// `(a + b)(a − b)` is the thing being practised.
    case differenceOfSquares = "sq-diff"
    /// The four fraction operations. Both operands carry a denominator, and
    /// the answer is an exact `Fraction` rather than an `Int`.
    case fractionAddition = "frac+"
    case fractionSubtraction = "frac−"
    case fractionMultiplication = "frac×"
    case fractionDivision = "frac÷"
    /// A square root that does not come out whole, answered to within a
    /// tolerance rather than exactly.
    case approximateSquareRoot = "sqrt~"
    /// A cube root that does not come out whole. Same tolerance treatment.
    case approximateCubeRoot = "cbrt~"
    /// A product wanted only to the right ballpark. Unlike the roots, its
    /// tolerance is a fraction of the answer rather than a fixed amount —
    /// see `MathProblem.answer`.
    case estimateProduct = "est×"
    /// Raising and lowering a value by a percentage. `operandA` is the
    /// percent and `operandB` the base, matching `percentage`.
    case percentageIncrease = "%+"
    case percentageDecrease = "%−"

    /// The four arithmetic operations used for random/Arena generation.
    /// Everything else is concept-only: those operations belong to specific
    /// lessons and must never appear in generic random generation.
    static var allCases: [MathOperation] {
        [.addition, .subtraction, .multiplication, .division]
    }

    /// Operations that take a single operand. `operandB` is unused for these,
    /// and they render as a prefix or suffix rather than as `a ∘ b`.
    var isUnary: Bool {
        switch self {
        case .cube, .squareRoot, .cubeRoot, .approximateSquareRoot, .approximateCubeRoot:
            return true
        default:
            return false
        }
    }

    /// Operations whose operands are fractions, so both denominators matter.
    var isFractional: Bool {
        switch self {
        case .fractionAddition, .fractionSubtraction,
             .fractionMultiplication, .fractionDivision:
            return true
        default:
            return false
        }
    }

    /// How close an answer must be to count as right, for the operations that
    /// are answered approximately.
    ///
    /// These are set from the taught method's *worst* case over the range its
    /// pattern generates, not from a general sense of "close enough" — a
    /// tolerance tighter than the method's own error would fail a player who
    /// applied it correctly. One Newton step off the nearest whole root is
    /// good to about 0.036 for square roots over 10…500, but only to about
    /// 0.051 for cube roots, which is why they differ.
    var tolerance: Double? {
        switch self {
        case .approximateSquareRoot: return 0.05
        case .approximateCubeRoot: return 0.1
        default: return nil
        }
    }

    /// Returns the display symbol for the operation. Raw values stay unique
    /// for stable `Codable` encoding, so the two are not always the same.
    var symbol: String {
        switch self {
        case .divisionWithRemainder: return "÷"
        case .cube: return "³"
        case .squareRoot, .approximateSquareRoot: return "√"
        case .cubeRoot, .approximateCubeRoot: return "∛"
        case .fractionAddition: return "+"
        case .fractionSubtraction: return "−"
        case .fractionMultiplication: return "×"
        case .fractionDivision: return "÷"
        default: return rawValue
        }
    }

    /// Evaluates the operation on two integer operands.
    ///
    /// All problems in this app are integer-valued by construction
    /// (see `MathEngine`, which only generates evenly-divisible division
    /// problems), so the result is always an exact `Int`.
    /// - Parameters:
    ///   - lhs: Left-hand side operand.
    ///   - rhs: Right-hand side operand.
    /// - Returns: The integer result of applying the operation.
    ///   Division by zero returns 0 as a safe fallback.
    ///   Division that is not exact truncates toward zero.
    func evaluate(lhs: Int, rhs: Int) -> Int {
        switch self {
        case .addition:
            return lhs + rhs
        case .subtraction:
            return lhs - rhs
        case .multiplication:
            return lhs * rhs
        case .division:
            guard rhs != 0 else { return 0 }
            return lhs / rhs
        case .percentage:
            // lhs = percent, rhs = base. Patterns guarantee an exact result.
            return lhs * rhs / 100
        case .remainder:
            guard rhs != 0 else { return 0 }
            return lhs % rhs
        case .divisionWithRemainder:
            // The quotient is the primary answer; the remainder rides along in
            // `MathProblem.answer`.
            guard rhs != 0 else { return 0 }
            return lhs / rhs
        case .cube:
            return lhs * lhs * lhs
        case .squareRoot:
            // Patterns only ever generate perfect squares, so this is exact.
            return Int(Double(max(0, lhs)).squareRoot().rounded())
        case .cubeRoot:
            // Likewise: exact cubes only.
            return Int(cbrt(Double(lhs)).rounded())
        case .differenceOfSquares:
            return lhs * lhs - rhs * rhs
        case .estimateProduct:
            return lhs * rhs
        case .percentageIncrease:
            return rhs + lhs * rhs / 100
        case .percentageDecrease:
            return rhs - lhs * rhs / 100
        case .approximateSquareRoot:
            // Rounded only so the Arena's integer-shaped plumbing has
            // something to hold; grading goes through `ProblemAnswer`.
            return Int(Double(max(0, lhs)).squareRoot().rounded())
        case .approximateCubeRoot:
            return Int(cbrt(Double(lhs)).rounded())
        case .fractionAddition, .fractionSubtraction,
             .fractionMultiplication, .fractionDivision:
            // Fractions carry denominators this signature cannot see, so the
            // real answer comes from `MathProblem.answer`. Returning the
            // numerator alone would be a plausible-looking lie, so return 0.
            return 0
        }
    }

    /// Applies this operation to two fractions. Only meaningful when
    /// `isFractional`; anything else falls back to the left operand.
    func evaluate(lhs: Fraction, rhs: Fraction) -> Fraction {
        switch self {
        case .fractionAddition: return lhs + rhs
        case .fractionSubtraction: return lhs - rhs
        case .fractionMultiplication: return lhs * rhs
        case .fractionDivision: return lhs / rhs
        default: return lhs
        }
    }
}
