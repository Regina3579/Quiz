//
//  ProPlansView.swift
//  QuizApp
//
//  Choosing a plan: what Pro gives, what the two subscriptions cost, and the
//  button that buys one. Reached from "Unlock Pro" on the page that explains
//  what Pro is, so this screen can get straight to the prices.
//
//  The header is one painted picture — the girl, the owl, the crown, the sign
//  and the banner — because none of its wording changes. Everything below it
//  is drawn, because all of it does: the prices come from the App Store in
//  the buyer's own currency, and the counts come from the app's own data so
//  the page cannot promise more than is there.
//
//  What this screen will NOT do is take money it cannot take. Until the
//  subscriptions exist in App Store Connect the button says so instead of
//  handing out Pro. See ProStore for what is left to set up.
//

import SwiftUI
import UIKit

struct ProPlansView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var store = ProStore()

    // MARK: - Painted pieces

    private enum Art {
        static let background = "ProPlansBG"
        static let header     = "ProPlansHeader"
        static let bestValue  = "ProPlanBestValue"

        static func has(_ name: String) -> Bool { UIImage(named: name) != nil }
    }

    private static let ink      = Color(red: 0.13, green: 0.10, blue: 0.40)
    private static let inkSoft  = Color(red: 0.33, green: 0.33, blue: 0.55)
    private static let cardBlue = Color(red: 0.90, green: 0.96, blue: 1.00)
    private static let pickPurp = Color(red: 0.42, green: 0.35, blue: 0.93)
    private static let gold     = Color(red: 1.00, green: 0.82, blue: 0.30)
    private static let cream    = Color(red: 1.00, green: 0.96, blue: 0.82)
    private static let magenta  = Color(red: 0.92, green: 0.15, blue: 0.62)

    /// One of the four things Pro gives, as the mockup lays them out.
    private struct Perk {
        let icon: String
        let title: String
        let detail: String
    }

    private var perks: [Perk] {
        [Perk(icon: "ProPlanTrophy",
              title: "All \(ProMode.proModes.count)\nPro Challenges",
              detail: "Timed, Lightning, Perfect Run, Gems Rush & more!"),
         Perk(icon: "ProPlanStickers",
              title: "All \(StickerCatalog.all.count)\nStickers",
              detail: "Plus all \(StickerBookPages.total) sticker book pages to fill!"),
         Perk(icon: "ProPlanChest",
              title: "Extra\nRewards",
              detail: "More gems from every Pro round you play!"),
         Perk(icon: "ProPlanGlobe",
              title: "New Content\nFirst",
              detail: "Be the first to play new adventures and updates!")]
    }

    // MARK: - Body

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width

            ZStack(alignment: .topTrailing) {
                backdrop

                ScrollView(showsIndicators: false) {
                    VStack(spacing: w * 0.024) {
                        header(w)
                        perkRow(w)
                        planRow(w, .monthly)
                        planRow(w, .yearly)
                        buyButton(w)
                        trustRow(w)
                        links(w)
                        Text("Same curious mind. A brighter tomorrow! 💗")
                            .font(.system(size: w * 0.034, weight: .semibold, design: .rounded))
                            .foregroundColor(.white.opacity(0.85))
                    }
                    .padding(.horizontal, w * 0.028)
                    .padding(.bottom, w * 0.06)
                }

                closeButton(w)
            }
        }
        .task {
            await store.load()
            await store.refreshEntitlements()
        }
        .alert("QuizSpark Pro",
               isPresented: Binding(get: { store.notice != nil },
                                    set: { if !$0 { store.notice = nil } })) {
            Button("OK", role: .cancel) { store.notice = nil }
        } message: {
            Text(store.notice ?? "")
        }
        .onChange(of: store.unlocked) { active in
            // The moment the App Store confirms this account has Pro, the
            // job of this screen is done.
            if active { dismiss() }
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
            LinearGradient(colors: [Color(red: 0.24, green: 0.16, blue: 0.48),
                                    Color(red: 0.16, green: 0.11, blue: 0.36)],
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
        }
    }

    @ViewBuilder
    private func header(_ w: CGFloat) -> some View {
        if Art.has(Art.header) {
            Image(Art.header).resizable().scaledToFit()
        } else {
            Text("Unlock Pro")
                .font(.system(size: w * 0.11, weight: .black, design: .rounded))
                .foregroundColor(Self.gold)
                .padding(.vertical, w * 0.08)
        }
    }

    private func closeButton(_ w: CGFloat) -> some View {
        Button {
            Haptics.play(.light)
            dismiss()
        } label: {
            Image(systemName: "xmark")
                .font(.system(size: w * 0.045, weight: .black))
                .foregroundColor(.white)
                .frame(width: w * 0.105, height: w * 0.105)
                .background(Circle().fill(.black.opacity(0.35)))
                .overlay(Circle().strokeBorder(.white.opacity(0.75), lineWidth: 2))
        }
        .buttonStyle(PressableButtonStyle())
        .padding(.trailing, w * 0.035)
        .padding(.top, w * 0.02)
    }

    // MARK: - The four perks

    private func perkRow(_ w: CGFloat) -> some View {
        HStack(alignment: .top, spacing: w * 0.016) {
            ForEach(0..<perks.count, id: \.self) { i in
                perkCard(w, perks[i])
            }
        }
    }

    private func perkCard(_ w: CGFloat, _ p: Perk) -> some View {
        VStack(spacing: w * 0.012) {
            Group {
                if Art.has(p.icon) {
                    Image(p.icon).resizable().scaledToFit()
                } else {
                    Color.clear
                }
            }
            .frame(height: w * 0.095)

            Text(p.title)
                .font(.system(size: w * 0.034, weight: .black, design: .rounded))
                .foregroundColor(Self.ink)
                .lineLimit(2)
                .minimumScaleFactor(0.6)

            Text(p.detail)
                .font(.system(size: w * 0.026, weight: .semibold, design: .rounded))
                .foregroundColor(Color(red: 0.16, green: 0.30, blue: 0.62))
                .lineLimit(4)
                .minimumScaleFactor(0.7)
                .fixedSize(horizontal: false, vertical: true)
        }
        .multilineTextAlignment(.center)
        .padding(.vertical, w * 0.020)
        .padding(.horizontal, w * 0.010)
        .frame(maxWidth: .infinity, alignment: .top)
        .background(
            RoundedRectangle(cornerRadius: w * 0.045, style: .continuous)
                .fill(Self.cardBlue)
        )
        .overlay(
            RoundedRectangle(cornerRadius: w * 0.045, style: .continuous)
                .strokeBorder(.white.opacity(0.85), lineWidth: 2)
        )
        .shadow(color: .black.opacity(0.28), radius: w * 0.02, y: w * 0.008)
    }

    // MARK: - The two plans

    private func planRow(_ w: CGFloat, _ plan: ProStore.Plan) -> some View {
        let picked = store.selected == plan
        let best = plan == .yearly

        return Button {
            Haptics.play(.light)
            store.selected = plan
        } label: {
            HStack(spacing: w * 0.030) {
                tick(w, on: picked)

                VStack(alignment: .leading, spacing: w * 0.004) {
                    Text(plan.title)
                        .font(.system(size: w * 0.058, weight: .black, design: .rounded))
                        .foregroundColor(Self.ink)
                    (Text(store.price(plan))
                        .font(.system(size: w * 0.058, weight: .black, design: .rounded))
                     + Text(" " + plan.period)
                        .font(.system(size: w * 0.046, weight: .bold, design: .rounded)))
                        .foregroundColor(Self.ink)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                    Text(plan.note)
                        .font(.system(size: w * 0.032, weight: .semibold, design: .rounded))
                        .foregroundColor(Self.inkSoft)
                }

                Spacer(minLength: 0)
                sideChip(w, plan)
            }
            .padding(.horizontal, w * 0.032)
            .padding(.vertical, w * 0.028)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: w * 0.055, style: .continuous)
                    .fill(best ? Self.cream : Color.white.opacity(0.97))
            )
            .overlay(
                RoundedRectangle(cornerRadius: w * 0.055, style: .continuous)
                    .strokeBorder(best ? Self.gold : Color.white.opacity(0.9),
                                  lineWidth: best ? w * 0.010 : 2)
            )
            .overlay(alignment: .top) {
                if best, Art.has(Art.bestValue) {
                    Image(Art.bestValue)
                        .resizable()
                        .scaledToFit()
                        .frame(width: w * 0.28)
                        .offset(y: -w * 0.030)
                }
            }
            .shadow(color: .black.opacity(0.30), radius: w * 0.022, y: w * 0.008)
        }
        .buttonStyle(PressableButtonStyle())
        .padding(.top, best ? w * 0.022 : 0)   // room for the badge on top
    }

    private func tick(_ w: CGFloat, on: Bool) -> some View {
        ZStack {
            Circle()
                .fill(on ? AnyShapeStyle(LinearGradient(
                            colors: [Self.pickPurp,
                                     Color(red: 0.30, green: 0.22, blue: 0.85)],
                            startPoint: .top, endPoint: .bottom))
                         : AnyShapeStyle(Color.white))
            Circle().strokeBorder(on ? .clear : Color(red: 0.80, green: 0.80, blue: 0.88),
                                  lineWidth: 2.5)
            if on {
                Image(systemName: "checkmark")
                    .font(.system(size: w * 0.038, weight: .black))
                    .foregroundColor(.white)
            }
        }
        .frame(width: w * 0.078, height: w * 0.078)
    }

    @ViewBuilder
    private func sideChip(_ w: CGFloat, _ plan: ProStore.Plan) -> some View {
        switch plan {
        case .monthly:
            chip(w, fill: Color(red: 0.93, green: 0.92, blue: 1.00), icon: "ProPlanPad") {
                Text("Great\nfor a short\nadventure!")
                    .font(.system(size: w * 0.032, weight: .semibold, design: .rounded))
                    .foregroundColor(Self.ink)
            }
        case .yearly:
            chip(w, fill: Color(red: 1.00, green: 0.98, blue: 0.90), icon: "ProPlanCoins") {
                VStack(alignment: .leading, spacing: w * 0.002) {
                    if let b = store.yearlyBreakdown {
                        Text("That's only\n\(b.perMonth) / month!")
                            .font(.system(size: w * 0.032, weight: .semibold, design: .rounded))
                            .foregroundColor(Self.ink)
                        if b.savedPercent > 0 {
                            Text("Save \(b.savedPercent)%")
                                .font(.system(size: w * 0.036, weight: .black, design: .rounded))
                                .foregroundColor(Self.magenta)
                        }
                    }
                }
            }
        }
    }

    private func chip<V: View>(_ w: CGFloat, fill: Color, icon: String,
                               @ViewBuilder _ words: () -> V) -> some View {
        HStack(spacing: w * 0.016) {
            words()
                .multilineTextAlignment(.leading)
                .lineLimit(3)
                .minimumScaleFactor(0.65)
            if Art.has(icon) {
                Image(icon).resizable().scaledToFit().frame(width: w * 0.078)
            }
        }
        .padding(.horizontal, w * 0.022)
        .padding(.vertical, w * 0.018)
        .background(RoundedRectangle(cornerRadius: w * 0.035, style: .continuous).fill(fill))
        .frame(maxWidth: w * 0.40)
    }

    // MARK: - Buying

    private func buyButton(_ w: CGFloat) -> some View {
        Button {
            Haptics.play(.light)
            Task { await store.buy() }
        } label: {
            HStack(spacing: w * 0.025) {
                Text(store.canPurchase ? "Start Your Pro Adventure"
                                       : "Subscriptions not set up yet")
                    .font(.system(size: w * 0.058, weight: .black, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                Image(systemName: "arrow.right")
                    .font(.system(size: w * 0.052, weight: .black))
            }
            .foregroundColor(.white)
            .shadow(color: .black.opacity(0.35), radius: 1, y: 1.5)
            .frame(maxWidth: .infinity)
            .padding(.vertical, w * 0.038)
            .background(
                Capsule().fill(LinearGradient(
                    colors: store.canPurchase
                        ? [Color(red: 0.54, green: 0.86, blue: 0.20),
                           Color(red: 0.24, green: 0.66, blue: 0.13)]
                        : [Color(red: 0.55, green: 0.55, blue: 0.62),
                           Color(red: 0.36, green: 0.36, blue: 0.44)],
                    startPoint: .top, endPoint: .bottom))
            )
            .overlay(
                Capsule()
                    .fill(LinearGradient(colors: [.white.opacity(0.40), .white.opacity(0.02)],
                                         startPoint: .top, endPoint: .bottom))
                    .padding(.horizontal, w * 0.018)
                    .padding(.top, w * 0.012)
                    .padding(.bottom, w * 0.062)
                    .allowsHitTesting(false)
            )
            .overlay(Capsule().strokeBorder(Self.gold, lineWidth: w * 0.009))
            .shadow(color: (store.canPurchase ? Color.green : .black).opacity(0.5),
                    radius: w * 0.04, y: w * 0.010)
            .opacity(store.working ? 0.6 : 1)
        }
        .buttonStyle(PressableButtonStyle())
        .disabled(store.working || store.loading)
        .padding(.top, w * 0.012)
    }

    private func trustRow(_ w: CGFloat) -> some View {
        HStack(spacing: w * 0.02) {
            trust(w, "🛡️", "Safe & Secure\nPayment")
            trust(w, "💗", "Cancel\nAnytime")
            trust(w, "👨‍👩‍👧", "Loved by\nParents & Kids")
        }
    }

    private func trust(_ w: CGFloat, _ icon: String, _ text: String) -> some View {
        HStack(spacing: w * 0.014) {
            Text(icon).font(.system(size: w * 0.050))
            Text(text)
                .font(.system(size: w * 0.030, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .lineLimit(2)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func links(_ w: CGFloat) -> some View {
        HStack(spacing: w * 0.022) {
            link(w, "Terms of Use")  { openLegal(Legal.terms) }
            Text("|").foregroundColor(.white.opacity(0.5))
            link(w, "Privacy Policy") { openLegal(Legal.privacy) }
            Text("|").foregroundColor(.white.opacity(0.5))
            link(w, "Restore Purchases") { Task { await store.restore() } }
        }
        .font(.system(size: w * 0.034, weight: .semibold, design: .rounded))
    }

    private func link(_ w: CGFloat, _ text: String,
                      action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(text)
                .font(.system(size: w * 0.031, weight: .semibold, design: .rounded))
                .foregroundColor(.white.opacity(0.92))
                .underline()
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
    }

    private func openLegal(_ url: URL?) {
        guard let url else { return }
        UIApplication.shared.open(url)
    }

    /// The two pages the App Store requires a subscription screen to link to.
    /// Point these at the real pages before submitting.
    private enum Legal {
        static let terms   = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")
        static let privacy = URL(string: "https://www.apple.com/legal/privacy/")
    }
}

#Preview {
    ProPlansView()
}
