//
//  ResultView.swift
//  QuizApp
//
//  A joyful end-of-quiz celebration with stars, confetti and a recap.
//

import SwiftUI

struct ResultView: View {
    @ObservedObject var model: QuizViewModel
    /// Called when the player chooses to leave back to the home screen.
    let onExit: () -> Void

    @State private var showContent = false
    @State private var starsShown = 0
    @State private var celebrate = false

    // MARK: - Rewards

    /// Stars earned, 0…3, based on how many answers were correct.
    private var starsEarned: Int {
        switch model.scorePercent {
        case 80...: return 3
        case 50...: return 2
        case 1...: return 1
        default: return 0
        }
    }

    private var heroEmoji: String {
        switch starsEarned {
        case 3: return "🏆"
        case 2: return "🎉"
        case 1: return "😄"
        default: return "🌱"
        }
    }

    private var headline: String {
        switch starsEarned {
        case 3: return "Superstar!"
        case 2: return "Great Job!"
        case 1: return "Nice Try!"
        default: return "Let's Try Again!"
        }
    }

    var body: some View {
        ZStack {
            VStack(spacing: 22) {
                Spacer(minLength: 0)

                Text(heroEmoji)
                    .font(.system(size: 90))
                    .scaleEffect(showContent ? 1 : 0.3)
                    .animation(.spring(response: 0.5, dampingFraction: 0.5), value: showContent)

                Text(headline)
                    .font(Theme.display(36))
                    .foregroundColor(.white)
                    .opacity(showContent ? 1 : 0)

                stars

                Text("You got \(model.score) out of \(model.totalQuestions)!")
                    .font(Theme.bold(20))
                    .foregroundColor(Theme.onColorSoft)
                    .opacity(showContent ? 1 : 0)

                recapRow
                    .opacity(showContent ? 1 : 0)

                Spacer(minLength: 0)

                actions
                    .opacity(showContent ? 1 : 0)
            }
            .padding(24)

            // Celebration confetti for 2+ stars.
            if starsEarned >= 2 {
                ConfettiView(isActive: celebrate)
                    .ignoresSafeArea()
            }
        }
        .onAppear { animateIn() }
    }

    private var stars: some View {
        HStack(spacing: 14) {
            ForEach(0..<3, id: \.self) { i in
                Image(systemName: i < starsShown ? "star.fill" : "star")
                    .font(.system(size: 44))
                    .foregroundColor(i < starsShown ? Theme.star : Color.white.opacity(0.4))
                    .scaleEffect(i < starsShown ? 1 : 0.7)
                    .animation(
                        .spring(response: 0.4, dampingFraction: 0.5)
                            .delay(Double(i) * 0.2),
                        value: starsShown
                    )
            }
        }
    }

    private var recapRow: some View {
        HStack(spacing: 8) {
            ForEach(Array(model.results.enumerated()), id: \.offset) { pair in
                Image(systemName: pair.element ? "checkmark" : "xmark")
                    .font(Theme.bold(13))
                    .foregroundColor(pair.element ? Theme.correct : Theme.incorrect)
                    .frame(width: 34, height: 34)
                    .background(Circle().fill(Color.white))
                    .shadow(color: Color.black.opacity(0.12), radius: 4, y: 2)
            }
        }
    }

    private var actions: some View {
        VStack(spacing: 12) {
            Button {
                Haptics.play(.light)
                withAnimation {
                    showContent = false
                    starsShown = 0
                    celebrate = false
                    model.restart()
                }
            } label: {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("Play Again")
                }
                .font(Theme.bold(19))
                .foregroundColor(model.quiz.palette.end)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 17)
                .background(RoundedRectangle(cornerRadius: 22, style: .continuous).fill(Color.white))
                .shadow(color: Color.black.opacity(0.15), radius: 8, y: 5)
            }
            .buttonStyle(PressableButtonStyle())

            Button {
                Haptics.play(.light)
                onExit()
            } label: {
                HStack {
                    Image(systemName: "house.fill")
                    Text("Back Home")
                }
                .font(Theme.bold(18))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(Color.white.opacity(0.22))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(Color.white.opacity(0.6), lineWidth: 2)
                )
            }
            .buttonStyle(PressableButtonStyle())
        }
    }

    // MARK: - Animation

    private func animateIn() {
        withAnimation(.easeOut(duration: 0.5)) {
            showContent = true
        }
        // Pop the stars in one by one, then fire confetti.
        withAnimation(.easeOut(duration: 0.4).delay(0.4)) {
            starsShown = starsEarned
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            celebrate = true
            if starsEarned >= 2 { Haptics.play(.success) }
        }
    }
}

#Preview {
    ZStack {
        QuizData.journeyToSpace.palette.gradient.ignoresSafeArea()
        ResultView(model: QuizViewModel(quiz: QuizData.journeyToSpace)) {}
    }
}
