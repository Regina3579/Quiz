//
//  IslandBackground.swift
//  QuizApp
//
//  A living, themed background for each island's level screen. The island's
//  colour gradient stays as the readable base, and topic-matched elements
//  (leaves, planets, bubbles, petals, confetti…) drift, float, orbit and
//  twinkle on top, driven smoothly by a TimelineView.
//

import SwiftUI

struct IslandBackground: View {
    let island: Island

    private var sprites: [Sprite] { Sprite.set(for: island.id) }

    var body: some View {
        ZStack {
            // Base: a full-screen scenic photo when the island has one,
            // otherwise the island's colour gradient.
            if let bg = island.backgroundImageName {
                Image(bg)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                // Gentle scrim so the header text and level nodes stay readable.
                LinearGradient(
                    colors: [.black.opacity(0.38), .black.opacity(0.10),
                             .black.opacity(0.12), .black.opacity(0.42)],
                    startPoint: .top, endPoint: .bottom
                )
                .ignoresSafeArea()
            } else {
                island.palette.gradient.ignoresSafeArea()
            }

            GeometryReader { geo in
                TimelineView(.animation) { timeline in
                    let t = timeline.date.timeIntervalSinceReferenceDate
                    ZStack {
                        ForEach(sprites) { sprite in
                            sprite.rendered(t: t, size: geo.size)
                        }
                    }
                }
            }
            .ignoresSafeArea()
        }
    }
}

// MARK: - Quiz gameplay background

/// The gameplay background for a quiz: the island's colour gradient with its
/// topic-matched ambient effects (jungle leaves, galaxy stars, ocean bubbles,
/// dino embers…) drifting gently on top. It deliberately never uses the scenic
/// photo, so the white question and answer cards stay perfectly readable while
/// each category still feels like its own little world.
struct QuizBackground: View {
    let island: Island

    private var sprites: [Sprite] { Sprite.set(for: island.id) }

    var body: some View {
        ZStack {
            island.palette.gradient.ignoresSafeArea()

            GeometryReader { geo in
                TimelineView(.animation) { timeline in
                    let t = timeline.date.timeIntervalSinceReferenceDate
                    ZStack {
                        ForEach(sprites) { sprite in
                            sprite.rendered(t: t, size: geo.size)
                        }
                    }
                }
            }
            .ignoresSafeArea()
            .allowsHitTesting(false)
        }
    }
}

// MARK: - Sprite model

struct Sprite: Identifiable {
    let id = UUID()

    enum Kind {
        case emoji(String)
        case dot(Color)
        case symbol(String, Color)
    }
    enum Motion {
        case driftX          // floats across the screen and wraps
        case fall            // drifts downward and wraps (petals, ash, confetti)
        case rise            // floats upward and wraps (bubbles)
        case bob             // gentle floating in place
        case twinkle         // fixed, pulsing opacity (stars, fireflies)
        case orbit(cx: Double, cy: Double, rx: Double, ry: Double)
    }

    let kind: Kind
    let size: CGFloat
    let opacity: Double
    let x: Double
    let y: Double
    let speed: Double
    let phase: Double
    let amp: Double
    let spin: Double
    let motion: Motion

    init(_ kind: Kind, size: CGFloat, opacity: Double = 0.9,
         x: Double = 0.5, y: Double = 0.5, speed: Double = 1, phase: Double = 0,
         amp: Double = 16, spin: Double = 0, motion: Motion) {
        self.kind = kind; self.size = size; self.opacity = opacity
        self.x = x; self.y = y; self.speed = speed; self.phase = phase
        self.amp = amp; self.spin = spin; self.motion = motion
    }

    private func frac(_ v: Double) -> Double { v - floor(v) }

    func rendered(t: Double, size: CGSize) -> some View {
        let w = size.width, h = size.height
        var px = x * w, py = y * h, o = opacity, angle = 0.0

        switch motion {
        case .driftX:
            px = frac(x + t * 0.02 * speed) * (w * 1.2) - w * 0.1
            py = y * h + sin(t * speed * 0.6 + phase) * amp
        case .fall:
            py = frac(y + t * 0.02 * speed) * (h * 1.2) - h * 0.1
            px = x * w + sin(t * 0.5 * speed + phase) * amp
        case .rise:
            py = h * 1.1 - frac(y + t * 0.025 * speed) * (h * 1.2)
            px = x * w + sin(t * 0.7 * speed + phase) * amp
        case .bob:
            px = x * w + sin(t * 0.4 * speed + phase) * amp
            py = y * h + cos(t * 0.5 * speed + phase) * amp
        case .twinkle:
            o = opacity * (0.35 + 0.65 * (0.5 + 0.5 * sin(t * speed * 2 + phase)))
        case let .orbit(cx, cy, rx, ry):
            px = (cx + cos(t * speed * 0.3 + phase) * rx) * w
            py = (cy + sin(t * speed * 0.3 + phase) * ry) * h
        }
        if spin != 0 { angle = t * spin }

        return content
            .rotationEffect(.degrees(angle))
            .opacity(o)
            .position(x: px, y: py)
    }

