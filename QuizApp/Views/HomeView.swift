//
//  HomeView.swift
//  QuizApp
//
//  The Adventure Map — the app's home. A long painted treasure map scrolls
//  past, with the ten islands dropped onto the circles left for them in the
//  artwork. Tap an unlocked island to dive into its levels.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var progress: GameProgress
    private let islands = QuizData.islands
    @State private var appeared = false
    @State private var showStickerBook = false
    @State private var showNameEntry = false
    @AppStorage(Sound.muteKey) private var isMuted = false
    @AppStorage(Player.nameKey) private var playerName = ""
    @AppStorage("quizspark.pro.visited") private var proVisited = false

    /// The controls float over the map, so the parchment starts below them
    /// or the painted banner ends up behind the Daily badge on the left and
    /// the sticker book on the right. Measured down the left column: top
    /// inset, jewel capsule, gap, the badge itself, and a little room — which
    /// also clears the taller right-hand column.
    private let dailyBadgeWidth: CGFloat = 118
    private var dailyBadgeHeight: CGFloat { dailyBadgeWidth * 219 / 252 }
    private var topAreaHeight: CGFloat { 6 + 44 + 8 + dailyBadgeHeight + 12 }

    /// Dark sepia ink that reads clearly on the aged-paper map.
    private let mapInk = Color(red: 0.30, green: 0.17, blue: 0.05)

    var body: some View {
        NavigationStack {
            ZStack {
                MapBackground()

                GeometryReader { geo in
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            // The painted banner has to clear the floating
                            // controls, so the parchment starts below them.
                            Color.clear.frame(height: topAreaHeight)
                            mapBoard(width: geo.size.width)
                        }
                    }
                }

                jewelBalance
                rightControls
            }
            .navigationDestination(for: Island.self) { island in
                IslandView(island: island)
            }
            .navigationDestination(for: LevelRoute.self) { route in
                QuizView(route: route)
            }
            .navigationDestination(for: ProHubRoute.self) { _ in
                ProHubView()
            }
            // The Daily Challenge is launched straight from the map.
            .navigationDestination(for: ProRoute.self) { route in
                ProQuizView(route: route)
            }
        }
        .fullScreenCover(isPresented: $showStickerBook) {
            StickerBookView().environmentObject(progress)
        }
        .fullScreenCover(isPresented: $showNameEntry) {
            NameEntryView(isEditing: !playerName.isEmpty)
        }
        .onAppear {
            appeared = true
            // Ask for a name the very first time the app is opened.
            if playerName.isEmpty { showNameEntry = true }
        }
    }

    // MARK: - Greeting

    /// The artwork paints its own "Adventure Map" banner, so only the
    /// greeting is drawn — tucked just underneath it.
    @ViewBuilder
    private var greetingChip: some View {
        if playerName.isEmpty {
            Text("Big adventures make brighter minds!")
                .font(Theme.medium(13))
                .foregroundColor(mapInk.opacity(0.9))
                .multilineTextAlignment(.center)
                .shadow(color: .white.opacity(0.6), radius: 2, y: 1)
                .opacity(appeared ? 1 : 0)
                .animation(.easeOut(duration: 0.5), value: appeared)
        } else {
            Button {
                Haptics.play(.light)
                showNameEntry = true
            } label: {
                HStack(spacing: 6) {
                    Text("Hi, \(playerName)!")
                        .font(Theme.bold(16))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    Image(systemName: "pencil.circle.fill")
                        .font(.system(size: 15))
                }
                .foregroundColor(mapInk)
                .padding(.horizontal, 16)
                .padding(.vertical, 7)
                .background(Capsule().fill(.white.opacity(0.82)))
                .overlay(Capsule().stroke(mapInk.opacity(0.3), lineWidth: 1.5))
                .shadow(color: .black.opacity(0.18), radius: 3, y: 2)
            }
            .buttonStyle(PressableButtonStyle())
            .accessibilityLabel("Change your name")
            .opacity(appeared ? 1 : 0)
            .animation(.easeOut(duration: 0.5), value: appeared)
        }
    }

    // MARK: - Daily Challenge (free for everyone)

    /// The Daily Challenge badge, cut from the design and placed where the
    /// design puts it: tucked under the jewel count in the top-left corner.
    /// It is free for every child, so it sits on the map rather than in the
    /// Pro room.
    private var dailyChallengeBadge: some View {
        let mode = ProMode.dailyChallenge
        let doneToday = progress.isPlayedToday(mode)

        return NavigationLink(value: ProRoute(mode: mode)) {
            Image("DailyBadge")
                .resizable()
                .scaledToFit()
                .frame(width: dailyBadgeWidth)
                .saturation(doneToday ? 0.35 : 1)
                .overlay {
                    if doneToday {
                        // A soft veil plus a tick, so it reads as finished
                        // without hiding what it is.
                        ZStack {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(.black.opacity(0.32))
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.4), radius: 3)
                        }
                        .padding(.top, 18)
                    }
                }
        }
        .buttonStyle(PressableButtonStyle())
        .disabled(doneToday)
        .simultaneousGesture(TapGesture().onEnded { Haptics.play(.light) })
        .accessibilityLabel(doneToday
            ? "Daily Challenge, already played today"
            : "Play today's Daily Challenge, 5 questions for up to \(mode.bestPossibleJewels) jewels")
        .opacity(appeared ? 1 : 0)
        .animation(.easeOut(duration: 0.5).delay(0.12), value: appeared)
    }

    // MARK: - Right-side controls (mute + sticker book)

    private var rightControls: some View {
        VStack {
            HStack {
                Spacer()
                VStack(spacing: 14) {
                    // The way in to the Pro Challenge modes.
                    NavigationLink(value: ProHubRoute()) {
                        ProCrownButton(showNew: !proVisited)
                    }
                    .buttonStyle(PressableButtonStyle())
                    .simultaneousGesture(TapGesture().onEnded {
                        Haptics.play(.light)
                        proVisited = true
                    })
                    .accessibilityLabel("Open the Pro Challenge")

                    Button {
                        Haptics.play(.light)
                        isMuted.toggle()
                    } label: {
                        Image(systemName: isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                            .font(Theme.bold(18))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(Circle().fill(Color.black.opacity(0.28)))
                            .overlay(Circle().stroke(.white.opacity(0.5), lineWidth: 1.5))
                            .shadow(color: .black.opacity(0.2), radius: 4, y: 2)
                    }
                    .buttonStyle(PressableButtonStyle())
                    .accessibilityLabel(isMuted ? "Unmute sounds" : "Mute sounds")

                    Button {
                        Haptics.play(.light)
                        showStickerBook = true
                    } label: {
                        StickerBookIcon()
                    }
                    .buttonStyle(PressableButtonStyle())
                    .accessibilityLabel("Open my sticker book")
                }
            }
            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.top, 6)
    }

    // MARK: - Jewel balance (top-left corner)

    private var jewelBalance: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                HStack(spacing: 7) {
                    JewelIcon(size: 22, sparkle: true)
                    Text("\(progress.jewels)")
                        .font(Theme.bold(19))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.55), radius: 2, y: 1)
                        .contentTransition(.numericText())
                        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: progress.jewels)
                }
                .padding(.horizontal, 14)
                .frame(height: 44)
                .background(Capsule().fill(Color.black.opacity(0.42)))
                .overlay(Capsule().stroke(.white.opacity(0.65), lineWidth: 1.5))
                .shadow(color: .black.opacity(0.25), radius: 4, y: 2)
                .accessibilityLabel("\(progress.jewels) jewels")
                Spacer()
            }

            dailyChallengeBadge

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 6)
    }

    // MARK: - The map board

    /// Where each island sits on the artwork, as a fraction of one panel.
    /// Measured from the dashed circles drawn into the two map halves.
    private struct Spot { let x: Double; let y: Double; let lowerHalf: Bool }
    private static let islandSpots: [Spot] = [
        Spot(x: 0.365, y: 0.233, lowerHalf: false),
        Spot(x: 0.676, y: 0.360, lowerHalf: false),
        Spot(x: 0.365, y: 0.481, lowerHalf: false),
        Spot(x: 0.675, y: 0.617, lowerHalf: false),
        Spot(x: 0.369, y: 0.740, lowerHalf: false),
        Spot(x: 0.352, y: 0.134, lowerHalf: true),
        Spot(x: 0.656, y: 0.278, lowerHalf: true),
        Spot(x: 0.352, y: 0.426, lowerHalf: true),
        Spot(x: 0.664, y: 0.573, lowerHalf: true),
        Spot(x: 0.367, y: 0.716, lowerHalf: true)
    ]

    /// Each half of the artwork is 852 x 1846.
    private static let panelRatio: CGFloat = 1846.0 / 852.0

    /// The dashed circles are about 15.5% of the width across; the badge is a
    /// touch larger so it covers the dashes rather than sitting inside them.
    private func islandDiameter(width: CGFloat) -> CGFloat { width * 0.185 }

    private func panelHeight(width: CGFloat) -> CGFloat { width * Self.panelRatio }

    /// The two painted halves stacked into one long map, with the islands
    /// dropped onto the circles left for them.
    private func mapBoard(width: CGFloat) -> some View {
        let panelH = panelHeight(width: width)
        let total = panelH * 2

        return ZStack(alignment: .topLeading) {
            VStack(spacing: 0) {
                Image("BgMapTop").resizable().scaledToFit()
                Image("BgMapBottom").resizable().scaledToFit()
            }
            .frame(width: width, height: total)

            // The greeting sits just under the painted banner.
            greetingChip
                .frame(width: width * 0.62)
                .position(x: width * 0.5, y: panelH * 0.165)

            ForEach(Array(islands.enumerated()), id: \.element.id) { pair in
                let spot = Self.islandSpots[min(pair.offset, Self.islandSpots.count - 1)]
                let y = (spot.lowerHalf ? panelH : 0) + panelH * spot.y
                islandNode(island: pair.element, index: pair.offset,
                           diameter: islandDiameter(width: width))
                    .position(x: width * spot.x, y: y)
            }
        }
        .frame(width: width, height: total)
    }

    @ViewBuilder
    private func islandNode(island: Island, index: Int, diameter: CGFloat) -> some View {
        let unlocked = progress.isIslandUnlocked(island: island, allIslands: islands)
        let earned = progress.totalStars(for: island)
        let maxStars = progress.maxStars(for: island)
        let complete = progress.isIslandComplete(island)

        Group {
            if unlocked {
                NavigationLink(value: island) {
                    IslandBadge(island: island, number: index + 1,
                                unlocked: true, complete: complete,
                                earned: earned, maxStars: maxStars,
                                diameter: diameter)
                }
                .buttonStyle(PressableButtonStyle())
                .simultaneousGesture(TapGesture().onEnded { Haptics.play(.light) })
            } else {
                IslandBadge(island: island, number: index + 1,
                            unlocked: false, complete: false,
                            earned: 0, maxStars: maxStars,
                            diameter: diameter)
            }
        }
        .opacity(appeared ? 1 : 0)
        .scaleEffect(appeared ? 1 : 0.7)
        .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(Double(index) * 0.05),
                   value: appeared)
    }
}

