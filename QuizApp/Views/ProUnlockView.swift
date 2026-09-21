//
//  ProUnlockView.swift
//  QuizApp
//
//  What Pro is, shown at the moment a player reaches for something behind it.
//
//  This page says what Pro adds and nothing else. It used to carry a second
//  list of everything that stays free, which was well meant but wrong in two
//  ways: a player finds the free game by playing it, and spending half a page
//  arguing against your own offer only muddles it. The one line of reassurance
//  a parent needs belongs beside the price, not here.
//
//  The header, the "Pro includes" tab and the two collection labels are each
//  one painted picture, because none of their wording changes. The challenge
//  pills and the counts come from ProMode and StickerCatalog, so the page
//  cannot promise a room the app does not have — and the sticker row shows
//  real stickers out of the book rather than made-up ones.
//
//  "Unlock Pro" leads to the plans, where the prices are.
//

import SwiftUI
import UIKit

struct ProUnlockView: View {
    @Environment(\.dismiss) private var dismiss

    /// What the player just tried to open. The page is the same either way —
    /// it is the whole of what Pro adds, and both doors lead to all of it.
    enum Reason {
        case proChallenges
        case sticker
    }

    let reason: Reason

    @State private var showPlans = false

    // MARK: - Painted pieces

    private enum Art {
        static let background = "ProInfoBG"
        static let header     = "ProInfoHeader"
        static let tab        = "ProInfoTab"
        static let bolt       = "ProInfoBolt"
        static let palette    = "ProInfoPalette"
        static let cuteLabel  = "ProInfoCuteLabel"
        static let epicLabel  = "ProInfoEpicLabel"

        static func has(_ name: String) -> Bool { UIImage(named: name) != nil }

        /// The painted badge for each challenge, where there is one. A mode
        /// added later falls back to its own emoji rather than to nothing.
        static func icon(for mode: ProMode) -> String? {
            switch mode {
            case .timedChallenge: return "ProModeTimed"
            case .lightningRound: return "ProModeLightning"
            case .perfectRun:     return "ProModePerfect"
            case .gemRush:        return "ProModeGem"
            case .categoryMaster: return "ProModeCategory"
            case .dailyChallenge: return nil
            }
        }
    }

    // Sampled from the artwork so the drawn parts belong to the same picture.
    private static let ink      = Color(red: 0.09, green: 0.11, blue: 0.42)
    private static let card     = Color(red: 1.00, green: 0.99, blue: 0.96)
    private static let gold     = Color(red: 1.00, green: 0.82, blue: 0.28)
    private static let goldPale = Color(red: 1.00, green: 0.95, blue: 0.70)
    private static let goldDeep = Color(red: 0.85, green: 0.56, blue: 0.10)
    private static let blueInk  = Color(red: 0.10, green: 0.38, blue: 0.92)
    private static let purpleInk = Color(red: 0.52, green: 0.22, blue: 0.94)

    /// The pill colour each challenge wears, as the artwork paints them.
    private func pillFace(_ mode: ProMode) -> [Color] {
        switch mode {
        case .timedChallenge:
            return [Color(red: 0.24, green: 0.68, blue: 1.00), Color(red: 0.03, green: 0.45, blue: 0.95)]
        case .lightningRound:
            return [Color(red: 1.00, green: 0.85, blue: 0.29), Color(red: 0.97, green: 0.68, blue: 0.08)]
        case .perfectRun:
            return [Color(red: 0.36, green: 0.86, blue: 0.42), Color(red: 0.08, green: 0.70, blue: 0.29)]
        case .gemRush:
            return [Color(red: 0.98, green: 0.38, blue: 0.78), Color(red: 0.88, green: 0.12, blue: 0.63)]
        case .categoryMaster:
            return [Color(red: 0.70, green: 0.42, blue: 1.00), Color(red: 0.52, green: 0.22, blue: 0.94)]
        case .dailyChallenge:
            return [Color(red: 0.60, green: 0.60, blue: 0.70), Color(red: 0.40, green: 0.40, blue: 0.52)]
        }
    }

