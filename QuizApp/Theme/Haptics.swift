//
//  Haptics.swift
//  QuizApp
//
//  Thin wrapper around UINotificationFeedbackGenerator for tactile feedback.
//

import UIKit

/// Small helper to trigger haptic feedback without sprinkling UIKit calls
/// throughout the codebase.
enum Haptics {
    enum Style {
        case success
        case error
        case light
    }

    static func play(_ style: Style) {
        switch style {
        case .success:
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        case .error:
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        case .light:
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
    }
}
