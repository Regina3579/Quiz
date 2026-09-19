//
//  HintPromptView.swift
//  QuizApp
//
//  The "Need a Hint?" card, in place of the system alert.
//
//  A system alert is grey, square, and identical to the one that tells you
//  your storage is full. This is the moment a child decides to spend gems
//  they earned, and it should look like part of the game.
//
//  The card is one painted picture — owl, ribbon, cloud, crystals and both
//  button shells — with only the words drawn live on top of it. The words
//  have to be live because the price changes (10, 20, 25) and so does the
//  title, which is "Need a Hint?" the first time, "Need More Help?" the
//  second, and "50-50 Magic" for the power-up.
//
//  Everything live is placed as a fraction of the artwork rather than in
//  points, so the card can be any width and the text still lands inside the
//  ribbon and the pills. If the picture is ever missing from the bundle the
//  view falls back to the drawn card below, which needs no artwork at all.
//

import SwiftUI
import UIKit

struct HintPromptView: View {
    let title: String
    /// The big line, split so the price can be coloured on its own.
    let leadIn: String
    let price: String
    let tail: String
    /// The smaller line under it, saying what the child actually gets.
    let detail: String
    let confirm: String

    let onConfirm: () -> Void
    let onCancel: () -> Void

    /// The painted card. Everything below is measured against it.
    static let artAsset = "HintCard"

    @State private var appeared = false

    // MARK: - Where the live parts sit on the picture

    /// 912 x 501, the size the artwork was cut to.
    private static let aspect: CGFloat = 1.8204

    private static let titleAt      = CGRect(x: 0.3454, y: 0.0439, width: 0.5132, height: 0.1956)
    private static let bodyAt       = CGRect(x: 0.3596, y: 0.2903, width: 0.5559, height: 0.3353)
    private static let leftBtnAt    = CGRect(x: 0.1349, y: 0.6707, width: 0.3509, height: 0.2275)
    private static let rightBtnAt   = CGRect(x: 0.4912, y: 0.6627, width: 0.4200, height: 0.2415)
    private static let leftLabelAt  = CGRect(x: 0.1656, y: 0.7345, width: 0.2961, height: 0.1198)
    /// Narrower than the pill, because the painted gem keeps the left end.
    private static let rightLabelAt = CGRect(x: 0.6000, y: 0.7345, width: 0.3120, height: 0.1198)

    /// Type sizes as a fraction of the card's width, so the wording stays in
    /// proportion on a small phone and on an iPad alike. They are set so the
    /// longest real wording — "Need More Help?" over the ribbon, "Use 25
    /// Gems" on the pill — still fits without being scaled down.
    private static let titleSize:  CGFloat = 0.076
    private static let priceSize:  CGFloat = 0.040
    private static let detailSize: CGFloat = 0.032
    private static let buttonSize: CGFloat = 0.044

    // The palette, sampled from the artwork so the live words belong to it.
    private static let gold    = Color(red: 1.00, green: 0.84, blue: 0.45)
    private static let goldD   = Color(red: 0.96, green: 0.65, blue: 0.16)
    private static let purpleD = Color(red: 0.35, green: 0.10, blue: 0.52)
    private static let magenta = Color(red: 0.86, green: 0.16, blue: 0.68)
    private static let navy    = Color(red: 0.13, green: 0.12, blue: 0.36)
    private static let cream   = Color(red: 1.00, green: 0.98, blue: 0.91)

    private static var hasArt: Bool { UIImage(named: artAsset) != nil }

