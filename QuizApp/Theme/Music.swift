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
//  anything compressed, because the encoder adds a few silent frames of
//  padding at each end. So the file is decoded once into a buffer, the padding
//  is trimmed off the buffer, and the engine loops what is left — which is
//  sample-accurate and still leaves the tracks small enough to ship. Decoding
//  alone does not fix it: the padding decodes into the buffer like any other
//  sample, and looping the buffer would simply play it.
//
//  And it has to stay underneath. A child is reading a question; the music is
//  there to settle them, not to compete. It plays at a fraction of the sound
//  effects, and it never ducks for them — a reward chime simply rings over the
//  top, which is what makes the chime feel like a reward.
//

// @preconcurrency: AVFoundation's node classes predate Sendable checking and
// are not marked, but every use of them here is already on the main actor.
@preconcurrency import AVFoundation
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
    /// One slot per voice. Both sides of a crossfade run at once, so a single
    /// slot is not enough — keeping only the last would leave the other still
    /// nudging a stopped node's volume after the app is paused.
    private var fades: [Task<Void, Never>?] = [nil, nil]
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

        guard prepare() else { return }
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
            ramp(voice: active, to: targetLevel)
        }
    }

    /// Eases the music back while speech is playing, and lifts it again after.
    /// Used for VoiceOver, and for anything the app reads aloud later.
    func setDucked(_ on: Bool) {
        guard ducking != on else { return }
        ducking = on
        guard AudioSettings.musicOn, voices[active].isPlaying else { return }
        ramp(voice: active, to: targetLevel)
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
    ///
    /// A crossfade caught halfway is finished by hand rather than frozen where
    /// it stood. Left alone it would come back as two themes playing together,
    /// each stuck at part volume, with nothing still running to separate them.
    func pause() {
        for index in fades.indices {
            fades[index]?.cancel()
            fades[index] = nil
        }
        for index in voices.indices where index != active {
            voices[index].stop()
            voices[index].volume = 0
        }
        voices[active].volume = targetLevel
        voices[active].pause()
    }

    func resume() {
        // `playing` is only non-nil once crossfade has connected a voice, so
        // these guards are also what keeps the engine from being started with
        // nothing wired to its output.
        guard started, AudioSettings.musicOn, playing != nil else { return }
        guard startEngine() else { return }
        if !voices[active].isPlaying { voices[active].play() }
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

    /// Attaches the voices and builds the output chain — and deliberately does
    /// not start the engine.
    ///
    /// Starting it here is what crashed the app. An engine with nothing
    /// connected to its output fails an assertion inside `start()`:
    ///
    ///     required condition is false: inputNode != nullptr || outputNode != nullptr
    ///
    /// That is a C++ assertion surfacing as an NSException, not a Swift error,
    /// so the `do`/`catch` written around it caught nothing and the app went
    /// down on launch. And the voices could not simply have been connected
    /// sooner: a player node has to be wired up with the format of the buffer
    /// it is about to play, and no track has been decoded yet. Connecting with
    /// a guessed format is what makes scheduleBuffer fail on a file that turns
    /// out to be mono, or recorded at a different rate from the mixer.
    ///
    /// So the engine is started in `crossfade` instead, at the first moment
    /// all three things are true: a decoded buffer, its real format, and a
    /// voice actually connected to the mixer.
    private func prepare() -> Bool {
        guard !started else { return true }
        // .ambient: mixes with whatever the family already has playing and
        // stays silent when the ring switch is off.
        try? AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
        try? AVAudioSession.sharedInstance().setActive(true)

        // Asking for the main mixer is what creates it and joins it to the
        // output. Nothing else here does, and without it the engine has no
        // output chain for a voice to be connected to.
        _ = engine.mainMixerNode

        for voice in voices {
            engine.attach(voice)
            voice.volume = 0
        }
        engine.prepare()
        started = true
        return true
    }

    /// Starts the engine if it is not already running. Safe to call only once
    /// something is connected to the mixer.
    @discardableResult
    private func startEngine() -> Bool {
        if engine.isRunning { return true }
        do {
            try engine.start()
            return true
        } catch {
            return false        // no music; the game is unaffected
        }
    }

    private func crossfade(to file: URL, named: String) {
        guard let buffer = buffer(from: file) else { return }

        let outgoing = active
        active = 1 - active
        let incoming = voices[active]

        incoming.stop()
        incoming.volume = 0
        engine.connect(incoming, to: engine.mainMixerNode, format: buffer.format)

        // Now, and not a moment earlier. There is a voice connected to the
        // mixer with the format of a buffer that has actually been decoded,
        // which is the condition the engine asserts on.
        guard startEngine() else { return }

        incoming.scheduleBuffer(buffer, at: nil, options: [.loops])
        incoming.play()
        playing = named

        ramp(voice: outgoing, to: 0) { [weak self] in self?.voices[outgoing].stop() }
        ramp(voice: active, to: targetLevel)
    }

    /// Decodes the whole track once, then cuts the silence off both ends.
    ///
    /// The trim is the part that matters, and this comment used to say the
    /// opposite — that decoding made the file's own framing irrelevant. It
    /// does not. A compressed file carries encoder padding, a few silent
    /// frames added at each end, and the decoder hands them straight back.
    /// They land inside the buffer like any other sample, so looping the
    /// buffer plays them: a small hiccup once every time round, which on a
    /// sixty-second loop is once a minute, forever.
    ///
    /// Trimming it here rather than in the file means it does not matter
    /// which decoder ran or how much padding it chose to add.
    private func buffer(from file: URL) -> AVAudioPCMBuffer? {
        guard let audio = try? AVAudioFile(forReading: file) else { return nil }
        let frames = AVAudioFrameCount(audio.length)
        guard frames > 0,
              let raw = AVAudioPCMBuffer(pcmFormat: audio.processingFormat,
                                         frameCapacity: frames) else { return nil }
        do {
            try audio.read(into: raw)
        } catch {
            return nil
        }
        return trimmingSilence(raw) ?? raw
    }

    /// Quieter than this at either end is padding, not music. About -60 dBFS,
    /// which is far below anything a track would actually open on — this one
    /// starts at -3.7 — so no real note is ever in danger of being cut.
    private static let silenceFloor: Float = 0.001

    private func trimmingSilence(_ buffer: AVAudioPCMBuffer) -> AVAudioPCMBuffer? {
        guard let samples = buffer.floatChannelData else { return nil }
        let count = Int(buffer.frameLength)
        let channels = Int(buffer.format.channelCount)
        guard count > 0, channels > 0 else { return nil }

        func sounds(at frame: Int) -> Bool {
            for c in 0..<channels where abs(samples[c][frame]) > Self.silenceFloor {
                return true
            }
            return false
        }

        var first = 0
        while first < count, !sounds(at: first) { first += 1 }
        var last = count - 1
        while last > first, !sounds(at: last) { last -= 1 }

        let kept = last - first + 1
        // Nothing to trim, or nothing but silence: leave the buffer alone.
        guard kept > 0, kept < count else { return nil }

        guard let out = AVAudioPCMBuffer(pcmFormat: buffer.format,
                                         frameCapacity: AVAudioFrameCount(kept)),
              let trimmed = out.floatChannelData else { return nil }
        for c in 0..<channels {
            for i in 0..<kept { trimmed[c][i] = samples[c][first + i] }
        }
        out.frameLength = AVAudioFrameCount(kept)
        return out
    }

    /// Eases one voice's volume across to `target`, then runs `done`.
    ///
    /// The voice is named by index rather than passed in. A player node is not
    /// Sendable, and handing one to something that runs later would mean
    /// promising the compiler something about it that is not true; an index is
    /// just a number, and the node is only ever touched from here, on the main
    /// actor, which is the thing that actually makes it safe.
    private func ramp(voice index: Int, to target: Float,
                      andThen done: (@MainActor () -> Void)? = nil) {
        // One fade per voice: a new one on the same voice supersedes the old,
        // which would otherwise carry on nudging the volume somewhere else.
        fades[index]?.cancel()

        let steps = 30
        let interval = UInt64(Self.fade / Double(steps) * 1_000_000_000)
        let from = voices[index].volume

        fades[index] = Task { @MainActor [weak self] in
            for step in 1...steps {
                try? await Task.sleep(nanoseconds: interval)
                guard !Task.isCancelled, let self else { return }
                self.voices[index].volume =
                    from + (target - from) * Float(step) / Float(steps)
            }
            guard let self else { return }
            self.voices[index].volume = target
            self.fades[index] = nil
            done?()
        }
    }

    private func fadeOutAndStop() {
        let index = active
        ramp(voice: index, to: 0) { [weak self] in
            guard let self else { return }
            self.voices[index].stop()
            self.engine.pause()
        }
    }
}
