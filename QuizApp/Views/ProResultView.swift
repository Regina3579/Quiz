//
//  ProResultView.swift
//  QuizApp
//
//  The end of a Pro Challenge round: how it went, the gems banked, and
//  whether a new personal best was set.
//
//  Built on four painted pieces — the night scene behind everything, the
//  cheering star, the title ribbon and the gem crest — with every word drawn
//  live on top. None of the wording can be painted in: the name changes, the
//  score changes, the gem total counts itself up, and the breakdown is
//  anywhere from two to five lines depending on how the round went.
//
//  The panel under the crest and both buttons are drawn rather than painted,
//  because they have to grow: the panel with the number of bonus lines, the
//  buttons with wording as long as "Come back tomorrow for a new set".
//
//  Every size here is a fraction of the screen's width, so the layout holds
//  its proportions from the smallest phone to an iPad.
//

import SwiftUI
import UIKit

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

    // MARK: - Painted pieces

    private enum Art {
        static let background = "ProResultBG"
        static let star       = "ProResultStar"
        static let banner     = "ProResultBanner"
        static let crest      = "ProResultCrest"

        /// Only the crest's shape is needed in code; the star and the ribbon
        /// are laid out by `scaledToFit` alone.
        static let crestAspect: CGFloat = 2.4791

        /// The ribbon's writing area, as a fraction of the banner picture.
        static let bannerTitleAt = CGRect(x: 0.10, y: 0.235, width: 0.80, height: 0.52)
        /// The blank gold scroll on the crest, likewise.
        static let crestTextAt   = CGRect(x: 0.15, y: 0.565, width: 0.70, height: 0.29)

        static func has(_ name: String) -> Bool { UIImage(named: name) != nil }
    }

    // Sampled from the artwork so the live parts belong to the same picture.
    private static let gold     = Color(red: 1.00, green: 0.82, blue: 0.30)
    private static let goldDeep = Color(red: 0.87, green: 0.56, blue: 0.09)
    private static let goldPale = Color(red: 1.00, green: 0.95, blue: 0.72)
    private static let plum     = Color(red: 0.28, green: 0.12, blue: 0.46)
    private static let plumDeep = Color(red: 0.16, green: 0.07, blue: 0.31)
    private static let night    = Color(red: 0.07, green: 0.09, blue: 0.27)

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
                    VStack(spacing: w * 0.035) {
                        starArt(w)
                        titleBanner(w)
                        subtitle(w)
                        if isNewBest { newBestBadge(w) }
                        recapRow(w)
                        gemPanel(w)
                        if !awardsWon.isEmpty { RewardChestView(awards: awardsWon) }
                        actions(w)
                    }
                    .opacity(showContent ? 1 : 0)
                    .padding(.horizontal, w * 0.045)
                    .padding(.top, w * 0.02)
                    .padding(.bottom, w * 0.12)
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
        if Art.has(Art.background) {
            GeometryReader { geo in
                Image(Art.background)
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
                    // The scene is painted bright at the horizon; this keeps
                    // the white wording readable wherever it lands on it.
                    .overlay(
                        LinearGradient(stops: [
                            .init(color: Self.night.opacity(0.42), location: 0.00),
                            .init(color: Self.night.opacity(0.10), location: 0.28),
                            .init(color: Self.night.opacity(0.10), location: 0.62),
                            .init(color: Self.night.opacity(0.45), location: 1.00)
                        ], startPoint: .top, endPoint: .bottom)
                    )
            }
            .ignoresSafeArea()
        } else {
            ProBackground().ignoresSafeArea()
        }
    }

    // MARK: - Star

    @ViewBuilder
    private func starArt(_ w: CGFloat) -> some View {
        if Art.has(Art.star) {
            Image(Art.star)
                .resizable()
                .scaledToFit()
                .frame(width: w * 0.56)
                .scaleEffect(showContent ? 1 : 0.35)
                .animation(.spring(response: 0.55, dampingFraction: 0.55), value: showContent)
        } else {
            Text(model.isPerfect ? "🏆" : "🎉")
                .font(.system(size: w * 0.19))
        }
    }

    // MARK: - Title

    private func titleBanner(_ w: CGFloat) -> some View {
        let parts = headline
        let whole = parts.lead + parts.name
        return Group {
            if Art.has(Art.banner) {
                Image(Art.banner)
                    .resizable()
                    .scaledToFit()
                    .overlay(alignment: .topLeading) {
                        GeometryReader { g in
                            place(Art.bannerTitleAt, g.size.width, g.size.height) {
                                OutlinedText(plain: whole,
                                             font: .system(size: w * 0.076,
                                                           weight: .black, design: .rounded),
                                             outline: Self.plumDeep,
                                             width: max(1.5, w * 0.006)) {
                                    (Text(parts.lead).foregroundColor(.white)
                                     + Text(parts.name).foregroundColor(Self.gold))
                                }
                            }
                        }
                        .allowsHitTesting(false)
                    }
                    .frame(width: w * 0.98)
            } else {
                Text(whole)
                    .font(.system(size: w * 0.076, weight: .black, design: .rounded))
                    .foregroundColor(.white)
            }
        }
    }

    private func subtitle(_ w: CGFloat) -> some View {
        let whole = subtitlePieces.map(\.0).joined()
        return OutlinedText(plain: whole,
                            font: .system(size: w * 0.052, weight: .heavy, design: .rounded),
                            outline: Self.plumDeep.opacity(0.9),
                            width: max(1, w * 0.004)) {
            subtitlePieces.reduce(Text("")) { acc, piece in
                acc + Text(piece.0).foregroundColor(piece.1 ? Self.gold : .white)
            }
        }
        .padding(.top, -w * 0.01)
    }

    private func newBestBadge(_ w: CGFloat) -> some View {
        HStack(spacing: w * 0.018) {
            Image(systemName: "rosette")
            Text("New personal best!")
                .font(.system(size: w * 0.040, weight: .heavy, design: .rounded))
        }
        .foregroundColor(Self.plumDeep)
        .padding(.horizontal, w * 0.04)
        .padding(.vertical, w * 0.022)
        .background(Capsule().fill(LinearGradient(colors: [Self.goldPale, Self.gold],
                                                  startPoint: .top, endPoint: .bottom)))
        .overlay(Capsule().strokeBorder(.white.opacity(0.75), lineWidth: 1.5))
        .shadow(color: Self.gold.opacity(0.55), radius: w * 0.03)
    }

    // MARK: - The row of ticks and crosses

    private func recapRow(_ w: CGFloat) -> some View {
        // Sized so a ten-question round still fits on one line; Category
        // Master's fifteen marks wrap onto a second, which is why this is a
        // grid and not a row.
        let d = w * 0.074
        return LazyVGrid(columns: [GridItem(.adaptive(minimum: d), spacing: w * 0.011)],
                         spacing: w * 0.011) {
            ForEach(0..<model.results.count, id: \.self) { i in
                mark(model.results[i], size: d)
            }
        }
        .padding(.horizontal, w * 0.01)
    }

    private func mark(_ right: Bool, size d: CGFloat) -> some View {
        let face: [Color] = right
            ? [Color(red: 0.46, green: 0.91, blue: 0.42), Color(red: 0.13, green: 0.68, blue: 0.24)]
            : [Color(red: 1.00, green: 0.48, blue: 0.51), Color(red: 0.86, green: 0.16, blue: 0.27)]
        return Image(systemName: right ? "checkmark" : "xmark")
            .font(.system(size: d * 0.46, weight: .black))
            .foregroundColor(.white)
            .shadow(color: .black.opacity(0.35), radius: 1, y: 1)
            .frame(width: d, height: d)
            .background(Circle().fill(LinearGradient(colors: face,
                                                     startPoint: .top, endPoint: .bottom)))
            .overlay(Circle().strokeBorder(.white.opacity(0.85), lineWidth: d * 0.06))
            .shadow(color: .black.opacity(0.35), radius: d * 0.10, y: d * 0.05)
    }

    // MARK: - The gem panel

    private func gemPanel(_ w: CGFloat) -> some View {
        let crestW = w * 0.82
        let crestH = crestW / Art.crestAspect
        // The crest hangs over the panel's top edge, so the panel is pushed
        // down by the part of it that sticks out above.
        let overhang = crestH * 0.62

        return ZStack(alignment: .top) {
            breakdown(w)
                .padding(.top, crestH - overhang + w * 0.03)
                .padding(.horizontal, w * 0.055)
                .padding(.bottom, w * 0.05)
                .frame(maxWidth: .infinity)
                .background(panelPlate(w))
                .padding(.top, overhang)

            if Art.has(Art.crest) {
                Image(Art.crest)
                    .resizable()
                    .scaledToFit()
                    .frame(width: crestW)
                    .overlay(alignment: .topLeading) {
                        GeometryReader { g in
                            place(Art.crestTextAt, g.size.width, g.size.height) {
                                gemTotal(w)
                            }
                        }
                        .allowsHitTesting(false)
                    }
            } else {
                gemTotal(w).padding(.top, w * 0.02)
            }
        }
    }

    private func gemTotal(_ w: CGFloat) -> some View {
        let whole = "+\(gemsShown) Gems"
        return OutlinedText(plain: whole,
                            font: .system(size: w * 0.072, weight: .black, design: .rounded),
                            outline: Self.goldDeep,
                            width: max(1, w * 0.004)) {
            (Text("+\(gemsShown)").foregroundColor(Theme.gemPink)
             + Text(" Gems").foregroundColor(Self.plum))
        }
        .contentTransition(.numericText())
    }

    /// The dark plate the breakdown sits on, in a bevelled gold frame.
    private func panelPlate(_ w: CGFloat) -> some View {
        let r = w * 0.085
        return RoundedRectangle(cornerRadius: r, style: .continuous)
            .fill(LinearGradient(colors: [Self.plum.opacity(0.94), Self.plumDeep.opacity(0.96)],
                                 startPoint: .top, endPoint: .bottom))
            .overlay(
                RoundedRectangle(cornerRadius: r, style: .continuous)
                    .strokeBorder(LinearGradient(
                        colors: [Self.goldPale, Self.gold, Self.goldDeep, Self.gold],
                        startPoint: .topLeading, endPoint: .bottomTrailing),
                        lineWidth: w * 0.022)
            )
            .overlay(
                RoundedRectangle(cornerRadius: r, style: .continuous)
                    .inset(by: w * 0.022)
                    .strokeBorder(.white.opacity(0.14), lineWidth: 1)
            )
            .shadow(color: Self.gold.opacity(0.35), radius: w * 0.045)
            .shadow(color: .black.opacity(0.45), radius: w * 0.03, y: w * 0.012)
    }

    private func breakdown(_ w: CGFloat) -> some View {
        let reward = model.reward
        return VStack(spacing: w * 0.028) {
            line(w, "✅", "\(reward.correctCount) correct × \(GemRules.perCorrect)",
                 reward.perCorrect)
            if reward.hasStreakThree {
                line(w, "🔥", "3 in a row" + (mode.hasStreakBonus ? " (double)" : ""),
                     reward.streakThreeBonus)
            }
            if reward.hasStreakFive {
                line(w, "🔥", "5 in a row" + (mode.hasStreakBonus ? " (double)" : ""),
                     reward.streakFiveBonus)
            }
            if reward.isPerfect {
                line(w, "🎁", mode.isOncePerDay ? "Perfect Daily bonus" : "Perfect round bonus",
                     reward.perfectBonus)
            }
            if reward.completionBonus > 0 {
                line(w, "🏁", "\(mode.title) completed", reward.completionBonus)
            }
        }
    }

    private func line(_ w: CGFloat, _ icon: String, _ label: String, _ amount: Int?) -> some View {
        HStack(spacing: w * 0.028) {
            Text(icon).font(.system(size: w * 0.050))
            Text(label)
                .font(.system(size: w * 0.044, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            Spacer(minLength: w * 0.02)
            if let amount {
                Text("+\(amount)")
                    .font(.system(size: w * 0.052, weight: .black, design: .rounded))
                    .foregroundColor(Self.gold)
                    .shadow(color: Self.goldDeep.opacity(0.8), radius: 0, y: 1.5)
            }
        }
    }

    // MARK: - Buttons

    private func actions(_ w: CGFloat) -> some View {
        VStack(spacing: w * 0.032) {
            // A once-a-day mode cannot be replayed for more gems today.
            if mode.isOncePerDay {
                GlossyPill(text: "Come back tomorrow for a new set",
                           icon: "calendar.badge.clock",
                           face: [Color(red: 0.45, green: 0.36, blue: 0.72),
                                  Color(red: 0.26, green: 0.18, blue: 0.52)],
                           width: w)
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
                               face: [Color(red: 1.00, green: 0.42, blue: 0.85),
                                      Color(red: 0.92, green: 0.15, blue: 0.62)],
                               width: w, big: true)
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
                           face: [Color(red: 0.24, green: 0.44, blue: 0.96),
                                  Color(red: 0.12, green: 0.20, blue: 0.72)],
                           width: w)
            }
            .buttonStyle(PressableButtonStyle())
        }
        .padding(.top, w * 0.02)
    }

    // MARK: - Placing live parts on a painted piece

    /// Puts a live part where the artwork leaves room for it, given that
    /// room as fractions of the picture.
    private func place<V: View>(_ r: CGRect, _ w: CGFloat, _ h: CGFloat,
                                @ViewBuilder _ content: () -> V) -> some View {
        content()
            .frame(width: r.width * w, height: r.height * h)
            .position(x: r.midX * w, y: r.midY * h)
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

// MARK: - The buttons

/// A glossy capsule with a gold rim, a highlight along the top and a glow
/// under it — drawn rather than painted, because the wording it has to hold
/// runs from "Play Again" to "Come back tomorrow for a new set".
private struct GlossyPill: View {
    let text: String
    let icon: String
    let face: [Color]
    let width: CGFloat
    var big: Bool = false

    private static let gold     = Color(red: 1.00, green: 0.82, blue: 0.30)
    private static let goldPale = Color(red: 1.00, green: 0.95, blue: 0.72)

    var body: some View {
        HStack(spacing: width * 0.028) {
            Image(systemName: icon)
                .font(.system(size: width * (big ? 0.058 : 0.048), weight: .black))
            Text(text)
                .font(.system(size: width * (big ? 0.065 : 0.055),
                              weight: .black, design: .rounded))
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        }
        .foregroundColor(.white)
        .shadow(color: .black.opacity(0.35), radius: 1, y: 1.5)
        .frame(maxWidth: .infinity)
        .padding(.vertical, width * (big ? 0.050 : 0.042))
        .background(
            Capsule().fill(LinearGradient(colors: face, startPoint: .top, endPoint: .bottom))
        )
        // The shine across the upper half is what makes it look like a
        // sweet rather than a rectangle with a colour in it.
        .overlay(
            Capsule()
                .fill(LinearGradient(colors: [.white.opacity(0.45), .white.opacity(0.02)],
                                     startPoint: .top, endPoint: .bottom))
                .padding(.horizontal, width * 0.020)
                .padding(.top, width * 0.014)
                .padding(.bottom, width * 0.070)
                .allowsHitTesting(false)
        )
        .overlay(
            Capsule().strokeBorder(LinearGradient(
                colors: [Self.goldPale, Self.gold, Self.goldPale],
                startPoint: .topLeading, endPoint: .bottomTrailing),
                lineWidth: width * 0.011)
        )
        .shadow(color: (face.last ?? .black).opacity(0.65), radius: width * 0.045, y: width * 0.012)
        .shadow(color: .black.opacity(0.35), radius: width * 0.02, y: width * 0.010)
    }
}
