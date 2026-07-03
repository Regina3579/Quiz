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

    // 🦁 Jungle — drifting leaves, butterflies, fireflies, a swinging monkey & parrot
    static var jungle: [Sprite] {
        var s: [Sprite] = []
        for i in 0..<5 {
            s.append(Sprite(.emoji("🍃"), size: 22 + CGFloat(i % 3) * 6, opacity: 0.85,
                            x: Double(i) / 5, y: Double(i) * 0.17, speed: 0.8 + Double(i) * 0.2,
                            phase: Double(i), amp: 26, spin: 40, motion: .fall))
        }
        for i in 0..<6 {
            s.append(Sprite(.dot(firefly), size: 5 + CGFloat(i % 3) * 2, opacity: 0.9,
                            x: 0.1 + Double(i) * 0.15, y: 0.2 + Double(i % 4) * 0.2,
                            speed: 0.8 + Double(i) * 0.2, phase: Double(i) * 1.3, motion: .twinkle))
        }
        s.append(Sprite(.emoji("🦋"), size: 30, x: 0.2, y: 0.3, speed: 1.0, phase: 0, motion: .driftX))
        s.append(Sprite(.emoji("🦋"), size: 24, x: 0.6, y: 0.6, speed: 1.4, phase: 2, motion: .driftX))
        s.append(Sprite(.emoji("🐒"), size: 34, opacity: 0.9, x: 0.1, y: 0.12, speed: 0.5, phase: 1, motion: .driftX))
        s.append(Sprite(.emoji("🦜"), size: 30, opacity: 0.9, x: 0.5, y: 0.8, speed: 0.9, phase: 3, motion: .driftX))
        return s
    }

    // 🚀 Galaxy — twinkling stars, orbiting planets, a shooting comet
    static var galaxy: [Sprite] {
        var s: [Sprite] = []
        for i in 0..<16 {
            let c: Color = (i % 6 == 0) ? Color(red: 1, green: 0.9, blue: 0.6)
                        : (i % 6 == 3) ? Color(red: 1, green: 0.8, blue: 0.95) : .white
            s.append(Sprite(.dot(c), size: 3 + CGFloat(i % 3) * 2, opacity: 0.9,
                            x: Double((i * 61) % 100) / 100, y: Double((i * 37) % 100) / 100,
                            speed: 0.6 + Double(i % 4) * 0.3, phase: Double(i), motion: .twinkle))
        }
        s.append(Sprite(.emoji("🪐"), size: 46, opacity: 0.95, speed: 1.0, phase: 0,
                        motion: .orbit(cx: 0.5, cy: 0.35, rx: 0.34, ry: 0.16)))
        s.append(Sprite(.emoji("🌍"), size: 34, opacity: 0.95, speed: 1.6, phase: 2,
                        motion: .orbit(cx: 0.5, cy: 0.5, rx: 0.28, ry: 0.22)))
        s.append(Sprite(.emoji("🌙"), size: 30, opacity: 0.95, speed: 0.8, phase: 4,
                        motion: .orbit(cx: 0.5, cy: 0.6, rx: 0.4, ry: 0.14)))
        s.append(Sprite(.emoji("☄️"), size: 30, opacity: 0.9, x: 0.0, y: 0.2, speed: 3.0, phase: 0, amp: 60, motion: .driftX))
        for i in 0..<3 {
            s.append(Sprite(.symbol("sparkle", .white), size: 16, opacity: 0.9,
                            x: 0.2 + Double(i) * 0.3, y: 0.15 + Double(i) * 0.25,
                            speed: 1 + Double(i) * 0.4, phase: Double(i), motion: .twinkle))
        }
        return s
    }

    // 🦖 Dino — drifting clouds, falling ash, swaying ferns, a volcano glow
    static var dino: [Sprite] {
        var s: [Sprite] = []
        s.append(Sprite(.dot(Color.orange.opacity(0.6)), size: 200, opacity: 0.5,
                        x: 0.15, y: 0.95, speed: 0.6, phase: 0, motion: .twinkle)) // volcano glow
        s.append(Sprite(.emoji("☁️"), size: 46, opacity: 0.6, x: 0.2, y: 0.2, speed: 0.5, motion: .driftX))
        s.append(Sprite(.emoji("☁️"), size: 36, opacity: 0.5, x: 0.6, y: 0.35, speed: 0.7, phase: 2, motion: .driftX))
        for i in 0..<9 {
            s.append(Sprite(.dot(Color(white: 0.75)), size: 3 + CGFloat(i % 3),
                            opacity: 0.5, x: Double(i) / 9, y: Double(i) * 0.11,
                            speed: 0.6 + Double(i % 3) * 0.2, phase: Double(i), amp: 18, motion: .fall))
        }
        s.append(Sprite(.emoji("🌿"), size: 40, opacity: 0.8, x: 0.08, y: 0.9, speed: 0.6, motion: .bob))
        s.append(Sprite(.emoji("🌿"), size: 34, opacity: 0.8, x: 0.9, y: 0.86, speed: 0.8, phase: 2, motion: .bob))
        s.append(Sprite(.emoji("🦴"), size: 26, opacity: 0.7, x: 0.75, y: 0.55, speed: 0.7, phase: 1, motion: .bob))
        return s
    }

    // 🐬 Ocean — rising bubbles, drifting fish, swaying seaweed, a jellyfish
    static var ocean: [Sprite] {
        var s: [Sprite] = []
        for i in 0..<11 {
            s.append(Sprite(.dot(Color.white.opacity(0.6)), size: 4 + CGFloat(i % 4) * 3,
                            opacity: 0.55, x: Double((i * 53) % 100) / 100, y: Double(i) * 0.09,
                            speed: 0.7 + Double(i % 3) * 0.3, phase: Double(i), amp: 14, motion: .rise))
        }
        s.append(Sprite(.emoji("🐠"), size: 34, x: 0.2, y: 0.3, speed: 1.0, motion: .driftX))
        s.append(Sprite(.emoji("🐟"), size: 30, x: 0.6, y: 0.55, speed: 1.3, phase: 2, motion: .driftX))
        s.append(Sprite(.emoji("🐡"), size: 30, x: 0.4, y: 0.75, speed: 0.8, phase: 4, motion: .driftX))
        s.append(Sprite(.emoji("🐙"), size: 34, opacity: 0.9, x: 0.82, y: 0.4, speed: 0.7, motion: .bob))
        s.append(Sprite(.emoji("🌿"), size: 42, opacity: 0.8, x: 0.1, y: 0.92, speed: 0.7, motion: .bob))
        s.append(Sprite(.emoji("🌿"), size: 36, opacity: 0.8, x: 0.9, y: 0.9, speed: 0.9, phase: 2, motion: .bob))
        return s
    }

    // 🧭 Explorer — drifting clouds, flying birds, sun glow, sparkles
    static var explorer: [Sprite] {
        var s: [Sprite] = []
        s.append(Sprite(.dot(Color(red: 1, green: 0.95, blue: 0.7)), size: 150, opacity: 0.5,
                        x: 0.85, y: 0.12, speed: 0.5, motion: .twinkle)) // sun glow
        s.append(Sprite(.emoji("☁️"), size: 48, opacity: 0.7, x: 0.2, y: 0.18, speed: 0.5, motion: .driftX))
        s.append(Sprite(.emoji("☁️"), size: 38, opacity: 0.6, x: 0.6, y: 0.3, speed: 0.7, phase: 2, motion: .driftX))
        s.append(Sprite(.emoji("☁️"), size: 42, opacity: 0.6, x: 0.4, y: 0.5, speed: 0.6, phase: 4, motion: .driftX))
        s.append(Sprite(.emoji("🕊️"), size: 26, x: 0.1, y: 0.35, speed: 1.2, motion: .driftX))
        s.append(Sprite(.emoji("🕊️"), size: 22, x: 0.5, y: 0.6, speed: 1.5, phase: 2, motion: .driftX))
        for i in 0..<3 {
            s.append(Sprite(.symbol("sparkle", .white), size: 14, opacity: 0.85,
                            x: 0.25 + Double(i) * 0.3, y: 0.7 + Double(i % 2) * 0.12,
                            speed: 1 + Double(i) * 0.3, phase: Double(i), motion: .twinkle))
        }
        return s
    }

    // 🌺 Blossom — falling petals, butterflies, bees, sparkles
    static var blossom: [Sprite] {
        var s: [Sprite] = []
        let petals = ["🌸", "🌺", "🌼", "🌷"]
        for i in 0..<7 {
            s.append(Sprite(.emoji(petals[i % petals.count]), size: 22 + CGFloat(i % 3) * 6,
                            opacity: 0.9, x: Double(i) / 7, y: Double(i) * 0.14,
                            speed: 0.7 + Double(i % 3) * 0.2, phase: Double(i), amp: 28, spin: 50, motion: .fall))
        }
        s.append(Sprite(.emoji("🦋"), size: 30, x: 0.2, y: 0.3, speed: 1.1, motion: .driftX))
        s.append(Sprite(.emoji("🦋"), size: 26, x: 0.6, y: 0.6, speed: 1.4, phase: 2, motion: .driftX))
        s.append(Sprite(.emoji("🐝"), size: 24, x: 0.4, y: 0.45, speed: 1.6, phase: 1, motion: .driftX))
        for i in 0..<3 {
            s.append(Sprite(.symbol("sparkle", .white), size: 13, opacity: 0.8,
                            x: 0.3 + Double(i) * 0.25, y: 0.2 + Double(i) * 0.25,
                            speed: 1 + Double(i) * 0.3, phase: Double(i), motion: .twinkle))
        }
        return s
    }

    // 🔬 Science — orbiting atoms, rising bubbles, sparks, floating gear/flask
    static var science: [Sprite] {
        var s: [Sprite] = []
        s.append(Sprite(.emoji("⚛️"), size: 40, opacity: 0.9, speed: 1.2, phase: 0,
                        motion: .orbit(cx: 0.3, cy: 0.35, rx: 0.18, ry: 0.14)))
        s.append(Sprite(.emoji("⚛️"), size: 32, opacity: 0.85, speed: 1.6, phase: 3,
                        motion: .orbit(cx: 0.72, cy: 0.6, rx: 0.16, ry: 0.12)))
        for i in 0..<7 {
            s.append(Sprite(.dot(Color.cyan.opacity(0.6)), size: 4 + CGFloat(i % 3) * 2,
                            opacity: 0.6, x: Double((i * 47) % 100) / 100, y: Double(i) * 0.14,
                            speed: 0.8 + Double(i % 3) * 0.3, phase: Double(i), amp: 12, motion: .rise))
        }
        s.append(Sprite(.emoji("🧪"), size: 30, opacity: 0.85, x: 0.15, y: 0.75, speed: 0.7, motion: .bob))
        s.append(Sprite(.emoji("💡"), size: 28, opacity: 0.85, x: 0.85, y: 0.25, speed: 0.9, phase: 2, motion: .bob))
        for i in 0..<4 {
            s.append(Sprite(.symbol("sparkle", .white), size: 12, opacity: 0.8,
                            x: 0.2 + Double(i) * 0.2, y: 0.5 + Double(i % 2) * 0.2,
                            speed: 1.2 + Double(i) * 0.3, phase: Double(i), motion: .twinkle))
        }
        return s
    }

    // 🧩 Brain Castle — floating puzzle pieces, question marks, bulbs, gears
    static var brain: [Sprite] {
        var s: [Sprite] = []
        for i in 0..<3 {
            s.append(Sprite(.emoji("🧩"), size: 30 + CGFloat(i) * 4, opacity: 0.85,
                            x: 0.2 + Double(i) * 0.28, y: 0.25 + Double(i) * 0.2,
                            speed: 0.8 + Double(i) * 0.2, phase: Double(i), amp: 22, motion: .bob))
        }
        for i in 0..<3 {
            s.append(Sprite(.emoji("❓"), size: 26 + CGFloat(i) * 4, opacity: 0.8,
                            x: 0.7 - Double(i) * 0.25, y: 0.35 + Double(i) * 0.2,
                            speed: 0.9 + Double(i) * 0.2, phase: Double(i) + 1, amp: 20, motion: .bob))
        }
        s.append(Sprite(.emoji("💡"), size: 30, opacity: 0.85, x: 0.15, y: 0.7, speed: 0.8, motion: .bob))
        s.append(Sprite(.emoji("⚙️"), size: 28, opacity: 0.7, x: 0.85, y: 0.7, speed: 0.8, phase: 2, spin: 60, motion: .bob))
        for i in 0..<4 {
            s.append(Sprite(.symbol("sparkle", .white), size: 13, opacity: 0.8,
                            x: 0.3 + Double(i) * 0.2, y: 0.15 + Double(i % 2) * 0.15,
                            speed: 1 + Double(i) * 0.3, phase: Double(i), motion: .twinkle))
        }
        return s
    }

    // 👑 Ancient — falling sand, scarabs, floating pot/scroll, sun glow, gold sparkles
    static var ancient: [Sprite] {
        var s: [Sprite] = []
        s.append(Sprite(.dot(Color(red: 1, green: 0.9, blue: 0.6)), size: 150, opacity: 0.4,
                        x: 0.8, y: 0.14, speed: 0.5, motion: .twinkle)) // desert sun
        for i in 0..<9 {
            s.append(Sprite(.dot(Color(red: 0.9, green: 0.8, blue: 0.55)), size: 3 + CGFloat(i % 3),
                            opacity: 0.5, x: Double(i) / 9, y: Double(i) * 0.11,
                            speed: 0.6 + Double(i % 3) * 0.2, phase: Double(i), amp: 22, motion: .fall))
        }
        s.append(Sprite(.emoji("🪲"), size: 24, opacity: 0.85, x: 0.2, y: 0.55, speed: 0.9, motion: .driftX))
        s.append(Sprite(.emoji("📜"), size: 30, opacity: 0.8, x: 0.85, y: 0.6, speed: 0.7, motion: .bob))
        s.append(Sprite(.emoji("🏺"), size: 30, opacity: 0.8, x: 0.12, y: 0.85, speed: 0.8, phase: 2, motion: .bob))
        for i in 0..<4 {
            s.append(Sprite(.symbol("sparkle", Color(red: 1, green: 0.85, blue: 0.4)), size: 13,
                            opacity: 0.85, x: 0.35 + Double(i) * 0.2, y: 0.3 + Double(i % 2) * 0.2,
                            speed: 1 + Double(i) * 0.3, phase: Double(i), motion: .twinkle))
        }
        return s
    }

    // 🏆 Champion — falling confetti, twinkling stars, drifting party poppers, a trophy
    static var champion: [Sprite] {
        var s: [Sprite] = []
        let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple, .pink]
        for i in 0..<15 {
            s.append(Sprite(.dot(colors[i % colors.count]), size: 6 + CGFloat(i % 3) * 3,
                            opacity: 0.9, x: Double((i * 43) % 100) / 100, y: Double(i) * 0.08,
                            speed: 0.9 + Double(i % 4) * 0.25, phase: Double(i), amp: 24, spin: 90, motion: .fall))
        }
        for i in 0..<6 {
            s.append(Sprite(.symbol("star.fill", Color(red: 1, green: 0.85, blue: 0.3)),
                            size: 12 + CGFloat(i % 3) * 4, opacity: 0.9,
                            x: Double((i * 67) % 100) / 100, y: Double((i * 29) % 100) / 100,
                            speed: 0.8 + Double(i % 3) * 0.3, phase: Double(i), motion: .twinkle))
        }
        s.append(Sprite(.emoji("🎉"), size: 34, x: 0.15, y: 0.3, speed: 1.0, motion: .driftX))
        s.append(Sprite(.emoji("🎊"), size: 30, x: 0.6, y: 0.6, speed: 1.3, phase: 2, motion: .driftX))
        s.append(Sprite(.emoji("🏆"), size: 34, opacity: 0.9, x: 0.85, y: 0.4, speed: 0.7, motion: .bob))
        return s
    }
}
