//
//  ProHubView.swift
//  QuizApp
//
//  The Pro Challenge room. Six harder ways to play, each paying out in
//  jewels so the sticker shop keeps filling up.
//

import SwiftUI

struct ProHubView: View {
    @EnvironmentObject private var progress: GameProgress
    @Environment(\.dismiss) private var dismiss

    /// The mode whose "how to play" card is open, if any.
    @State private var briefing: ProMode?
    @State private var appeared = false

    var body: some View {
        ZStack {
            ProBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    header
                    ForEach(Array(ProMode.allCases.enumerated()), id: \.element) { pair in
                        modeCard(pair.element, index: pair.offset)
                    }
                    footer
                }
                .padding(.horizontal, 18)
                .padding(.bottom, 30)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) { backButton }
            ToolbarItem(placement: .topBarTrailing) { jewelPill }
        }
        .sheet(item: $briefing) { mode in
            ProBriefingSheet(mode: mode)
                .environmentObject(progress)
        }
        .onAppear { appeared = true }
    }

    // MARK: - Chrome

    private var backButton: some View {
        Button {
            Haptics.play(.light)
            dismiss()
        } label: {
            Image(systemName: "chevron.left")
                .font(Theme.bold(16))
                .foregroundColor(.white)
                .padding(8)
                .background(Circle().fill(Color.white.opacity(0.22)))
        }
    }

    private var jewelPill: some View {
        HStack(spacing: 6) {
            JewelIcon(size: 18, sparkle: true)
            Text("\(progress.jewels)")
                .font(Theme.bold(16))
                .foregroundColor(.white)
                .contentTransition(.numericText())
        }
        .padding(.horizontal, 12)
        .frame(height: 34)
        .background(Capsule().fill(Color.black.opacity(0.32)))
        .overlay(Capsule().stroke(.white.opacity(0.5), lineWidth: 1))
    }

    private var header: some View {
        VStack(spacing: 8) {
            Text("👑")
                .font(.system(size: 46))
            Text("Pro Challenge")
                .font(Theme.display(32))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.35), radius: 4, y: 2)
            Text("Six harder ways to play — every round pays jewels")
                .font(Theme.medium(14))
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
        }
        .padding(.top, 4)
        .padding(.bottom, 2)
        .opacity(appeared ? 1 : 0)
        .animation(.easeOut(duration: 0.45), value: appeared)
    }

    private var footer: some View {
        HStack(spacing: 8) {
            Image(systemName: "sparkles")
            Text("Spend your jewels in the sticker book")
                .font(Theme.medium(13))
        }
        .foregroundColor(.white.opacity(0.75))
        .padding(.top, 6)
    }

    // MARK: - Mode card

    private func modeCard(_ mode: ProMode, index: Int) -> some View {
        let best = progress.proBest(mode)
        let doneToday = progress.isPlayedToday(mode)

        return Button {
            Haptics.play(.light)
            briefing = mode
        } label: {
            HStack(spacing: 14) {
                Text(mode.emoji)
                    .font(.system(size: 34))
                    .frame(width: 58, height: 58)
                    .background(Circle().fill(.white.opacity(0.25)))
                    .overlay(Circle().stroke(.white.opacity(0.55), lineWidth: 1.5))

                VStack(alignment: .leading, spacing: 4) {
                    Text(mode.title)
                        .font(Theme.bold(19))
                        .foregroundColor(.white)
                    Text(mode.tagline)
                        .font(Theme.medium(13))
                        .foregroundColor(.white.opacity(0.9))
                        .fixedSize(horizontal: false, vertical: true)
                    if mode.isOncePerDay, let today = DailyChallenge.island() {
                        Text("Today: \(today.emoji) \(today.name)")
                            .font(Theme.bold(12))
                            .foregroundColor(.white)
                    }
                    HStack(spacing: 10) {
                        if doneToday { doneTodayTag } else { rewardTag(mode) }
                        if best > 0 { bestTag(best, of: mode.questionCount) }
                    }
                    .padding(.top, 2)
                }

                Spacer(minLength: 0)

                Image(systemName: "chevron.right")
                    .font(Theme.bold(15))
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(mode.palette.gradient)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(.white.opacity(0.35), lineWidth: 1.5)
            )
            .shadow(color: .black.opacity(0.25), radius: 8, y: 5)
            .saturation(doneToday ? 0.45 : 1)
        }
        .buttonStyle(PressableButtonStyle())
        .disabled(doneToday)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 18)
        .animation(.spring(response: 0.5, dampingFraction: 0.85)
            .delay(Double(index) * 0.06), value: appeared)
    }

    private func rewardTag(_ mode: ProMode) -> some View {
        HStack(spacing: 4) {
            JewelIcon(size: 13)
            Text("up to \(mode.bestPossibleJewels)")
                .font(Theme.bold(12))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 9)
        .padding(.vertical, 4)
        .background(Capsule().fill(.black.opacity(0.22)))
    }

    private var doneTodayTag: some View {
        HStack(spacing: 4) {
            Image(systemName: "checkmark.circle.fill").font(.system(size: 11))
            Text("done today")
                .font(Theme.bold(12))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 9)
        .padding(.vertical, 4)
        .background(Capsule().fill(.black.opacity(0.28)))
    }

    private func bestTag(_ best: Int, of total: Int) -> some View {
        HStack(spacing: 4) {
            Image(systemName: "rosette").font(.system(size: 11))
            Text("best \(best)/\(total)")
                .font(Theme.bold(12))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 9)
        .padding(.vertical, 4)
        .background(Capsule().fill(.black.opacity(0.22)))
    }
}

