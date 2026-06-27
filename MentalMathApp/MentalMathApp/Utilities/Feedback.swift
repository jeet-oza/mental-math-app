//
//  Feedback.swift
//  MentalMathApp
//
//  Lightweight haptic + sound feedback for gameplay moments. System sounds are
//  placeholders that can be swapped for custom audio assets later.
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif
#if os(iOS)
import AudioToolbox
#endif

enum Feedback {

    /// A correct answer / banked path.
    static func correct() {
        notify(.success)
        play(1057) // light positive tone
    }

    /// An incorrect answer.
    static func incorrect() {
        notify(.error)
        play(1053)
    }

    /// A key press on the number pad.
    static func tap() {
        #if canImport(UIKit)
        UISelectionFeedbackGenerator().selectionChanged()
        #endif
    }

    // MARK: - Private

    #if canImport(UIKit)
    private static func notify(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        UINotificationFeedbackGenerator().notificationOccurred(type)
    }
    #else
    private enum Stub { case success, error }
    private static func notify(_ type: Stub) {}
    #endif

    private static func play(_ id: UInt32) {
        #if os(iOS)
        AudioServicesPlaySystemSound(SystemSoundID(id))
        #endif
    }
}
