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
//  is going to have.
//

import SwiftUI

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

        var line: String {
            switch self {
            case .proChallenges:
                return "Six new ways to play every adventure — against the "
                     + "clock, in a lightning round, or without a single "
                     + "mistake."
            case .sticker:
                return "Every sticker on every shelf, to buy with the gems "
                     + "you have already earned."
            }
        }
    }

    let reason: Reason

    private let ink = Color(red: 0.24, green: 0.14, blue: 0.34)

    var body: some View {
        ZStack {
            LinearGradient(colors: [
                Color(red: 0.99, green: 0.95, blue: 0.83),
                Color(red: 0.96, green: 0.88, blue: 0.72)
            ], startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    header
                    included
                    reassurance
                    buttons
                }
                .padding(20)
            }
        }
    }

    private var header: some View {
        VStack(spacing: 8) {
            Text("👑").font(.system(size: 52))

            Text(reason.headline)
                .font(Theme.display(27))
                .foregroundColor(ink)
                .multilineTextAlignment(.center)

            Text(reason.line)
                .font(Theme.medium(15))
                .foregroundColor(ink.opacity(0.75))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.top, 20)
    }

    private var included: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Pro includes")
                .font(Theme.bold(17))
                .foregroundColor(ink)

            row("⚡️", "All six Pro Challenges",
                "Timed, Lightning, Perfect Run, Gem Rush and more")
            row("🎨", "Every sticker unlocked",
                "All ten collections, still bought with gems you earn")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(card)
    }

    /// The part a parent actually wants to read: what they are not losing by
    /// saying no.
    private var reassurance: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Free either way")
                .font(Theme.bold(17))
                .foregroundColor(ink)

            row("🗺️", "All ten adventures",
                "Every level and every question, start to finish")
            row("🏆", "The whole Trophy Room",
                "Every trophy, cup and crown is open to everyone")
            row("📅", "The Daily Challenge",
                "A new one every day, free forever")
            row("⭐️", "Ten stickers to keep",
                "One from each adventure, chosen and bought with gems")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(card)
    }

    private func row(_ icon: String, _ title: String, _ detail: String) -> some View {
        HStack(alignment: .top, spacing: 11) {
            Text(icon).font(.system(size: 20)).frame(width: 26)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(Theme.bold(15))
                    .foregroundColor(ink)
                Text(detail)
                    .font(Theme.medium(12))
                    .foregroundColor(ink.opacity(0.65))
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
    }

    private var buttons: some View {
        VStack(spacing: 11) {
            Button {
                Haptics.play(.success)
                // Grants Pro without charging anything — see Pro.unlock().
                Pro.unlock()
                dismiss()
            } label: {
                Text("Unlock Pro")
                    .font(Theme.bold(18))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(LinearGradient(colors: [Color(red: 0.98, green: 0.71, blue: 0.20),
                                                      Color(red: 0.91, green: 0.45, blue: 0.15)],
                                             startPoint: .top, endPoint: .bottom)))
                    .shadow(color: .black.opacity(0.2), radius: 6, y: 3)
            }
            .buttonStyle(PressableButtonStyle())

            Button {
                Haptics.play(.light)
                dismiss()
            } label: {
                Text("Not now")
                    .font(Theme.bold(15))
                    .foregroundColor(ink.opacity(0.6))
                    .padding(.vertical, 8)
            }
        }
        .padding(.top, 2)
    }

    private var card: some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .fill(.white.opacity(0.7))
            .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color(red: 0.80, green: 0.63, blue: 0.36), lineWidth: 1.5))
    }
}

#Preview {
    ProUnlockView(reason: .proChallenges)
}
