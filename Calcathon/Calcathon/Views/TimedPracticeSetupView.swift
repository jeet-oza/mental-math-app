//
//  TimedPracticeSetupView.swift
//  Calcathon
//
//  Builds a timed session from lesson techniques or an open arithmetic mix.
//

import SwiftUI

struct TimedPracticeSetupView: View {
    @State private var mode: TimedPracticeMode = .techniques
    @State private var durationMinutes = 2
    @State private var selectedLessonIDs: Set<String> = ["add_9"]
    @State private var selectedOperations: Set<MathOperation> = [.addition]
    @State private var digits: [MathOperation: OperandDigits] = [
        .addition: OperandDigits(first: 2, second: 2),
        .subtraction: OperandDigits(first: 2, second: 2),
        .multiplication: OperandDigits(first: 2, second: 1),
        .division: OperandDigits(first: 1, second: 1),
    ]

    private let openOperations: [MathOperation] = [.addition, .subtraction, .multiplication, .division]

    var body: some View {
        Form {
            Section {
                PageHeroCard(
                    eyebrow: "Accuracy first",
                    title: "Build your round",
                    message: "Choose familiar skills, keep the round short, and try to beat your own score.",
                    icon: "timer",
                    accent: .brandTeal
                )
            }
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)

            Section {
                Picker("Practice type", selection: $mode) {
                    ForEach(TimedPracticeMode.allCases) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .pickerStyle(.segmented)
            } footer: {
                Text(mode == .techniques
                     ? "Mix the shortcuts taught in Learn."
                     : "Build a custom mix with any number sizes.")
            }

            if mode == .techniques {
                techniqueSection
            } else {
                openMixSection
            }

            Section {
                Stepper(value: $durationMinutes, in: 1...10, step: 1) {
                    HStack {
                        Label("Timer", systemImage: "timer")
                        Spacer()
                        Text("\(durationMinutes) min")
                            .font(.headline.monospacedDigit())
                            .foregroundStyle(Color.brandAccent)
                    }
                }
            } header: {
                Text("Time")
            } footer: {
                Text("Choose from 1 to 10 minutes. Your result includes questions and correct answers per minute.")
            }

            Section {
                NavigationLink(destination: TimedPracticeView(plan: plan)) {
                    Label("Start \(durationMinutes)-Minute Practice", systemImage: "play.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(plan.isValid ? Color.brandAccent : .secondary)
                }
                .disabled(!plan.isValid)
            } footer: {
                if !plan.isValid {
                    Text(mode == .techniques
                         ? "Choose at least one technique to begin."
                         : "Choose at least one operation to begin.")
                        .foregroundStyle(.red)
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(BrandBackground())
        .navigationTitle("Timed Practice")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }

    private var techniqueSection: some View {
        Section("Techniques") {
            NavigationLink {
                TechniquePickerView(selection: $selectedLessonIDs)
            } label: {
                HStack {
                    Label("Choose techniques", systemImage: "checklist")
                    Spacer()
                    Text("\(selectedLessonIDs.count) selected")
                        .foregroundStyle(.secondary)
                }
            }

            if !selectedLessonIDs.isEmpty {
                Text(selectedTechniqueSummary)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
            }
        }
    }

    private var openMixSection: some View {
        ForEach(openOperations, id: \.self) { operation in
            Section {
                Button {
                    toggleOperation(operation)
                } label: {
                    HStack {
                        Label(operation.title, systemImage: operation.iconName)
                            .foregroundStyle(.primary)
                        Spacer()
                        Image(systemName: selectedOperations.contains(operation)
                              ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(selectedOperations.contains(operation)
                                             ? Color.brandAccent : .secondary)
                    }
                }

                if selectedOperations.contains(operation) {
                    digitStepper(
                        title: firstDigitLabel(for: operation),
                        value: digitBinding(for: operation, first: true)
                    )
                    digitStepper(
                        title: secondDigitLabel(for: operation),
                        value: digitBinding(for: operation, first: false)
                    )
                }
            } header: {
                if selectedOperations.contains(operation) {
                    Text(exampleSizeText(for: operation))
                }
            }
        }
    }

    private func digitStepper(title: String, value: Binding<Int>) -> some View {
        Stepper(value: value, in: 1...4) {
            HStack {
                Text(title)
                Spacer()
                Text("\(value.wrappedValue) digit\(value.wrappedValue == 1 ? "" : "s")")
                    .foregroundStyle(Color.brandAccent)
                    .monospacedDigit()
            }
        }
    }

    private var allLessons: [Lesson] { LessonCatalog.allGroups.flatMap(\.lessons) }

    private var plan: TimedPracticePlan {
        TimedPracticePlan(
            mode: mode,
            durationMinutes: durationMinutes,
            lessons: allLessons.filter { selectedLessonIDs.contains($0.id) },
            openOperations: openOperations.filter(selectedOperations.contains),
            digits: digits
        )
    }

    private var selectedTechniqueSummary: String {
        let names = allLessons.filter { selectedLessonIDs.contains($0.id) }.map(\.title)
        return names.prefix(4).joined(separator: " • ")
            + (names.count > 4 ? " • and \(names.count - 4) more" : "")
    }

    private func toggleOperation(_ operation: MathOperation) {
        if selectedOperations.contains(operation) {
            selectedOperations.remove(operation)
        } else {
            selectedOperations.insert(operation)
        }
    }

    private func digitBinding(for operation: MathOperation, first: Bool) -> Binding<Int> {
        Binding {
            let setting = digits[operation] ?? OperandDigits()
            return first ? setting.first : setting.second
        } set: { newValue in
            var setting = digits[operation] ?? OperandDigits()
            if first { setting.first = newValue } else { setting.second = newValue }
            digits[operation] = setting
        }
    }

    private func firstDigitLabel(for operation: MathOperation) -> String {
        switch operation {
        case .addition, .subtraction: return "First number"
        case .multiplication: return "First factor"
        case .division: return "Answer size"
        default: return "First number"
        }
    }

    private func secondDigitLabel(for operation: MathOperation) -> String {
        switch operation {
        case .addition, .subtraction: return "Second number"
        case .multiplication: return "Second factor"
        case .division: return "Divisor size"
        default: return "Second number"
        }
    }

    private func exampleSizeText(for operation: MathOperation) -> String {
        let setting = digits[operation] ?? OperandDigits()
        if operation == .division {
            return "Division • \(setting.first)-digit answer ÷ \(setting.second)-digit divisor"
        }
        return "\(operation.title) • \(setting.first)-digit by \(setting.second)-digit"
    }
}

private struct TechniquePickerView: View {
    @Binding var selection: Set<String>

    private var allIDs: Set<String> {
        Set(LessonCatalog.allGroups.flatMap(\.lessons).map(\.id))
    }

    var body: some View {
        List {
            ForEach(LessonCatalog.allGroups) { group in
                Section(group.title) {
                    Button {
                        toggleGroup(group)
                    } label: {
                        HStack {
                            Text(group.lessons.allSatisfy { selection.contains($0.id) }
                                 ? "Clear category" : "Select category")
                            Spacer()
                            Image(systemName: "checklist")
                        }
                        .font(.caption.bold())
                        .foregroundStyle(Color.brandAccent)
                    }

                    ForEach(group.lessons) { lesson in
                        Button {
                            toggle(lesson.id)
                        } label: {
                            HStack(alignment: .top) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(lesson.title).foregroundStyle(.primary)
                                    Text(lesson.description)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Image(systemName: selection.contains(lesson.id)
                                      ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(selection.contains(lesson.id)
                                                     ? Color.brandAccent : .secondary)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Choose Techniques")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button("Select All") { selection = allIDs }
                    Button("Clear All", role: .destructive) { selection.removeAll() }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
    }

    private func toggle(_ id: String) {
        if selection.contains(id) { selection.remove(id) } else { selection.insert(id) }
    }

    private func toggleGroup(_ group: LessonGroup) {
        let ids = Set(group.lessons.map(\.id))
        if ids.isSubset(of: selection) {
            selection.subtract(ids)
        } else {
            selection.formUnion(ids)
        }
    }
}

extension MathOperation {
    var title: String {
        switch self {
        case .addition: return "Addition"
        case .subtraction: return "Subtraction"
        case .multiplication: return "Multiplication"
        case .division: return "Division"
        default: return symbol
        }
    }

    var iconName: String {
        switch self {
        case .addition: return "plus.circle.fill"
        case .subtraction: return "minus.circle.fill"
        case .multiplication: return "multiply.circle.fill"
        case .division: return "divide.circle.fill"
        default: return "number.circle.fill"
        }
    }
}

#Preview {
    NavigationStack { TimedPracticeSetupView() }
}