// MARK: - How to play

/// The card that explains a mode before the round begins, and starts it.
private struct ProBriefingSheet: View {
    let mode: ProMode
    @EnvironmentObject private var progress: GameProgress
    @Environment(\.dismiss) private var dismiss

    /// Category Master asks which island to be tested on.
    @State private var chosenIsland: Island?
    @State private var playing = false

    private var islands: [Island] { QuizData.islands }

    var body: some View {
        NavigationStack {
            ZStack {
                mode.palette.gradient.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        Text(mode.emoji).font(.system(size: 60))
                        Text(mode.title)
                            .font(Theme.display(28))
                            .foregroundColor(.white)

                        Text(mode.rules)
                            .font(Theme.medium(15))
                            .foregroundColor(Theme.ink)
                            .lineSpacing(4)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(16)
                            .bubbleCard(cornerRadius: 18, fill: Theme.didYouKnow)

                        if mode.isOncePerDay, let today = DailyChallenge.island() {
                            todaysAdventure(today)
                        }

                        rewardRow

                        if mode.needsCategory { islandPicker }

                        startButton
                    }
                    .padding(20)
                }
            }
            .navigationDestination(isPresented: $playing) {
                ProQuizView(route: ProRoute(mode: mode, islandID: chosenIsland?.id))
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { dismiss() }
                        .font(Theme.bold(15))
                        .foregroundColor(.white)
                }
            }
        }
    }

    private func todaysAdventure(_ island: Island) -> some View {
        HStack(spacing: 10) {
            Text(island.emoji).font(.system(size: 28))
            VStack(alignment: .leading, spacing: 2) {
                Text("Today's adventure")
                    .font(Theme.medium(12))
                    .foregroundColor(.white.opacity(0.85))
                Text(island.name)
                    .font(Theme.bold(17))
                    .foregroundColor(.white)
            }
            Spacer(minLength: 0)
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 18, style: .continuous)
            .fill(.white.opacity(0.18)))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous)
            .stroke(.white.opacity(0.35), lineWidth: 1))
    }

    private var rewardRow: some View {
        HStack(spacing: 10) {
            JewelIcon(size: 24, sparkle: true)
            VStack(alignment: .leading, spacing: 2) {
                Text("Up to \(mode.bestPossibleJewels) jewels")
                    .font(Theme.bold(17))
                    .foregroundColor(.white)
                Text("\(mode.jewelsPerCorrect) per correct answer"
                     + (mode.completionBonus > 0 ? " · \(mode.completionBonus) bonus for a clean sweep" : ""))
                    .font(Theme.medium(12))
                    .foregroundColor(.white.opacity(0.9))
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 18, style: .continuous)
            .fill(.white.opacity(0.18)))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous)
            .stroke(.white.opacity(0.35), lineWidth: 1))
    }

    private var islandPicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Choose your category")
                .font(Theme.bold(16))
                .foregroundColor(.white)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 104), spacing: 10)], spacing: 10) {
                ForEach(islands) { island in
                    islandChip(island)
                }
            }
        }
    }

    private func islandChip(_ island: Island) -> some View {
        let picked = chosenIsland?.id == island.id
        return Button {
            Haptics.play(.light)
            chosenIsland = island
        } label: {
            VStack(spacing: 5) {
                Text(island.emoji).font(.system(size: 24))
                Text(island.name)
                    .font(Theme.bold(11))
                    .foregroundColor(picked ? Theme.ink : .white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(picked ? Color.white : Color.white.opacity(0.18)))
            .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(.white.opacity(picked ? 0 : 0.35), lineWidth: 1))
        }
        .buttonStyle(PressableButtonStyle())
    }

    private var startButton: some View {
        let ready = !mode.needsCategory || chosenIsland != nil

        return Button {
            Haptics.play(.light)
            playing = true
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "play.fill")
                Text(ready ? "Start Challenge" : "Pick a category first")
            }
            .font(Theme.bold(18))
            .foregroundColor(ready ? mode.palette.end : .white.opacity(0.85))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(ready ? AnyShapeStyle(Color.white)
                            : AnyShapeStyle(Color.white.opacity(0.2))))
            .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
        }
        .buttonStyle(PressableButtonStyle())
        .disabled(!ready)
    }
}

