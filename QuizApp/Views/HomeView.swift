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
    @AppStorage(Sound.muteKey) private var isMuted = false

    private let rowHeight: CGFloat = 150

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

                muteButton
            }
            .navigationDestination(for: Island.self) { island in
                IslandView(island: island)
            }
            .navigationDestination(for: LevelRoute.self) { route in
                QuizView(route: route)
            }
        }
        .onAppear { appeared = true }
    }

    // MARK: - Header

    private var mapHeader: some View {
        VStack(spacing: 6) {
            Text("🗺️ Adventure Map")
                .font(Theme.display(30))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.25), radius: 4, y: 2)

            Text("Pick an island and start your quest!")
                .font(Theme.medium(15))
                .foregroundColor(.white.opacity(0.95))
                .shadow(color: .black.opacity(0.2), radius: 3, y: 1)
        }
        .frame(maxWidth: .infinity)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : -12)
        .animation(.easeOut(duration: 0.5), value: appeared)
    }

    // MARK: - Mute button (top-right corner)

    private var muteButton: some View {
        VStack {
            HStack {
                Spacer()
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
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 6)
    }

    // MARK: - Winding trail of islands

    private func trail(width: CGFloat) -> some View {
        let count = islands.count
        let contentHeight = CGFloat(count) * rowHeight + 40

        return ZStack {
            // Dashed path connecting the islands.
            IslandPath(count: count, width: width, rowHeight: rowHeight)
                .stroke(
                    Color.white.opacity(0.7),
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
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.25), radius: 3, y: 1)

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

// MARK: - Magical adventure background

/// The hand-painted "floating islands" scene fills the screen, with a light
/// layer of twinkling stars and shimmering sparkles drifting over the sky so
/// the map still feels alive. The painted planets, clouds and scenery are part
/// of the artwork, so nothing is duplicated on top of them.
private struct MapBackground: View {
    @State private var twinkle = false

    // Deterministic pseudo-random in 0...1 so layout is stable each launch.
    private func rnd(_ i: Int, _ salt: Int) -> Double {
        let x = sin(Double(i) * 12.9898 + Double(salt) * 78.233) * 43758.5453
        return x - floor(x)
    }

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            ZStack {
                // The painted adventure-map scene, filling the screen.
                Image("BgAdventureMap")
                    .resizable()
                    .scaledToFill()
                    .frame(width: w, height: h)
                    .clipped()

                // Gentle darkening at the very top so the white title stays readable.
                LinearGradient(
                    colors: [Color.black.opacity(0.28), .clear],
                    startPoint: .top, endPoint: .center)
                    .frame(height: h * 0.5)
                    .frame(maxHeight: .infinity, alignment: .top)

                // Twinkling stars sprinkled across the upper sky.
                ForEach(0..<30, id: \.self) { i in
                    let size = 1.5 + rnd(i, 3) * 3
                    let baseOpacity = 0.25 + rnd(i, 4) * 0.4
                    Circle()
                        .fill(starColor(i))
                        .frame(width: size, height: size)
                        .position(x: rnd(i, 1) * w, y: rnd(i, 2) * h * 0.42)
                        .opacity(twinkle ? baseOpacity + 0.4 : baseOpacity - 0.15)
                        .animation(
                            .easeInOut(duration: 1.2 + rnd(i, 5) * 1.8)
                                .repeatForever(autoreverses: true)
                                .delay(rnd(i, 6) * 2),
                            value: twinkle)
                }

                // A few larger shimmering sparkles high in the sky.
                ForEach(0..<6, id: \.self) { i in
                    Image(systemName: "sparkle")
                        .font(.system(size: 12 + CGFloat(rnd(i, 7) * 16)))
                        .foregroundStyle(.white.opacity(0.85))
                        .position(x: rnd(i, 8) * w, y: rnd(i, 9) * h * 0.38)
                        .opacity(twinkle ? 1 : 0.3)
                        .scaleEffect(twinkle ? 1 : 0.7)
                        .animation(
                            .easeInOut(duration: 1.6 + rnd(i, 10) * 1.2)
                                .repeatForever(autoreverses: true)
                                .delay(rnd(i, 11) * 2),
                            value: twinkle)
                }
            }
            .ignoresSafeArea()
            .onAppear { twinkle = true }
        }
        .ignoresSafeArea()
    }

    /// A mostly-white star with an occasional warm or pink tint for magic.
    private func starColor(_ i: Int) -> Color {
        switch i % 7 {
        case 0: return Color(red: 1.0, green: 0.9, blue: 0.6)   // warm gold
        case 3: return Color(red: 1.0, green: 0.8, blue: 0.9)   // soft pink
        default: return .white
        }
    }
}

#Preview {
    HomeView().environmentObject(GameProgress())
}
