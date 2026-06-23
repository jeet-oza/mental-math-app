//
//  ArenaContainerView.swift
//  MentalMathApp
//
//  Arena tab host: a segmented picker switches between the two arena modes,
//  Equations (rapid-fire problems) and Grid (Number Wordament).
//

import SwiftUI

struct ArenaContainerView: View {
    enum Mode: String, CaseIterable, Identifiable {
        case equations = "Equations"
        case grid = "Grid"
        var id: String { rawValue }
    }

    @State private var mode: Mode = .equations

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("Mode", selection: $mode) {
                    ForEach(Mode.allCases) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.segmented)
                .padding([.horizontal, .top])

                switch mode {
                case .equations:
                    ArenaTabView()
                case .grid:
                    GridArenaView()
                }
            }
            .navigationTitle("Arena")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
        }
    }
}