    var body: some View {
        ZStack {
            // Tapping away is the same as Not Now — a child who opened this by
            // accident should not have to find the right button.
            Color.black.opacity(0.55)
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture(perform: onCancel)

            Group {
                if Self.hasArt { paintedCard } else { drawnCard }
            }
            .scaleEffect(appeared ? 1 : 0.86)
            .opacity(appeared ? 1 : 0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.38, dampingFraction: 0.72)) {
                appeared = true
            }
        }
    }

    // MARK: - The painted card

    private var paintedCard: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = w / Self.aspect

            Image(Self.artAsset)
                .resizable()
                .scaledToFit()
                .frame(width: w, height: h)
                // The two tap targets go on first and the words on top of
                // them, so a child tapping the middle of "Use 10 Gems" is
                // still tapping the button.
                .overlay(alignment: .topLeading) { buttonTargets(w: w, h: h) }
                .overlay(alignment: .topLeading) {
                    ZStack(alignment: .topLeading) {
                        ribbonTitle(w: w, h: h)
                        bodyText(w: w, h: h)
                        buttonLabels(w: w, h: h)
                    }
                    .allowsHitTesting(false)
                }
        }
        .aspectRatio(Self.aspect, contentMode: .fit)
        // The artwork is 912 pixels wide; letting the card grow past this on
        // an iPad would only soften it.
        .frame(maxWidth: 560)
        .padding(.horizontal, 8)
    }

    /// Places a live part inside the picture, given its rectangle as
    /// fractions of the artwork.
    private func place<V: View>(_ r: CGRect, _ w: CGFloat, _ h: CGFloat,
                                @ViewBuilder _ content: () -> V) -> some View {
        content()
            .frame(width: r.width * w, height: r.height * h)
            .position(x: r.midX * w, y: r.midY * h)
    }

    private func ribbonTitle(w: CGFloat, h: CGFloat) -> some View {
        place(Self.titleAt, w, h) {
            OutlinedText(plain: title,
                         font: .system(size: w * Self.titleSize,
                                       weight: .black, design: .rounded),
                         outline: Self.purpleD,
                         width: max(1.5, w * 0.007)) {
                Text(title).foregroundStyle(
                    LinearGradient(colors: [.white, Self.gold, Self.goldD],
                                   startPoint: .top, endPoint: .bottom))
            }
        }
    }

    private func bodyText(w: CGFloat, h: CGFloat) -> some View {
        place(Self.bodyAt, w, h) {
            VStack(spacing: h * 0.03) {
                // The price is the one thing that must not be skimmed, so it
                // is the one thing in a different colour.
                // Both lines are capped, because the opening they sit in is
                // painted and cannot grow. With a cap, a long sentence scales
                // itself down to fit; without one it would simply spill over
                // the cloud and the buttons.
                (Text(leadIn).foregroundColor(Self.navy)
                 + Text(price).foregroundColor(Self.magenta)
                 + Text(tail).foregroundColor(Self.navy))
                    .font(.system(size: w * Self.priceSize,
                                  weight: .bold, design: .rounded))
                    .lineLimit(1)

                Text(detail)
                    .font(.system(size: w * Self.detailSize,
                                  weight: .semibold, design: .rounded))
                    .foregroundColor(Self.navy.opacity(0.78))
                    .lineLimit(2)
            }
            .multilineTextAlignment(.center)
            .minimumScaleFactor(0.5)
        }
    }

    /// The pills are painted into the picture, so a button here is only the
    /// tappable area sitting exactly on top of one, plus its own press flash.
    private func buttonTargets(w: CGFloat, h: CGFloat) -> some View {
        ZStack(alignment: .topLeading) {
            place(Self.leftBtnAt, w, h) {
                Button(action: onCancel) { Color.clear }
                    .buttonStyle(PillPressStyle(inset: h * 0.02))
            }
            place(Self.rightBtnAt, w, h) {
                Button(action: onConfirm) { Color.clear }
                    .buttonStyle(PillPressStyle(inset: h * 0.02))
            }
        }
    }

    private func buttonLabels(w: CGFloat, h: CGFloat) -> some View {
        ZStack(alignment: .topLeading) {
            place(Self.leftLabelAt, w, h) {
                Text("Not Now")
                    .font(.system(size: w * Self.buttonSize,
                                  weight: .heavy, design: .rounded))
                    .foregroundColor(Self.navy)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            }
            place(Self.rightLabelAt, w, h) {
                OutlinedText(plain: confirm,
                             font: .system(size: w * Self.buttonSize,
                                           weight: .heavy, design: .rounded),
                             outline: Self.purpleD.opacity(0.75),
                             width: max(1, w * 0.004)) {
                    Text(confirm).foregroundColor(.white)
                }
            }
        }
    }

    // MARK: - The drawn card, if the artwork is ever missing

    private var drawnCard: some View {
        VStack(spacing: 13) {
            HStack(spacing: 12) {
                Text("💡")
                    .font(.system(size: 42))
                    .shadow(color: Self.gold.opacity(0.9), radius: 12)

                VStack(spacing: 5) {
                    (Text(leadIn).foregroundColor(Self.navy)
                     + Text(price).foregroundColor(Self.magenta)
                     + Text(tail).foregroundColor(Self.navy))
                        .font(Theme.bold(17))
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.7)

                    Text(detail)
                        .font(Theme.medium(14))
                        .foregroundColor(Self.purpleD)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity)
            }

            HStack(spacing: 10) {
                Button(action: onCancel) {
                    Text("Not Now")
                        .font(Theme.bold(16))
                        .foregroundColor(Self.navy)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                        .background(Capsule().fill(Self.cream))
                        .overlay(Capsule().strokeBorder(Self.goldD, lineWidth: 2.5))
                }
                .buttonStyle(PressableButtonStyle())

                Button(action: onConfirm) {
                    HStack(spacing: 6) {
                        GemIcon(size: 18)
                        Text(confirm)
                            .font(Theme.bold(16))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .background(Capsule().fill(LinearGradient(
                        colors: [Self.magenta, Self.purpleD],
                        startPoint: .top, endPoint: .bottom)))
                    .overlay(Capsule().strokeBorder(Self.gold, lineWidth: 2.5))
                }
                .buttonStyle(PressableButtonStyle())
            }
            .padding(.top, 2)
        }
        .padding(.top, 34)
        .padding(.bottom, 18)
        .padding(.horizontal, 18)
        .background(RoundedRectangle(cornerRadius: 30, style: .continuous).fill(Self.cream))
        .overlay(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .strokeBorder(LinearGradient(colors: [Self.gold, Self.goldD, Self.gold],
                                             startPoint: .topLeading,
                                             endPoint: .bottomTrailing), lineWidth: 4)
        )
        .overlay(alignment: .top) {
            Text(title)
                .font(Theme.display(24))
                .foregroundColor(Self.gold)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .padding(.horizontal, 26)
                .padding(.vertical, 9)
                .background(Capsule().fill(Self.purpleD))
                .overlay(Capsule().strokeBorder(Self.gold, lineWidth: 3))
                .offset(y: -20)
        }
        .shadow(color: .black.opacity(0.45), radius: 18, y: 8)
        .padding(.horizontal, 22)
    }
}

#Preview {
    ZStack {
        Color.green.ignoresSafeArea()
        HintPromptView(title: "Need a Hint?",
                       leadIn: "Use ", price: "10 Gems", tail: " to get a clue!",
                       detail: "We will give you a little clue to point you the right way.",
                       confirm: "Use 10 Gems",
                       onConfirm: {}, onCancel: {})
    }
}
