//
//  ResultView.swift
//  QuizApp
//
//  End-of-quiz summary with an animated score ring and a recap grid.
//

import SwiftUI

struct ResultView: View {
    @ObservedObject var model: QuizViewModel
    /// Called when the player chooses to leave back to the home screen.
    let onExit: () -> Void

    @State private var ringProgress: Double = 0
    @State private var showContent = false

    // MARK: - Copy that adapts to performance

    private var headline: String {
        switch model.scorePercent {
        case 100: return "Perfect! 🏆"
        case 80...: return "Brilliant! 🌟"
        case 60...: return "Well done! 👏"
        case 40...: return "Not bad! 💪"
        default: return "Keep practicing! 📚"
        }
    }

    private var subtitle: String {
        "You scored \(model.score) out of \(model.totalQuestions)"
    }

    var body: some View {
        VStack(spacing: 28) {
            Spacer(minLength: 0)

            Text(headline)
                .font(.largeTitle.weight(.heavy))
                .foregroundStyle(Theme.textPrimary)
                .multilineTextAlignment(.center)
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 12)

            scoreRing

            Text(subtitle)
                .font(.title3.weight(.medium))
                .foregroundStyle(Theme.textSecondary)
                .opacity(showContent ? 1 : 0)

            recapGrid
                .opacity(showContent ? 1 : 0)

            Spacer(minLength: 0)

            actions
                .opacity(showContent ? 1 : 0)
        }
        .padding(24)
        .onAppear { animateIn() }
    }

    private var scoreRing: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.12), lineWidth: 16)

            Circle()
                .trim(from: 0, to: ringProgress)
                .stroke(
                    model.quiz.palette.gradient,
                    style: StrokeStyle(lineWidth: 16, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))

            VStack(spacing: 2) {
                Text("\(model.scorePercent)%")
                    .font(.system(size: 44, weight: .heavy, design: .rounded))
                    .foregroundStyle(Theme.textPrimary)
                    .contentTransition(.numericText())
                Text("score")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Theme.textSecondary)
            }
        }
        .frame(width: 200, height: 200)
        .shadow(color: model.quiz.palette.end.opacity(0.4), radius: 20)
    }

    private var recapGrid: some View {
        HStack(spacing: 8) {
            ForEach(Array(model.results.enumerated()), id: \.offset) { pair in
                Image(systemName: pair.element ? "checkmark" : "xmark")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 34, height: 34)
                    .background(
                        Circle().fill(pair.element ? Theme.correct : Theme.incorrect)
                    )
            }
        }
    }

    private var actions: some View {
        VStack(spacing: 12) {
            Button {
                Haptics.play(.light)
                withAnimation {
                    ringProgress = 0
                    showContent = false
                    model.restart()
                }
            } label: {
                Label("Play Again", systemImage: "arrow.clockwise")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(model.quiz.palette.gradient)
                    )
                    .shadow(color: model.quiz.palette.end.opacity(0.5), radius: 12, y: 6)
            }
            .buttonStyle(PressableButtonStyle())

            Button {
                Haptics.play(.light)
                onExit()
            } label: {
                Text("Back to Categories")
                    .font(.headline)
                    .foregroundStyle(Theme.textPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .glassCard(cornerRadius: 18)
            }
            .buttonStyle(PressableButtonStyle())
        }
    }

    // MARK: - Animation

    private func animateIn() {
        withAnimation(.easeOut(duration: 0.5)) {
            showContent = true
        }
        withAnimation(.easeOut(duration: 1.0).delay(0.2)) {
            ringProgress = Double(model.score) / Double(max(1, model.totalQuestions))
        }
    }
}

#Preview {
    ZStack {
        Theme.backgroundGradient.ignoresSafeArea()
        ResultView(model: {
            let m = QuizViewModel(quiz: QuizData.scienceQuiz)
            return m
        }()) {}
    }
}
