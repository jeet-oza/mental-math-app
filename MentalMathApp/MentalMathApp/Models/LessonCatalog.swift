//
//  LessonCatalog.swift
//  MentalMathApp
//
//  Static catalog of all lesson groups and lessons.
//  This is the source of truth for the Learn Mode curriculum.
//

import Foundation

/// Provides the complete curriculum of lesson groups.
nonisolated enum LessonCatalog {

    /// All available lesson groups, ordered for progression.
    static let allGroups: [LessonGroup] = [
        basicAdditionGroup,
        basicSubtractionGroup,
        multiplicationTricksGroup
    ]

    // MARK: - Basic Addition

    static let basicAdditionGroup = LessonGroup(
        id: "basic_addition",
        title: "Basic Addition",
        description: "Master shortcuts for adding numbers quickly.",
        iconName: "plus.circle.fill",
        lessons: [
            addingNineLesson,
            addingElevenLesson,
            doublingNumbersLesson
        ]
    )

    private static let addingNineLesson = Lesson(
        id: "add_9",
        title: "Adding 9",
        description: "Add 10, then subtract 1.",
        trick: MathTrick(
            name: "Add 9 Shortcut",
            steps: [
                "Instead of adding 9 directly, add 10 to the number.",
                "Then subtract 1 from the result."
            ],
            example: TrickExample(
                problem: "47 + 9",
                solution: "56",
                stepByStepExplanation: [
                    "Step 1: 47 + 10 = 57",
                    "Step 2: 57 - 1 = 56",
                    "Answer: 56"
                ]
            )
        ),
        operations: [.addition],
        difficulty: .easy
    )

    private static let addingElevenLesson = Lesson(
        id: "add_11",
        title: "Adding 11",
        description: "Add 10, then add 1 more.",
        trick: MathTrick(
            name: "Add 11 Shortcut",
            steps: [
                "Add 10 to the number first.",
                "Then add 1 more."
            ],
            example: TrickExample(
                problem: "38 + 11",
                solution: "49",
                stepByStepExplanation: [
                    "Step 1: 38 + 10 = 48",
                    "Step 2: 48 + 1 = 49",
                    "Answer: 49"
                ]
            )
        ),
        operations: [.addition],
        difficulty: .easy
    )

    private static let doublingNumbersLesson = Lesson(
        id: "doubling",
        title: "Doubling Numbers",
        description: "Break numbers into easy parts to double them.",
        trick: MathTrick(
            name: "Split and Double",
            steps: [
                "Break the number into tens and ones.",
                "Double each part separately.",
                "Add the doubled parts together."
            ],
            example: TrickExample(
                problem: "36 × 2",
                solution: "72",
                stepByStepExplanation: [
                    "Step 1: Split 36 into 30 + 6",
                    "Step 2: Double 30 → 60",
                    "Step 3: Double 6 → 12",
                    "Step 4: 60 + 12 = 72",
                    "Answer: 72"
                ]
            )
        ),
        operations: [.multiplication],
        difficulty: .easy
    )

    // MARK: - Basic Subtraction

    static let basicSubtractionGroup = LessonGroup(
        id: "basic_subtraction",
        title: "Basic Subtraction",
        description: "Shortcuts for subtracting numbers mentally.",
        iconName: "minus.circle.fill",
        lessons: [
            subtractingNineLesson,
            subtractingFromRoundNumbersLesson
        ],
        requiredGroupId: "basic_addition"
    )

    private static let subtractingNineLesson = Lesson(
        id: "sub_9",
        title: "Subtracting 9",
        description: "Subtract 10, then add 1 back.",
        trick: MathTrick(
            name: "Subtract 9 Shortcut",
            steps: [
                "Subtract 10 from the number.",
                "Then add 1 back."
            ],
            example: TrickExample(
                problem: "63 - 9",
                solution: "54",
                stepByStepExplanation: [
                    "Step 1: 63 - 10 = 53",
                    "Step 2: 53 + 1 = 54",
                    "Answer: 54"
                ]
            )
        ),
        operations: [.subtraction],
        difficulty: .easy
    )

    private static let subtractingFromRoundNumbersLesson = Lesson(
        id: "sub_round",
        title: "Subtract from Round Numbers",
        description: "Use complements to subtract from 100, 1000, etc.",
        trick: MathTrick(
            name: "Complement Method",
            steps: [
                "For each digit except the last, subtract from 9.",
                "For the last digit, subtract from 10.",
                "This gives you the answer directly."
            ],
            example: TrickExample(
                problem: "100 - 37",
                solution: "63",
                stepByStepExplanation: [
                    "Step 1: First digit of 37 → 9 - 3 = 6",
                    "Step 2: Last digit of 37 → 10 - 7 = 3",
                    "Answer: 63"
                ]
            )
        ),
        operations: [.subtraction],
        difficulty: .easy
    )

    // MARK: - Multiplication Tricks

    static let multiplicationTricksGroup = LessonGroup(
        id: "multiplication_tricks",
        title: "Multiplication Tricks",
        description: "Powerful shortcuts for multiplying numbers.",
        iconName: "multiply.circle.fill",
        lessons: [
            multiplyByElevenLesson,
            multiplyByFiveLesson
        ],
        requiredGroupId: "basic_subtraction"
    )

    private static let multiplyByElevenLesson = Lesson(
        id: "mult_11",
        title: "Multiply by 11",
        description: "A famous trick for 2-digit × 11.",
        trick: MathTrick(
            name: "The 11 Trick",
            steps: [
                "Write down the first digit.",
                "Add the two digits together for the middle.",
                "Write down the last digit.",
                "If the sum is ≥ 10, carry the 1."
            ],
            example: TrickExample(
                problem: "36 × 11",
                solution: "396",
                stepByStepExplanation: [
                    "Step 1: First digit → 3",
                    "Step 2: 3 + 6 = 9 (middle digit)",
                    "Step 3: Last digit → 6",
                    "Answer: 396"
                ]
            )
        ),
        operations: [.multiplication],
        difficulty: .medium
    )

    private static let multiplyByFiveLesson = Lesson(
        id: "mult_5",
        title: "Multiply by 5",
        description: "Halve the number and multiply by 10.",
        trick: MathTrick(
            name: "Half and Shift",
            steps: [
                "Divide the other number by 2.",
                "Multiply the result by 10 (add a zero).",
                "If the number was odd, add 5."
            ],
            example: TrickExample(
                problem: "48 × 5",
                solution: "240",
                stepByStepExplanation: [
                    "Step 1: 48 ÷ 2 = 24",
                    "Step 2: 24 × 10 = 240",
                    "Answer: 240"
                ]
            )
        ),
        operations: [.multiplication],
        difficulty: .easy
    )
}