    /// A handful of real stickers out of the book — the first Cute sticker of
    /// four collections and the first Epic of three — so the row shows what is
    /// actually collected rather than a drawing of what it might be.
    private var cuteSample: [Sticker] {
        Array(StickerCatalog.categories.compactMap { $0.cute.first }.prefix(4))
    }
    private var epicSample: [Sticker] {
        Array(StickerCatalog.categories.compactMap { $0.epic.first }.suffix(3))
    }

    // MARK: - Body

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width

            ZStack {
                backdrop

                ScrollView(showsIndicators: false) {
                    VStack(spacing: w * 0.014) {
                        header(w)
                        includesTab(w)
                        challengeCard(w)
                        stickerCard(w)
                        tagline(w)
                        unlockButton(w)
                        notNow(w)
                    }
                    .padding(.horizontal, w * 0.025)
                    .padding(.bottom, w * 0.03)
                }
            }
        }
        .fullScreenCover(isPresented: $showPlans) {
            ProPlansView()
        }
    }

    @ViewBuilder
    private var backdrop: some View {
        if Art.has(Art.background) {
            GeometryReader { geo in
                Image(Art.background)
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
            }
            .ignoresSafeArea()
        } else {
            LinearGradient(colors: [Color(red: 0.42, green: 0.72, blue: 0.98),
                                    Color(red: 0.20, green: 0.42, blue: 0.72)],
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
        }
    }

    @ViewBuilder
    private func header(_ w: CGFloat) -> some View {
        if Art.has(Art.header) {
            Image(Art.header).resizable().scaledToFit()
        } else {
            Text("Pro Challenges")
                .font(.system(size: w * 0.095, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .padding(.vertical, w * 0.07)
        }
    }

    @ViewBuilder
    private func includesTab(_ w: CGFloat) -> some View {
        if Art.has(Art.tab) {
            Image(Art.tab)
                .resizable()
                .scaledToFit()
                .frame(width: w * 0.66)
                .zIndex(2)
                .padding(.bottom, -w * 0.030)   // it sits astride the card below
        } else {
            Text("Pro includes")
                .font(.system(size: w * 0.055, weight: .black, design: .rounded))
                .foregroundColor(Self.gold)
        }
    }

    // MARK: - What Pro adds

    private func challengeCard(_ w: CGFloat) -> some View {
        let modes = ProMode.proModes
        return VStack(spacing: w * 0.022) {
            HStack(spacing: w * 0.022) {
                badge(w, Art.bolt, size: 0.125)
                goldTitle(w, "All \(modes.count) Pro Challenges", size: 0.068)
                Spacer(minLength: 0)
            }

            // Three to a line, then whatever is left — which is how the
            // artwork lays five of them out, and it still works for six.
            VStack(spacing: w * 0.020) {
                ForEach(0..<rowCount(modes.count), id: \.self) { row in
                    HStack(spacing: w * 0.018) {
                        ForEach(slice(modes, row), id: \.self) { mode in
                            modePill(w, mode)
                        }
                    }
                }
            }
        }
        .padding(w * 0.024)
        .frame(maxWidth: .infinity)
        .background(panel(w))
    }

    private func rowCount(_ count: Int) -> Int { max(1, (count + 2) / 3) }

    private func slice(_ modes: [ProMode], _ row: Int) -> [ProMode] {
        Array(modes.dropFirst(row * 3).prefix(3))
    }

    private func modePill(_ w: CGFloat, _ mode: ProMode) -> some View {
        HStack(spacing: w * 0.014) {
            Group {
                if let name = Art.icon(for: mode), Art.has(name) {
                    Image(name).resizable().scaledToFit()
                } else {
                    Text(mode.emoji).font(.system(size: w * 0.046))
                }
            }
            .frame(width: w * 0.060, height: w * 0.060)

            Text(mode.title)
                .font(.system(size: w * 0.038, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.35), radius: 1, y: 1)
                .lineLimit(2)
                .minimumScaleFactor(0.6)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, w * 0.018)
        .padding(.vertical, w * 0.012)
        .frame(maxWidth: .infinity)
        .background(
            Capsule().fill(LinearGradient(colors: pillFace(mode),
                                          startPoint: .top, endPoint: .bottom))
        )
        .overlay(
            Capsule()
                .fill(LinearGradient(colors: [.white.opacity(0.40), .white.opacity(0.02)],
                                     startPoint: .top, endPoint: .bottom))
                .padding(.horizontal, w * 0.012)
                .padding(.top, w * 0.008)
                .padding(.bottom, w * 0.038)
                .allowsHitTesting(false)
        )
        .overlay(Capsule().strokeBorder(.white.opacity(0.85), lineWidth: 2))
        .shadow(color: .black.opacity(0.22), radius: w * 0.012, y: w * 0.005)
    }

    // MARK: - Stickers

    private func stickerCard(_ w: CGFloat) -> some View {
        VStack(spacing: w * 0.012) {
            HStack(spacing: w * 0.022) {
                badge(w, Art.palette, size: 0.135)
                goldTitle(w, "Every Sticker Unlocked", size: 0.064)
                Spacer(minLength: 0)
            }

            (Text("Cute Collection").foregroundColor(Self.blueInk)
             + Text(" + ").foregroundColor(Self.ink)
             + Text("Epic Collection").foregroundColor(Self.purpleInk))
                .font(.system(size: w * 0.046, weight: .black, design: .rounded))
                .lineLimit(1)
                .minimumScaleFactor(0.6)

            Text("All \(StickerCatalog.categories.count) collections available with gems you earn")
                .font(.system(size: w * 0.036, weight: .semibold, design: .rounded))
                .foregroundColor(Self.ink.opacity(0.85))
                .lineLimit(1)
                .minimumScaleFactor(0.6)

            // The book itself is part of what Pro opens, and a page saying
            // every sticker is unlocked owes the player somewhere to put
            // them. The number comes from the book so the two cannot drift.
            HStack(spacing: w * 0.014) {
                Image(systemName: "book.fill")
                    .font(.system(size: w * 0.036, weight: .black))
                Text("Sticker book pages \(StickerBookPages.lockedRange) unlock — all \(StickerBookPages.total) yours to fill")
                    .font(.system(size: w * 0.034, weight: .bold, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.55)
            }
            .foregroundColor(Self.blueInk)
            .padding(.horizontal, w * 0.026)
            .padding(.vertical, w * 0.012)
            .background(Capsule().fill(Self.blueInk.opacity(0.10)))
            .padding(.top, w * 0.004)

            HStack(spacing: w * 0.008) {
                ForEach(cuteSample) { StickerGlyph(sticker: $0, size: w * 0.100) }
                Spacer(minLength: w * 0.010)
                ForEach(epicSample) { StickerGlyph(sticker: $0, size: w * 0.100) }
            }
            .padding(.top, w * 0.010)

            HStack(spacing: 0) {
                collectionLabel(w, Art.cuteLabel, "CUTE COLLECTION",
                                face: [Color(red: 0.30, green: 0.68, blue: 1.00),
                                       Color(red: 0.06, green: 0.45, blue: 0.95)])
                Spacer(minLength: w * 0.02)
                collectionLabel(w, Art.epicLabel, "EPIC COLLECTION",
                                face: [Self.purpleInk, Color(red: 0.42, green: 0.14, blue: 0.80)])
            }
            .padding(.top, w * 0.004)
        }
        .padding(w * 0.024)
        .frame(maxWidth: .infinity)
        .background(panel(w))
    }

    @ViewBuilder
    private func collectionLabel(_ w: CGFloat, _ art: String, _ text: String,
                                 face: [Color]) -> some View {
        if Art.has(art) {
            Image(art).resizable().scaledToFit().frame(width: w * 0.33)
        } else {
            Text(text)
                .font(.system(size: w * 0.032, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .padding(.horizontal, w * 0.03)
                .padding(.vertical, w * 0.012)
                .background(Capsule().fill(LinearGradient(colors: face,
                                                          startPoint: .top, endPoint: .bottom)))
        }
    }

    // MARK: - Shared bits

    /// The card headings, lettered in gold the way the artwork letters them.
    private func goldTitle(_ w: CGFloat, _ text: String, size: CGFloat) -> some View {
        OutlinedText(plain: text,
                     font: .system(size: w * size, weight: .black, design: .rounded),
                     outline: Self.ink,
                     width: max(1.5, w * 0.005)) {
            Text(text).foregroundStyle(LinearGradient(
                colors: [.white, Self.goldPale, Self.gold],
                startPoint: .top, endPoint: .bottom))
        }
    }

    @ViewBuilder
    private func badge(_ w: CGFloat, _ name: String, size: CGFloat) -> some View {
        if Art.has(name) {
            Image(name).resizable().scaledToFit().frame(width: w * size)
        } else {
            Color.clear.frame(width: w * size, height: w * size)
        }
    }

    private func panel(_ w: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: w * 0.055, style: .continuous)
            .fill(Self.card)
            .overlay(
                RoundedRectangle(cornerRadius: w * 0.055, style: .continuous)
                    .strokeBorder(LinearGradient(
                        colors: [Self.goldPale, Self.gold, Self.goldDeep],
                        startPoint: .topLeading, endPoint: .bottomTrailing),
                        lineWidth: w * 0.011)
            )
            .shadow(color: .black.opacity(0.26), radius: w * 0.022, y: w * 0.008)
    }

    private func tagline(_ w: CGFloat) -> some View {
        HStack(spacing: w * 0.020) {
            Text("⭐️").font(.system(size: w * 0.042))
            OutlinedText(plain: "Play more. Collect more. Unlock more fun!",
                         font: .system(size: w * 0.040, weight: .black, design: .rounded),
                         outline: Color(red: 0.10, green: 0.20, blue: 0.45),
                         width: max(1, w * 0.004)) {
                Text("Play more. Collect more. Unlock more fun!")
                    .foregroundColor(.white)
            }
            Text("⭐️").font(.system(size: w * 0.042))
        }
        .padding(.top, w * 0.006)
    }

    private func unlockButton(_ w: CGFloat) -> some View {
        Button {
            Haptics.play(.light)
            // This page says what Pro is; the prices live on the next one.
            showPlans = true
        } label: {
            HStack(spacing: w * 0.025) {
                Image(systemName: "crown.fill")
                    .font(.system(size: w * 0.054, weight: .black))
                Text("Unlock Pro")
                    .font(.system(size: w * 0.070, weight: .black, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            }
            .foregroundColor(.white)
            .shadow(color: Self.goldDeep.opacity(0.9), radius: 1, y: 2)
            .frame(maxWidth: .infinity)
            .padding(.vertical, w * 0.036)
            .background(
                Capsule().fill(LinearGradient(
                    colors: [Color(red: 1.00, green: 0.85, blue: 0.30),
                             Color(red: 0.97, green: 0.62, blue: 0.09)],
                    startPoint: .top, endPoint: .bottom))
            )
            .overlay(
                Capsule()
                    .fill(LinearGradient(colors: [.white.opacity(0.55), .white.opacity(0.03)],
                                         startPoint: .top, endPoint: .bottom))
                    .padding(.horizontal, w * 0.018)
                    .padding(.top, w * 0.012)
                    .padding(.bottom, w * 0.062)
                    .allowsHitTesting(false)
            )
            .overlay(Capsule().strokeBorder(Self.goldPale, lineWidth: w * 0.010))
            .shadow(color: Self.gold.opacity(0.75), radius: w * 0.045, y: w * 0.010)
        }
        .buttonStyle(PressableButtonStyle())
        .padding(.top, w * 0.010)
    }

    private func notNow(_ w: CGFloat) -> some View {
        Button {
            Haptics.play(.light)
            dismiss()
        } label: {
            Text("Not now")
                .font(.system(size: w * 0.042, weight: .bold, design: .rounded))
                .foregroundColor(.white.opacity(0.92))
                .underline()
                .shadow(color: .black.opacity(0.5), radius: 3, y: 1)
                .padding(.vertical, w * 0.014)
        }
    }
}

#Preview {
    ProUnlockView(reason: .proChallenges)
}
