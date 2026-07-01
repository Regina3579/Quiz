//
//  TimerRing.swift
//  QuizApp
//
//  A friendly circular countdown that gently changes color as time runs low.
//

import SwiftUI

struct TimerRing: View {
    let timeRemaining: Int
    let total: Int

    private var fraction: Double {
        guard total > 0 else { return 0 }
        return Double(timeRemaining) / Double(total)
    }

    private var ringColor: Color {
        switch fraction {
        case ..<0.25: return Theme.incorrect
        case ..<0.5: return Theme.sunshine
        default: return .white
        }
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(0.20))

            Circle()
                .stroke(Color.white.opacity(0.30), lineWidth: 5)

            Circle()
                .trim(from: 0, to: fraction)
                .stroke(
                    ringColor,
                    style: StrokeStyle(lineWidth: 5, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1), value: timeRemaining)

            Text("\(timeRemaining)")
                .font(Theme.bold(17).monospacedDigit())
                .foregroundColor(.white)
        }
        .frame(width: 50, height: 50)
    }
}
