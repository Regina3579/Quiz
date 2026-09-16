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

    /// Shared key for the in-app mute toggle. When true, no sound effects play.
    static let muteKey = "quizspark.muted"

    static var isMuted: Bool {
        UserDefaults.standard.bool(forKey: muteKey)
    }

    /// Correct answer: happy chime + a success vibration.
    static func correct() {
        Haptics.play(.success)
        play("correct")
    }

    /// Wrong answer. A harsh buzzer tells a child off for thinking, so this
    /// prefers a soft "oops" tone when one is bundled, and otherwise plays the
    /// old sound quietly rather than at full blast. The vibration is a light
    /// tap, not the error pattern, for the same reason.
    static func wrong() {
        Haptics.play(.light)
        if Bundle.main.url(forResource: "oops", withExtension: "wav") != nil {
            play("oops")
        } else {
            play("wrong", volume: 0.45)
        }
    }

    /// Soft paper swish when a sticker-book page is turned.
    static func pageFlip() { play("pageflip") }

    /// Cheery pop when a sticker is placed in the book.
    static func stickerPop() { play("stickerpop") }

    static func play(_ name: String, volume: Float = 1) {
        // Respect the in-app mute button — skip all sound when muted.
        guard !isMuted else { return }
        prepareSession()
        if let existing = players[name] {
            existing.volume = volume
            existing.currentTime = 0
            existing.play()
            return
        }
        guard let url = Bundle.main.url(forResource: name, withExtension: "wav") else { return }
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.volume = volume
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
