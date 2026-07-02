//
//  Haptics.swift
//  QuizApp
//
//  Thin wrapper around UINotificationFeedbackGenerator for tactile feedback.
//

import UIKit
import AVFoundation

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

/// Plays short bundled sound effects (cheery for correct, buzzer for wrong).
/// Players are cached and reused so repeat taps are instant.
enum Sound {
    private static var players: [String: AVAudioPlayer] = [:]
    private static var sessionReady = false

    /// Correct answer: happy chime + a success vibration.
    static func correct() {
        Haptics.play(.success)
        play("correct")
    }

    /// Wrong answer: buzzer + an error vibration.
    static func wrong() {
        Haptics.play(.error)
        play("wrong")
    }

    static func play(_ name: String) {
        prepareSession()
        if let existing = players[name] {
            existing.currentTime = 0
            existing.play()
            return
        }
        guard let url = Bundle.main.url(forResource: name, withExtension: "wav") else { return }
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            players[name] = player
            player.play()
        } catch {
            // If audio fails, the haptic still gives feedback.
        }
    }

    private static func prepareSession() {
        guard !sessionReady else { return }
        // .ambient mixes with other audio and respects the mute switch.
        try? AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
        try? AVAudioSession.sharedInstance().setActive(true)
        sessionReady = true
    }
}
