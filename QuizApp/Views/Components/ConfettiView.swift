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

/// A gentle one-shot celebration played when a child answers correctly: a
/// simple ring of gold stars floats slowly outward from the tapped answer and
/// softly fades. Bump `trigger` (e.g. increment an Int) to replay it, and pass
/// the `origin` (in global coordinates) of the correct answer button.
struct CorrectBurst: View {
    /// Increment this to fire a fresh celebration.
    let trigger: Int
    /// Where the stars burst from, in global screen coordinates.
    let origin: CGPoint

    private let stars = ["⭐️", "🌟"]

    var body: some View {
        GeometryReader { geo in
            // Convert the global origin into this view's local space.
            let localOrigin = geo.frame(in: .global).origin
            let center = CGPoint(x: origin.x - localOrigin.x,
                                 y: origin.y - localOrigin.y)
            ZStack {
                if trigger > 0 {
                    // A simple, even ring of gold stars drifting slowly outward.
                    ForEach(0..<10, id: \.self) { i in
                        BurstStar(emoji: stars[i % stars.count],
                                  index: i, total: 10, center: center)
                    }
                }
            }
            // Recreating the subtree on each trigger restarts the animation.
            .id(trigger)
        }
        .allowsHitTesting(false)
    }
}

/// One gold star that drifts gently outward from the centre and softly fades.
private struct BurstStar: View {
    let emoji: String
    let index: Int
    let total: Int
    let center: CGPoint

    @State private var out = false

    /// Evenly spaced around a circle for a clean, simple burst.
    private var angle: Double {
        Double(index) / Double(total) * 2 * .pi - .pi / 2
    }
    private var distance: CGFloat { 130 }
    private var size: CGFloat { 30 }

    var body: some View {
        Text(emoji)
            .font(.system(size: size))
            .position(
                x: center.x + (out ? CGFloat(cos(angle)) * distance : 0),
                y: center.y + (out ? CGFloat(sin(angle)) * distance : 0)
            )
            .scaleEffect(out ? 1.0 : 0.4)
            .opacity(out ? 0 : 1)
            .onAppear {
                // Slow and beautiful: a gentle, unhurried drift.
                withAnimation(.easeOut(duration: 1.8)) { out = true }
            }
    }
}
