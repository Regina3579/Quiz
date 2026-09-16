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

/// What a parent can turn on and off. Music and sound effects are separate,
/// because they are answers to different complaints: one child is distracted
/// by a tune, another is in a quiet room and only wants the chimes gone.
enum AudioSettings {
    static let musicKey = "quizspark.music.on"
    static let effectsKey = "quizspark.effects.on"
    static let musicVolumeKey = "quizspark.music.volume"
    /// The single toggle these replaced, read once so nobody's choice is lost.
    static let legacyMuteKey = "quizspark.muted"

    static var musicOn: Bool {
        get { defaults.object(forKey: musicKey) as? Bool ?? true }
        set { defaults.set(newValue, forKey: musicKey) }
    }

    static var effectsOn: Bool {
        get { defaults.object(forKey: effectsKey) as? Bool ?? true }
        set { defaults.set(newValue, forKey: effectsKey) }
    }

    /// 0…1, scaling the music's own quiet level rather than replacing it —
    /// so even at the top of the slider the music stays under the questions.
    static var musicVolume: Double {
        get { defaults.object(forKey: musicVolumeKey) as? Double ?? 1.0 }
        set { defaults.set(min(1, max(0, newValue)), forKey: musicVolumeKey) }
    }

    private static var defaults: UserDefaults { .standard }

    /// Carries the old single mute switch over to the two new ones. Runs once:
    /// after it, the legacy key is gone and the new keys are authoritative.
    static func migrateLegacyMute() {
        guard let wasMuted = defaults.object(forKey: legacyMuteKey) as? Bool else { return }
        if wasMuted {
            musicOn = false
            effectsOn = false
        }
        defaults.removeObject(forKey: legacyMuteKey)
    }
}

/// Plays short bundled sound effects (cheery for correct, a soft oops for
/// wrong). Players are cached and reused so repeat taps are instant.
enum Sound {
    private static var players: [String: AVAudioPlayer] = [:]
    private static var sessionReady = false

    /// Deliberately no `muteKey` here any more. It used to name a key where
    /// true meant "muted"; the key it would now have to point at means the
    /// opposite, so anything still binding to it would read backwards.
    /// Use `AudioSettings.effectsKey` and its true-means-on sense instead.
    static var isMuted: Bool { !AudioSettings.effectsOn }

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
