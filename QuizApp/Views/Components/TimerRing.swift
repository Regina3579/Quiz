//
//  TimerRing.swift
//  QuizApp
//
//  A circular countdown ring that shifts color as time runs low.
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
        case ..<0.5: return .orange
        default: return Theme.correct
        }
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.12), lineWidth: 5)

            Circle()
                .trim(from: 0, to: fraction)
                .stroke(
                    ringColor,
                    style: StrokeStyle(lineWidth: 5, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1), value: timeRemaining)

            Text("\(timeRemaining)")
                .font(.headline.weight(.bold).monospacedDigit())
                .foregroundStyle(Theme.textPrimary)
        }
        .frame(width: 46, height: 46)
    }
}
