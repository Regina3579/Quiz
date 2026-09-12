//
//  ProResultView.swift
//  QuizApp
//
//  The end of a Pro Challenge round: how it went, the jewels banked, and
//  whether a new personal best was set.
//

import SwiftUI

struct ProResultView: View {
    @ObservedObject var model: ProQuizViewModel
    /// Leaves the round and returns to the Pro hub.
    let onExit: () -> Void

    @EnvironmentObject private var progress: GameProgress

    @State private var showContent = false
    @State private var celebrate = false
    @State private var recorded = false
    @State private var isNewBest = false
    @State private var jewelsShown = 0

    private var mode: ProMode { model.mode }

    private var playerName: String { Player.name }

    private var headline: String {
        let name = playerName
        if model.isPerfect {
            return name.isEmpty ? "Flawless!" : "Flawless, \(name)!"
        }
        if model.endedEarly {
            return "So Close!"
        }
        if model.score >= model.totalQuestions / 2 {
            return name.isEmpty ? "Well Played!" : "Well played, \(name)!"
        }
        return "Good Try!"
    }

    private var heroEmoji: String {
        if model.isPerfect { return "🏆" }
        if model.endedEarly { return "💔" }
        return model.score >= model.totalQuestions / 2 ? "🎉" : "🌱"
    }

    private var subtitle: String {
        if model.endedEarly {
            return "You got \(model.score) right before the run ended."
        }
        return "You got \(model.score) out of \(model.totalQuestions)!"
    }

    var body: some View {
        ZStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    Text(heroEmoji)
                        .font(.system(size: 76))
                        .scaleEffect(showContent ? 1 : 0.3)
                        .animation(.spring(response: 0.5, dampingFraction: 0.5), value: showContent)

                    Text(headline)
                        .font(Theme.display(32))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .opacity(showContent ? 1 : 0)

                    Text(subtitle)
                        .font(Theme.bold(17))
                        .foregroundColor(.white.opacity(0.95))
                        .multilineTextAlignment(.center)
                        .opacity(showContent ? 1 : 0)

                    if isNewBest { newBestBadge.opacity(showContent ? 1 : 0) }

                    recapRow.opacity(showContent ? 1 : 0)

                    jewelCard.opacity(showContent ? 1 : 0)

                    actions.opacity(showContent ? 1 : 0)
                }
                .padding(24)
                .frame(maxWidth: .infinity)
            }

            if model.isPerfect || model.score >= model.totalQuestions - 1 {
                ConfettiView(isActive: celebrate).ignoresSafeArea().allowsHitTesting(false)
            }
        }
        .onAppear { animateIn() }
    }

    private var newBestBadge: some View {
        HStack(spacing: 7) {
            Image(systemName: "rosette")
            Text("New personal best!")
                .font(Theme.bold(15))
        }
        .foregroundColor(Theme.ink)
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(Capsule().fill(Theme.star))
        .shadow(color: .black.opacity(0.2), radius: 5, y: 3)
    }

    private var recapRow: some View {
        // Wraps, because Category Master shows fifteen marks.
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 32), spacing: 6)], spacing: 6) {
            ForEach(Array(model.results.enumerated()), id: \.offset) { pair in
                Image(systemName: pair.element ? "checkmark" : "xmark")
                    .font(Theme.bold(12))
                    .foregroundColor(pair.element ? Theme.correct : Theme.incorrect)
                    .frame(width: 30, height: 30)
                    .background(Circle().fill(.white))
                    .shadow(color: .black.opacity(0.12), radius: 3, y: 2)
            }
        }
        .padding(.horizontal, 4)
    }

    private var jewelCard: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                JewelIcon(size: 34, sparkle: true)
                Text("+\(jewelsShown)")
                    .font(Theme.display(36))
                    .foregroundStyle(Theme.jewelPink)
                Text("Jewels")
                    .font(Theme.bold(17))
                    .foregroundColor(.white.opacity(0.9))
            }

            VStack(spacing: 6) {
                line("✅", "\(model.score) correct", model.jewelsEarned)
                if mode.hasStreakBonus && model.bestStreak > 1 {
                    line("🔥", "Best streak: \(model.bestStreak) in a row", nil)
                }
                if model.completionBonus > 0 {
                    line("🎁", "Clean sweep bonus", model.completionBonus)
                }
            }
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 18)
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 20, style: .continuous)
            .fill(Color.white.opacity(0.16)))
        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous)
            .stroke(.white.opacity(0.35), lineWidth: 1))
    }

    private func line(_ icon: String, _ label: String, _ amount: Int?) -> some View {
        HStack(spacing: 8) {
            Text(icon).font(.system(size: 15))
            Text(label)
                .font(Theme.medium(14))
                .foregroundColor(.white.opacity(0.9))
            Spacer(minLength: 12)
            if let amount {
                Text("+\(amount)")
                    .font(Theme.bold(15))
                    .foregroundColor(Theme.star)
            }
        }
    }

    private var actions: some View {
        VStack(spacing: 12) {
            Button {
                Haptics.play(.light)
                showContent = false
                celebrate = false
                jewelsShown = 0
                recorded = false
                isNewBest = false
                withAnimation { model.restart() }
                animateIn()
            } label: {
                actionLabel(icon: "arrow.clockwise", text: "Play Again", filled: true)
            }
            .buttonStyle(PressableButtonStyle())

            Button {
                Haptics.play(.light)
                onExit()
            } label: {
                actionLabel(icon: "square.grid.2x2.fill", text: "Back to Pro", filled: false)
            }
            .buttonStyle(PressableButtonStyle())
        }
    }

    private func actionLabel(icon: String, text: String, filled: Bool) -> some View {
        HStack {
            Image(systemName: icon)
            Text(text)
        }
        .font(Theme.bold(18))
        .foregroundColor(filled ? mode.palette.end : .white)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(RoundedRectangle(cornerRadius: 22, style: .continuous)
            .fill(filled ? AnyShapeStyle(Color.white)
                         : AnyShapeStyle(Color.white.opacity(0.22))))
        .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous)
            .stroke(filled ? Color.clear : Color.white.opacity(0.6), lineWidth: 2))
    }

    // MARK: - Animation & saving

    private func animateIn() {
        // Bank the round once, however many times this view re-appears.
        if !recorded {
            isNewBest = progress.finishProRound(mode: mode,
                                                score: model.score,
                                                jewels: model.totalJewels)
            recorded = true
        }

        withAnimation(.easeOut(duration: 0.5)) { showContent = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            celebrate = true
            if model.isPerfect { Haptics.play(.success) }
            countUpJewels()
        }
    }

    private func countUpJewels() {
        let total = model.totalJewels
        guard total > 0 else { return }
        let step = max(1, total / 22)
        Timer.scheduledTimer(withTimeInterval: 0.045, repeats: true) { timer in
            let next = jewelsShown + step
            if next >= total {
                jewelsShown = total
                timer.invalidate()
                Haptics.play(.light)
            } else {
                jewelsShown = next
            }
        }
    }
}
