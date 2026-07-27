//
//  LessonCatalog.swift
//  Calcathon
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
        multiplicationTricksGroup,
        advancedMultiplicationGroup,
        squaringShortcutsGroup,
        divisionTricksGroup,
        percentageTricksGroup
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
            addingNearHundredLesson
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
        difficulty: .easy,
        pattern: ProblemPattern.fixedOperand(operation: .addition, fixedValues: [9], position: .right, variableRange: 10...99)
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
        difficulty: .easy,
        pattern: ProblemPattern.fixedOperand(operation: .addition, fixedValues: [11], position: .right, variableRange: 10...99)
    )

    private static let addingNearHundredLesson = Lesson(
        id: "add_near100",
        title: "Add a Number Near 100",
        description: "Round up to 100, add, then take off the little extra.",
        trick: MathTrick(
            name: "Round Up, Then Adjust",
            steps: [
                "The number you're adding is just below 100 (or 1000).",
                "Add the round number instead — it's much easier.",
                "Then subtract however much you rounded up by.",
                "Example: + 98 is the same as + 100 − 2."
            ],
            example: TrickExample(
                problem: "156 + 98",
                solution: "254",
                stepByStepExplanation: [
                    "Step 1: 98 is 2 below 100",
                    "Step 2: 156 + 100 = 256",
                    "Step 3: 256 − 2 = 254",
                    "Answer: 254"
                ]
            )
        ),
        operations: [.addition],
        difficulty: .medium,
        pattern: ProblemPattern.nearRound(operation: .addition, base: 100, offsetRange: 1...19, otherRange: 110...899)
    )

    // MARK: - Basic Subtraction

    static let basicSubtractionGroup = LessonGroup(
        id: "basic_subtraction",
        title: "Basic Subtraction",
        description: "Shortcuts for subtracting numbers mentally.",
        iconName: "minus.circle.fill",
        lessons: [
            subtractingNineLesson,
            subtractingNearHundredLesson,
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
        difficulty: .easy,
        pattern: ProblemPattern.fixedOperand(operation: .subtraction, fixedValues: [9], position: .right, variableRange: 18...99)
    )

    private static let subtractingNearHundredLesson = Lesson(
        id: "sub_near100",
        title: "Subtract a Number Near 100",
        description: "Round up to 100, subtract, then add back the little extra.",
        trick: MathTrick(
            name: "Round Up, Then Add Back",
            steps: [
                "The number you're subtracting is just below 100 (or 1000).",
                "Subtract the round number instead — it's much easier.",
                "Then add back however much you rounded up by.",
                "Example: − 96 is the same as − 100 + 4."
            ],
            example: TrickExample(
                problem: "234 − 96",
                solution: "138",
                stepByStepExplanation: [
                    "Step 1: 96 is 4 below 100",
                    "Step 2: 234 − 100 = 134",
                    "Step 3: 134 + 4 = 138",
                    "Answer: 138"
                ]
            )
        ),
        operations: [.subtraction],
        difficulty: .medium,
        pattern: ProblemPattern.nearRound(operation: .subtraction, base: 100, offsetRange: 1...19, otherRange: 110...899)
    )

    private static let subtractingFromRoundNumbersLesson = Lesson(
        id: "sub_round",
        title: "Subtract Around Multiples of 10",
        description: "Subtract from 100 or 1000 by taking each digit from 9, then adding 1.",
        trick: MathTrick(
            name: "Nines, Then Plus 1",
            steps: [
                "Subtract each digit of the number from 9.",
                "Add 1 to that result — and you're done.",
                "Taking every digit from 9 keeps it simple; the +1 handles the last place, so you never have to subtract from 10."
            ],
            example: TrickExample(
                problem: "100 - 37",
                solution: "63",
                stepByStepExplanation: [
                    "Step 1: 9 - 3 = 6 and 9 - 7 = 2 → 62",
                    "Step 2: 62 + 1 = 63",
                    "Answer: 63"
                ]
            )
        ),
        operations: [.subtraction],
        difficulty: .easy,
        pattern: ProblemPattern.fixedOperand(operation: .subtraction, fixedValues: [100, 1000], position: .left, variableRange: 11...89)
    )

    // MARK: - Multiplication Tricks

    /// Shortcuts tied to one specific multiplier (×11, ×5, ×25 …). Each works
    /// only for its own number, and each is a single step.
    static let multiplicationTricksGroup = LessonGroup(
        id: "multiplication_tricks",
        title: "Multiplication Tricks",
        description: "Powerful shortcuts for multiplying numbers.",
        iconName: "multiply.circle.fill",
        lessons: [
            multiplyByElevenLesson,
            multiplyByFiveLesson,
            multiplyByNineLesson,
            multiplyByFourLesson,
            multiplyBySixLesson,
            multiplyByTwentyFiveLesson
        ],
        requiredGroupId: "basic_subtraction"
    )

    // MARK: - Advanced Multiplication

    /// Methods rather than shortcuts: pick a base and adjust, or work the
    /// columns crosswise. These are not tied to a particular multiplier, so
    /// they cover the pairs no single-number trick reaches.
    static let advancedMultiplicationGroup = LessonGroup(
        id: "advanced_multiplication",
        title: "Advanced Multiplication",
        description: "Base methods and crosswise columns — for numbers no simple shortcut fits.",
        iconName: "arrow.triangle.swap",
        lessons: [
            multiplyNearHundredLesson,
            multiplyNearHundredCarryLesson,
            multiplyNearFiftyLesson,
            multiplyNearThousandLesson,
            crosswiseBasicsLesson,
            crosswiseCarryLesson,
            crosswiseThreeDigitLesson
        ],
        requiredGroupId: "multiplication_tricks"
    )

    private static let multiplyBySixLesson = Lesson(
        id: "mult_6_even",
        title: "Multiply Even Numbers by 6",
        description: "Halve it, ×10, then add the number back.",
        trick: MathTrick(
            name: "Half, Shift, Add",
            steps: [
                "Halve the even number.",
                "Multiply that by 10 (add a zero).",
                "Add the original number to the result."
            ],
            example: TrickExample(
                problem: "42 × 6",
                solution: "252",
                stepByStepExplanation: [
                    "Step 1: 42 ÷ 2 = 21",
                    "Step 2: 21 × 10 = 210",
                    "Step 3: 210 + 42 = 252",
                    "Answer: 252"
                ]
            )
        ),
        operations: [.multiplication],
        difficulty: .medium,
        pattern: ProblemPattern.evenTimes(fixed: 6, evenRange: 12...98)
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
        difficulty: .medium,
        pattern: ProblemPattern.fixedOperand(operation: .multiplication, fixedValues: [11], position: .right, variableRange: 10...99)
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
        difficulty: .easy,
        pattern: ProblemPattern.fixedOperand(operation: .multiplication, fixedValues: [5], position: .right, variableRange: 2...99)
    )

    private static let multiplyByNineLesson = Lesson(
        id: "mult_9",
        title: "Multiply by 9",
        description: "Multiply by 10, then subtract the number.",
        trick: MathTrick(
            name: "Times 10 Minus the Number",
            steps: [
                "Multiply the number by 10 (add a zero).",
                "Subtract the original number from that result."
            ],
            example: TrickExample(
                problem: "7 × 9",
                solution: "63",
                stepByStepExplanation: [
                    "Step 1: 7 × 10 = 70",
                    "Step 2: 70 − 7 = 63",
                    "Answer: 63"
                ]
            )
        ),
        operations: [.multiplication],
        difficulty: .easy,
        pattern: ProblemPattern.fixedOperand(operation: .multiplication, fixedValues: [9], position: .right, variableRange: 2...99)
    )

    private static let multiplyByFourLesson = Lesson(
        id: "mult_4",
        title: "Multiply by 4",
        description: "Double the number, then double again.",
        trick: MathTrick(
            name: "Double Twice",
            steps: [
                "Double the number.",
                "Double the result again."
            ],
            example: TrickExample(
                problem: "23 × 4",
                solution: "92",
                stepByStepExplanation: [
                    "Step 1: 23 × 2 = 46",
                    "Step 2: 46 × 2 = 92",
                    "Answer: 92"
                ]
            )
        ),
        operations: [.multiplication],
        difficulty: .easy,
        pattern: ProblemPattern.fixedOperand(operation: .multiplication, fixedValues: [4], position: .right, variableRange: 11...99)
    )

    private static let multiplyByTwentyFiveLesson = Lesson(
        id: "mult_25",
        title: "Multiply by 25",
        description: "Multiply by 100, then divide by 4.",
        trick: MathTrick(
            name: "Quarter of 100",
            steps: [
                "Multiply the number by 100 (add two zeros).",
                "Divide that result by 4."
            ],
            example: TrickExample(
                problem: "16 × 25",
                solution: "400",
                stepByStepExplanation: [
                    "Step 1: 16 × 100 = 1600",
                    "Step 2: 1600 ÷ 4 = 400",
                    "Answer: 400"
                ]
            )
        ),
        operations: [.multiplication],
        difficulty: .medium,
        pattern: ProblemPattern.fixedOperand(operation: .multiplication, fixedValues: [25], position: .right, variableRange: 4...40)
    )

    private static let multiplyNearHundredLesson = Lesson(
        id: "mult_near100",
        title: "Multiply Near 100",
        description: "Multiply two numbers near 100 — both above or both below — using 100 as a base.",
        trick: MathTrick(
            name: "Base 100",
            steps: [
                "Measure how far each number is from 100 (102 → 2 above, 97 → 3 below).",
                "Multiply those two distances for the last two digits (pad to two, e.g. 6 → 06).",
                "Both above 100: add the distances to 100 for the leading digits.",
                "Both below 100: subtract the distances from 100 instead.",
                "Put the two parts side by side."
            ],
            examples: [
                TrickExample(
                    problem: "102 × 106",
                    solution: "10812",
                    stepByStepExplanation: [
                        "Step 1: 102 = 100 + 2 and 106 = 100 + 6",
                        "Step 2: Distances 2 × 6 = 12 → last two digits",
                        "Step 3: 100 + 2 + 6 = 108 → leading digits",
                        "Answer: 10812"
                    ]
                ),
                TrickExample(
                    problem: "98 × 97",
                    solution: "9506",
                    stepByStepExplanation: [
                        "Step 1: 98 = 100 − 2 and 97 = 100 − 3",
                        "Step 2: Distances 2 × 3 = 6 → 06 (last two digits)",
                        "Step 3: 100 − 2 − 3 = 95 → leading digits",
                        "Answer: 9506"
                    ]
                )
            ]
        ),
        operations: [.multiplication],
        difficulty: .hard,
        pattern: ProblemPattern.nearHundred(kinds: [.bothAbove, .bothBelow])
    )

    private static let multiplyNearHundredCarryLesson = Lesson(
        id: "mult_near100_carry",
        title: "Near 100: Carry & Cross",
        description: "Near-100 products where the tail carries (112 × 113) or crosses 100 (103 × 98).",
        trick: MathTrick(
            name: "Base 100 — Adjust",
            steps: [
                "Take each number's signed distance from 100 (above is +, below is −).",
                "Base = either number plus the other's signed distance.",
                "Tail = the two distances multiplied, keeping the sign.",
                "Write the base, then the tail. If the tail is ≥ 100, carry its hundreds into the base.",
                "If the tail is negative, drop the base by 1 and add 100 to the tail."
            ],
            examples: [
                TrickExample(
                    problem: "112 × 113",
                    solution: "12656",
                    stepByStepExplanation: [
                        "Step 1: 112 → +12 and 113 → +13",
                        "Step 2: Base = 112 + 13 = 125",
                        "Step 3: Tail = 12 × 13 = 156 (≥ 100, carry 1)",
                        "Step 4: 125 + 1 = 126, tail 56 → 12656",
                        "Answer: 12656"
                    ]
                ),
                TrickExample(
                    problem: "103 × 98",
                    solution: "10094",
                    stepByStepExplanation: [
                        "Step 1: 103 → +3 and 98 → −2",
                        "Step 2: Base = 103 + (−2) = 101",
                        "Step 3: Tail = 3 × (−2) = −6 (negative → borrow)",
                        "Step 4: 101 − 1 = 100, tail = 100 − 6 = 94 → 10094",
                        "Answer: 10094"
                    ]
                )
            ]
        ),
        operations: [.multiplication],
        difficulty: .hard,
        pattern: ProblemPattern.nearHundred(kinds: [.mixed, .carry])
    )

    private static let multiplyNearFiftyLesson = Lesson(
        id: "mult_near50",
        title: "Multiply Near 50",
        description: "Numbers in the 40s and 50s, using 50 as the base.",
        trick: MathTrick(
            name: "Base 50 — Halve the Front",
            steps: [
                "Measure how far each number is from 50 (53 → 3 above, 46 → 4 below).",
                "Front = one number plus the other's distance, then halved — because 50 is half of 100.",
                "Tail = the two distances multiplied, padded to two digits.",
                "If the front comes out as a half, drop the ½ and add 50 to the tail.",
                "Write the front, then the tail."
            ],
            examples: [
                TrickExample(
                    problem: "53 × 57",
                    solution: "3021",
                    stepByStepExplanation: [
                        "Step 1: 53 = 50 + 3 and 57 = 50 + 7",
                        "Step 2: Front = 53 + 7 = 60, halved → 30",
                        "Step 3: Tail = 3 × 7 = 21",
                        "Answer: 3021"
                    ]
                ),
                TrickExample(
                    problem: "52 × 57",
                    solution: "2964",
                    stepByStepExplanation: [
                        "Step 1: 52 = 50 + 2 and 57 = 50 + 7",
                        "Step 2: Front = 52 + 7 = 59, halved → 29½",
                        "Step 3: Drop the ½ → front 29, and add 50 to the tail",
                        "Step 4: Tail = 2 × 7 = 14, plus 50 = 64",
                        "Answer: 2964"
                    ]
                )
            ]
        ),
        operations: [.multiplication],
        difficulty: .hard,
        pattern: ProblemPattern.nearBase(base: 50, deviationRange: 1...8)
    )

    private static let multiplyNearThousandLesson = Lesson(
        id: "mult_near1000",
        title: "Multiply Near 1000",
        description: "Four-digit products in two easy pieces, using 1000 as the base.",
        trick: MathTrick(
            name: "Base 1000",
            steps: [
                "Measure how far each number is from 1000 (1012 → 12 above, 994 → 6 below).",
                "Front = one number plus the other's distance (or minus, if both are below).",
                "Tail = the two distances multiplied, padded to three digits.",
                "Three digits, not two — the base has three zeros.",
                "Write the front, then the tail."
            ],
            examples: [
                TrickExample(
                    problem: "1012 × 1008",
                    solution: "1020096",
                    stepByStepExplanation: [
                        "Step 1: Distances are 12 above and 8 above",
                        "Step 2: Front = 1012 + 8 = 1020",
                        "Step 3: Tail = 12 × 8 = 96 → 096",
                        "Answer: 1020096"
                    ]
                ),
                TrickExample(
                    problem: "994 × 988",
                    solution: "982072",
                    stepByStepExplanation: [
                        "Step 1: Distances are 6 below and 12 below",
                        "Step 2: Front = 994 − 12 = 982",
                        "Step 3: Tail = 6 × 12 = 72 → 072",
                        "Answer: 982072"
                    ]
                )
            ]
        ),
        operations: [.multiplication],
        difficulty: .hard,
        pattern: ProblemPattern.nearBase(base: 1000, deviationRange: 1...19)
    )

    private static let crosswiseBasicsLesson = Lesson(
        id: "mult_crosswise",
        title: "Vertically and Crosswise",
        description: "Any two 2-digit numbers, read off as three columns.",
        trick: MathTrick(
            name: "Three Columns",
            steps: [
                "Write the numbers one above the other, digits lined up.",
                "Right column: multiply the two units digits.",
                "Middle column: multiply crosswise — top tens × bottom units, plus top units × bottom tens — and add the two.",
                "Left column: multiply the two tens digits.",
                "Read the three results left to right.",
                "Every column is a small times-table fact, so you never write out a long multiplication."
            ],
            examples: [
                TrickExample(
                    problem: "23 × 13",
                    solution: "299",
                    stepByStepExplanation: [
                        "Step 1: Units → 3 × 3 = 9",
                        "Step 2: Crosswise → 2 × 3 + 3 × 1 = 9",
                        "Step 3: Tens → 2 × 1 = 2",
                        "Step 4: Read left to right → 2 | 9 | 9",
                        "Answer: 299"
                    ]
                ),
                TrickExample(
                    problem: "31 × 22",
                    solution: "682",
                    stepByStepExplanation: [
                        "Step 1: Units → 1 × 2 = 2",
                        "Step 2: Crosswise → 3 × 2 + 1 × 2 = 8",
                        "Step 3: Tens → 3 × 2 = 6",
                        "Step 4: Read left to right → 6 | 8 | 2",
                        "Answer: 682"
                    ]
                )
            ]
        ),
        operations: [.multiplication],
        difficulty: .medium,
        pattern: ProblemPattern.crosswise(kind: .carryFree)
    )

    private static let crosswiseCarryLesson = Lesson(
        id: "mult_crosswise_carry",
        title: "Crosswise with Carries",
        description: "The same three columns, now carrying from one column into the next.",
        trick: MathTrick(
            name: "Three Columns — Carry Left",
            steps: [
                "Work the same three columns, but start from the right.",
                "Keep only the last digit of each column.",
                "Carry everything above 9 into the column to its left, and add it there.",
                "The left column plus its carry becomes the front of the answer.",
                "Only one digit is ever written down per column, so you can hold the running answer in your head."
            ],
            examples: [
                TrickExample(
                    problem: "47 × 63",
                    solution: "2961",
                    stepByStepExplanation: [
                        "Step 1: Units → 7 × 3 = 21 → write 1, carry 2",
                        "Step 2: Crosswise → 4 × 3 + 7 × 6 = 54, plus carry 2 = 56 → write 6, carry 5",
                        "Step 3: Tens → 4 × 6 = 24, plus carry 5 = 29",
                        "Step 4: Read left to right → 29 | 6 | 1",
                        "Answer: 2961"
                    ]
                ),
                TrickExample(
                    problem: "86 × 74",
                    solution: "6364",
                    stepByStepExplanation: [
                        "Step 1: Units → 6 × 4 = 24 → write 4, carry 2",
                        "Step 2: Crosswise → 8 × 4 + 6 × 7 = 74, plus carry 2 = 76 → write 6, carry 7",
                        "Step 3: Tens → 8 × 7 = 56, plus carry 7 = 63",
                        "Step 4: Read left to right → 63 | 6 | 4",
                        "Answer: 6364"
                    ]
                )
            ]
        ),
        operations: [.multiplication],
        difficulty: .hard,
        pattern: ProblemPattern.crosswise(kind: .carrying)
    )

    private static let crosswiseThreeDigitLesson = Lesson(
        id: "mult_crosswise_3digit",
        title: "Crosswise: 3 × 3 Digits",
        description: "The same method widened to five columns — where it really beats long multiplication.",
        trick: MathTrick(
            name: "Five Columns",
            steps: [
                "For 3-digit numbers the pattern widens from three columns to five.",
                "Right to left: units × units; then the two crosswise pairs; then the full three-way crossing in the middle; then back down to two pairs; finally hundreds × hundreds.",
                "The middle column is the widest — three products added together.",
                "Carry from each column into the next, exactly as before.",
                "You write one digit per column and never line up a partial product."
            ],
            examples: [
                TrickExample(
                    problem: "123 × 456",
                    solution: "56088",
                    stepByStepExplanation: [
                        "Step 1: 3 × 6 = 18 → write 8, carry 1",
                        "Step 2: 2×6 + 3×5 = 27, plus 1 = 28 → write 8, carry 2",
                        "Step 3: 1×6 + 2×5 + 3×4 = 28, plus 2 = 30 → write 0, carry 3",
                        "Step 4: 1×5 + 2×4 = 13, plus 3 = 16 → write 6, carry 1",
                        "Step 5: 1 × 4 = 4, plus 1 = 5",
                        "Answer: 56088"
                    ]
                ),
                TrickExample(
                    problem: "214 × 123",
                    solution: "26322",
                    stepByStepExplanation: [
                        "Step 1: 4 × 3 = 12 → write 2, carry 1",
                        "Step 2: 1×3 + 4×2 = 11, plus 1 = 12 → write 2, carry 1",
                        "Step 3: 2×3 + 1×2 + 4×1 = 12, plus 1 = 13 → write 3, carry 1",
                        "Step 4: 2×2 + 1×1 = 5, plus 1 = 6",
                        "Step 5: 2 × 1 = 2",
                        "Answer: 26322"
                    ]
                )
            ]
        ),
        operations: [.multiplication],
        difficulty: .hard,
        pattern: ProblemPattern.crosswiseThreeDigit
    )

    // MARK: - Squaring Shortcuts

    static let squaringShortcutsGroup = LessonGroup(
        id: "squaring_shortcuts",
        title: "Squaring Shortcuts",
        description: "Fast ways to square numbers in your head.",
        iconName: "square.on.square",
        lessons: [
            squaresEndingInFiveLesson,
            sameTensUnitsSumTenLesson,
            squaresNearFiftyLesson,
            squaresNearHundredLesson
        ],
        requiredGroupId: "advanced_multiplication"
    )

    private static let squaresEndingInFiveLesson = Lesson(
        id: "sq_ends5",
        title: "Squares Ending in 5",
        description: "Square any number ending in 5 instantly.",
        trick: MathTrick(
            name: "Tens × Next, then 25",
            steps: [
                "Take the tens digit T.",
                "Multiply T by (T + 1).",
                "Write 25 after that result."
            ],
            example: TrickExample(
                problem: "35 × 35",
                solution: "1225",
                stepByStepExplanation: [
                    "Step 1: Tens digit is 3",
                    "Step 2: 3 × 4 = 12",
                    "Step 3: Append 25 → 1225",
                    "Answer: 1225"
                ]
            )
        ),
        operations: [.multiplication],
        difficulty: .medium,
        pattern: ProblemPattern.squareEndingInFive(tensRange: 1...9)
    )

    private static let squaresNearFiftyLesson = Lesson(
        id: "sq_near50",
        title: "Squares Near 50",
        description: "Square numbers in the 40s and 50s using 25 as a base.",
        trick: MathTrick(
            name: "25 ± Difference",
            steps: [
                "Find the difference d from 50 (e.g. 53 → +3, 47 → −3).",
                "Add d to 25 to get the hundreds part.",
                "Add d² (the square of the difference) at the end."
            ],
            example: TrickExample(
                problem: "53 × 53",
                solution: "2809",
                stepByStepExplanation: [
                    "Step 1: 53 is 3 above 50",
                    "Step 2: 25 + 3 = 28 → 2800",
                    "Step 3: 3² = 9 → 2800 + 9",
                    "Answer: 2809"
                ]
            )
        ),
        operations: [.multiplication],
        difficulty: .hard,
        pattern: ProblemPattern.square(range: 41...59)
    )

    private static let sameTensUnitsSumTenLesson = Lesson(
        id: "mult_same_tens",
        title: "Same Tens, Units Make 10",
        description: "Pairs like 43 × 47 — same tens digit, units adding to 10 — in one line.",
        trick: MathTrick(
            name: "Tens × Next, then Units",
            steps: [
                "Check the shape: both numbers share a tens digit, and their units digits add to 10.",
                "Take the tens digit T and multiply it by (T + 1).",
                "Multiply the two units digits together.",
                "Write the second result after the first, padded to two digits.",
                "This is the same rule as squares ending in 5 — that's just the case where both units digits are 5."
            ],
            examples: [
                TrickExample(
                    problem: "43 × 47",
                    solution: "2021",
                    stepByStepExplanation: [
                        "Step 1: Units 3 + 7 = 10 ✓, tens both 4",
                        "Step 2: 4 × 5 = 20",
                        "Step 3: 3 × 7 = 21",
                        "Answer: 2021"
                    ]
                ),
                TrickExample(
                    problem: "62 × 68",
                    solution: "4216",
                    stepByStepExplanation: [
                        "Step 1: Units 2 + 8 = 10 ✓, tens both 6",
                        "Step 2: 6 × 7 = 42",
                        "Step 3: 2 × 8 = 16",
                        "Answer: 4216"
                    ]
                )
            ]
        ),
        operations: [.multiplication],
        difficulty: .medium,
        pattern: ProblemPattern.sameTensUnitsSumTen(tensRange: 1...9)
    )

    private static let squaresNearHundredLesson = Lesson(
        id: "sq_near100",
        title: "Squares Near 100",
        description: "Square anything from 91 to 109 by leaning on 100.",
        trick: MathTrick(
            name: "Double the Distance",
            steps: [
                "Find the distance d from 100 (103 → +3, 96 → −4).",
                "Add d to the number again — that's the front.",
                "Multiply the front by 100 (append two zeros).",
                "Add d² on the end.",
                "The same move works off any round base — 50 and 1000 included."
            ],
            examples: [
                TrickExample(
                    problem: "103 × 103",
                    solution: "10609",
                    stepByStepExplanation: [
                        "Step 1: 103 is 3 above 100",
                        "Step 2: 103 + 3 = 106 → 10600",
                        "Step 3: 3² = 9 → 10600 + 9",
                        "Answer: 10609"
                    ]
                ),
                TrickExample(
                    problem: "96 × 96",
                    solution: "9216",
                    stepByStepExplanation: [
                        "Step 1: 96 is 4 below 100",
                        "Step 2: 96 − 4 = 92 → 9200",
                        "Step 3: 4² = 16 → 9200 + 16",
                        "Answer: 9216"
                    ]
                )
            ]
        ),
        operations: [.multiplication],
        difficulty: .medium,
        pattern: ProblemPattern.squareNearBase(base: 100, deviationRange: 1...9)
    )

    // MARK: - Division Tricks

    static let divisionTricksGroup = LessonGroup(
        id: "division_tricks",
        title: "Division Tricks",
        description: "Shortcuts for dividing numbers mentally.",
        iconName: "divide.circle.fill",
        lessons: [
            divideByFourLesson,
            divideByFiveLesson,
            divideByNineLesson,
            remainderBySevenLesson
        ],
        requiredGroupId: "squaring_shortcuts"
    )

    private static let divideByFourLesson = Lesson(
        id: "div_4",
        title: "Divide by 4",
        description: "Halve the number, then halve again.",
        trick: MathTrick(
            name: "Halve Twice",
            steps: [
                "Halve the number.",
                "Halve the result again."
            ],
            example: TrickExample(
                problem: "92 ÷ 4",
                solution: "23",
                stepByStepExplanation: [
                    "Step 1: 92 ÷ 2 = 46",
                    "Step 2: 46 ÷ 2 = 23",
                    "Answer: 23"
                ]
            )
        ),
        operations: [.division],
        difficulty: .medium,
        pattern: ProblemPattern.divisor(divisors: [4], quotientRange: 2...25)
    )

    private static let divideByFiveLesson = Lesson(
        id: "div_5",
        title: "Divide by 5",
        description: "Double the number, then divide by 10.",
        trick: MathTrick(
            name: "Double then Shift",
            steps: [
                "Double the number.",
                "Divide that result by 10 (move the decimal / drop a zero)."
            ],
            example: TrickExample(
                problem: "85 ÷ 5",
                solution: "17",
                stepByStepExplanation: [
                    "Step 1: 85 × 2 = 170",
                    "Step 2: 170 ÷ 10 = 17",
                    "Answer: 17"
                ]
            )
        ),
        operations: [.division],
        difficulty: .medium,
        pattern: ProblemPattern.divisor(divisors: [5], quotientRange: 2...40)
    )

    private static let divideByNineLesson = Lesson(
        id: "div_9",
        title: "Divide by 9 — Running Sums",
        description: "No long division: just add the digits as you go left to right.",
        trick: MathTrick(
            name: "Add As You Go",
            steps: [
                "Write down the first digit — that's the first digit of the answer.",
                "Add the next digit to it — that's the next digit of the answer.",
                "Keep the running total going across the number.",
                "The very last total is the remainder, not part of the answer.",
                "These divide exactly, so the remainder always comes out as 9 — add 1 to what you've written and you're done."
            ],
            examples: [
                TrickExample(
                    problem: "117 ÷ 9",
                    solution: "13",
                    stepByStepExplanation: [
                        "Step 1: First digit → 1",
                        "Step 2: 1 + 1 = 2 → so far 12",
                        "Step 3: Remainder = 2 + 7 = 9",
                        "Step 4: Remainder is 9, so add 1 → 13",
                        "Answer: 13"
                    ]
                ),
                TrickExample(
                    problem: "342 ÷ 9",
                    solution: "38",
                    stepByStepExplanation: [
                        "Step 1: First digit → 3",
                        "Step 2: 3 + 4 = 7 → so far 37",
                        "Step 3: Remainder = 7 + 2 = 9",
                        "Step 4: Remainder is 9, so add 1 → 38",
                        "Answer: 38"
                    ]
                )
            ]
        ),
        operations: [.division],
        difficulty: .hard,
        pattern: ProblemPattern.divideByNine(quotientRange: 12...99)
    )

    private static let remainderBySevenLesson = Lesson(
        id: "mod_7",
        title: "Remainder After 7",
        description: "Find what's left over after dividing by 7 — without dividing.",
        trick: MathTrick(
            name: "The 7 Cycle",
            steps: [
                "Each place value has a fixed weight for 7. From the right they run 1, 3, 2, 6, 4, 5 — then repeat.",
                "Multiply each digit by its weight and add everything up.",
                "Take that total's remainder after 7. That's the answer.",
                "If the total is still big, run the same trick on it.",
                "A remainder of 0 means the number divides by 7 exactly — this is the divisibility test nobody knows."
            ],
            examples: [
                TrickExample(
                    problem: "528 mod 7",
                    solution: "3",
                    stepByStepExplanation: [
                        "Step 1: Weights from the right → 8×1, 2×3, 5×2",
                        "Step 2: 8 + 6 + 10 = 24",
                        "Step 3: 24 − 21 = 3",
                        "Answer: 3"
                    ]
                ),
                TrickExample(
                    problem: "1234 mod 7",
                    solution: "2",
                    stepByStepExplanation: [
                        "Step 1: Weights from the right → 4×1, 3×3, 2×2, 1×6",
                        "Step 2: 4 + 9 + 4 + 6 = 23",
                        "Step 3: 23 − 21 = 2",
                        "Answer: 2"
                    ]
                )
            ]
        ),
        operations: [.remainder],
        difficulty: .hard,
        pattern: ProblemPattern.remainder(divisor: 7, range: 100...9999)
    )

    // MARK: - Percentage Tricks

    static let percentageTricksGroup = LessonGroup(
        id: "percentage_tricks",
        title: "Percentage Tricks",
        description: "Find percentages of numbers in seconds.",
        iconName: "percent",
        lessons: [
            tenPercentLesson,
            onePercentLesson,
            fivePercentLesson,
            twentyFivePercentLesson
        ],
        requiredGroupId: "division_tricks"
    )

    private static let tenPercentLesson = Lesson(
        id: "pct_10",
        title: "Find 10%",
        description: "Move the decimal point one place left.",
        trick: MathTrick(
            name: "Shift Once",
            steps: [
                "To find 10% of a number, divide it by 10.",
                "Move the decimal point one place to the left."
            ],
            example: TrickExample(
                problem: "10% of 80",
                solution: "8",
                stepByStepExplanation: [
                    "Step 1: 80 ÷ 10 = 8",
                    "Answer: 8"
                ]
            )
        ),
        operations: [.percentage],
        difficulty: .easy,
        pattern: ProblemPattern.percentage(percents: [10], multiplierRange: 2...50)
    )

    private static let onePercentLesson = Lesson(
        id: "pct_1",
        title: "Find 1%",
        description: "Move the decimal point two places left.",
        trick: MathTrick(
            name: "Shift Twice",
            steps: [
                "To find 1% of a number, divide it by 100.",
                "Move the decimal point two places to the left."
            ],
            example: TrickExample(
                problem: "1% of 700",
                solution: "7",
                stepByStepExplanation: [
                    "Step 1: 700 ÷ 100 = 7",
                    "Answer: 7"
                ]
            )
        ),
        operations: [.percentage],
        difficulty: .easy,
        pattern: ProblemPattern.percentage(percents: [1], multiplierRange: 1...30)
    )

    private static let fivePercentLesson = Lesson(
        id: "pct_5",
        title: "Find 5%",
        description: "Take 10%, then halve it.",
        trick: MathTrick(
            name: "Half of 10%",
            steps: [
                "First find 10% by dividing by 10.",
                "Then halve that result to get 5%."
            ],
            example: TrickExample(
                problem: "5% of 80",
                solution: "4",
                stepByStepExplanation: [
                    "Step 1: 10% of 80 = 8",
                    "Step 2: 8 ÷ 2 = 4",
                    "Answer: 4"
                ]
            )
        ),
        operations: [.percentage],
        difficulty: .medium,
        pattern: ProblemPattern.percentage(percents: [5], multiplierRange: 2...30)
    )

    private static let twentyFivePercentLesson = Lesson(
        id: "pct_25",
        title: "Find 25%",
        description: "A quarter of the number — just divide by 4.",
        trick: MathTrick(
            name: "Quarter It",
            steps: [
                "25% is one quarter.",
                "Divide the number by 4."
            ],
            example: TrickExample(
                problem: "25% of 80",
                solution: "20",
                stepByStepExplanation: [
                    "Step 1: 80 ÷ 4 = 20",
                    "Answer: 20"
                ]
            )
        ),
        operations: [.percentage],
        difficulty: .medium,
        pattern: ProblemPattern.percentage(percents: [25], multiplierRange: 2...25)
    )
}
