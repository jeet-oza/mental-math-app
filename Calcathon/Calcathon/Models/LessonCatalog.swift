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
        digitRulesGroup,
        advancedMultiplicationGroup,
        crosswiseColumnsGroup,
        problemReshapingGroup,
        squaringShortcutsGroup,
        powersAndRootsGroup,
        divisionTricksGroup,
        advancedDivisionGroup,
        numberChecksGroup,
        percentageTricksGroup,
        fractionsGroup
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
        title: "Subtract From Multiples of 10",
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
            multiplyByTwentyFiveLesson,
            multiplyByNinesLesson
        ],
        requiredGroupId: "basic_subtraction"
    )

    // MARK: - Digit-by-Digit Rules

    /// Trachtenberg's rules for the awkward single-digit multipliers. Where the
    /// tricks group has a different idea for every multiplier, these are one
    /// mechanism reused: prepend a zero, walk right to left, and build each
    /// output digit from the digit under it and its *neighbour* — the digit on
    /// its right. Nothing is ever held in mind but one carry, and the number
    /// can be any length.
    static let digitRulesGroup = LessonGroup(
        id: "digit_rules",
        title: "Multiplication — Digit by Digit",
        description: "One mechanism for ×6, ×11 and ×12 — read each digit off its neighbour.",
        iconName: "list.number",
        lessons: [
            neighbourSixLesson,
            neighbourElevenLesson,
            neighbourTwelveLesson
        ],
        requiredGroupId: "multiplication_tricks"
    )

    /// Shared preamble for the neighbour rules, so every lesson in the group
    /// states the convention the same way.
    private static let neighbourNote =
        "Write a 0 in front of the number. Each digit's \"neighbour\" is the digit on its right; the last digit has none (treat it as 0)."

    private static let neighbourElevenLesson = Lesson(
        id: "tb_11",
        title: "×11, Any Length",
        description: "The 2-digit ×11 trick is one case of a rule that runs across a number of any size.",
        trick: MathTrick(
            name: "Add the Neighbour",
            steps: [
                neighbourNote,
                "Working right to left, each answer digit is the digit plus its neighbour.",
                "The last digit has no neighbour, so it just comes down.",
                "Carry as usual when a total reaches 10."
            ],
            example: TrickExample(
                problem: "4213 × 11",
                solution: "46343",
                stepByStepExplanation: [
                    "Step 1: Write it as 04213",
                    "Step 2: 3 has no neighbour → 3",
                    "Step 3: 1 + 3 = 4",
                    "Step 4: 2 + 1 = 3",
                    "Step 5: 4 + 2 = 6",
                    "Step 6: 0 + 4 = 4",
                    "Answer: 46343"
                ]
            )
        ),
        operations: [.multiplication],
        difficulty: .medium,
        pattern: ProblemPattern.fixedOperand(operation: .multiplication, fixedValues: [11], position: .right, variableRange: 1000...9999)
    )

    private static let neighbourTwelveLesson = Lesson(
        id: "tb_12",
        title: "Multiply by 12",
        description: "Same walk as ×11, but double each digit on the way past.",
        trick: MathTrick(
            name: "Double, Add the Neighbour",
            steps: [
                neighbourNote,
                "Working right to left, each answer digit is double the digit, plus its neighbour.",
                "Carry anything over 9 into the next step."
            ],
            example: TrickExample(
                problem: "316 × 12",
                solution: "3792",
                stepByStepExplanation: [
                    "Step 1: Write it as 0316",
                    "Step 2: (2 × 6) + 0 = 12 → write 2, carry 1",
                    "Step 3: (2 × 1) + 6 + 1 = 9",
                    "Step 4: (2 × 3) + 1 = 7",
                    "Step 5: (2 × 0) + 3 = 3",
                    "Answer: 3792"
                ]
            )
        ),
        operations: [.multiplication],
        difficulty: .medium,
        pattern: ProblemPattern.fixedOperand(operation: .multiplication, fixedValues: [12], position: .right, variableRange: 100...999)
    )

    private static let neighbourSixLesson = Lesson(
        id: "tb_6",
        title: "Multiply by 6",
        description: "Works on odd numbers too, unlike halve-and-shift.",
        trick: MathTrick(
            name: "Half the Neighbour, +5 if Odd",
            steps: [
                neighbourNote,
                "Each answer digit is the digit itself, plus half its neighbour.",
                "Halving always throws the fraction away: half of 7 is 3.",
                "If the digit you are on is odd, add 5.",
                "Carry anything over 9 into the next step."
            ],
            example: TrickExample(
                problem: "357 × 6",
                solution: "2142",
                stepByStepExplanation: [
                    "Step 1: Write it as 0357",
                    "Step 2: 7 is odd, no neighbour → 7 + 0 + 5 = 12 → write 2, carry 1",
                    "Step 3: 5 is odd, neighbour 7 → 5 + 3 + 5 + 1 = 14 → write 4, carry 1",
                    "Step 4: 3 is odd, neighbour 5 → 3 + 2 + 5 + 1 = 11 → write 1, carry 1",
                    "Step 5: 0 is even, neighbour 3 → 0 + 1 + 1 = 2",
                    "Answer: 2142"
                ]
            )
        ),
        operations: [.multiplication],
        difficulty: .hard,
        pattern: ProblemPattern.fixedOperand(operation: .multiplication, fixedValues: [6], position: .right, variableRange: 100...999)
    )

    // MARK: - Advanced Multiplication

    /// Pick a round number near both operands and adjust. Not tied to a
    /// particular multiplier, so these reach the pairs no single-number trick
    /// does. Split from the crosswise lessons, which are a different idea
    /// wearing the same "advanced" label.
    static let advancedMultiplicationGroup = LessonGroup(
        id: "advanced_multiplication",
        title: "Multiplication — Near Base Method",
        description: "Anchor both numbers to a round base — 50, 100, 200, 500, 1000 — and correct.",
        iconName: "arrow.triangle.swap",
        lessons: [
            multiplyNearHundredLesson,
            multiplyNearHundredCarryLesson,
            multiplyNearFiftyLesson,
            multiplyNearTwoHundredLesson,
            multiplyNearFiveHundredLesson,
            multiplyNearThousandLesson
        ],
        requiredGroupId: "digit_rules"
    )

    /// Column-by-column multiplication. Unlike the base methods these need no
    /// round number anywhere nearby, which is what makes them the fallback
    /// when nothing else fits.
    static let crosswiseColumnsGroup = LessonGroup(
        id: "crosswise_columns",
        title: "Multiplication — Vedic Math",
        description: "Multiply digit by digit, one column at a time — works on any pair at all.",
        iconName: "square.grid.3x3",
        lessons: [
            crosswiseBasicsLesson,
            crosswiseCarryLesson,
            crosswiseThreeDigitLesson
        ],
        requiredGroupId: "advanced_multiplication"
    )

    private static let multiplyNearFiveHundredLesson = Lesson(
        id: "mult_near500",
        title: "Multiply Near 500",
        description: "Numbers in the high 400s and low 500s — and ×500 is just halve, then three zeros.",
        trick: MathTrick(
            name: "Base 500",
            steps: [
                "Measure how far each number is from 500, both on the same side.",
                "Cross-subtract: take one number and adjust it by the other's distance.",
                "Multiply that by 500 — which is halving it and adding three zeros.",
                "Multiply the two distances together and add that on.",
                "Halving instead of multiplying is what makes 500 an easier base than it looks."
            ],
            examples: [
                TrickExample(
                    problem: "493 × 496",
                    solution: "244528",
                    stepByStepExplanation: [
                        "Step 1: 493 is 7 below 500, 496 is 4 below",
                        "Step 2: Cross-subtract → 493 − 4 = 489",
                        "Step 3: 489 × 500 → half of 489 is 244.5, so 244500",
                        "Step 4: Distances → 7 × 4 = 28",
                        "Step 5: 244500 + 28 = 244528",
                        "Answer: 244528"
                    ]
                ),
                TrickExample(
                    problem: "506 × 503",
                    solution: "254518",
                    stepByStepExplanation: [
                        "Step 1: 506 is 6 above 500, 503 is 3 above",
                        "Step 2: Cross-add → 506 + 3 = 509",
                        "Step 3: 509 × 500 → half of 509 is 254.5, so 254500",
                        "Step 4: Distances → 6 × 3 = 18",
                        "Step 5: 254500 + 18 = 254518",
                        "Answer: 254518"
                    ]
                )
            ]
        ),
        operations: [.multiplication],
        difficulty: .hard,
        pattern: ProblemPattern.nearBase(base: 500, deviationRange: 1...12)
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

    private static let multiplyByNinesLesson = Lesson(
        id: "mult_99",
        title: "Multiply by 99 or 999",
        description: "Two halves, written straight down — no multiplying at all.",
        trick: MathTrick(
            name: "One Less, Then the Complement",
            steps: [
                "Left half: knock 1 off the number you're multiplying.",
                "Right half: take that same number away from the next round number (100 for 99, 1000 for 999).",
                "For the right half use the complement rule you already know — all digits from 9, the last from 10.",
                "Pad the right half to as many digits as there are 9s.",
                "Write the two halves side by side."
            ],
            examples: [
                TrickExample(
                    problem: "76 × 99",
                    solution: "7524",
                    stepByStepExplanation: [
                        "Step 1: Left → 76 − 1 = 75",
                        "Step 2: Right → 100 − 76 = 24",
                        "Step 3: Two digits of 9s, so the right half is 24",
                        "Answer: 7524"
                    ]
                ),
                TrickExample(
                    problem: "45 × 999",
                    solution: "44955",
                    stepByStepExplanation: [
                        "Step 1: Left → 45 − 1 = 44",
                        "Step 2: Right → 1000 − 45 = 955",
                        "Step 3: Three digits of 9s, so the right half is 955",
                        "Answer: 44955"
                    ]
                )
            ]
        ),
        operations: [.multiplication],
        difficulty: .medium,
        pattern: ProblemPattern.fixedOperand(
            operation: .multiplication, fixedValues: [99, 999], position: .right, variableRange: 11...99)
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

    // MARK: - Reshape the Problem

    /// Techniques that change the problem before any arithmetic happens. Every
    /// other group makes a *calculation* faster; these make the calculation
    /// smaller, which is the habit the calculating prodigies had in common —
    /// none of them computed the problem they were handed.
    static let problemReshapingGroup = LessonGroup(
        id: "problem_reshaping",
        title: "Multiplication — Advanced",
        description: "Split it or re-base it — change the problem before you solve it.",
        iconName: "arrow.triangle.branch",
        lessons: [
            twoReferenceLesson,
            multiplyByFactorsLesson,
            doubleAndHalveLesson,
            anchorMethodLesson,
            midpointMethodLesson
        ],
        requiredGroupId: "crosswise_columns"
    )

    private static let doubleAndHalveLesson = Lesson(
        id: "mult_double_halve",
        title: "Double and Halve",
        description: "Move a factor of 2 from one side to the other and the product doesn't change.",
        trick: MathTrick(
            name: "Rebalance the Pair",
            steps: [
                "Double the smaller number and halve the larger one.",
                "The product is unchanged, because you removed a 2 from one side and gave it to the other.",
                "Aim for a pair you already know — landing on a times table you own is the whole point.",
                "Halving only works while the larger number stays even, so stop when it turns odd."
            ],
            examples: [
                TrickExample(
                    problem: "3 × 14",
                    solution: "42",
                    stepByStepExplanation: [
                        "Step 1: Double 3 → 6",
                        "Step 2: Halve 14 → 7",
                        "Step 3: 6 × 7 = 42",
                        "Answer: 42"
                    ]
                ),
                TrickExample(
                    problem: "6 × 24",
                    solution: "144",
                    stepByStepExplanation: [
                        "Step 1: Double 6 → 12",
                        "Step 2: Halve 24 → 12",
                        "Step 3: 12 × 12 = 144",
                        "Answer: 144"
                    ]
                )
            ]
        ),
        operations: [.multiplication],
        difficulty: .easy,
        pattern: ProblemPattern.doubleAndHalve(smallRange: 3...9, evenRange: 12...48)
    )

    private static let anchorMethodLesson = Lesson(
        id: "mult_anchor",
        title: "The Anchor Method",
        description: "The one identity behind every base method — and it works off any round number, not just 100.",
        trick: MathTrick(
            name: "Anchor and Correct",
            steps: [
                "Pick a round number near both — 10, 20, 30, whatever is closest.",
                "Take each number's signed distance from that anchor.",
                "Add both distances to the anchor. Multiply that by the anchor.",
                "Multiply the two distances together, keeping the signs, and add it on.",
                "One number moving above and the other below is not a special case — the signs handle it."
            ],
            examples: [
                TrickExample(
                    problem: "18 × 16",
                    solution: "288",
                    stepByStepExplanation: [
                        "Step 1: Anchor 20 → 18 is −2, 16 is −4",
                        "Step 2: 20 − 2 − 4 = 14",
                        "Step 3: 20 × 14 = 280",
                        "Step 4: (−2) × (−4) = +8",
                        "Step 5: 280 + 8 = 288",
                        "Answer: 288"
                    ]
                ),
                TrickExample(
                    problem: "18 × 24",
                    solution: "432",
                    stepByStepExplanation: [
                        "Step 1: Anchor 20 → 18 is −2, 24 is +4",
                        "Step 2: 20 − 2 + 4 = 22",
                        "Step 3: 20 × 22 = 440",
                        "Step 4: (−2) × (+4) = −8",
                        "Step 5: 440 − 8 = 432",
                        "Answer: 432"
                    ]
                )
            ]
        ),
        operations: [.multiplication],
        difficulty: .medium,
        pattern: ProblemPattern.anchorProduct(anchors: [20, 30, 40, 60, 70], deviationRange: 1...5)
    )

    private static let midpointMethodLesson = Lesson(
        id: "mult_midpoint",
        title: "Meet in the Middle",
        description: "Turn any product into one square minus another — 46 × 58 becomes 52² − 6².",
        trick: MathTrick(
            name: "Midpoint Method",
            steps: [
                "Find the number halfway between the two — their average.",
                "Note how far each one sits from that midpoint. Both are the same distance, one either side.",
                "Square the midpoint.",
                "Subtract the distance squared. That's the answer.",
                "It works because (m − g)(m + g) is always m² − g², so a product becomes a square you already know."
            ],
            examples: [
                TrickExample(
                    problem: "46 × 58",
                    solution: "2668",
                    stepByStepExplanation: [
                        "Step 1: Midpoint of 46 and 58 is 52",
                        "Step 2: Each sits 6 away from 52",
                        "Step 3: 52² = 2704",
                        "Step 4: 6² = 36",
                        "Step 5: 2704 − 36 = 2668",
                        "Answer: 2668"
                    ]
                ),
                TrickExample(
                    problem: "28 × 32",
                    solution: "896",
                    stepByStepExplanation: [
                        "Step 1: Midpoint of 28 and 32 is 30",
                        "Step 2: Each sits 2 away from 30",
                        "Step 3: 30² = 900",
                        "Step 4: 2² = 4",
                        "Step 5: 900 − 4 = 896",
                        "Answer: 896"
                    ]
                )
            ]
        ),
        operations: [.multiplication],
        difficulty: .medium,
        pattern: ProblemPattern.midpointProduct(midpointRange: 20...90, gapRange: 2...8)
    )

    private static let twoReferenceLesson = Lesson(
        id: "mult_two_reference",
        title: "Two Reference Numbers",
        description: "For pairs too far apart to share a base, like 8 × 53 — give each number its own.",
        trick: MathTrick(
            name: "Base and Multiple",
            steps: [
                "Use 10 for the small number and 50 for the large one. 50 is 5 × 10, so 5 is the link between them.",
                "Take each number's signed distance from its own reference (8 → −2, 53 → +3).",
                "Multiply the small number's distance by the link (5) and add that to the large number.",
                "Multiply that total by 10.",
                "Add the two distances multiplied together, keeping the sign."
            ],
            examples: [
                TrickExample(
                    problem: "8 × 53",
                    solution: "424",
                    stepByStepExplanation: [
                        "Step 1: 8 → −2 from 10, and 53 → +3 from 50",
                        "Step 2: −2 × 5 = −10, so 53 − 10 = 43",
                        "Step 3: 43 × 10 = 430",
                        "Step 4: distances −2 × 3 = −6",
                        "Step 5: 430 − 6 = 424",
                        "Answer: 424"
                    ]
                ),
                TrickExample(
                    problem: "12 × 47",
                    solution: "564",
                    stepByStepExplanation: [
                        "Step 1: 12 → +2 from 10, and 47 → −3 from 50",
                        "Step 2: +2 × 5 = +10, so 47 + 10 = 57",
                        "Step 3: 57 × 10 = 570",
                        "Step 4: distances 2 × −3 = −6",
                        "Step 5: 570 − 6 = 564",
                        "Answer: 564"
                    ]
                )
            ]
        ),
        operations: [.multiplication],
        difficulty: .hard,
        pattern: ProblemPattern.twoReference(base: 10, multiple: 50, deviationRange: 1...4)
    )

    private static let multiplyByFactorsLesson = Lesson(
        id: "mult_factors",
        title: "Multiply by Factors",
        description: "Break an awkward multiplier into two easy ones and go twice.",
        trick: MathTrick(
            name: "Split the Multiplier",
            steps: [
                "Split the multiplier into two factors you already have a shortcut for.",
                "Multiply by the first, then multiply that result by the second.",
                "Order is free — take whichever leaves the rounder number in the middle.",
                "14 = 2 × 7, 15 = 5 × 3, 16 = 4 × 4, 18 = 2 × 9, 24 = 3 × 8, 45 = 5 × 9."
            ],
            examples: [
                TrickExample(
                    problem: "47 × 14",
                    solution: "658",
                    stepByStepExplanation: [
                        "Step 1: 14 = 2 × 7",
                        "Step 2: 47 × 2 = 94",
                        "Step 3: 94 × 7 = 658",
                        "Answer: 658"
                    ]
                ),
                TrickExample(
                    problem: "36 × 45",
                    solution: "1620",
                    stepByStepExplanation: [
                        "Step 1: 45 = 9 × 5",
                        "Step 2: 36 × 9 = 324",
                        "Step 3: 324 × 5 = 1620 (half of 3240)",
                        "Answer: 1620"
                    ]
                )
            ]
        ),
        operations: [.multiplication],
        difficulty: .medium,
        pattern: ProblemPattern.fixedOperand(
            operation: .multiplication,
            fixedValues: [14, 15, 16, 18, 21, 24, 35, 45, 48, 63],
            position: .right,
            variableRange: 12...99
        )
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
            squaresNearHundredLesson,
            squareNeighbourLesson,
            squaresNearFiveHundredLesson,
            squareAnyTwoDigitLesson
        ],
        requiredGroupId: "problem_reshaping"
    )

    private static let squaresNearFiveHundredLesson = Lesson(
        id: "sq_near500",
        title: "Squares Near 500",
        description: "513² without touching a big multiplication — 250 does the work.",
        trick: MathTrick(
            name: "250 Plus the Distance",
            steps: [
                "Take the number's signed distance from 500 (513 → +13, 492 → −8).",
                "Add that distance to 250. Those are the leading digits.",
                "Square the distance and write it as three digits, padding with zeros.",
                "Put the two parts side by side.",
                "It works because 500² is 250 thousands, and each step of 1 adds 1000."
            ],
            examples: [
                TrickExample(
                    problem: "513 × 513",
                    solution: "263169",
                    stepByStepExplanation: [
                        "Step 1: 513 is 13 above 500",
                        "Step 2: 250 + 13 = 263",
                        "Step 3: 13² = 169",
                        "Answer: 263169"
                    ]
                ),
                TrickExample(
                    problem: "492 × 492",
                    solution: "242064",
                    stepByStepExplanation: [
                        "Step 1: 492 is 8 below 500",
                        "Step 2: 250 − 8 = 242",
                        "Step 3: 8² = 64 → pad to 064",
                        "Answer: 242064"
                    ]
                )
            ]
        ),
        operations: [.multiplication],
        difficulty: .hard,
        pattern: ProblemPattern.squareNearBase(base: 500, deviationRange: 1...25)
    )

    private static let squareNeighbourLesson = Lesson(
        id: "sq_neighbour",
        title: "Squares Next Door",
        description: "31² and 29² both fall straight out of 30² — for anything ending in 1 or 9.",
        trick: MathTrick(
            name: "Borrow the Round Square",
            steps: [
                "Round to the nearest multiple of ten and square it — that part is just a times table and two zeros.",
                "Going up one: add the round number, then add the number you want.",
                "Going down one: subtract the round number, then subtract the number you want.",
                "Put another way, stepping from one square to the next adds the two numbers involved."
            ],
            examples: [
                TrickExample(
                    problem: "31 × 31",
                    solution: "961",
                    stepByStepExplanation: [
                        "Step 1: 30² = 900",
                        "Step 2: Going up, so add 30 → 930",
                        "Step 3: Then add 31 → 961",
                        "Answer: 961"
                    ]
                ),
                TrickExample(
                    problem: "69 × 69",
                    solution: "4761",
                    stepByStepExplanation: [
                        "Step 1: Nearest round is 70, and 70² = 4900",
                        "Step 2: Going down, so subtract 70 → 4830",
                        "Step 3: Then subtract 69 → 4761",
                        "Answer: 4761"
                    ]
                )
            ]
        ),
        operations: [.multiplication],
        difficulty: .medium,
        pattern: ProblemPattern.squareAdjacentToRound(tensRange: 2...9)
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

    private static let squareAnyTwoDigitLesson = Lesson(
        id: "sq_any",
        title: "Square Any 2-Digit Number",
        description: "The catch-all: three columns that work when no special shape fits.",
        trick: MathTrick(
            name: "The Duplex",
            steps: [
                "Split the number into its tens digit and its units digit.",
                "Right column: the units digit squared.",
                "Middle column: the two digits multiplied, then doubled.",
                "Left column: the tens digit squared.",
                "Work right to left, keeping one digit per column and carrying the rest left.",
                "This is the crosswise method pointed at a number and itself — so it squares anything, no special shape needed."
            ],
            examples: [
                TrickExample(
                    problem: "43 × 43",
                    solution: "1849",
                    stepByStepExplanation: [
                        "Step 1: Units → 3² = 9",
                        "Step 2: Middle → 4 × 3 × 2 = 24 → write 4, carry 2",
                        "Step 3: Tens → 4² = 16, plus carry 2 = 18",
                        "Answer: 1849"
                    ]
                ),
                TrickExample(
                    problem: "67 × 67",
                    solution: "4489",
                    stepByStepExplanation: [
                        "Step 1: Units → 7² = 49 → write 9, carry 4",
                        "Step 2: Middle → 6 × 7 × 2 = 84, plus carry 4 = 88 → write 8, carry 8",
                        "Step 3: Tens → 6² = 36, plus carry 8 = 44",
                        "Answer: 4489"
                    ]
                )
            ]
        ),
        operations: [.multiplication],
        difficulty: .hard,
        pattern: ProblemPattern.square(range: 21...99)
    )

    private static let multiplyNearTwoHundredLesson = Lesson(
        id: "mult_near200",
        title: "Multiply Near 200",
        description: "A working base of 200 — same method, but the front doubles instead of halving.",
        trick: MathTrick(
            name: "Sub-Base 200",
            steps: [
                "Measure how far each number is from 200 (203 → 3 above).",
                "Front = one number plus the other's distance.",
                "Because 200 is twice 100, double that front.",
                "Tail = the two distances multiplied, padded to two digits.",
                "Write the front, then the tail.",
                "The same idea covers any working base: halve for 50, double for 200, triple for 300."
            ],
            examples: [
                TrickExample(
                    problem: "203 × 204",
                    solution: "41412",
                    stepByStepExplanation: [
                        "Step 1: Distances 3 and 4, both above",
                        "Step 2: Front = 203 + 4 = 207",
                        "Step 3: Double it → 414",
                        "Step 4: Tail = 3 × 4 = 12",
                        "Answer: 41412"
                    ]
                ),
                TrickExample(
                    problem: "196 × 197",
                    solution: "38612",
                    stepByStepExplanation: [
                        "Step 1: Distances 4 and 3, both below",
                        "Step 2: Front = 196 − 3 = 193",
                        "Step 3: Double it → 386",
                        "Step 4: Tail = 4 × 3 = 12",
                        "Answer: 38612"
                    ]
                )
            ]
        ),
        operations: [.multiplication],
        difficulty: .hard,
        pattern: ProblemPattern.nearBase(base: 200, deviationRange: 1...9)
    )

    private static let divideByEightLesson = Lesson(
        id: "div_8",
        title: "Divide by 8",
        description: "Halve it three times.",
        trick: MathTrick(
            name: "Halve Three Times",
            steps: [
                "Halve the number.",
                "Halve the result.",
                "Halve it once more — 8 is just 2 × 2 × 2.",
                "Three easy halvings beat one hard division."
            ],
            example: TrickExample(
                problem: "184 ÷ 8",
                solution: "23",
                stepByStepExplanation: [
                    "Step 1: 184 ÷ 2 = 92",
                    "Step 2: 92 ÷ 2 = 46",
                    "Step 3: 46 ÷ 2 = 23",
                    "Answer: 23"
                ]
            )
        ),
        operations: [.division],
        difficulty: .medium,
        pattern: ProblemPattern.divisor(divisors: [8], quotientRange: 2...40)
    )

    // MARK: - Powers & Roots

    /// Cubes and roots. Roots are the reverse-engineering lessons: the answer
    /// is read off the number's last digit and its leading group, with no
    /// division or trial multiplication anywhere.
    static let powersAndRootsGroup = LessonGroup(
        id: "powers_and_roots",
        title: "Powers & Roots",
        description: "Cube numbers, and read square and cube roots straight off the digits.",
        iconName: "function",
        lessons: [
            differenceOfSquaresLesson,
            cubeNearHundredLesson,
            cubeAnyTwoDigitLesson,
            squareRootLesson,
            cubeRootLesson,
            estimateSquareRootLesson,
            estimateCubeRootLesson
        ],
        requiredGroupId: "squaring_shortcuts"
    )

    /// Shared note for both estimation lessons: these are the first answers
    /// in the app that are not exact, and a player needs telling.
    private static let estimateAccuracyNote =
        "This is an estimate, so close counts — you don't need more than two decimal places."

    private static let estimateSquareRootLesson = Lesson(
        id: "root_square_estimate",
        title: "Estimate Any Square Root",
        description: "√50 in your head, to two decimals — for the numbers that aren't perfect squares.",
        trick: MathTrick(
            name: "Nearest Square, Then Correct",
            steps: [
                "Find the nearest perfect square and take its root — that's your starting guess.",
                "Subtract that square from your number. The gap may be negative; that's fine.",
                "Divide the gap by twice your guess.",
                "Add that correction to the guess.",
                "The nearer the square, the better the answer — so always round to the *closest* one, above or below.",
                estimateAccuracyNote
            ],
            examples: [
                TrickExample(
                    problem: "√50",
                    solution: "7.07",
                    stepByStepExplanation: [
                        "Step 1: Nearest square is 49, so start at 7",
                        "Step 2: Gap → 50 − 49 = 1",
                        "Step 3: Twice the guess → 2 × 7 = 14",
                        "Step 4: Correction → 1 ÷ 14 ≈ 0.07",
                        "Step 5: 7 + 0.07 = 7.07",
                        "Answer: 7.07"
                    ]
                ),
                TrickExample(
                    problem: "√60",
                    solution: "7.75",
                    stepByStepExplanation: [
                        "Step 1: Nearest square is 64, so start at 8",
                        "Step 2: Gap → 60 − 64 = −4",
                        "Step 3: Twice the guess → 2 × 8 = 16",
                        "Step 4: Correction → −4 ÷ 16 = −0.25",
                        "Step 5: 8 − 0.25 = 7.75",
                        "Answer: 7.75 (true value 7.746)"
                    ]
                )
            ]
        ),
        operations: [.approximateSquareRoot],
        difficulty: .hard,
        pattern: ProblemPattern.approximateSquareRoot(range: 10...500),
        answerMode: .expression
    )

    private static let estimateCubeRootLesson = Lesson(
        id: "root_cube_estimate",
        title: "Estimate Any Cube Root",
        description: "The same correction, with the cube's own slope — three times the guess squared.",
        trick: MathTrick(
            name: "Nearest Cube, Then Correct",
            steps: [
                "Find the nearest exact cube and take its root — that's your starting guess.",
                "Subtract that cube from your number, keeping the sign.",
                "Divide the gap by three times your guess squared.",
                "Add that correction to the guess.",
                "It is the square-root method with 3n² where that one used 2n, for the same reason.",
                estimateAccuracyNote
            ],
            examples: [
                TrickExample(
                    problem: "∛130",
                    solution: "5.07",
                    stepByStepExplanation: [
                        "Step 1: Nearest cube is 125, so start at 5",
                        "Step 2: Gap → 130 − 125 = 5",
                        "Step 3: Three times the guess squared → 3 × 25 = 75",
                        "Step 4: Correction → 5 ÷ 75 ≈ 0.07",
                        "Step 5: 5 + 0.07 = 5.07",
                        "Answer: 5.07"
                    ]
                ),
                TrickExample(
                    problem: "∛200",
                    solution: "5.85",
                    stepByStepExplanation: [
                        "Step 1: Nearest cube is 216, so start at 6",
                        "Step 2: Gap → 200 − 216 = −16",
                        "Step 3: Three times the guess squared → 3 × 36 = 108",
                        "Step 4: Correction → −16 ÷ 108 ≈ −0.15",
                        "Step 5: 6 − 0.15 = 5.85",
                        "Answer: 5.85 (true value 5.848)"
                    ]
                )
            ]
        ),
        operations: [.approximateCubeRoot],
        difficulty: .hard,
        pattern: ProblemPattern.approximateCubeRoot(range: 100...9999),
        answerMode: .expression
    )

    private static let differenceOfSquaresLesson = Lesson(
        id: "sq_difference",
        title: "Difference of Two Squares",
        description: "Never square either number — turn the whole thing into one small product.",
        trick: MathTrick(
            name: "Sum Times Difference",
            steps: [
                "You're asked for one square minus another.",
                "Add the two numbers together.",
                "Subtract the smaller from the larger.",
                "Multiply those two results — that's the answer.",
                "Both squares disappear, which is why this beats working them out."
            ],
            examples: [
                TrickExample(
                    problem: "47² − 43²",
                    solution: "360",
                    stepByStepExplanation: [
                        "Step 1: 47 + 43 = 90",
                        "Step 2: 47 − 43 = 4",
                        "Step 3: 90 × 4 = 360",
                        "Answer: 360"
                    ]
                ),
                TrickExample(
                    problem: "85² − 15²",
                    solution: "7000",
                    stepByStepExplanation: [
                        "Step 1: 85 + 15 = 100",
                        "Step 2: 85 − 15 = 70",
                        "Step 3: 100 × 70 = 7000",
                        "Answer: 7000"
                    ]
                )
            ]
        ),
        operations: [.differenceOfSquares],
        difficulty: .medium,
        pattern: ProblemPattern.differenceOfSquares(range: 21...99, gapRange: 2...12)
    )

    private static let cubeNearHundredLesson = Lesson(
        id: "cube_near100",
        title: "Cube a Number Near 100",
        description: "Three parts, built from the distance above 100.",
        trick: MathTrick(
            name: "Yavadunam for Cubes",
            steps: [
                "Find the distance d above 100 (104 → 4).",
                "First part: the number plus twice that distance.",
                "Second part: three times the distance squared.",
                "Third part: the distance cubed.",
                "Write the three parts side by side, each of the last two padded to two digits.",
                "Carry left out of any part that overflows two digits."
            ],
            examples: [
                TrickExample(
                    problem: "104³",
                    solution: "1124864",
                    stepByStepExplanation: [
                        "Step 1: d = 4",
                        "Step 2: First → 104 + 8 = 112",
                        "Step 3: Second → 3 × 16 = 48",
                        "Step 4: Third → 4³ = 64",
                        "Step 5: 112 | 48 | 64",
                        "Answer: 1124864"
                    ]
                ),
                TrickExample(
                    problem: "106³",
                    solution: "1191016",
                    stepByStepExplanation: [
                        "Step 1: d = 6",
                        "Step 2: First → 106 + 12 = 118",
                        "Step 3: Second → 3 × 36 = 108",
                        "Step 4: Third → 6³ = 216",
                        "Step 5: 216 → write 16, carry 2; 108 + 2 = 110 → write 10, carry 1; 118 + 1 = 119",
                        "Answer: 1191016"
                    ]
                )
            ]
        ),
        operations: [.cube],
        difficulty: .hard,
        pattern: ProblemPattern.cubeNearBase(base: 100, deviationRange: 1...9)
    )

    private static let cubeAnyTwoDigitLesson = Lesson(
        id: "cube_any",
        title: "Cube Any 2-Digit Number",
        description: "Four columns in a fixed ratio — works on any two digits.",
        trick: MathTrick(
            name: "Ratio and Double",
            steps: [
                "Write four numbers: the tens digit cubed, then each next one multiplied by (units ÷ tens).",
                "In practice: t³, then t²u, then tu², then u³.",
                "Double the middle two and add each doubling onto itself.",
                "Now add down the four columns, carrying left as usual.",
                "The ratio between neighbours is always the same, which is what makes the four numbers quick to write."
            ],
            examples: [
                TrickExample(
                    problem: "24³",
                    solution: "13824",
                    stepByStepExplanation: [
                        "Step 1: Four terms → 8, 16, 32, 64",
                        "Step 2: Double the middle two → 32 and 64",
                        "Step 3: Add them on → 8 | 48 | 96 | 64",
                        "Step 4: Carry right to left → 13824",
                        "Answer: 13824"
                    ]
                ),
                TrickExample(
                    problem: "13³",
                    solution: "2197",
                    stepByStepExplanation: [
                        "Step 1: Four terms → 1, 3, 9, 27",
                        "Step 2: Double the middle two → 6 and 18",
                        "Step 3: Add them on → 1 | 9 | 27 | 27",
                        "Step 4: Carry right to left → 2197",
                        "Answer: 2197"
                    ]
                )
            ]
        ),
        operations: [.cube],
        difficulty: .hard,
        pattern: ProblemPattern.cube(range: 11...39)
    )

    private static let squareRootLesson = Lesson(
        id: "root_square",
        title: "Square Root of a Perfect Square",
        description: "Read the root off the ends — no dividing, no guessing.",
        trick: MathTrick(
            name: "Ends and Bracket",
            steps: [
                "The last digit tells you the root's last digit: 1→1 or 9, 4→2 or 8, 9→3 or 7, 6→4 or 6, 5→5, 0→0.",
                "Ignore the last two digits and look at what's left.",
                "Find the biggest square that fits inside it — its root is your first digit.",
                "That leaves two candidates. Square the one ending in 5 between them.",
                "If the number is below that, take the smaller candidate; above it, take the larger."
            ],
            examples: [
                TrickExample(
                    problem: "√5329",
                    solution: "73",
                    stepByStepExplanation: [
                        "Step 1: Ends in 9 → root ends in 3 or 7",
                        "Step 2: Leading part is 53; 7² = 49 fits, 8² = 64 doesn't → first digit 7",
                        "Step 3: Candidates 73 and 77",
                        "Step 4: 75² = 5625, and 5329 is below it → take 73",
                        "Answer: 73"
                    ]
                ),
                TrickExample(
                    problem: "√3364",
                    solution: "58",
                    stepByStepExplanation: [
                        "Step 1: Ends in 4 → root ends in 2 or 8",
                        "Step 2: Leading part is 33; 5² = 25 fits, 6² = 36 doesn't → first digit 5",
                        "Step 3: Candidates 52 and 58",
                        "Step 4: 55² = 3025, and 3364 is above it → take 58",
                        "Answer: 58"
                    ]
                )
            ]
        ),
        operations: [.squareRoot],
        difficulty: .medium,
        pattern: ProblemPattern.perfectSquareRoot(range: 11...99)
    )

    private static let cubeRootLesson = Lesson(
        id: "root_cube",
        title: "Cube Root of an Exact Cube",
        description: "The party trick: a five-digit cube root at a glance.",
        trick: MathTrick(
            name: "Last Digit, First Group",
            steps: [
                "Cube endings never collide, so the last digit gives the root's last digit outright.",
                "Most match themselves — 1→1, 4→4, 5→5, 6→6, 9→9, 0→0.",
                "Only two pairs swap: 8→2 and 2→8, 7→3 and 3→7.",
                "Now cross off the last three digits and look at what's left.",
                "The biggest cube that fits inside it gives the first digit.",
                "Put the two digits together — that's the whole root."
            ],
            examples: [
                TrickExample(
                    problem: "∛39304",
                    solution: "34",
                    stepByStepExplanation: [
                        "Step 1: Ends in 4 → root ends in 4",
                        "Step 2: Cross off 304, leaving 39",
                        "Step 3: 3³ = 27 fits, 4³ = 64 doesn't → first digit 3",
                        "Answer: 34"
                    ]
                ),
                TrickExample(
                    problem: "∛103823",
                    solution: "47",
                    stepByStepExplanation: [
                        "Step 1: Ends in 3 → root ends in 7 (the swapping pair)",
                        "Step 2: Cross off 823, leaving 103",
                        "Step 3: 4³ = 64 fits, 5³ = 125 doesn't → first digit 4",
                        "Answer: 47"
                    ]
                )
            ]
        ),
        operations: [.cubeRoot],
        difficulty: .medium,
        pattern: ProblemPattern.exactCubeRoot(range: 11...99)
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
            divideByEightLesson,
            divideByNineLesson,
            divideByNineRemainderLesson,
            divideByFactorsLesson
        ],
        requiredGroupId: "powers_and_roots"
    )

    private static let divideByNineRemainderLesson = Lesson(
        id: "div_9_remainder",
        title: "Divide by 9 — With a Remainder",
        description: "Any two-digit number ÷ 9: the tens digit is the answer, the digit sum is the remainder.",
        trick: MathTrick(
            name: "Tens Digit, Digit Sum",
            steps: [
                "The tens digit is the quotient.",
                "Add the two digits together — that's the remainder.",
                "If that remainder reaches 9 or more, it is too big to be a remainder for 9.",
                "In that case divide the remainder by 9 as well: add its quotient to your answer and keep what's left.",
                "This is the running-sum method stopped after one step, which is why the digits add up."
            ],
            examples: [
                TrickExample(
                    problem: "34 ÷ 9",
                    solution: "3 r 7",
                    stepByStepExplanation: [
                        "Step 1: Tens digit → 3",
                        "Step 2: 3 + 4 = 7, and 7 is under 9",
                        "Answer: 3 r 7"
                    ]
                ),
                TrickExample(
                    problem: "75 ÷ 9",
                    solution: "8 r 3",
                    stepByStepExplanation: [
                        "Step 1: Tens digit → 7",
                        "Step 2: 7 + 5 = 12, which is too big for a remainder",
                        "Step 3: 12 ÷ 9 = 1 r 3",
                        "Step 4: Add the 1 → 7 + 1 = 8, and keep the 3",
                        "Answer: 8 r 3"
                    ]
                )
            ]
        ),
        operations: [.divisionWithRemainder],
        difficulty: .medium,
        pattern: ProblemPattern.nearBaseDivision(
            base: 10,
            side: .below,
            offsetRange: 1...1,
            quotientRange: 2...10
        )
    )

    private static let divideByFactorsLesson = Lesson(
        id: "div_factors",
        title: "Divide by Factors",
        description: "Two easy divisions beat one hard one — ÷14 is ÷2 then ÷7.",
        trick: MathTrick(
            name: "Split the Divisor",
            steps: [
                "Split the divisor into two factors you can divide by easily.",
                "Divide by the first, then divide that result by the second.",
                "Divide by the larger factor first if it keeps the middle number whole.",
                "14 = 2 × 7, 15 = 3 × 5, 16 = 4 × 4, 18 = 2 × 9, 24 = 4 × 6, 35 = 5 × 7."
            ],
            examples: [
                TrickExample(
                    problem: "1638 ÷ 14",
                    solution: "117",
                    stepByStepExplanation: [
                        "Step 1: 14 = 2 × 7",
                        "Step 2: 1638 ÷ 2 = 819",
                        "Step 3: 819 ÷ 7 = 117",
                        "Answer: 117"
                    ]
                ),
                TrickExample(
                    problem: "1080 ÷ 24",
                    solution: "45",
                    stepByStepExplanation: [
                        "Step 1: 24 = 4 × 6",
                        "Step 2: 1080 ÷ 4 = 270",
                        "Step 3: 270 ÷ 6 = 45",
                        "Answer: 45"
                    ]
                )
            ]
        ),
        operations: [.division],
        difficulty: .medium,
        pattern: ProblemPattern.divisor(
            divisors: [14, 15, 16, 18, 21, 24, 35, 45],
            quotientRange: 3...99
        )
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



    // MARK: - Advanced Division

    /// The methods that replace long division. All three answer with a
    /// quotient *and* a remainder, because that is what these methods actually
    /// produce — forcing exact division would hide how they work.
    static let advancedDivisionGroup = LessonGroup(
        id: "advanced_division",
        title: "Advanced Division",
        description: "Replace long division: add the complement, transpose, or fly a flag.",
        iconName: "divide.square.fill",
        lessons: [
            nikhilamDivisionLesson,
            paravartyaDivisionLesson,
            flagDivisionLesson
        ],
        requiredGroupId: "division_tricks"
    )

    private static let nikhilamDivisionLesson = Lesson(
        id: "div_nikhilam",
        title: "Divide by 88, 97, 993…",
        description: "Divisors just below a round number — add the complement instead of subtracting.",
        trick: MathTrick(
            name: "Nikhilam Division",
            steps: [
                "Find how far the divisor sits below the round number: 88 → 12, 97 → 3.",
                "Split the dividend so the right-hand part has as many digits as the divisor.",
                "Bring the first digit down — that's your first quotient digit.",
                "Multiply it by the complement and add the result into the columns to its right.",
                "Take the next column total down as the next quotient digit, and repeat to the split.",
                "Whatever sits right of the split is the remainder. If it comes out bigger than the divisor, move one more into the quotient."
            ],
            examples: [
                TrickExample(
                    problem: "1104 ÷ 88",
                    solution: "12 r 48",
                    stepByStepExplanation: [
                        "Step 1: 88 is 12 below 100 → complement 12",
                        "Step 2: Split 11 | 04",
                        "Step 3: Bring down 1 → 1 × 12 = 12 added right",
                        "Step 4: Next column 1 + 1 = 2 → 2 × 12 = 24 added right",
                        "Step 5: Right of the split → 0 + 2 + 2 = 4, then 4 + 4 = 8",
                        "Answer: 12 r 48"
                    ]
                ),
                TrickExample(
                    problem: "2345 ÷ 97",
                    solution: "24 r 17",
                    stepByStepExplanation: [
                        "Step 1: 97 is 3 below 100 → complement 3",
                        "Step 2: Split 23 | 45, working through gives 23 r 114",
                        "Step 3: 114 is bigger than 97, so take one more",
                        "Step 4: 23 + 1 = 24, and 114 − 97 = 17",
                        "Answer: 24 r 17"
                    ]
                )
            ]
        ),
        operations: [.divisionWithRemainder],
        difficulty: .hard,
        pattern: ProblemPattern.nearBaseDivision(
            base: 100, side: .below, offsetRange: 2...12, quotientRange: 11...49)
    )

    private static let paravartyaDivisionLesson = Lesson(
        id: "div_paravartya",
        title: "Divide by 112, 123, 104…",
        description: "Divisors just above a round number — flip the signs and add.",
        trick: MathTrick(
            name: "Paravartya Yojayet — Transpose and Apply",
            steps: [
                "Drop the divisor's leading 1 and flip the sign of every digit left: 112 → −1, −2.",
                "Split the dividend so the right-hand part has as many digits as those flipped digits.",
                "Bring the first digit down as the first quotient digit.",
                "Multiply it by the flipped digits and add them into the columns to the right — they're negative, so this subtracts.",
                "Carry on to the split; what's left of it is the quotient, right of it the remainder.",
                "If the remainder lands negative, drop the quotient by 1 and add the divisor back onto it."
            ],
            examples: [
                TrickExample(
                    problem: "1234 ÷ 112",
                    solution: "11 r 2",
                    stepByStepExplanation: [
                        "Step 1: 112 → flipped digits −1, −2",
                        "Step 2: Split 12 | 34",
                        "Step 3: Bring down 1 → adds −1, −2 to the right",
                        "Step 4: Next column 2 − 1 = 1 → adds −1, −2 again",
                        "Step 5: Right of the split → 3 − 2 − 1 = 0, then 4 − 2 = 2",
                        "Answer: 11 r 2"
                    ]
                ),
                TrickExample(
                    problem: "1345 ÷ 112",
                    solution: "12 r 1",
                    stepByStepExplanation: [
                        "Step 1: Flipped digits −1, −2",
                        "Step 2: Split 13 | 45",
                        "Step 3: Bring down 1 → next column 3 − 1 = 2",
                        "Step 4: Right of the split → 4 − 2 − 2 = 0, then 5 − 4 = 1",
                        "Answer: 12 r 1"
                    ]
                )
            ]
        ),
        operations: [.divisionWithRemainder],
        difficulty: .hard,
        pattern: ProblemPattern.nearBaseDivision(
            base: 100, side: .above, offsetRange: 2...23, quotientRange: 11...39)
    )

    private static let flagDivisionLesson = Lesson(
        id: "div_flag",
        title: "Straight Division",
        description: "The general method — any divisor, one digit of the answer at a time.",
        trick: MathTrick(
            name: "Dhwajanka — The Flag Method",
            steps: [
                "Split the divisor: the first digit does the dividing, the last digit becomes the flag.",
                "Divide the dividend's first two digits by the main digit — that's your first answer digit, with something left over.",
                "Write that leftover in front of the dividend's next digit to make the running number.",
                "Subtract the flag times the answer digit you just wrote.",
                "Divide what's left by the main digit again for the next answer digit, and repeat.",
                "After the last digit, whatever remains is the remainder.",
                "If a step ever goes negative, back the previous answer digit down by 1 and redo it."
            ],
            examples: [
                TrickExample(
                    problem: "1234 ÷ 52",
                    solution: "23 r 38",
                    stepByStepExplanation: [
                        "Step 1: Main digit 5, flag 2",
                        "Step 2: 12 ÷ 5 = 2 remainder 2 → first digit 2",
                        "Step 3: Running number 23, minus flag 2 × 2 = 4 → 19",
                        "Step 4: 19 ÷ 5 = 3 remainder 4 → next digit 3",
                        "Step 5: Running number 44, minus 2 × 3 = 6 → 38",
                        "Answer: 23 r 38"
                    ]
                ),
                TrickExample(
                    problem: "2345 ÷ 31",
                    solution: "75 r 20",
                    stepByStepExplanation: [
                        "Step 1: Main digit 3, flag 1",
                        "Step 2: 23 ÷ 3 = 7 remainder 2 → first digit 7",
                        "Step 3: Running number 24, minus 1 × 7 = 7 → 17",
                        "Step 4: 17 ÷ 3 = 5 remainder 2 → next digit 5",
                        "Step 5: Running number 25, minus 1 × 5 = 5 → 20",
                        "Answer: 75 r 20"
                    ]
                )
            ]
        ),
        operations: [.divisionWithRemainder],
        difficulty: .hard,
        pattern: ProblemPattern.flagDivision(divisorRange: 21...79, quotientRange: 11...79)
    )

    // MARK: - Number Checks

    /// Remainder tricks. Each one turns "divide and see what's left" into a
    /// digit game, and together they're how you check your own arithmetic.
    static let numberChecksGroup = LessonGroup(
        id: "number_checks",
        title: "Number Checks",
        description: "Find remainders from the digits alone — and use them to check your work.",
        iconName: "checkmark.seal.fill",
        lessons: [
            remainderByNineLesson,
            remainderByElevenLesson,
            remainderBySevenLesson,
            remainderByThirteenLesson
        ],
        requiredGroupId: "advanced_division"
    )

    private static let remainderByElevenLesson = Lesson(
        id: "mod_11",
        title: "The 11 Check",
        description: "Alternate plus and minus across the digits.",
        trick: MathTrick(
            name: "Alternating Sum",
            steps: [
                "Start at the right-hand digit and add it.",
                "Subtract the next one, add the one after, and keep alternating.",
                "The total is the remainder after 11.",
                "If it comes out negative, add 11 to it.",
                "A total of 0 means the number divides by 11 exactly."
            ],
            examples: [
                TrickExample(
                    problem: "1234 mod 11",
                    solution: "2",
                    stepByStepExplanation: [
                        "Step 1: From the right → 4 − 3 + 2 − 1",
                        "Step 2: That comes to 2",
                        "Answer: 2"
                    ]
                ),
                TrickExample(
                    problem: "1099 mod 11",
                    solution: "10",
                    stepByStepExplanation: [
                        "Step 1: From the right → 9 − 9 + 0 − 1",
                        "Step 2: That comes to −1",
                        "Step 3: Negative, so add 11 → 10",
                        "Answer: 10"
                    ]
                )
            ]
        ),
        operations: [.remainder],
        difficulty: .medium,
        pattern: ProblemPattern.remainder(divisor: 11, range: 100...9999)
    )

    private static let remainderByNineLesson = Lesson(
        id: "mod_9",
        title: "Casting Out Nines",
        description: "Add the digits to get the remainder after 9 — the classic way to check your own answers.",
        trick: MathTrick(
            name: "Add the Digits Down",
            steps: [
                "Add up all the digits of the number.",
                "If that total still has more than one digit, add its digits too.",
                "Keep going until one digit is left. That's the remainder after 9.",
                "Landing on 9 means the remainder is 0 — the number divides by 9 exactly.",
                "This is how you check any sum or product: do it to both sides, and they must match.",
                "Nines vanish as you add, so you can skip any 9 — and any pair of digits making 9."
            ],
            examples: [
                TrickExample(
                    problem: "4857 mod 9",
                    solution: "6",
                    stepByStepExplanation: [
                        "Step 1: 4 + 8 + 5 + 7 = 24",
                        "Step 2: Still two digits → 2 + 4 = 6",
                        "Answer: 6"
                    ]
                ),
                TrickExample(
                    problem: "738 mod 9",
                    solution: "0",
                    stepByStepExplanation: [
                        "Step 1: 7 + 3 + 8 = 18",
                        "Step 2: 1 + 8 = 9",
                        "Step 3: Landed on 9, so the remainder is 0",
                        "Answer: 0"
                    ]
                )
            ]
        ),
        operations: [.remainder],
        difficulty: .medium,
        pattern: ProblemPattern.remainder(divisor: 9, range: 100...9999)
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

    private static let remainderByThirteenLesson = Lesson(
        id: "mod_13",
        title: "Remainder After 13",
        description: "Split the number into groups of three and alternate the signs — 1001 does the work.",
        trick: MathTrick(
            name: "The 1001 Split",
            steps: [
                "Break the number into groups of three digits, starting from the right.",
                "Add the rightmost group, subtract the next, add the next, and so on.",
                "Take the result's remainder after 13. A negative total just means adding 13 until it turns positive.",
                "This works because 1001 = 7 × 11 × 13, so every group of three is one step around all three at once.",
                "The very same total gives you the remainder after 7 and after 11 — one calculation, three answers."
            ],
            examples: [
                TrickExample(
                    problem: "8214 mod 13",
                    solution: "11",
                    stepByStepExplanation: [
                        "Step 1: Groups of three from the right → 8 | 214",
                        "Step 2: 214 − 8 = 206",
                        "Step 3: 13 × 15 = 195, and 206 − 195 = 11",
                        "Answer: 11"
                    ]
                ),
                TrickExample(
                    problem: "45678 mod 13",
                    solution: "9",
                    stepByStepExplanation: [
                        "Step 1: Groups of three from the right → 45 | 678",
                        "Step 2: 678 − 45 = 633",
                        "Step 3: 13 × 48 = 624, and 633 − 624 = 9",
                        "Answer: 9"
                    ]
                )
            ]
        ),
        operations: [.remainder],
        difficulty: .hard,
        pattern: ProblemPattern.remainder(divisor: 13, range: 1000...999999)
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
            twentyFivePercentLesson,
            percentageIncreaseLesson,
            percentageDecreaseLesson,
            estimateProductLesson
        ],
        requiredGroupId: "number_checks"
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

    private static let percentageIncreaseLesson = Lesson(
        id: "pct_increase",
        title: "Increase by a Percentage",
        description: "Prices, tips, markups — find the part, then add it on.",
        trick: MathTrick(
            name: "Find It, Then Add It",
            steps: [
                "Work out the percentage of the number, using whichever shortcut fits.",
                "Add that to the original.",
                "For a round percentage there is a faster way: 20% up is the same as ×1.2, which is the number plus a fifth of itself."
            ],
            examples: [
                TrickExample(
                    problem: "80 up 25%",
                    solution: "100",
                    stepByStepExplanation: [
                        "Step 1: 25% of 80 → 80 ÷ 4 = 20",
                        "Step 2: 80 + 20 = 100",
                        "Answer: 100"
                    ]
                ),
                TrickExample(
                    problem: "60 up 10%",
                    solution: "66",
                    stepByStepExplanation: [
                        "Step 1: 10% of 60 → 6",
                        "Step 2: 60 + 6 = 66",
                        "Answer: 66"
                    ]
                )
            ]
        ),
        operations: [.percentageIncrease],
        difficulty: .medium,
        pattern: ProblemPattern.percentageChange(
            percents: [10, 20, 25, 50], multiplierRange: 2...30, increase: true
        )
    )

    private static let percentageDecreaseLesson = Lesson(
        id: "pct_decrease",
        title: "Decrease by a Percentage",
        description: "Discounts and sale prices — find the part, then take it off.",
        trick: MathTrick(
            name: "Find It, Then Take It Off",
            steps: [
                "Work out the percentage of the number.",
                "Subtract it from the original.",
                "For a big discount it is quicker to find what's left: 25% off means you pay 75%, which is three quarters.",
                "Careful — 20% off then 20% off again is not 40% off. Each cut applies to what's left."
            ],
            examples: [
                TrickExample(
                    problem: "80 down 25%",
                    solution: "60",
                    stepByStepExplanation: [
                        "Step 1: 25% of 80 → 20",
                        "Step 2: 80 − 20 = 60",
                        "Step 3: Or straight to it — three quarters of 80 is 60",
                        "Answer: 60"
                    ]
                ),
                TrickExample(
                    problem: "150 down 20%",
                    solution: "120",
                    stepByStepExplanation: [
                        "Step 1: 20% of 150 → 30",
                        "Step 2: 150 − 30 = 120",
                        "Answer: 120"
                    ]
                )
            ]
        ),
        operations: [.percentageDecrease],
        difficulty: .medium,
        pattern: ProblemPattern.percentageChange(
            percents: [10, 20, 25, 50], multiplierRange: 2...30, increase: false
        )
    )

    // MARK: - Estimating

    private static let estimateProductLesson = Lesson(
        id: "est_product",
        title: "Estimate a Product",
        description: "Get the size of an answer in one second — the skill that catches your own mistakes.",
        trick: MathTrick(
            name: "Round and Multiply",
            steps: [
                "Round each number to the nearest ten.",
                "Multiply the rounded pair — the zeros make it a single-digit product with zeros stuck on.",
                "That's your estimate. It is not the answer, and it is not meant to be.",
                "Rounding one number up and the other down keeps the error small, since the two mistakes pull opposite ways.",
                "Anything within about a fifth counts here — the point is the magnitude, not the digits."
            ],
            examples: [
                TrickExample(
                    problem: "347 × 62, roughly",
                    solution: "21000",
                    stepByStepExplanation: [
                        "Step 1: Round → 350 and 60",
                        "Step 2: 35 × 6 = 210",
                        "Step 3: Put the zeros back → 21000",
                        "Answer: about 21000 (the exact value is 21514)"
                    ]
                ),
                TrickExample(
                    problem: "489 × 71, roughly",
                    solution: "35000",
                    stepByStepExplanation: [
                        "Step 1: Round → 490 and 70",
                        "Step 2: 49 × 7 = 343",
                        "Step 3: Put the zeros back → 34300",
                        "Answer: about 34300 (the exact value is 34719)"
                    ]
                )
            ]
        ),
        operations: [.estimateProduct],
        difficulty: .easy,
        pattern: ProblemPattern.estimateProduct(leftRange: 100...999, rightRange: 40...99),
        answerMode: .expression
    )

    // MARK: - Fractions

    /// The first lessons whose answers are not whole numbers. Adding and
    /// subtracting reuse the crossing pattern from `mult_crosswise` — the
    /// point is that this is not a new technique, just the same one pointed
    /// at a numerator and a denominator.
    static let fractionsGroup = LessonGroup(
        id: "fractions",
        title: "Fractions",
        description: "Cross for adding, straight across for multiplying — no common denominators to hunt for.",
        iconName: "divide",
        lessons: [
            addFractionsLesson,
            subtractFractionsLesson,
            multiplyFractionsLesson,
            divideFractionsLesson,
            multiplyDecimalsLesson,
            seventhsLesson
        ],
        requiredGroupId: "percentage_tricks"
    )

    private static let seventhsLesson = Lesson(
        id: "dec_sevenths",
        title: "Sevenths as Decimals",
        description: "Every seventh uses the same six digits, in the same order — learn one, get all six.",
        trick: MathTrick(
            name: "One Cycle, Six Starting Points",
            steps: [
                "1/7 = 0.142857, repeating forever.",
                "Every other seventh is that same cycle 142857, just begun at a different digit.",
                "To find which, compare against the sevenths you know: 3/7 is a bit over 0.4, so start at the 4.",
                "Reading on from there and wrapping around gives 428571.",
                "The halves of the cycle add to 9 — 142 + 857 — which is a quick way to check you have it right."
            ],
            examples: [
                TrickExample(
                    problem: "3/7 — repeating digits",
                    solution: "428571",
                    stepByStepExplanation: [
                        "Step 1: The cycle is 142857",
                        "Step 2: 3/7 ≈ 0.43, so it begins at the 4",
                        "Step 3: Read on from the 4 and wrap → 4, 2, 8, 5, 7, 1",
                        "Answer: 428571"
                    ]
                ),
                TrickExample(
                    problem: "5/7 — repeating digits",
                    solution: "714285",
                    stepByStepExplanation: [
                        "Step 1: The cycle is 142857",
                        "Step 2: 5/7 ≈ 0.71, so it begins at the 7",
                        "Step 3: Read on from the 7 and wrap → 7, 1, 4, 2, 8, 5",
                        "Answer: 714285"
                    ]
                )
            ]
        ),
        operations: [.repeatingBlock],
        difficulty: .hard,
        pattern: ProblemPattern.repeatingBlock(numerators: [1, 2, 3, 4, 5, 6], denominator: 7)
    )

    private static let multiplyDecimalsLesson = Lesson(
        id: "dec_multiply",
        title: "Multiply Decimals",
        description: "Ignore the points entirely, then count them back in at the end.",
        trick: MathTrick(
            name: "Multiply, Then Place the Point",
            steps: [
                "Ignore both decimal points and multiply the numbers as whole numbers.",
                "Count how many digits sit after the point across *both* original numbers.",
                "Put the point back that many digits from the right of your answer.",
                "Sanity-check the size: 2.5 × 3.4 has to be near 2 × 3, so 8.5 is right and 85 is not.",
                "You can answer in decimal or as a fraction — 8.5 and 17/2 both count."
            ],
            examples: [
                TrickExample(
                    problem: "2.5 × 3.4",
                    solution: "8.5",
                    stepByStepExplanation: [
                        "Step 1: Ignore the points → 25 × 34 = 850",
                        "Step 2: One decimal place each, so two in total",
                        "Step 3: Two digits from the right of 850 → 8.50",
                        "Answer: 8.5"
                    ]
                ),
                TrickExample(
                    problem: "1.2 × 0.45",
                    solution: "0.54",
                    stepByStepExplanation: [
                        "Step 1: Ignore the points → 12 × 45 = 540",
                        "Step 2: One place plus two places, so three in total",
                        "Step 3: Three digits from the right of 540 → 0.540",
                        "Answer: 0.54"
                    ]
                )
            ]
        ),
        operations: [.decimalMultiplication],
        difficulty: .medium,
        pattern: ProblemPattern.decimalProduct(digitRange: 11...99, placeRange: 1...2),
        answerMode: .expression
    )

    /// Shared closing note: every fraction lesson grades by value, so there
    /// is never a reason to make a player reduce.
    private static let fractionReducingNote =
        "You don't have to reduce — 14/24 and 7/12 are both accepted."

    private static let addFractionsLesson = Lesson(
        id: "frac_add",
        title: "Add Fractions Crosswise",
        description: "No common denominator needed — cross-multiply and you have the answer.",
        trick: MathTrick(
            name: "Cross for the Top, Straight for the Bottom",
            steps: [
                "Multiply the first top by the second bottom.",
                "Multiply the second top by the first bottom.",
                "Add those two — that's your numerator.",
                "Multiply the two bottoms together — that's your denominator.",
                "This is the same crossing you already did for two-digit multiplication.",
                fractionReducingNote
            ],
            examples: [
                TrickExample(
                    problem: "2/3 + 1/5",
                    solution: "13/15",
                    stepByStepExplanation: [
                        "Step 1: Cross one way → 2 × 5 = 10",
                        "Step 2: Cross the other → 1 × 3 = 3",
                        "Step 3: Add them → 10 + 3 = 13",
                        "Step 4: Bottoms → 3 × 5 = 15",
                        "Answer: 13/15"
                    ]
                ),
                TrickExample(
                    problem: "1/4 + 2/5",
                    solution: "13/20",
                    stepByStepExplanation: [
                        "Step 1: Cross one way → 1 × 5 = 5",
                        "Step 2: Cross the other → 2 × 4 = 8",
                        "Step 3: Add them → 5 + 8 = 13",
                        "Step 4: Bottoms → 4 × 5 = 20",
                        "Answer: 13/20"
                    ]
                )
            ]
        ),
        operations: [.fractionAddition],
        difficulty: .medium,
        pattern: ProblemPattern.fractionOperands(operation: .fractionAddition, denominatorRange: 3...9),
        answerMode: .expression
    )

    private static let subtractFractionsLesson = Lesson(
        id: "frac_sub",
        title: "Subtract Fractions Crosswise",
        description: "The same crossing as adding, with a minus in the middle.",
        trick: MathTrick(
            name: "Cross and Subtract",
            steps: [
                "Multiply the first top by the second bottom.",
                "Multiply the second top by the first bottom.",
                "Subtract the second from the first — that's your numerator.",
                "Multiply the two bottoms together — that's your denominator.",
                "Order matters here in a way it didn't for adding: the first fraction's cross comes first.",
                fractionReducingNote
            ],
            examples: [
                TrickExample(
                    problem: "3/4 − 1/6",
                    solution: "7/12",
                    stepByStepExplanation: [
                        "Step 1: First top × second bottom → 3 × 6 = 18",
                        "Step 2: Second top × first bottom → 1 × 4 = 4",
                        "Step 3: Subtract → 18 − 4 = 14",
                        "Step 4: Bottoms → 4 × 6 = 24",
                        "Step 5: 14/24 reduces to 7/12",
                        "Answer: 7/12"
                    ]
                ),
                TrickExample(
                    problem: "2/3 − 1/4",
                    solution: "5/12",
                    stepByStepExplanation: [
                        "Step 1: First top × second bottom → 2 × 4 = 8",
                        "Step 2: Second top × first bottom → 1 × 3 = 3",
                        "Step 3: Subtract → 8 − 3 = 5",
                        "Step 4: Bottoms → 3 × 4 = 12",
                        "Answer: 5/12"
                    ]
                )
            ]
        ),
        operations: [.fractionSubtraction],
        difficulty: .medium,
        pattern: ProblemPattern.fractionOperands(operation: .fractionSubtraction, denominatorRange: 3...9),
        answerMode: .expression
    )

    private static let multiplyFractionsLesson = Lesson(
        id: "frac_multiply",
        title: "Multiply Fractions",
        description: "The easiest one — straight across, tops and bottoms.",
        trick: MathTrick(
            name: "Straight Across",
            steps: [
                "Multiply the two tops together.",
                "Multiply the two bottoms together.",
                "That's it — no crossing, no common denominator.",
                "Cancel before you multiply if you spot a shared factor; it keeps the numbers small.",
                fractionReducingNote
            ],
            examples: [
                TrickExample(
                    problem: "2/3 × 3/4",
                    solution: "1/2",
                    stepByStepExplanation: [
                        "Step 1: Tops → 2 × 3 = 6",
                        "Step 2: Bottoms → 3 × 4 = 12",
                        "Step 3: 6/12 reduces to 1/2",
                        "Answer: 1/2"
                    ]
                ),
                TrickExample(
                    problem: "3/5 × 5/9",
                    solution: "1/3",
                    stepByStepExplanation: [
                        "Step 1: The 5s cancel top and bottom",
                        "Step 2: Left with 3/9",
                        "Step 3: 3/9 reduces to 1/3",
                        "Answer: 1/3"
                    ]
                )
            ]
        ),
        operations: [.fractionMultiplication],
        difficulty: .easy,
        pattern: ProblemPattern.fractionOperands(operation: .fractionMultiplication, denominatorRange: 3...9),
        answerMode: .expression
    )

    private static let divideFractionsLesson = Lesson(
        id: "frac_divide",
        title: "Divide Fractions",
        description: "Flip the second one over, then multiply.",
        trick: MathTrick(
            name: "Invert and Multiply",
            steps: [
                "Turn the second fraction upside down.",
                "Change the ÷ to a ×.",
                "Now multiply straight across, as usual.",
                "Flipping works because dividing by 4/9 is the same as multiplying by 9/4.",
                fractionReducingNote
            ],
            examples: [
                TrickExample(
                    problem: "2/3 ÷ 4/9",
                    solution: "3/2",
                    stepByStepExplanation: [
                        "Step 1: Flip the second → 9/4",
                        "Step 2: Now 2/3 × 9/4",
                        "Step 3: Tops → 2 × 9 = 18, bottoms → 3 × 4 = 12",
                        "Step 4: 18/12 reduces to 3/2",
                        "Answer: 3/2"
                    ]
                ),
                TrickExample(
                    problem: "3/4 ÷ 1/2",
                    solution: "3/2",
                    stepByStepExplanation: [
                        "Step 1: Flip the second → 2/1",
                        "Step 2: Now 3/4 × 2/1",
                        "Step 3: Tops → 3 × 2 = 6, bottoms → 4 × 1 = 4",
                        "Step 4: 6/4 reduces to 3/2",
                        "Answer: 3/2"
                    ]
                )
            ]
        ),
        operations: [.fractionDivision],
        difficulty: .medium,
        pattern: ProblemPattern.fractionOperands(operation: .fractionDivision, denominatorRange: 3...9),
        answerMode: .expression
    )
}
