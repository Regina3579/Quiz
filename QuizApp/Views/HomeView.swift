//
//  HomeView.swift
//  QuizApp
//
//  The Adventure Map — the app's home. Ten islands wind up a dotted trail
//  over a bright ocean. Tap an unlocked island to dive into its levels.
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

    private let rowHeight: CGFloat = 150

    /// Dark sepia ink that reads clearly on the aged-paper map.
    private let mapInk = Color(red: 0.30, green: 0.17, blue: 0.05)

    var body: some View {
        NavigationStack {
            ZStack {
                MapBackground()

                GeometryReader { geo in
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            mapHeader
                                .padding(.horizontal, 20)
                                .padding(.top, 8)
                                .padding(.bottom, 4)

                            trail(width: geo.size.width)
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

    // MARK: - Header

    private var mapHeader: some View {
        VStack(spacing: 6) {
            Text("🗺️ Adventure Map")
                .font(Theme.display(30))
                .foregroundColor(mapInk)
                .shadow(color: .white.opacity(0.5), radius: 3, y: 1)

            if playerName.isEmpty {
                Text("Explore every island on your adventure!")
                    .font(Theme.medium(15))
                    .foregroundColor(mapInk.opacity(0.85))
                    .shadow(color: .white.opacity(0.5), radius: 2, y: 1)
            } else {
                // Tapping the greeting lets the child change their name.
                Button {
                    Haptics.play(.light)
                    showNameEntry = true
                } label: {
                    HStack(spacing: 6) {
                        Text("Hi, \(playerName)!")
                            .font(Theme.bold(16))
                        Image(systemName: "pencil.circle.fill")
                            .font(.system(size: 15))
                    }
                    .foregroundColor(mapInk)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(.white.opacity(0.65)))
                    .overlay(Capsule().stroke(mapInk.opacity(0.25), lineWidth: 1))
                }
                .buttonStyle(PressableButtonStyle())
                .accessibilityLabel("Change your name")
            }
        }
        .frame(maxWidth: .infinity)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : -12)
        .animation(.easeOut(duration: 0.5), value: appeared)
    }

    // MARK: - Right-side controls (mute + sticker book)

    private var rightControls: some View {
        VStack {
            HStack {
                Spacer()
                VStack(spacing: 14) {
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
        VStack {
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
                Spacer()
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 6)
        .accessibilityLabel("\(progress.jewels) jewels")
    }

    // MARK: - Winding trail of islands

    private func trail(width: CGFloat) -> some View {
        let count = islands.count
        let contentHeight = CGFloat(count) * rowHeight + 40

        return ZStack {
            // Dashed path connecting the islands.
            IslandPath(count: count, width: width, rowHeight: rowHeight)
                .stroke(
                    mapInk.opacity(0.55),
                    style: StrokeStyle(lineWidth: 5, lineCap: .round, dash: [2, 16])
                )

            ForEach(Array(islands.enumerated()), id: \.element.id) { pair in
                let index = pair.offset
                let island = pair.element
                let pos = nodePosition(index: index, width: width)
                islandNode(island: island, index: index)
                    .position(x: pos.x, y: pos.y)
            }
        }
        .frame(width: width, height: contentHeight)
    }

    private func nodePosition(index: Int, width: CGFloat) -> CGPoint {
        let x = index.isMultiple(of: 2) ? width * 0.32 : width * 0.68
        let y = CGFloat(index) * rowHeight + rowHeight / 2
        return CGPoint(x: x, y: y)
    }

    @ViewBuilder
    private func islandNode(island: Island, index: Int) -> some View {
        let unlocked = progress.isIslandUnlocked(island: island, allIslands: islands)
        let earned = progress.totalStars(for: island)
        let maxStars = progress.maxStars(for: island)
        let complete = progress.isIslandComplete(island)

        Group {
            if unlocked {
                NavigationLink(value: island) {
                    IslandBadge(island: island, number: index + 1,
                                unlocked: true, complete: complete,
                                earned: earned, maxStars: maxStars)
                }
                .buttonStyle(PressableButtonStyle())
                .simultaneousGesture(TapGesture().onEnded { Haptics.play(.light) })
            } else {
                IslandBadge(island: island, number: index + 1,
                            unlocked: false, complete: false,
                            earned: 0, maxStars: maxStars)
            }
        }
        .opacity(appeared ? 1 : 0)
        .scaleEffect(appeared ? 1 : 0.7)
        .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(Double(index) * 0.06),
                   value: appeared)
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

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                // Artwork if the island has it, otherwise a colored emoji disc.
                if let imageName = island.imageName {
                    Image(imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 96, height: 96)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(.white, lineWidth: 5))
                        .grayscale(unlocked ? 0 : 1)
                        .opacity(unlocked ? 1 : 0.55)
                        .shadow(color: .black.opacity(0.25), radius: 8, y: 5)
                } else {
                    Circle()
                        .fill(unlocked ? AnyShapeStyle(island.palette.gradient)
                                       : AnyShapeStyle(Color.gray.opacity(0.55)))
                        .frame(width: 96, height: 96)
                        .overlay(Circle().stroke(.white, lineWidth: 5))
                        .shadow(color: .black.opacity(0.25), radius: 8, y: 5)
                    if unlocked {
                        Text(island.emoji).font(.system(size: 46))
                    }
                }

                if !unlocked {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 34, weight: .bold))
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
                    .offset(x: -40, y: -34)

                if complete {
                    Text("👑")
                        .font(.system(size: 26))
                        .offset(y: -52)
                }
            }

            VStack(spacing: 4) {
                Text(island.name)
                    .font(Theme.bold(16))
                    .foregroundColor(Color(red: 0.28, green: 0.15, blue: 0.04))
                    .shadow(color: .white.opacity(0.8), radius: 3)
                    .shadow(color: .white.opacity(0.6), radius: 1)

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
        .frame(width: 150)
    }
}

// MARK: - Connecting path shape

/// A dashed zig-zag path linking the island nodes.
private struct IslandPath: Shape {
    let count: Int
    let width: CGFloat
    let rowHeight: CGFloat

    func path(in rect: CGRect) -> Path {
        var p = Path()
        for i in 0..<count {
            let x = i.isMultiple(of: 2) ? width * 0.32 : width * 0.68
            let y = CGFloat(i) * rowHeight + rowHeight / 2
            let pt = CGPoint(x: x, y: y)
            if i == 0 { p.move(to: pt) } else { p.addLine(to: pt) }
        }
        return p
    }
}

// MARK: - Adventure map background

/// The vintage treasure-map parchment fills the whole screen. A soft warm
/// vignette around the edges adds depth and gently frames the island trail,
/// while the aged-paper artwork carries the "adventure" feeling on its own.
private struct MapBackground: View {
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            ZStack {
                // Warm paper tone behind, in case the image doesn't fully cover.
                Color(red: 0.80, green: 0.68, blue: 0.44)

                // The treasure-map parchment, filling the screen.
                Image("BgAdventureMap")
                    .resizable()
                    .scaledToFill()
                    .frame(width: w, height: h)
                    .clipped()

                // Soft warm vignette to add depth around the edges.
                RadialGradient(
                    colors: [.clear, Color(red: 0.28, green: 0.16, blue: 0.05).opacity(0.28)],
                    center: .center, startRadius: h * 0.28, endRadius: h * 0.62)
            }
            .ignoresSafeArea()
        }
        .ignoresSafeArea()
    }
}

#Preview {
    HomeView().environmentObject(GameProgress())
}