// MARK: - Pro button

/// The way in to the Pro Challenge room: a deep purple medallion with a gold
/// crown, a "Challenges" ribbon beneath it, and a NEW flash until it has been
/// opened once.
private struct ProCrownButton: View {
    /// Drops the NEW flash once the child has visited the Pro room.
    let showNew: Bool

    private var medallion: LinearGradient {
        LinearGradient(colors: [
            Color(red: 0.62, green: 0.32, blue: 0.93),
            Color(red: 0.38, green: 0.16, blue: 0.72)
        ], startPoint: .top, endPoint: .bottom)
    }

    private var gold: LinearGradient {
        LinearGradient(colors: [
            Color(red: 1.00, green: 0.90, blue: 0.48),
            Color(red: 0.96, green: 0.68, blue: 0.14)
        ], startPoint: .top, endPoint: .bottom)
    }

    var body: some View {
        VStack(spacing: -8) {
            ZStack {
                Circle()
                    .fill(medallion)
                    .frame(width: 62, height: 62)
                    .overlay(Circle().stroke(gold, lineWidth: 3))
                    .shadow(color: .black.opacity(0.35), radius: 6, y: 4)

                VStack(spacing: 1) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(gold)
                    Text("PRO")
                        .font(Theme.display(14))
                        .foregroundColor(.white)
                }
            }
            .overlay(alignment: .topTrailing) {
                if showNew {
                    Text("NEW")
                        .font(Theme.bold(9))
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(Color(red: 0.93, green: 0.21, blue: 0.31)))
                        .overlay(Capsule().stroke(.white, lineWidth: 1.2))
                        .offset(x: 10, y: -4)
                }
            }

