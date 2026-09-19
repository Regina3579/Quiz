//
//  ProUnlockView.swift
//  QuizApp
//
//  What Pro is, shown at the moment a child reaches for something behind it.
//
//  Written for the parent holding the phone, not the child tapping it: plain
//  about what is included, plain that the whole game is already open, and with
//  no countdown, no "only today", and nothing dressed up as a prize. A page
//  that pressures a seven-year-old into asking for money is not one this app
//  is going to have. The artwork is bright; the wording is not pushy.
//
//  Built from painted pieces — the castle scene, the crowned owl and its
//  ribbon, the parchment under it, the two section tabs and the six row icons
//  — with the wording drawn live on top. The headline and the line under it
//  change with what the child just reached for, and the list of challenges is
//  counted from ProMode rather than written down, so the page cannot promise
//  a room the app does not have.
//
//  The two buttons are pinned below the scrolling part. There is more here
//  than fits a phone screen, and "Unlock Pro" is not something a parent
//  should have to go looking for.
//

import SwiftUI
import UIKit

struct ProUnlockView: View {
    @Environment(\.dismiss) private var dismiss

    /// What the child just tried to open, so the page opens on that rather
    /// than on a generic pitch.
    enum Reason {
        case proChallenges
        case sticker

        var headline: String {
            switch self {
            case .proChallenges: return "Pro Challenges"
            case .sticker:       return "More Stickers"
            }
        }

        /// The big line on the parchment.
        var lead: String {
            switch self {
            case .proChallenges:
                return "\(ProMode.proModes.count) fun new ways to play every adventure!"
            case .sticker:
                return "Every sticker on every shelf!"
            }
        }

        /// The smaller line under it.
        var detail: String {
            switch self {
            case .proChallenges:
                return "Race the clock, go for the perfect run!"
            case .sticker:
                return "Buy any of them with the gems you earn."
            }
        }
    }

    let reason: Reason

    @State private var showPlans = false

    // MARK: - Painted pieces

    private enum Art {
        static let background = "ProPaywallBG"
        static let crest      = "ProPaywallCrest"
        static let scroll     = "ProPaywallScroll"
        static let tabPro     = "ProPaywallTabPro"
        static let tabFree    = "ProPaywallTabFree"

        /// The ribbon's writing area, as a fraction of the crest picture.
        static let crestTitleAt  = CGRect(x: 0.139, y: 0.609, width: 0.735, height: 0.318)
        /// The parchment's writing area, likewise.
        static let scrollTextAt  = CGRect(x: 0.085, y: 0.190, width: 0.830, height: 0.640)

        static func has(_ name: String) -> Bool { UIImage(named: name) != nil }
    }

    private static let ink     = Color(red: 0.14, green: 0.11, blue: 0.38)
    private static let inkSoft = Color(red: 0.40, green: 0.38, blue: 0.56)
    private static let cream   = Color(red: 0.99, green: 0.96, blue: 0.87)
    private static let goldRim = Color(red: 0.95, green: 0.74, blue: 0.24)

    /// One row of the two lists: a painted icon, a title, a line of detail.
    private struct Row {
        let icon: String
        let title: String
        let detail: String
    }

    private var proRows: [Row] {
        [Row(icon: "ProIconBolt",
             title: "All \(ProMode.proModes.count) Pro Challenges",
             detail: ProMode.proModes.map(\.title).joined(separator: ", ")),
         Row(icon: "ProIconPalette",
             title: "Every sticker unlocked",
             detail: "All \(StickerCatalog.categories.count) collections, still bought with gems you earn")]
    }

    private var freeRows: [Row] {
        [Row(icon: "ProIconMap",
             title: "All \(QuizData.islands.count) adventures",
             detail: "Every level and every question, start to finish"),
         Row(icon: "ProIconTrophy",
             title: "The whole Trophy Room",
             detail: "Every trophy, cup and crown is open to everyone"),
         Row(icon: "ProIconCalendar",
             title: "The Daily Challenge",
             detail: "A new one every day, free forever"),
         Row(icon: "ProIconStar",
             title: "\(StickerCatalog.freeSampleIDs.count) stickers to keep",
             detail: "One from each adventure, chosen and bought with gems")]
    }

    // MARK: - Body

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width