// MARK: - Background

/// A deep jewel-toned backdrop with slow drifting sparkles, so the Pro room
/// feels like a different, grander place from the adventure map.
struct ProBackground: View {
    private let sparkles: [Sprite] = {
        var s: [Sprite] = []
        let gold = Color(red: 1.0, green: 0.86, blue: 0.36)
        for i in 0..<26 {
            s.append(Sprite(.dot(i % 3 == 0 ? .white : gold),
                            size: 2 + CGFloat(i % 4) * 2, opacity: 0.9,
                            x: Double((i * 61) % 100) / 100,
                            y: Double((i * 37) % 100) / 100,
                            speed: 0.6 + Double(i % 4) * 0.35,
                            phase: Double(i), motion: .twinkle))
        }
        for i in 0..<5 {
            s.append(Sprite(.symbol("sparkle", gold), size: 13 + CGFloat(i % 3) * 5,
                            opacity: 0.75, x: 0.14 + Double(i) * 0.18,
                            y: 0.2 + Double(i % 3) * 0.22,
                            speed: 0.7 + Double(i) * 0.2, phase: Double(i),
                            amp: 24, motion: .bob))
        }
        return s
    }()

    var body: some View {
        ZStack {
            LinearGradient(colors: [
                Color(red: 0.20, green: 0.12, blue: 0.42),
                Color(red: 0.40, green: 0.17, blue: 0.55),
                Color(red: 0.24, green: 0.16, blue: 0.50)
            ], startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()

            GeometryReader { geo in
                TimelineView(.animation) { timeline in
                    let t = timeline.date.timeIntervalSinceReferenceDate
                    ZStack {
                        ForEach(sparkles) { sprite in
                            sprite.rendered(t: t, size: geo.size)
                        }
                    }
                }
            }
            .ignoresSafeArea()
            .allowsHitTesting(false)
        }
    }
}

#Preview {
    NavigationStack {
        ProHubView().environmentObject(GameProgress())
    }
}
