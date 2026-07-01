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