    @ViewBuilder
    private var content: some View {
        switch kind {
        case let .emoji(e):
            Text(e).font(.system(size: size))
        case let .dot(c):
            Circle().fill(c).frame(width: size, height: size)
                .shadow(color: c.opacity(0.8), radius: size * 0.4)
        case let .symbol(name, c):
            Image(systemName: name).font(.system(size: size)).foregroundStyle(c)
        }
    }
}

// MARK: - Per-island sprite sets

extension Sprite {
    static func set(for id: Int) -> [Sprite] {
        switch id {
        case 0:  return jungle
        case 1:  return galaxy
        case 2:  return dino
        case 3:  return ocean
        case 4:  return explorer
        case 5:  return blossom
        case 6:  return science
        case 7:  return brain
        case 8:  return ancient
        case 9:  return champion
        default: return galaxy
        }
    }

    private static let firefly = Color(red: 1.0, green: 0.95, blue: 0.5)

    // 🦁 Jungle — lots of leaves flying/fluttering down, plus soft fireflies.
    // (The scenic photo already has the animals.)
    static var jungle: [Sprite] {
        var s: [Sprite] = []
        // A signature creature gliding across in real time.
        s.append(Sprite(.emoji("🦜"), size: 34, opacity: 0.95, x: 0.0, y: 0.28, speed: 1.1, amp: 24, motion: .driftX))
        let leaves = ["🍃", "🍂", "🍃"]
        // Fluttering, falling leaves scattered across the screen.
        for i in 0..<11 {
            s.append(Sprite(.emoji(leaves[i % leaves.count]),
                            size: 18 + CGFloat(i % 4) * 7, opacity: 0.9,
                            x: Double((i * 37) % 100) / 100, y: Double(i) * 0.12,
                            speed: 0.6 + Double(i % 4) * 0.25, phase: Double(i),
                            amp: 30 + Double(i % 3) * 12, spin: 30 + Double(i % 4) * 20,
                            motion: .fall))
        }
        // A few leaves flying across on the breeze.
        for i in 0..<3 {
            s.append(Sprite(.emoji("🍃"), size: 22 + CGFloat(i) * 5, opacity: 0.85,
                            x: Double(i) * 0.3, y: 0.25 + Double(i) * 0.25,
                            speed: 1.1 + Double(i) * 0.4, phase: Double(i) * 2,
                            amp: 22, spin: 50, motion: .driftX))
        }
        // Soft glowing fireflies.
        for i in 0..<6 {
            s.append(Sprite(.dot(firefly), size: 5 + CGFloat(i % 3) * 2, opacity: 0.9,
                            x: 0.1 + Double(i) * 0.15, y: 0.25 + Double(i % 4) * 0.18,
                            speed: 0.8 + Double(i) * 0.2, phase: Double(i) * 1.3, motion: .twinkle))
        }
        return s
    }

