//
//  ResultView.swift
//  QuizApp
//
//  End-of-level celebration: stars pop in, confetti falls, and progress
//  is saved so the next level unlocks on the trail.
//
//  Built from the same pieces as the Pro Challenge result — the cheering
//  star, the title ribbon, the gem crest and the glossy buttons — so the two
//  screens plainly belong to one game. The differences are the ones that
//  matter: a level is scored in stars, and its gem haul can be nothing at
//  all, in which case the panel simply is not there.
//
//  The backdrop stays the island's own scene rather than the painted night
//  forest. Finishing a level in Ocean Paradise should still look like Ocean
//  Paradise; what the artwork brings is the furniture on top of it.
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
    @State private var reward: GemReward?
    @State private var gemsShown = 0
    /// Trophy Room awards this level won, snapshotted as it was banked.
    @State private var awardsWon: [Achievement] = []

    private var earned: Int { model.starsEarned }

    /// The child's name, ready to drop into a greeting (empty if not set).
    private var playerName: String { Player.name }

    /// The greeting, split so the child's own name can be the gold part.
    private var headline: (lead: String, name: String) {
        let name = playerName
        switch earned {
        case 3:  return name.isEmpty ? ("Perfect!", "") : ("Perfect, ", name + "!")
        case 2:  return name.isEmpty ? ("Great Job!", "") : ("Great job, ", name + "!")
        case 1:  return ("Level Cleared!", "")
        default: return name.isEmpty ? ("Almost There!", "")
                                     : ("Almost there, ", name + "!")
        }
    }

    /// The score line, with the numbers picked out in gold.
    private var subtitlePieces: [(String, Bool)] {
        if earned == 0 {
            return [("Get at least half right to earn a star!", false)]
        }
        return [("You got ", false), ("\(model.score)", true), (" out of ", false),
                ("\(model.totalQuestions)", true), ("!", false)]
    }

    private var fallbackEmoji: String {
        switch earned {
        case 3: return "🏆"
        case 2: return "🎉"
        case 1: return "😄"
        default: return "🌱"
        }
    }

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width

            ZStack {
                scrim

                ScrollView(showsIndicators: false) {
                    VStack(spacing: w * 0.028) {
                        ResultStarMascot(width: w, appeared: showContent,
                                         fallback: fallbackEmoji, scale: 0.42)
                        ResultBanner(lead: headline.lead, name: headline.name, width: w)
                        StarRating(shown: starsShown, width: w)
                            .padding(.vertical, w * 0.01)
                        ResultLine(pieces: subtitlePieces, size: w * 0.052)
                        ResultMarkRow(results: model.results, width: w)
                        gemPanel(w)
                        if !awardsWon.isEmpty { RewardChestView(awards: awardsWon) }
                        actions(w)
                    }
                    .opacity(showContent ? 1 : 0)
                    .padding(.horizontal, w * 0.045)
                    .padding(.top, w * 0.02)
                    .padding(.bottom, w * 0.07)
                    .frame(maxWidth: .infinity)
                }

                if earned >= 2 {
                    ConfettiView(isActive: celebrate)
                        .ignoresSafeArea()
                        .allowsHitTesting(false)
                }
            }
        }
        .onAppear { animateIn() }
    }

    /// The island's own scene is behind this screen, and a reef or a castle is
    /// far too busy to read a score off. This lays a deep wash over it: dark
    /// enough through the middle, where the numbers are, that white type and a
    /// pink gem count stand clear, but lighter at the very top and bottom so
    /// the scene still shows and the screen keeps the island's colour.
    private var scrim: some View {
        LinearGradient(stops: [
            .init(color: .black.opacity(0.55), location: 0.00),
            .init(color: .black.opacity(0.74), location: 0.22),
            .init(color: .black.opacity(0.76), location: 0.72),
            .init(color: .black.opacity(0.58), location: 1.00)
        ], startPoint: .top, endPoint: .bottom)
        .ignoresSafeArea()
    }

    /// The gem haul, if there was one. A level cleared with nothing to show
    /// for it gets no empty frame — the screen just closes up around it.
    @ViewBuilder
    private func gemPanel(_ w: CGFloat) -> some View {
        if let reward, reward.total > 0 {
            GemPanel(total: gemsShown, width: w) {
                VStack(spacing: w * 0.028) {
                    RewardRow(icon: "⭐️",
                              label: "\(reward.correctCount) correct × \(GemRules.perCorrect)",
                              amount: reward.perCorrect, width: w)
                    if reward.hasStreakThree {
                        RewardRow(icon: "🔥", label: "3 in a row",
                                  amount: reward.streakThreeBonus, width: w)
                    }
                    if reward.hasStreakFive {
                        RewardRow(icon: "🔥", label: "5 in a row",
                                  amount: reward.streakFiveBonus, width: w)
                    }
                    if reward.isPerfect {
                        RewardRow(icon: "🎁", label: "Perfect round bonus",
                                  amount: reward.perfectBonus, width: w)
                    }
                }
            }
        }
    }

    private func actions(_ w: CGFloat) -> some View {
        VStack(spacing: w * 0.028) {
            Button {
                Haptics.play(.light)
                withAnimation {
                    showContent = false
                    starsShown = 0
                    celebrate = false
                    model.restart()
                }
            } label: {
                GlossyPill(text: "Play Again", icon: "arrow.clockwise",
                           face: GlossyPill.pink, width: w, big: true)
            }
            .buttonStyle(PressableButtonStyle())

            Button {
                Haptics.play(.light)
                onExit()
            } label: {
                GlossyPill(text: "Back to Trail", icon: "map.fill",
                           face: GlossyPill.blue, width: w)
            }
            .buttonStyle(PressableButtonStyle())
        }
        .padding(.top, w * 0.02)
    }

    // MARK: - Animation & saving

    private func animateIn() {
        // Save the result once (keeps the player's best score) and award gems.
        if !recorded {
            reward = progress.completeLevel(islandID: model.island.id,
                                            level: model.level.number,
                                            correct: model.score,
                                            total: model.totalQuestions,
                                            earned: earned,
                                            results: model.results)
            // Whatever the level just won, captured before anything else can
            // change it.
            awardsWon = progress.recentlyUnlocked
            recorded = true
        }

        withAnimation(.easeOut(duration: 0.5)) { showContent = true }
        withAnimation(.easeOut(duration: 0.4).delay(0.4)) { starsShown = earned }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            celebrate = true
            if earned >= 2 { Haptics.play(.success) }
            countUpGems()
        }
    }

    /// Rolls the gem number up from zero for a satisfying reward reveal.
    private func countUpGems() {
        guard let total = reward?.total, total > 0 else { return }
        let steps = 22
        let stepValue = max(1, total / steps)
        Timer.scheduledTimer(withTimeInterval: 0.045, repeats: true) { timer in
            let next = gemsShown + stepValue
            if next >= total {
                gemsShown = total
                timer.invalidate()
                Haptics.play(.light)
            } else {
                gemsShown = next
            }
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
