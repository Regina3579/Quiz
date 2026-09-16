//
//  Music.swift
//  QuizApp
//
//  The background score: one gentle theme that follows the child around the
//  app, changing instruments as they move from one adventure to the next so
//  the whole game still sounds like one place.
//
//  Two things shape how this is built.
//
//  It has to loop without a seam. AVAudioPlayer's own looping leaves a gap on
//  anything compressed, because AAC carries a few silent frames of encoder
//  padding at each end. So the file is decoded once into a buffer and the
//  engine is told to loop *the buffer*, which is sample-accurate and leaves
//  the tracks small enough to ship.
//
//  And it has to stay underneath. A child is reading a question; the music is
//  there to settle them, not to compete. It plays at a fraction of the sound
//  effects, and it never ducks for them — a reward chime simply rings over the
//  top, which is what makes the chime feel like a reward.
//

import AVFoundation
import SwiftUI
import UIKit

@MainActor
final class Music {
    static let shared = Music()

    /// Roughly a fifth of a sound effect, which sits under a question without
    /// disappearing entirely. The slider in Settings scales this rather than
    /// replacing it, so even at the top the music stays under the questions.
    static let level: Float = 0.18

    /// How far the music drops while something is being spoken. Not silence:
    /// cutting out entirely is more noticeable than easing back.
    private static let duckedFraction: Float = 0.25

    /// What the active voice should be playing at right now.
    private var targetLevel: Float {
        let chosen = Self.level * Float(AudioSettings.musicVolume)
        return ducking ? chosen * Self.duckedFraction : chosen
    }

    private var ducking = false

    /// Long enough not to jolt, short enough not to feel like a mistake.
    private static let fade: TimeInterval = 0.9

    private let engine = AVAudioEngine()
    /// Two voices so one theme can fade out under the next rather than
    /// stopping first and leaving a hole.
    private let voices = [AVAudioPlayerNode(), AVAudioPlayerNode()]
    private var active = 0

    private var playing: String?
    /// Both sides of a crossfade run at once, so one slot is not enough —
    /// keeping only the last would leave the other still nudging a stopped
    /// node's volume after the app is paused.
    private var faders: [Timer] = []
    private var started = false
    private var watching = false

    private init() {}

    // MARK: - What plays where

    /// The shared theme, heard on the map and anywhere without one of its own.
    static let mapTrack = "music_map"

    /// Each adventure keeps the tune and changes the instruments:
    ///
    ///   Jungle Kingdom     marimba, flute, soft hand percussion
    ///   Galaxy Quest       celesta, soft synth, magical chimes
    ///   Dino Valley        marimba, playful low pizzicato strings
    ///   Ocean Paradise     harp, bells, gentle watery ambience
    ///   Explorer's Trail   ukulele and plucked strings, flute
    ///   Blossom Garden     piano, harp, soft birds and chimes
    ///   Science Lab        marimba, playful electronic plucks
    ///   Brain Castle       celesta, strings, magical bells
    ///   Ancient Kingdom    soft flute, harp, gentle hand drum
    ///   Champion's Summit  light orchestral, uplifting but calm
    static func track(forIsland id: Int) -> String {
        switch id {
        case 0: return "music_jungle"
        case 1: return "music_galaxy"
        case 2: return "music_dino"
        case 3: return "music_ocean"
        case 4: return "music_explorer"
        case 5: return "music_blossom"
        case 6: return "music_science"
        case 7: return "music_brain"
        case 8: return "music_ancient"
        case 9: return "music_champion"
        default: return mapTrack
        }
    }

    /// The Pro room lifts the energy a little without ever getting tense:
    /// a light ticking pulse under the clock, something bouncier for
    /// Lightning, a thread of suspense for Perfect Run, sparkle for Jewel
    /// Rush. Any of these with no file of its own falls back to the room's
    /// theme, and that to the map's.
    static func track(for mode: ProMode) -> String {
        switch mode {
        case .timedChallenge: return "music_timed"
        case .lightningRound: return "music_lightning"
        case .perfectRun:     return "music_perfect"
        case .jewelRush:      return "music_jewel"
        case .categoryMaster: return "music_category"
        case .dailyChallenge: return "music_daily"
        }
    }

    static let proTrack = "music_pro"
    static let bookTrack = "music_book"

    // MARK: - Playing

    /// Fades over to a track. A track with no file falls back to the shared
    /// theme, so the app can ship with one piece of music and gain the rest
    /// later without a line of this changing.
    func play(_ name: String) {
        let resolved = resolve(name)
        guard resolved != playing else { return }
        guard AudioSettings.musicOn else { playing = resolved; return }
        guard let file = url(for: resolved) else { return }

        guard start() else { return }
        crossfade(to: file, named: resolved)
    }

    /// Called when the music switch or the volume slider changes.
    func applySettings() {
        if !AudioSettings.musicOn {
            fadeOutAndStop()
        } else if let wanted = playing, !voices[active].isPlaying {
            playing = nil          // force play() to act
            play(wanted)
        } else {
            ramp(voices[active], to: targetLevel, andThen: nil)
        }
    }