    // 🚀 Galaxy — lots of twinkling stars plus sparkles flying around and a
    // shooting comet. (The scenic photo already has the planets & rocket.)
    static var galaxy: [Sprite] {
        var s: [Sprite] = []
        // A UFO zooming across the galaxy in real time.
        s.append(Sprite(.emoji("🛸"), size: 36, opacity: 0.95, x: 0.0, y: 0.34, speed: 1.4, amp: 20, motion: .driftX))
        // Twinkling star field (white, gold, pink, blue).
        for i in 0..<26 {
            let c: Color = (i % 6 == 0) ? Color(red: 1, green: 0.9, blue: 0.6)
                        : (i % 6 == 2) ? Color(red: 1, green: 0.8, blue: 0.95)
                        : (i % 6 == 4) ? Color(red: 0.7, green: 0.85, blue: 1) : .white
            s.append(Sprite(.dot(c), size: 2 + CGFloat(i % 4) * 2, opacity: 0.95,
                            x: Double((i * 61) % 100) / 100, y: Double((i * 37) % 100) / 100,
                            speed: 0.7 + Double(i % 4) * 0.4, phase: Double(i), motion: .twinkle))
        }
        // Sparkles flying across on the cosmic breeze.
        for i in 0..<4 {
            s.append(Sprite(.symbol("sparkle", .white), size: 14 + CGFloat(i % 3) * 6, opacity: 0.9,
                            x: Double(i) * 0.25, y: 0.15 + Double(i) * 0.2,
                            speed: 1.0 + Double(i) * 0.4, phase: Double(i) * 2, amp: 24, spin: 40,
                            motion: .driftX))
        }
        // Sparkles floating and drifting around in place.
        for i in 0..<4 {
            s.append(Sprite(.symbol("sparkles", Color(red: 1, green: 0.95, blue: 0.7)),
                            size: 16 + CGFloat(i % 2) * 8, opacity: 0.85,
                            x: 0.2 + Double(i) * 0.2, y: 0.3 + Double(i % 3) * 0.2,
                            speed: 0.8 + Double(i) * 0.3, phase: Double(i), amp: 28, motion: .bob))
        }
        // A couple of little stars drifting by.
        s.append(Sprite(.symbol("star.fill", Color(red: 1, green: 0.85, blue: 0.3)),
                        size: 18, opacity: 0.9, x: 0.1, y: 0.45, speed: 0.7, phase: 1, amp: 30, motion: .bob))
        s.append(Sprite(.symbol("star.fill", Color(red: 1, green: 0.85, blue: 0.3)),
                        size: 14, opacity: 0.85, x: 0.8, y: 0.7, speed: 0.9, phase: 3, amp: 26, motion: .bob))
        // Shooting comets streaking across.
        s.append(Sprite(.emoji("☄️"), size: 28, opacity: 0.9, x: 0.0, y: 0.18, speed: 3.0, phase: 0, amp: 50, motion: .driftX))
        s.append(Sprite(.emoji("☄️"), size: 22, opacity: 0.85, x: 0.0, y: 0.55, speed: 2.4, phase: 3, amp: 40, motion: .driftX))
        return s
    }

    // 🦖 Dino — falling leaves, glowing embers rising, a few sparkles
    static var dino: [Sprite] {
        var s: [Sprite] = []
        // A pterodactyl gliding across the sky in real time.
        s.append(Sprite(.emoji("🦅"), size: 32, opacity: 0.9, x: 0.0, y: 0.16, speed: 1.2, amp: 18, motion: .driftX))
        for i in 0..<7 {
            s.append(Sprite(.emoji(["🍃", "🍂"][i % 2]), size: 18 + CGFloat(i % 3) * 6, opacity: 0.85,
                            x: Double((i * 37) % 100) / 100, y: Double(i) * 0.13,
                            speed: 0.6 + Double(i % 3) * 0.25, phase: Double(i), amp: 28, spin: 40, motion: .fall))
        }
        for i in 0..<7 {
            s.append(Sprite(.dot(Color(red: 1, green: 0.72, blue: 0.32)), size: 4 + CGFloat(i % 3) * 2,
                            opacity: 0.7, x: Double((i * 53) % 100) / 100, y: Double(i) * 0.12,
                            speed: 0.6 + Double(i % 3) * 0.3, phase: Double(i), amp: 14, motion: .rise))
        }
        for i in 0..<3 {
            s.append(Sprite(.symbol("sparkle", .white), size: 13, opacity: 0.7,
                            x: 0.25 + Double(i) * 0.28, y: 0.2 + Double(i) * 0.2,
                            speed: 1 + Double(i) * 0.3, phase: Double(i), motion: .twinkle))
        }
        return s
    }

    // 🐬 Ocean — lots of rising bubbles and gentle light sparkles
    static var ocean: [Sprite] {
        var s: [Sprite] = []
        // A fish swimming across in real time.
        s.append(Sprite(.emoji("🐠"), size: 34, opacity: 0.95, x: 0.0, y: 0.42, speed: 1.0, amp: 20, motion: .driftX))
        for i in 0..<14 {
            s.append(Sprite(.dot(Color.white.opacity(0.65)), size: 4 + CGFloat(i % 4) * 3,
                            opacity: 0.55, x: Double((i * 53) % 100) / 100, y: Double(i) * 0.08,
                            speed: 0.7 + Double(i % 3) * 0.3, phase: Double(i), amp: 16, motion: .rise))
        }
        for i in 0..<5 {
            s.append(Sprite(.symbol("sparkle", .white), size: 12 + CGFloat(i % 3) * 5, opacity: 0.7,
                            x: 0.15 + Double(i) * 0.18, y: 0.18 + Double(i % 3) * 0.2,
                            speed: 0.9 + Double(i) * 0.3, phase: Double(i), motion: .twinkle))
        }
        return s
    }

