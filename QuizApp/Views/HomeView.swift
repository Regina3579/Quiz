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

// MARK: - Ocean/adventure background

private struct MapBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.40, green: 0.78, blue: 0.92),
                    Color(red: 0.30, green: 0.62, blue: 0.85),
                    Color(red: 0.24, green: 0.52, blue: 0.80)
                ],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            // Playful floating decorations.
            Group {
                Text("☁️").font(.system(size: 54)).offset(x: -120, y: -320)
                Text("☁️").font(.system(size: 40)).offset(x: 130, y: -250)
                Text("🌴").font(.system(size: 44)).offset(x: 140, y: 30)
                Text("⛵️").font(.system(size: 40)).offset(x: -130, y: 160)
                Text("🐚").font(.system(size: 30)).offset(x: 120, y: 330)
                Text("🌊").font(.system(size: 36)).offset(x: -140, y: -60)
            }
            .opacity(0.55)
        }
    }
}

#Preview {
    HomeView().environmentObject(GameProgress())
}
