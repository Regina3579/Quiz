//
//  ConfettiView.swift
//  QuizApp
//
//  A lightweight, cheerful confetti burst using falling emoji.
//

import SwiftUI

struct ConfettiView: View {
    /// Set to true to start the celebration.
    let isActive: Bool

    private let pieces = "🎉🌟⭐️🎊✨🏆💫".map(String.init)

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(0..<40, id: \.self) { i in
                    ConfettiPiece(
                        emoji: pieces[i % pieces.count],
                        containerSize: geo.size,
                        isActive: isActive,
                        seed: i
                    )
                }
            }
        }
        .allowsHitTesting(false)
    }
}

private struct ConfettiPiece: View {
    let emoji: String
    let containerSize: CGSize
    let isActive: Bool
    let seed: Int

    @State private var fell = false

    private var startX: CGFloat {
        // Spread pieces across the width using a stable pseudo-random value.
        let r = Double((seed * 9301 + 49297) % 233280) / 233280.0
        return CGFloat(r) * containerSize.width
    }

    private var size: CGFloat {
        let r = Double((seed * 4213 + 1301) % 100) / 100.0
        return 18 + CGFloat(r) * 16
    }

    private var delay: Double {
        Double((seed * 131) % 100) / 100.0 * 0.6
    }

    private var duration: Double {
        2.0 + Double((seed * 71) % 100) / 100.0 * 1.5
    }

    var body: some View {
        Text(emoji)
            .font(.system(size: size))
            .position(
                x: startX,
                y: fell ? containerSize.height + 40 : -40
            )
            .rotationEffect(.degrees(fell ? Double((seed % 2 == 0) ? 360 : -360) : 0))
            .opacity(fell ? 0 : 1)
            .onChange(of: isActive) { active in
                if active { animate() }
            }
            .onAppear {
                if isActive { animate() }
            }
    }

    private func animate() {
        withAnimation(.easeIn(duration: duration).delay(delay)) {
            fell = true
        }
    }
}

// MARK: - Correct-answer celebration

/// A joyful one-shot burst played when a child answers correctly: gold stars
/// and sparkles shoot outward from the middle of the screen while a little
/// confetti flutters down. Bump `trigger` (e.g. increment an Int) to replay it.
struct CorrectBurst: View {
    /// Increment this to fire a fresh celebration.
    let trigger: Int

    private let sparkles = ["⭐️", "🌟", "✨", "💫", "⭐️", "🌟", "✨"]
    private let confetti = ["🎉", "⭐️", "✨", "🌟", "🎊", "💫"]

    var body: some View {
        GeometryReader { geo in
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height * 0.42)
            ZStack {
                if trigger > 0 {
                    // Stars & sparkles bursting outward from the centre.
                    ForEach(0..<18, id: \.self) { i in
                        BurstStar(emoji: sparkles[i % sparkles.count],
                                  index: i, total: 18, center: center)
                    }
                    // A little confetti fluttering down from the top.
                    ForEach(0..<12, id: \.self) { i in
                        BurstConfetti(emoji: confetti[i % confetti.count],
                                      index: i, size: geo.size)
                    }
                }
            }
            // Recreating the subtree on each trigger restarts the animations.
            .id(trigger)
        }
        .allowsHitTesting(false)
    }
}

/// One star/sparkle that flies out from the centre, grows and fades.
private struct BurstStar: View {
    let emoji: String
    let index: Int
    let total: Int
    let center: CGPoint

    @State private var out = false

    private var angle: Double {
        let base = Double(index) / Double(total) * 2 * .pi
        let jitter = (Double((index * 37) % 100) / 100.0 - 0.5) * 0.35
        return base + jitter
    }
    private var distance: CGFloat {
        let r = Double((index * 9301 + 49297) % 233280) / 233280.0
        return 110 + CGFloat(r) * 130
    }
    private var size: CGFloat {
        let r = Double((index * 4213 + 1301) % 100) / 100.0
        return 20 + CGFloat(r) * 22
    }

    var body: some View {
        Text(emoji)
            .font(.system(size: size))
            .position(
                x: center.x + (out ? CGFloat(cos(angle)) * distance : 0),
                y: center.y + (out ? CGFloat(sin(angle)) * distance : 0)
            )
            .scaleEffect(out ? 1.1 : 0.3)
            .opacity(out ? 0 : 1)
            .onAppear {
                withAnimation(.easeOut(duration: 0.85)) { out = true }
            }
    }
}

/// A single confetti piece fluttering down from the top.
private struct BurstConfetti: View {
    let emoji: String
    let index: Int
    let size: CGSize

    @State private var fell = false

    private var startX: CGFloat {
        let r = Double((index * 9301 + 49297) % 233280) / 233280.0
        return CGFloat(r) * size.width
    }
    private var pieceSize: CGFloat { 14 + CGFloat((index * 13) % 14) }
    private var delay: Double { Double((index * 29) % 100) / 100.0 * 0.3 }

    var body: some View {
        Text(emoji)
            .font(.system(size: pieceSize))
            .position(x: startX, y: fell ? size.height * 0.62 : -30)
            .rotationEffect(.degrees(fell ? Double(index % 2 == 0 ? 240 : -240) : 0))
            .opacity(fell ? 0 : 1)
            .onAppear {
                withAnimation(.easeIn(duration: 1.1).delay(delay)) { fell = true }
            }
    }
}