    // 🧭 Explorer — sunlit sparkles drifting across, soft floating light motes
    static var explorer: [Sprite] {
        var s: [Sprite] = []
        // An aeroplane flying across in real time.
        s.append(Sprite(.emoji("✈️"), size: 32, opacity: 0.95, x: 0.0, y: 0.18, speed: 1.5, amp: 12, motion: .driftX))
        for i in 0..<5 {
            s.append(Sprite(.symbol("sparkle", .white), size: 13 + CGFloat(i % 3) * 5, opacity: 0.8,
                            x: Double(i) * 0.22, y: 0.15 + Double(i % 3) * 0.18,
                            speed: 0.9 + Double(i) * 0.3, phase: Double(i) * 2, amp: 20, motion: .driftX))
        }
        for i in 0..<6 {
            s.append(Sprite(.dot(Color(red: 1, green: 0.98, blue: 0.8)), size: 4 + CGFloat(i % 3) * 2,
                            opacity: 0.6, x: Double((i * 61) % 100) / 100, y: Double((i * 37) % 100) / 100,
                            speed: 0.8 + Double(i % 3) * 0.3, phase: Double(i), motion: .twinkle))
        }
        return s
    }

    // 🌺 Blossom — falling flower petals and leaves, soft sparkles
    static var blossom: [Sprite] {
        var s: [Sprite] = []
        // A butterfly flying over the garden in real time.
        s.append(Sprite(.emoji("🦋"), size: 34, opacity: 0.95, x: 0.0, y: 0.32, speed: 1.1, amp: 30, motion: .driftX))
        let petals = ["🌸", "🌺", "🌼", "🌷", "🍃"]
        for i in 0..<9 {
            s.append(Sprite(.emoji(petals[i % petals.count]), size: 18 + CGFloat(i % 3) * 7, opacity: 0.9,
                            x: Double((i * 37) % 100) / 100, y: Double(i) * 0.11,
                            speed: 0.6 + Double(i % 3) * 0.25, phase: Double(i), amp: 30, spin: 50, motion: .fall))
        }
        for i in 0..<4 {
            s.append(Sprite(.symbol("sparkle", .white), size: 12, opacity: 0.75,
                            x: 0.2 + Double(i) * 0.2, y: 0.2 + Double(i) * 0.18,
                            speed: 1 + Double(i) * 0.3, phase: Double(i), motion: .twinkle))
        }
        return s
    }

    // 🔬 Science — rising bubbles, glowing sparks, floating sparkles
    static var science: [Sprite] {
        var s: [Sprite] = []
        // A friendly robot hovering across in real time.
        s.append(Sprite(.emoji("🤖"), size: 32, opacity: 0.9, x: 0.0, y: 0.3, speed: 1.0, amp: 22, motion: .driftX))
        for i in 0..<8 {
            s.append(Sprite(.dot(Color.cyan.opacity(0.65)), size: 4 + CGFloat(i % 3) * 3, opacity: 0.6,
                            x: Double((i * 47) % 100) / 100, y: Double(i) * 0.11,
                            speed: 0.8 + Double(i % 3) * 0.3, phase: Double(i), amp: 12, motion: .rise))
        }
        for i in 0..<8 {
            let c: Color = (i % 3 == 0) ? Color(red: 0.6, green: 1, blue: 0.9)
                        : (i % 3 == 1) ? Color(red: 0.8, green: 0.7, blue: 1) : .white
            s.append(Sprite(.dot(c), size: 3 + CGFloat(i % 3) * 2, opacity: 0.85,
                            x: Double((i * 61) % 100) / 100, y: Double((i * 29) % 100) / 100,
                            speed: 0.9 + Double(i % 3) * 0.4, phase: Double(i), motion: .twinkle))
        }
        for i in 0..<3 {
            s.append(Sprite(.symbol("sparkles", .white), size: 16, opacity: 0.75,
                            x: 0.25 + Double(i) * 0.25, y: 0.3 + Double(i % 2) * 0.2,
                            speed: 1 + Double(i) * 0.3, phase: Double(i), amp: 22, motion: .bob))
        }
        return s
    }

