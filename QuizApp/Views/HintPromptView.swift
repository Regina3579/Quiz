//
//  HintPromptView.swift
//  QuizApp
//
//  The "Need a Hint?" card, in place of the system alert.
//
//  A system alert is grey, square, and identical to the one that tells you
//  your storage is full. This is the moment a child decides to spend gems
//  they earned, and it should look like part of the game — a ribbon, a
//  rounded card, and a button that plainly says what it costs.
//
//  Nothing here is painted artwork, so it works today. If a mascot is ever
//  added to the bundle under `HintPromptView.mascotAsset`, it appears beside
//  the text and nothing else has to change.
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

    /// Optional painted mascot, shown only if it is in the bundle.
    static let mascotAsset = "HintOwl"

    @State private var appeared = false

    // The card's palette, kept here so the ribbon, the border and the
    // confirm button are all lit by the same gold.
    private static let purple  = Color(red: 0.49, green: 0.24, blue: 0.78)
    private static let purpleD = Color(red: 0.34, green: 0.13, blue: 0.60)
    private static let gold    = Color(red: 1.00, green: 0.82, blue: 0.27)
    private static let goldD   = Color(red: 0.85, green: 0.58, blue: 0.10)
    private static let magenta = Color(red: 0.86, green: 0.16, blue: 0.68)
    private static let navy    = Color(red: 0.16, green: 0.13, blue: 0.45)
    private static let cream   = Color(red: 1.00, green: 0.98, blue: 0.91)

    var body: some View {
        ZStack {
            // Tapping away is the same as Not Now — a child who opened this by
            // accident should not have to find the right button.
            Color.black.opacity(0.55)
                .ignoresSafeArea()
                .onTapGesture(perform: onCancel)

            card
                .padding(.horizontal, 22)
                .scaleEffect(appeared ? 1 : 0.86)
                .opacity(appeared ? 1 : 0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.38, dampingFraction: 0.72)) {
                appeared = true
            }
        }
    }

    private var card: some View {
        VStack(spacing: 0) {
            content
                .padding(.top, 34)
                .padding(.bottom, 18)
                .padding(.horizontal, 18)
                .background(
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .fill(Self.cream)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .strokeBorder(LinearGradient(
                            colors: [Self.gold, Self.goldD, Self.gold],
                            startPoint: .topLeading, endPoint: .bottomTrailing),
                            lineWidth: 4)
                )
                .overlay(alignment: .top) { ribbon.offset(y: -20) }
                .shadow(color: .black.opacity(0.45), radius: 18, y: 8)
        }
    }

    /// The purple banner that sits across the top edge.
    private var ribbon: some View {
        Text(title)
            .font(Theme.display(24))
            .foregroundColor(Self.gold)
            .shadow(color: Self.purpleD, radius: 0, x: 0, y: 2)
            .lineLimit(1)
            .minimumScaleFactor(0.6)
            .padding(.horizontal, 26)
            .padding(.vertical, 9)
            .background(
                Capsule().fill(LinearGradient(
                    colors: [Self.purple, Self.purpleD],
                    startPoint: .top, endPoint: .bottom))
            )
            .overlay(Capsule().strokeBorder(Self.gold, lineWidth: 3))
            .shadow(color: .black.opacity(0.35), radius: 6, y: 3)
    }

    private var content: some View {
        VStack(spacing: 13) {
            HStack(spacing: 12) {
                if UIImage(named: Self.mascotAsset) != nil {
                    Image(Self.mascotAsset)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 78, height: 78)
                } else {
                    Text("💡")
                        .font(.system(size: 42))
                        .shadow(color: Self.gold.opacity(0.9), radius: 12)
                }

                VStack(spacing: 5) {
                    // The price is the one thing that must not be skimmed, so
                    // it is the one thing in a different colour.
                    (Text(leadIn).foregroundColor(Self.navy)
                     + Text(price).foregroundColor(Self.magenta)
                     + Text(tail).foregroundColor(Self.navy))
                        .font(Theme.bold(17))
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.7)

                    Text(detail)
                        .font(Theme.medium(14))
                        .foregroundColor(Self.purple)
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
                        colors: [Self.magenta, Self.purple],
                        startPoint: .top, endPoint: .bottom)))
                    .overlay(Capsule().strokeBorder(Self.gold, lineWidth: 2.5))
                    .shadow(color: Self.magenta.opacity(0.5), radius: 7, y: 3)
                }
                .buttonStyle(PressableButtonStyle())
            }
            .padding(.top, 2)
        }
    }
}

#Preview {
    ZStack {
        Color.green.ignoresSafeArea()
        HintPromptView(title: "Need a Hint?",
                       leadIn: "Use ", price: "10 Gems", tail: " to get a clue!",
                       detail: "We will remove 1 wrong answer for you.",
                       confirm: "Use 10 Gems",
                       onConfirm: {}, onCancel: {})
    }
}