            // The little ribbon that names what the medallion opens.
            Text("Challenges")
                .font(Theme.bold(11))
                .foregroundColor(Color(red: 0.36, green: 0.20, blue: 0.02))
                .padding(.horizontal, 9)
                .padding(.vertical, 3)
                .background(Capsule().fill(gold))
                .overlay(Capsule().stroke(.white.opacity(0.8), lineWidth: 1))
                .shadow(color: .black.opacity(0.25), radius: 3, y: 2)
        }
        .frame(width: 82)
    }
}

// MARK: - Island badge

private struct IslandBadge: View {
    let island: Island
    let number: Int
    let unlocked: Bool
    let complete: Bool
    let earned: Int
    let maxStars: Int
    /// Matched to the dashed circle painted on the map.
    let diameter: CGFloat

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                // Artwork if the island has it, otherwise a colored emoji disc.
                if let imageName = island.imageName {
                    Image(imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: diameter, height: diameter)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(.white, lineWidth: diameter * 0.055))
                        .grayscale(unlocked ? 0 : 1)
                        .opacity(unlocked ? 1 : 0.55)
                        .shadow(color: .black.opacity(0.25), radius: 8, y: 5)
                } else {
                    Circle()
                        .fill(unlocked ? AnyShapeStyle(island.palette.gradient)
                                       : AnyShapeStyle(Color.gray.opacity(0.55)))
                        .frame(width: diameter, height: diameter)
                        .overlay(Circle().stroke(.white, lineWidth: diameter * 0.055))
                        .shadow(color: .black.opacity(0.25), radius: 8, y: 5)
                    if unlocked {
                        Text(island.emoji).font(.system(size: diameter * 0.48))
                    }
                }

                if !unlocked {
                    Image(systemName: "lock.fill")
                        .font(.system(size: diameter * 0.36, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.5), radius: 3)
                }

                // Little number badge.
                Text("\(number)")
                    .font(Theme.bold(14))
                    .foregroundColor(island.palette.end)
                    .frame(width: 28, height: 28)
                    .background(Circle().fill(.white))
                    .overlay(Circle().stroke(island.palette.end.opacity(0.3), lineWidth: 1))
                    .offset(x: -diameter * 0.42, y: -diameter * 0.36)

                if complete {
                    Text("👑")
                        .font(.system(size: diameter * 0.28))
                        .offset(y: -diameter * 0.56)
                }
            }

            VStack(spacing: 4) {
                // The name sits on a little parchment banner so it stays
                // readable wherever it lands on the map.
                Text(island.name)
                    .font(Theme.bold(15))
                    .foregroundColor(Color(red: 0.28, green: 0.15, blue: 0.04))
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 5)
                    .background(
                        RoundedRectangle(cornerRadius: 7, style: .continuous)
                            .fill(LinearGradient(colors: [
                                Color(red: 0.99, green: 0.94, blue: 0.80),
                                Color(red: 0.94, green: 0.85, blue: 0.65)
                            ], startPoint: .top, endPoint: .bottom))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 7, style: .continuous)
                            .stroke(Color(red: 0.60, green: 0.44, blue: 0.22), lineWidth: 1.5)
                    )
                    .shadow(color: .black.opacity(0.25), radius: 3, y: 2)

                if unlocked {
                    HStack(spacing: 3) {
                        Image(systemName: "star.fill").font(.system(size: 11))
                        Text("\(earned)/\(maxStars)").font(Theme.bold(12))
                    }
                    .foregroundColor(Theme.ink)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(.white))
                } else {
                    Text("Locked")
                        .font(Theme.bold(12))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(Color.black.opacity(0.25)))
                }
            }
        }
        .frame(width: diameter * 1.75)
    }
}

// MARK: - Behind the map

/// The map artwork has a leafy border painted around it, so the page behind
/// it is the same deep jungle green. It only shows in the strip above the
/// parchment, where the floating controls sit.
private struct MapBackground: View {
    var body: some View {
        Color(red: 0.173, green: 0.252, blue: 0.141).ignoresSafeArea()
    }
}

#Preview {
    HomeView().environmentObject(GameProgress())
}