    /// Eases the music back while speech is playing, and lifts it again after.
    /// Used for VoiceOver, and for anything the app reads aloud later.
    func setDucked(_ on: Bool) {
        guard ducking != on else { return }
        ducking = on
        guard AudioSettings.musicOn, voices[active].isPlaying else { return }
        ramp(voices[active], to: targetLevel, andThen: nil)
    }

    /// Starts watching for the things that should quieten the music: VoiceOver
    /// reading the screen, and another app taking over the audio.
    func beginWatchingForSpeech() {
        guard !watching else { return }
        watching = true
        setDucked(UIAccessibility.isVoiceOverRunning)

        let centre = NotificationCenter.default
        centre.addObserver(forName: UIAccessibility.voiceOverStatusDidChangeNotification,
                           object: nil, queue: .main) { _ in
            Task { @MainActor in
                Music.shared.setDucked(UIAccessibility.isVoiceOverRunning)
            }
        }
        centre.addObserver(forName: AVAudioSession.silenceSecondaryAudioHintNotification,
                           object: nil, queue: .main) { note in
            let raw = note.userInfo?[AVAudioSessionSilenceSecondaryAudioHintTypeKey] as? UInt
            let began = raw == AVAudioSession.SilenceSecondaryAudioHintType.begin.rawValue
            Task { @MainActor in
                Music.shared.setDucked(began)
            }
        }
    }

    /// Leaving the app: stop cleanly rather than being cut off.
    func pause() {
        faders.forEach { $0.invalidate() }
        faders.removeAll()
        voices.forEach { $0.pause() }
    }

    func resume() {
        guard started, AudioSettings.musicOn, playing != nil else { return }
        try? engine.start()
        voices.forEach { if $0.isPlaying == false { $0.play() } }
    }

    // MARK: - Engine

    /// A Pro mode with no track of its own drops to the Pro room's theme, and
    /// anything still missing to the map's, so one file is enough to start.
    private func resolve(_ name: String) -> String {
        if url(for: name) != nil { return name }
        if name.hasPrefix("music_"), url(for: Self.proTrack) != nil,
           name != Self.mapTrack, name != Self.bookTrack,
           Self.proFallbacks.contains(name) {
            return Self.proTrack
        }
        return Self.mapTrack
    }

    private static let proFallbacks: Set<String> = [
        "music_timed", "music_lightning", "music_perfect",
        "music_jewel", "music_category", "music_daily"
    ]

    private func url(for name: String) -> URL? {
        for ext in ["m4a", "mp3", "wav", "caf"] {
            if let u = Bundle.main.url(forResource: name, withExtension: ext) { return u }
        }
        return nil
    }

    private func start() -> Bool {
        guard !started else { return true }
        // .ambient: mixes with whatever the family already has playing and
        // stays silent when the ring switch is off.
        try? AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
        try? AVAudioSession.sharedInstance().setActive(true)

        // Attached now, connected later: a player node has to be wired up with
        // the format of the buffer it is about to play, and that is not known
        // until a track has been decoded. Connecting with a guessed format is
        // what makes scheduleBuffer fail on a file that turns out to be mono,
        // or recorded at a different rate from the mixer.
        for voice in voices {
            engine.attach(voice)
            voice.volume = 0
        }
        do {
            try engine.start()
        } catch {
            return false        // no music; the game is unaffected
        }
        started = true
        return true
    }

    private func crossfade(to file: URL, named: String) {
        guard let buffer = buffer(from: file) else { return }

        let outgoing = voices[active]
        active = 1 - active
        let incoming = voices[active]

        incoming.stop()
        incoming.volume = 0
        engine.connect(incoming, to: engine.mainMixerNode, format: buffer.format)
        incoming.scheduleBuffer(buffer, at: nil, options: [.loops])
        incoming.play()
        playing = named

        ramp(outgoing, to: 0, andThen: { outgoing.stop() })
        ramp(incoming, to: targetLevel, andThen: nil)
    }

    /// Decodes the whole track once. Looping a decoded buffer is what makes
    /// the join seamless — the file's own framing never comes into it.
    private func buffer(from file: URL) -> AVAudioPCMBuffer? {
        guard let audio = try? AVAudioFile(forReading: file) else { return nil }
        let frames = AVAudioFrameCount(audio.length)
        guard frames > 0,
              let buffer = AVAudioPCMBuffer(pcmFormat: audio.processingFormat,
                                            frameCapacity: frames) else { return nil }
        do {
            try audio.read(into: buffer)
        } catch {
            return nil
        }
        return buffer
    }

    private func ramp(_ node: AVAudioPlayerNode, to target: Float,
                      andThen done: (() -> Void)?) {
        let from = node.volume
        let steps = 30
        var step = 0
        let timer = Timer.scheduledTimer(withTimeInterval: Self.fade / Double(steps),
                                         repeats: true) { t in
            step += 1
            let progress = Float(step) / Float(steps)
            Task { @MainActor in
                node.volume = from + (target - from) * progress
                if step >= steps {
                    t.invalidate()
                    node.volume = target
                    done?()
                }
            }
        }
        RunLoop.main.add(timer, forMode: .common)
        faders.append(timer)
        faders.removeAll { !$0.isValid }
    }

    private func fadeOutAndStop() {
        let voice = voices[active]
        ramp(voice, to: 0) { [weak self] in
            voice.stop()
            self?.engine.pause()
        }
    }
}
