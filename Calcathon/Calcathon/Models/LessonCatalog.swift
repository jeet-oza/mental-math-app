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
        difficulty: .easy,
        pattern: ProblemPattern.fixedOperand(operation: .multiplication, fixedValues: [2], position: .right, variableRange: 11...99)
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
        difficulty: .easy,
        pattern: ProblemPattern.fixedOperand(operation: .subtraction, fixedValues: [9], position: .right, variableRange: 18...99)
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
        difficulty: .easy,
        pattern: ProblemPattern.fixedOperand(operation: .subtraction, fixedValues: [100, 1000], position: .left, variableRange: 11...89)
    )

    // MARK: - Multiplication Tricks

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
            multiplyByTwentyFiveLesson,
            twoDigitByOneDigitLesson,
            multiplyNearHundredLesson
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
            name: "Times 10 Minus 1",
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

    private static let twoDigitByOneDigitLesson = Lesson(
        id: "mult_2x1",
        title: "Two-Digit × One-Digit",
        description: "Split the big number into tens and ones.",
        trick: MathTrick(
            name: "Split and Add",
            steps: [
                "Break the two-digit number into tens and ones.",
                "Multiply each part by the single digit.",
                "Add the two products together."
            ],
            example: TrickExample(
                problem: "23 × 6",
                solution: "138",
                stepByStepExplanation: [
                    "Step 1: 20 × 6 = 120",
                    "Step 2: 3 × 6 = 18",
                    "Step 3: 120 + 18 = 138",
                    "Answer: 138"
                ]
            )
        ),
        operations: [.multiplication],
        difficulty: .medium,
        pattern: ProblemPattern.twoOperand(operation: .multiplication, leftRange: 11...99, rightRange: 3...9)
    )

    private static let multiplyNearHundredLesson = Lesson(
        id: "mult_near100",
        title: "Multiply Near 100",
        description: "Multiply two numbers just above 100 using 100 as a base.",
        trick: MathTrick(
            name: "Base 100",
            steps: [
                "Write each number as 100 plus a little extra (102 = 100 + 2).",
                "Multiply the two extras for the last two digits (pad to two digits, e.g. 6 → 06).",
                "Add both extras onto 100 for the leading digits.",
                "Put the two parts side by side."
            ],
            example: TrickExample(
                problem: "102 × 106",
                solution: "10812",
                stepByStepExplanation: [
                    "Step 1: 102 = 100 + 2 and 106 = 100 + 6",
                    "Step 2: Extras 2 × 6 = 12 → last two digits",
                    "Step 3: 100 + 2 + 6 = 108 → leading digits",
                    "Answer: 10812"
                ]
            )
        ),
        operations: [.multiplication],
        difficulty: .hard,
        pattern: ProblemPattern.nearHundred(excessRange: 1...9)
    )

    // MARK: - Squaring Shortcuts

    static let squaringShortcutsGroup = LessonGroup(
        id: "squaring_shortcuts",
        title: "Squaring Shortcuts",
        description: "Fast ways to square numbers in your head.",
        iconName: "square.on.square",
        lessons: [
            squaresEndingInFiveLesson,
            squaresNearFiftyLesson
        ],
        requiredGroupId: "multiplication_tricks"
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

    // MARK: - Division Tricks

    static let divisionTricksGroup = LessonGroup(
        id: "division_tricks",
        title: "Division Tricks",
        description: "Shortcuts for dividing numbers mentally.",
        iconName: "divide.circle.fill",
        lessons: [
            halvingLesson,
            divideByFourLesson,
            divideByFiveLesson,
            divideByTenLesson
        ],
        requiredGroupId: "squaring_shortcuts"
    )

    private static let halvingLesson = Lesson(
        id: "div_2",
        title: "Halving Numbers",
        description: "Split into tens and ones, then halve each.",
        trick: MathTrick(
            name: "Split and Halve",
            steps: [
                "Break the number into tens and ones.",
                "Halve each part.",
                "Add the halves back together."
            ],
            example: TrickExample(
                problem: "84 ÷ 2",
                solution: "42",
                stepByStepExplanation: [
                    "Step 1: 80 ÷ 2 = 40",
                    "Step 2: 4 ÷ 2 = 2",
                    "Step 3: 40 + 2 = 42",
                    "Answer: 42"
                ]
            )
        ),
        operations: [.division],
        difficulty: .easy,
        pattern: ProblemPattern.divisor(divisors: [2], quotientRange: 10...99)
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

    private static let divideByTenLesson = Lesson(
        id: "div_10",
        title: "Divide by 10",
        description: "Just shift the digits one place down.",
        trick: MathTrick(
            name: "Drop a Zero",
            steps: [
                "For multiples of 10, remove one trailing zero.",
                "The remaining number is your answer."
            ],
            example: TrickExample(
                problem: "230 ÷ 10",
                solution: "23",
                stepByStepExplanation: [
                    "Step 1: Remove the trailing zero from 230",
                    "Answer: 23"
                ]
            )
        ),
        operations: [.division],
        difficulty: .easy,
        pattern: ProblemPattern.divisor(divisors: [10], quotientRange: 2...99)
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
