//
//  ProHubView.swift
//  QuizApp
//
//  The Pro Challenge room. Five harder ways to play, each paying out in
//  jewels so the sticker shop keeps filling up.
//

import SwiftUI

struct ProHubView: View {
    @EnvironmentObject private var progress: GameProgress
    @Environment(\.dismiss) private var dismiss

    /// The mode whose "how to play" card is open, if any.
    @State private var briefing: ProMode?
    @State private var appeared = false

    /// The header artwork is 941 x 485 in the design, and the back button and
    /// jewel pill sit at these fractions of it. Overlaying them here keeps
    /// them live while the rest of the header stays the original picture.
    private let headerAspect: CGFloat = 941.0 / 485.0
    private let backButtonAt = CGPoint(x: 0.080, y: 0.100)
    private let jewelPillAt  = CGPoint(x: 0.869, y: 0.100)

    var body: some View {
        ZStack {
            ProBackground().ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    headerArt
                    cards
                    Image("ProFooterArt")
                        .resizable()
                        .scaledToFit()
                        .padding(.top, 4)
                }
            }
            .ignoresSafeArea(edges: .bottom)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .sheet(item: $briefing) { mode in
            ProBriefingSheet(mode: mode)
                .environmentObject(progress)
        }
        .onAppear { appeared = true }
    }

    // MARK: - Header

    /// The illustrated header, with the two live controls sitting exactly
    /// where the design draws them.
    private var headerArt: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = w / headerAspect

            Image("ProHeaderArt")
                .resizable()
                .scaledToFit()
                .frame(width: w, height: h)
                .overlay(alignment: .topLeading) {
                    backButton
                        .position(x: w * backButtonAt.x, y: h * backButtonAt.y)
                }
                .overlay(alignment: .topLeading) {
                    jewelPill
                        .position(x: w * jewelPillAt.x, y: h * jewelPillAt.y)
                }
        }
        // Reserve the picture's own height so the scroll view lays out right.
        .aspectRatio(headerAspect, contentMode: .fit)
    }

    private var backButton: some View {
        Button {
            Haptics.play(.light)
            dismiss()
        } label: {
            Image(systemName: "chevron.left")
                .font(.system(size: 19, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 42, height: 42)
                .background(Circle().fill(Color(red: 0.36, green: 0.22, blue: 0.62)))
                .overlay(Circle().stroke(Color(red: 0.69, green: 0.55, blue: 0.98),
                                         lineWidth: 2.5))
                .shadow(color: .black.opacity(0.3), radius: 4, y: 2)
        }
        .buttonStyle(PressableButtonStyle())
        .accessibilityLabel("Back")
    }

    private var jewelPill: some View {
        HStack(spacing: 7) {
            JewelIcon(size: 21, sparkle: true)
            Text("\(progress.jewels)")
                .font(Theme.display(21))
                .foregroundColor(.white)
                .contentTransition(.numericText())
        }
        .padding(.horizontal, 14)
        .frame(height: 42)
        .background(Capsule().fill(Color(red: 0.20, green: 0.12, blue: 0.38)))
        .overlay(Capsule().stroke(Color(red: 0.69, green: 0.55, blue: 0.98),
                                  lineWidth: 2.5))
        .shadow(color: .black.opacity(0.3), radius: 4, y: 2)
        .accessibilityLabel("\(progress.jewels) jewels")
    }

    // MARK: - Mode cards

    private var cards: some View {
        VStack(spacing: 8) {
            ForEach(Array(ProMode.proModes.enumerated()), id: \.element) { pair in
                modeCard(pair.element, index: pair.offset)
            }
        }
        .padding(.horizontal, 18)
        .padding(.top, 6)
    }

    /// Each row is the card illustration itself. Everything on it — icon,
    /// title, tagline, jewel total — is fixed for that mode, so the picture
    /// can be used whole. Only a personal best is added on top.
    private func modeCard(_ mode: ProMode, index: Int) -> some View {
        let best = progress.proBest(mode)

        return Button {
            Haptics.play(.light)
            briefing = mode
        } label: {
            Group {
                if let art = mode.cardImageName {
                    Image(art).resizable().scaledToFit()
                } else {
                    Color.clear.frame(height: 1)
                }
            }
            .overlay(alignment: .bottomTrailing) {
                if best > 0 { bestTag(best, of: mode.questionCount) }
            }
        }
        .buttonStyle(PressableButtonStyle())
        .accessibilityLabel("\(mode.title). \(mode.tagline). Up to \(mode.bestPossibleJewels) jewels")
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 18)
        .animation(.spring(response: 0.5, dampingFraction: 0.85)
            .delay(Double(index) * 0.06), value: appeared)
    }

    private func bestTag(_ best: Int, of total: Int) -> some View {
        HStack(spacing: 4) {
            Image(systemName: "rosette").font(.system(size: 10))
            Text("best \(best)/\(total)").font(Theme.bold(11))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(Capsule().fill(.black.opacity(0.34)))
        .overlay(Capsule().stroke(.white.opacity(0.4), lineWidth: 1))
        .padding(.trailing, 52)
        .padding(.bottom, 8)
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
                            weekStrip
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

    /// The Monday-to-Friday line-up, so a child can see that Wednesday is
    /// ocean day and has a reason to come back for it.
    private var weekStrip: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("This week")
                .font(Theme.bold(14))
                .foregroundColor(.white.opacity(0.9))

            HStack(spacing: 6) {
                ForEach(DailyChallenge.weekdaySchedule, id: \.weekday) { entry in
                    dayChip(entry.weekday, entry.island)
                }
                weekendChip
            }
        }
    }

    private func dayChip(_ label: String, _ island: Island) -> some View {
        let isToday = DailyChallenge.island()?.id == island.id
                   && !DailyChallenge.isWeekend()
        return VStack(spacing: 4) {
            Text(label)
                .font(Theme.bold(10))
                .foregroundColor(isToday ? Theme.ink : .white.opacity(0.85))
            Text(island.emoji).font(.system(size: 20))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(RoundedRectangle(cornerRadius: 12, style: .continuous)
            .fill(isToday ? Color.white : Color.white.opacity(0.16)))
    }

    private var weekendChip: some View {
        let isToday = DailyChallenge.isWeekend()
        return VStack(spacing: 4) {
            Text("Sat/Sun")
                .font(Theme.bold(10))
                .foregroundColor(isToday ? Theme.ink : .white.opacity(0.85))
            Text("🎲").font(.system(size: 20))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(RoundedRectangle(cornerRadius: 12, style: .continuous)
            .fill(isToday ? Color.white : Color.white.opacity(0.16)))
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
            // Sampled from the design so the gaps between the card artwork
            // and the page behind them are the same colour.
            LinearGradient(colors: [
                Color(red: 0.20, green: 0.12, blue: 0.45),
                Color(red: 0.18, green: 0.10, blue: 0.47),
                Color(red: 0.13, green: 0.13, blue: 0.34)
            ], startPoint: .top, endPoint: .bottom)
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