            ZStack(alignment: .bottom) {
                backdrop

                ScrollView(showsIndicators: false) {
                    VStack(spacing: w * 0.030) {
                        crest(w)
                        scroll(w)
                        section(w, tab: Art.tabPro, tabWidth: 0.727,
                                tabAspect: 7.773, rows: proRows)
                        section(w, tab: Art.tabFree, tabWidth: 0.748,
                                tabAspect: 8.186, rows: freeRows)
                    }
                    .padding(.horizontal, w * 0.02)
                    .padding(.top, w * 0.01)
                    // Room for the pinned buttons, so the last row can be
                    // scrolled clear of them.
                    .padding(.bottom, w * 0.40)
                }

                footer(w)
            }
            .fullScreenCover(isPresented: $showPlans) {
                ProPlansView()
            }
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
            LinearGradient(colors: [Color(red: 0.99, green: 0.95, blue: 0.83),
                                    Color(red: 0.96, green: 0.88, blue: 0.72)],
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
        }
    }

    // MARK: - Crowned owl and ribbon

    @ViewBuilder
    private func crest(_ w: CGFloat) -> some View {
        if Art.has(Art.crest) {
            Image(Art.crest)
                .resizable()
                .scaledToFit()
                .overlay(alignment: .topLeading) {
                    GeometryReader { g in
                        OutlinedText(plain: reason.headline,
                                     font: .system(size: w * 0.088,
                                                   weight: .black, design: .rounded),
                                     outline: Color(red: 0.31, green: 0.09, blue: 0.50),
                                     width: max(1.5, w * 0.007)) {
                            Text(reason.headline).foregroundColor(.white)
                        }
                        .placed(in: Art.crestTitleAt, g.size.width, g.size.height)
                    }
                    .allowsHitTesting(false)
                }
                .frame(width: w * 0.97)
        } else {
            Text(reason.headline)
                .font(.system(size: w * 0.088, weight: .black, design: .rounded))
                .foregroundColor(Self.ink)
        }
    }

    // MARK: - Parchment

    @ViewBuilder
    private func scroll(_ w: CGFloat) -> some View {
        let words = VStack(spacing: w * 0.008) {
            Text(reason.lead)
                .font(.system(size: w * 0.043, weight: .black, design: .rounded))
                .foregroundColor(Self.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            Text(reason.detail)
                .font(.system(size: w * 0.033, weight: .semibold, design: .rounded))
                .foregroundColor(Self.ink.opacity(0.85))
                .lineLimit(2)
                .minimumScaleFactor(0.5)
        }
        .multilineTextAlignment(.center)

        if Art.has(Art.scroll) {
            Image(Art.scroll)
                .resizable()
                .scaledToFit()
                .overlay(alignment: .topLeading) {
                    GeometryReader { g in
                        words.placed(in: Art.scrollTextAt, g.size.width, g.size.height)
                    }
                    .allowsHitTesting(false)
                }
                .frame(width: w * 0.98)
                .padding(.top, -w * 0.045)   // the ribbon's tails overlap it
        } else {
            words.padding(.horizontal, w * 0.06)
        }
    }

    // MARK: - A tab and the card under it

    private func section(_ w: CGFloat, tab: String, tabWidth: CGFloat,
                         tabAspect: CGFloat, rows: [Row]) -> some View {
        let tabHeight = w * tabWidth / tabAspect
        // The tab sits astride the card's top edge, so the card starts part
        // of the way down it and the rest of the tab stands above.
        return ZStack(alignment: .top) {
            card(w, rows: rows)
                .padding(.top, tabHeight * 0.55)

            if Art.has(tab) {
                Image(tab)
                    .resizable()
                    .scaledToFit()
                    .frame(width: w * tabWidth)
            }
        }
    }

    private func card(_ w: CGFloat, rows: [Row]) -> some View {
        VStack(spacing: 0) {
            ForEach(0..<rows.count, id: \.self) { i in
                if i > 0 {
                    Rectangle()
                        .fill(Self.goldRim.opacity(0.28))
                        .frame(height: 1)
                        .padding(.horizontal, w * 0.05)
                }
                row(w, rows[i])
            }
        }
        .padding(.top, w * 0.055)
        .padding(.bottom, w * 0.02)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: w * 0.065, style: .continuous)
                .fill(Self.cream)
        )
        .overlay(
            RoundedRectangle(cornerRadius: w * 0.065, style: .continuous)
                .strokeBorder(LinearGradient(
                    colors: [Color(red: 1.00, green: 0.93, blue: 0.62),
                             Self.goldRim,
                             Color(red: 0.85, green: 0.58, blue: 0.14)],
                    startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: w * 0.014)
        )
        .shadow(color: .black.opacity(0.28), radius: w * 0.025, y: w * 0.010)
    }

    private func row(_ w: CGFloat, _ r: Row) -> some View {
        HStack(spacing: w * 0.030) {
            Group {
                if Art.has(r.icon) {
                    Image(r.icon).resizable().scaledToFit()
                } else {
                    Color.clear
                }
            }
            .frame(width: w * 0.115, height: w * 0.115)

            VStack(alignment: .leading, spacing: w * 0.004) {
                Text(r.title)
                    .font(.system(size: w * 0.048, weight: .black, design: .rounded))
                    .foregroundColor(Self.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                Text(r.detail)
                    .font(.system(size: w * 0.032, weight: .semibold, design: .rounded))
                    .foregroundColor(Self.inkSoft)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, w * 0.045)
        .padding(.vertical, w * 0.022)
    }

    // MARK: - The two buttons, kept in view

    private func footer(_ w: CGFloat) -> some View {
        VStack(spacing: w * 0.010) {
            Button {
                Haptics.play(.light)
                // This page explains what Pro is; the prices and the actual
                // purchase live on the next one.
                showPlans = true
            } label: {
                GlossyPill(text: "Unlock Pro", icon: "crown.fill",
                           face: [Color(red: 1.00, green: 0.80, blue: 0.24),
                                  Color(red: 0.92, green: 0.50, blue: 0.08)],
                           width: w, big: true)
            }
            .buttonStyle(PressableButtonStyle())

            Button {
                Haptics.play(.light)
                dismiss()
            } label: {
                Text("Not now")
                    .font(.system(size: w * 0.044, weight: .heavy, design: .rounded))
                    .foregroundColor(.white.opacity(0.92))
                    .shadow(color: .black.opacity(0.55), radius: 3, y: 1)
                    .padding(.vertical, w * 0.020)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, w * 0.055)
        .padding(.bottom, w * 0.02)
        .background(
            LinearGradient(colors: [.black.opacity(0), .black.opacity(0.30),
                                    .black.opacity(0.42)],
                           startPoint: .top, endPoint: .bottom)
                .padding(.top, -w * 0.10)
                .allowsHitTesting(false)
        )
    }
}

#Preview {
    ProUnlockView(reason: .proChallenges)
}