    // 🧩 Brain Castle — magical twinkles and floating sparkles
    static var brain: [Sprite] {
        var s: [Sprite] = []
        // A wise owl flying across in real time.
        s.append(Sprite(.emoji("🦉"), size: 32, opacity: 0.9, x: 0.0, y: 0.24, speed: 1.1, amp: 18, motion: .driftX))
        for i in 0..<10 {
            let c: Color = (i % 3 == 0) ? Color(red: 1, green: 0.8, blue: 0.95)
                        : (i % 3 == 1) ? Color(red: 0.75, green: 0.8, blue: 1) : .white
            s.append(Sprite(.dot(c), size: 3 + CGFloat(i % 3) * 2, opacity: 0.9,
                            x: Double((i * 61) % 100) / 100, y: Double((i * 37) % 100) / 100,
                            speed: 0.8 + Double(i % 4) * 0.35, phase: Double(i), motion: .twinkle))
        }
        for i in 0..<4 {
            s.append(Sprite(.symbol("sparkles", Color(red: 1, green: 0.95, blue: 0.7)),
                            size: 15 + CGFloat(i % 2) * 7, opacity: 0.8,
                            x: 0.2 + Double(i) * 0.2, y: 0.25 + Double(i % 3) * 0.2,
                            speed: 0.8 + Double(i) * 0.3, phase: Double(i), amp: 26, motion: .bob))
        }
        return s
    }

    // 👑 Ancient — falling desert sand and shimmering gold sparkles
    static var ancient: [Sprite] {
        var s: [Sprite] = []
        // A falcon soaring across in real time.
        s.append(Sprite(.emoji("🦅"), size: 30, opacity: 0.9, x: 0.0, y: 0.2, speed: 1.2, amp: 18, motion: .driftX))
        for i in 0..<10 {
            s.append(Sprite(.dot(Color(red: 0.95, green: 0.85, blue: 0.6)), size: 3 + CGFloat(i % 3) * 2,
                            opacity: 0.5, x: Double(i) / 10, y: Double(i) * 0.1,
                            speed: 0.6 + Double(i % 3) * 0.25, phase: Double(i), amp: 24, motion: .fall))
        }
        for i in 0..<6 {
            s.append(Sprite(.symbol(i % 2 == 0 ? "sparkle" : "sparkles", Color(red: 1, green: 0.85, blue: 0.4)),
                            size: 13 + CGFloat(i % 3) * 4, opacity: 0.85,
                            x: Double((i * 53) % 100) / 100, y: Double((i * 29) % 100) / 100,
                            speed: 0.9 + Double(i % 3) * 0.3, phase: Double(i), motion: .twinkle))
        }
        return s
    }

    // 🏆 Champion — celebration confetti, twinkling gold stars, sparkles
    static var champion: [Sprite] {
        var s: [Sprite] = []
        // A hot-air balloon drifting across in real time.
        s.append(Sprite(.emoji("🎈"), size: 34, opacity: 0.95, x: 0.0, y: 0.28, speed: 0.9, amp: 22, motion: .driftX))
        let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple, .pink]
        for i in 0..<16 {
            s.append(Sprite(.dot(colors[i % colors.count]), size: 6 + CGFloat(i % 3) * 3, opacity: 0.9,
                            x: Double((i * 43) % 100) / 100, y: Double(i) * 0.07,
                            speed: 0.9 + Double(i % 4) * 0.25, phase: Double(i), amp: 24, spin: 90, motion: .fall))
        }
        for i in 0..<7 {
            s.append(Sprite(.symbol("star.fill", Color(red: 1, green: 0.85, blue: 0.3)),
                            size: 12 + CGFloat(i % 3) * 4, opacity: 0.9,
                            x: Double((i * 67) % 100) / 100, y: Double((i * 29) % 100) / 100,
                            speed: 0.8 + Double(i % 3) * 0.3, phase: Double(i), motion: .twinkle))
        }
        for i in 0..<3 {
            s.append(Sprite(.symbol("sparkles", .white), size: 16, opacity: 0.8,
                            x: 0.25 + Double(i) * 0.25, y: 0.2 + Double(i % 2) * 0.2,
                            speed: 1 + Double(i) * 0.3, phase: Double(i), amp: 22, motion: .bob))
        }
        return s
    }
}
