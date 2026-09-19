//
//  ProResultView.swift
//  QuizApp
//
//  The end of a Pro Challenge round: how it went, the gems banked, and
//  whether a new personal best was set.
//
//  The furniture — the cheering star, the title ribbon, the gem crest, the
//  gold plate, the tick marks and the glossy buttons — is shared with the end
//  of an island level and lives in ResultKit. What is here is only what a Pro
//  round does differently: the painted night scene behind it, the wording, the
//  bonus lines, and the once-a-day modes that cannot be replayed for more
//  gems today.
//
//  Every size is a fraction of the screen's width, so the layout holds its
//  proportions from the smallest phone to an iPad.
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
    @State private var gemsShown = 0
    /// Trophy Room awards this round won, snapshotted as it was banked.
    @State private var awardsWon: [Achievement] = []

    private var mode: ProMode { model.mode }
    private var playerName: String { Player.name }

    // MARK: - Words

    /// The headline, split so the child's own name can be the gold part.
    private var headline: (lead: String, name: String) {
        let name = playerName
        if model.isPerfect {
            return name.isEmpty ? ("Flawless!", "") : ("Flawless, ", name + "!")
        }
        if model.endedEarly { return ("So Close!", "") }
        if model.score >= model.totalQuestions / 2 {
            return name.isEmpty ? ("Well Played!", "") : ("Well played, ", name + "!")
        }
        return ("Good Try!", "")
    }

    private var subtitlePieces: [(String, Bool)] {
        if model.endedEarly {
            return [("You got ", false), ("\(model.score)", true),
                    (" right before the run ended.", false)]
        }
        return [("You got ", false), ("\(model.score)", true), (" out of ", false),
                ("\(model.totalQuestions)", true), ("!", false)]
    }

    // MARK: - Body

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width

            ZStack {
                backdrop

                ScrollView(showsIndicators: false) {
                    VStack(spacing: w * 0.028) {
                        ResultStarMascot(width: w, appeared: showContent,
                                         fallback: model.isPerfect ? "🏆" : "🎉")
                        ResultBanner(lead: headline.lead, name: headline.name, width: w)
                        ResultLine(pieces: subtitlePieces, size: w * 0.052)
                        if isNewBest { newBestBadge(w) }
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

                if model.isPerfect || model.score >= model.totalQuestions - 1 {
                    ConfettiView(isActive: celebrate)
                        .ignoresSafeArea()
                        .allowsHitTesting(false)
                }
            }
        }
        .onAppear { animateIn() }
    }

    /// The painted night scene, or the Pro room's own sky if it is missing.
    @ViewBuilder
    private var backdrop: some View {
        if ResultArt.has(ResultArt.background) {
            GeometryReader { geo in
                Image(ResultArt.background)
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
                    // The scene is painted bright at the horizon; this keeps
                    // the white wording readable wherever it lands on it.
                    .overlay(
                        LinearGradient(stops: [
                            .init(color: ResultArt.night.opacity(0.42), location: 0.00),
                            .init(color: ResultArt.night.opacity(0.10), location: 0.28),
                            .init(color: ResultArt.night.opacity(0.10), location: 0.62),
                            .init(color: ResultArt.night.opacity(0.45), location: 1.00)
                        ], startPoint: .top, endPoint: .bottom)
                    )
            }
            .ignoresSafeArea()
        } else {
            ProBackground().ignoresSafeArea()
        }
    }

    private func newBestBadge(_ w: CGFloat) -> some View {
        HStack(spacing: w * 0.018) {
            Image(systemName: "rosette")
            Text("New personal best!")
                .font(.system(size: w * 0.040, weight: .heavy, design: .rounded))
        }
        .foregroundColor(ResultArt.plumDeep)
        .padding(.horizontal, w * 0.04)
        .padding(.vertical, w * 0.022)
        .background(Capsule().fill(LinearGradient(colors: [ResultArt.goldPale, ResultArt.gold],
                                                  startPoint: .top, endPoint: .bottom)))
        .overlay(Capsule().strokeBorder(.white.opacity(0.75), lineWidth: 1.5))
        .shadow(color: ResultArt.gold.opacity(0.55), radius: w * 0.03)
    }

    private func gemPanel(_ w: CGFloat) -> some View {
        let reward = model.reward
        return GemPanel(total: gemsShown, width: w) {
            VStack(spacing: w * 0.028) {
                RewardRow(icon: "✅",
                          label: "\(reward.correctCount) correct × \(GemRules.perCorrect)",
                          amount: reward.perCorrect, width: w)
                if reward.hasStreakThree {
                    RewardRow(icon: "🔥",
                              label: "3 in a row" + (mode.hasStreakBonus ? " (double)" : ""),
                              amount: reward.streakThreeBonus, width: w)
                }
                if reward.hasStreakFive {
                    RewardRow(icon: "🔥",
                              label: "5 in a row" + (mode.hasStreakBonus ? " (double)" : ""),
                              amount: reward.streakFiveBonus, width: w)
                }
                if reward.isPerfect {
                    RewardRow(icon: "🎁",
                              label: mode.isOncePerDay ? "Perfect Daily bonus"
                                                       : "Perfect round bonus",
                              amount: reward.perfectBonus, width: w)
                }
                if reward.completionBonus > 0 {
                    RewardRow(icon: "🏁", label: "\(mode.title) completed",
                              amount: reward.completionBonus, width: w)
                }
            }
        }
    }

    private func actions(_ w: CGFloat) -> some View {
        VStack(spacing: w * 0.028) {
            // A once-a-day mode cannot be replayed for more gems today.
            if mode.isOncePerDay {
                GlossyPill(text: "Come back tomorrow for a new set",
                           icon: "calendar.badge.clock",
                           face: GlossyPill.calm, width: w)
            } else {
                Button {
                    Haptics.play(.light)
                    showContent = false
                    celebrate = false
                    gemsShown = 0
                    recorded = false
                    isNewBest = false
                    withAnimation { model.restart() }
                    animateIn()
                } label: {
                    GlossyPill(text: "Play Again", icon: "arrow.clockwise",
                               face: GlossyPill.pink, width: w, big: true)
                }
                .buttonStyle(PressableButtonStyle())
            }

            Button {
                Haptics.play(.light)
                onExit()
            } label: {
                // The Daily Challenge is launched from the map, everything
                // else from the Pro room, so name the right destination.
                GlossyPill(text: mode.isPro ? "Back to Pro" : "Back to Map",
                           icon: mode.isPro ? "square.grid.2x2.fill" : "map.fill",
                           face: GlossyPill.blue, width: w)
            }
            .buttonStyle(PressableButtonStyle())
        }
        .padding(.top, w * 0.02)
    }

    // MARK: - Animation & saving

    private func animateIn() {
        // Bank the round once, however many times this view re-appears.
        if !recorded {
            isNewBest = progress.finishProRound(mode: mode,
                                                score: model.score,
                                                gems: model.totalGems,
                                                results: model.results,
                                                endedEarly: model.endedEarly)
            awardsWon = progress.recentlyUnlocked
            recorded = true
        }

        withAnimation(.easeOut(duration: 0.5)) { showContent = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            celebrate = true
            if model.isPerfect { Haptics.play(.success) }
            countUpGems()
        }
    }

    private func countUpGems() {
        let total = model.totalGems
        guard total > 0 else { return }
        let step = max(1, total / 22)
        Timer.scheduledTimer(withTimeInterval: 0.045, repeats: true) { timer in
            let next = gemsShown + step
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
