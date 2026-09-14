//
//  RewardChestView.swift
//  QuizApp
//
//  When a round wins something worth having, the result screen doesn't just
//  add the jewels — it puts a treasure chest on the table. The child taps it,
//  the lid flies open, and the prizes come out one after another.
//
//  Awards that carry no prize skip the chest and show as a quiet line instead:
//  a chest every few minutes would stop meaning anything.
//

import SwiftUI

struct RewardChestView: View {
    /// Everything this round won. The chest is for the ones with prizes in.
    let awards: [Achievement]

    @State private var opened = false
    @State private var wobble = false
    @State private var shown = 0

    private var prized: [Achievement] { awards.filter(\.opensChest) }
    private var plain: [Achievement] { awards.filter { !$0.opensChest } }

    private var jewels: Int { prized.reduce(0) { $0 + $1.jewelReward } }
    private var stickers: Int { prized.filter { $0.stickerReward != nil }.count }

    var body: some View {
        VStack(spacing: 12) {
            if prized.isEmpty {
                quietAwards
            } else if opened {
                openChest
            } else {
                closedChest
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 20, style: .continuous)
            .fill(.black.opacity(0.30)))
        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous)
            .stroke(Theme.star.opacity(opened || prized.isEmpty ? 0.55 : 0.85),
                    lineWidth: 2))
        .onAppear {
            guard !prized.isEmpty else { return }
            withAnimation(.easeInOut(duration: 0.7).repeatForever(autoreverses: true)) {
                wobble = true
            }
        }
    }

    // MARK: - Before

    private var closedChest: some View {
        VStack(spacing: 10) {
            Text("🎁 Achievement Chest Unlocked!")
                .font(Theme.display(17))
                .foregroundColor(Theme.star)
                .multilineTextAlignment(.center)

            Text("🧰")
                .font(.system(size: 62))
                .rotationEffect(.degrees(wobble ? 5 : -5))
                .shadow(color: Theme.star.opacity(0.8), radius: 14)

            Text("Tap to open!")
                .font(Theme.bold(14))
                .foregroundColor(.white.opacity(0.85))
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .onTapGesture(perform: open)
        .accessibilityLabel("Achievement chest. Tap to open")
    }

    private func open() {
        Haptics.play(.success)
        Sound.correct()
        withAnimation(.spring(response: 0.45, dampingFraction: 0.6)) { opened = true }
        // The prizes land one after another, so each one gets its moment.
        for step in 1...(prized.count + 2) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.18 * Double(step)) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    shown = step
                }
            }
        }
    }

    // MARK: - After

    private var openChest: some View {
        VStack(spacing: 10) {
            Text("🎉").font(.system(size: 44))

            if jewels > 0 {
                prizeLine(index: 1) {
                    HStack(spacing: 7) {
                        JewelIcon(size: 22)
                        Text("+\(jewels)")
                            .font(Theme.display(24))
                            .foregroundStyle(Theme.jewelPink)
                    }
                }
            }

            if stickers > 0 {
                prizeLine(index: 2) {
                    Text(stickers == 1 ? "+1 rare sticker" : "+\(stickers) rare stickers")
                        .font(Theme.bold(16))
                        .foregroundColor(.white)
                }
            }

            VStack(spacing: 6) {
                ForEach(Array(prized.enumerated()), id: \.element.id) { pair in
                    prizeLine(index: pair.offset + 3) {
                        HStack(spacing: 8) {
                            Text(pair.element.emoji).font(.system(size: 24))
                            Text(pair.element.title)
                                .font(Theme.bold(15))
                                .foregroundColor(.white)
                            Spacer(minLength: 0)
                        }
                    }
                }
            }

            if !plain.isEmpty {
                Divider().overlay(.white.opacity(0.25)).padding(.vertical, 2)
                ForEach(plain) { award in
                    HStack(spacing: 8) {
                        Text(award.emoji).font(.system(size: 20))
                        Text(award.title)
                            .font(Theme.bold(14))
                            .foregroundColor(.white.opacity(0.9))
                        Spacer(minLength: 0)
                    }
                }
            }

            Text("Kept in your Trophy Room")
                .font(Theme.medium(11))
                .foregroundColor(.white.opacity(0.6))
                .padding(.top, 2)
        }
    }

    /// Each prize pops in when its turn comes.
    @ViewBuilder
    private func prizeLine<Content: View>(index: Int,
                                          @ViewBuilder content: () -> Content) -> some View {
        content()
            .frame(maxWidth: .infinity)
            .opacity(shown >= index ? 1 : 0)
            .scaleEffect(shown >= index ? 1 : 0.7)
    }

    // MARK: - No prize, just the award

    private var quietAwards: some View {
        VStack(spacing: 8) {
            Text(awards.count == 1 ? "New award!" : "\(awards.count) new awards!")
                .font(Theme.display(17))
                .foregroundColor(Theme.star)

            ForEach(awards) { award in
                HStack(spacing: 10) {
                    Text(award.emoji).font(.system(size: 24))
                    VStack(alignment: .leading, spacing: 1) {
                        Text(award.title)
                            .font(Theme.bold(15))
                            .foregroundColor(.white)
                        Text(award.detail)
                            .font(Theme.medium(12))
                            .foregroundColor(.white.opacity(0.7))
                            .lineLimit(1)
                    }
                    Spacer(minLength: 0)
                }
            }

            Text("Kept in your Trophy Room")
                .font(Theme.medium(11))
                .foregroundColor(.white.opacity(0.55))
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        RewardChestView(awards: [AchievementCatalog.grandCups[0],
                                 AchievementCatalog.badges[0]])
            .padding()
    }
}
