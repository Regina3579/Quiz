//
//  ResultView.swift
//  QuizApp
//
//  End-of-level celebration: stars pop in, confetti falls, and progress
//  is saved so the next level unlocks on the trail.
//

import SwiftUI

struct ResultView: View {
    @ObservedObject var model: QuizViewModel
    /// Called to leave back to the island trail.
    let onExit: () -> Void

    @EnvironmentObject private var progress: GameProgress

    @State private var showContent = false
    @State private var starsShown = 0
    @State private var celebrate = false
    @State private var recorded = false

    private var earned: Int { model.starsEarned }

    private var heroEmoji: String {
        switch earned {
        case 3: return "🏆"
        case 2: return "🎉"
        case 1: return "😄"
        default: return "🌱"
        }
    }

    private var headline: String {
        switch earned {
        case 3: return "Perfect!"
        case 2: return "Great Job!"
        case 1: return "Level Cleared!"
        default: return "Almost There!"
        }
    }

    private var subtitle: String {
        if earned == 0 {
            return "Get at least half right to earn a star. Try again!"
        }
        return "You got \(model.score) out of \(model.totalQuestions)!"
    }

    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                Spacer(minLength: 0)

                Text(heroEmoji)
                    .font(.system(size: 84))
                    .scaleEffect(showContent ? 1 : 0.3)
                    .animation(.spring(response: 0.5, dampingFraction: 0.5), value: showContent)

                Text(headline)
                    .font(Theme.display(34))
                    .foregroundColor(.white)
                    .opacity(showContent ? 1 : 0)

                stars

                Text(subtitle)
                    .font(Theme.bold(18))
                    .foregroundColor(.white.opacity(0.95))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .opacity(showContent ? 1 : 0)

                recapRow.opacity(showContent ? 1 : 0)

                Spacer(minLength: 0)

                actions.opacity(showContent ? 1 : 0)
            }
            .padding(24)

            if earned >= 2 {
                ConfettiView(isActive: celebrate).ignoresSafeArea()
            }
        }
        .onAppear { animateIn() }
    }

    private var stars: some View {
        HStack(spacing: 16) {
            ForEach(0..<3, id: \.self) { i in
                Image(systemName: i < starsShown ? "star.fill" : "star")
                    .font(.system(size: 46))
                    .foregroundColor(i < starsShown ? Theme.star : .white.opacity(0.45))
                    .scaleEffect(i < starsShown ? 1 : 0.7)
                    .animation(.spring(response: 0.4, dampingFraction: 0.5).delay(Double(i) * 0.2),
                               value: starsShown)
            }
        }
    }

    private var recapRow: some View {
        HStack(spacing: 7) {
            ForEach(Array(model.results.enumerated()), id: \.offset) { pair in
                Image(systemName: pair.element ? "checkmark" : "xmark")
                    .font(Theme.bold(12))
                    .foregroundColor(pair.element ? Theme.correct : Theme.incorrect)
                    .frame(width: 30, height: 30)
                    .background(Circle().fill(.white))
                    .shadow(color: .black.opacity(0.12), radius: 3, y: 2)
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
                actionLabel(icon: "arrow.clockwise", text: "Play Again",
                            filled: true, tint: model.island.palette.end)
            }
            .buttonStyle(PressableButtonStyle())

            Button {
                Haptics.play(.light)
                onExit()
            } label: {
                actionLabel(icon: "map.fill", text: "Back to Trail",
                            filled: false, tint: model.island.palette.end)
            }
            .buttonStyle(PressableButtonStyle())
        }
    }

    private func actionLabel(icon: String, text: String, filled: Bool, tint: Color) -> some View {
        HStack {
            Image(systemName: icon)
            Text(text)
        }
        .font(Theme.bold(18))
        .foregroundColor(filled ? tint : .white)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(filled ? AnyShapeStyle(Color.white) : AnyShapeStyle(Color.white.opacity(0.22)))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(filled ? Color.clear : Color.white.opacity(0.6), lineWidth: 2)
        )
    }

    // MARK: - Animation & saving

    private func animateIn() {
        // Save the result once (keeps the player's best score).
        if !recorded {
            progress.record(islandID: model.island.id,
                            level: model.level.number,
                            earned: earned)
            recorded = true
        }

        withAnimation(.easeOut(duration: 0.5)) { showContent = true }
        withAnimation(.easeOut(duration: 0.4).delay(0.4)) { starsShown = earned }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            celebrate = true
            if earned >= 2 { Haptics.play(.success) }
        }
    }
}

#Preview {
    ZStack {
        QuizData.jungleKingdom.palette.gradient.ignoresSafeArea()
        ResultView(model: QuizViewModel(island: QuizData.jungleKingdom,
                                        level: QuizData.jungleKingdom.levels[0])) {}
            .environmentObject(GameProgress())
    }
}
