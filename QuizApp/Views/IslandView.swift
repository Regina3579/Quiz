//
//  IslandView.swift
//  QuizApp
//
//  An island's level map: a winding trail of ten level stops. Cleared
//  levels show their stars, the next one is ready to play, and the rest
//  wait behind a friendly lock.
//

import SwiftUI

struct IslandView: View {
    let island: Island

    @EnvironmentObject private var progress: GameProgress
    @Environment(\.dismiss) private var dismiss

    private let rowHeight: CGFloat = 128

    var body: some View {
        ZStack {
            island.palette.gradient.ignoresSafeArea()

            GeometryReader { geo in
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        header
                            .padding(.horizontal, 20)
                            .padding(.top, 4)
                            .padding(.bottom, 8)

                        trail(width: geo.size.width)
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    Haptics.play(.light)
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(Theme.bold(16))
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Circle().fill(Color.white.opacity(0.25)))
                }
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: 8) {
            Text(island.emoji).font(.system(size: 60))
            Text(island.name)
                .font(Theme.display(28))
                .foregroundColor(.white)
            Text(island.blurb)
                .font(Theme.medium(15))
                .foregroundColor(.white.opacity(0.95))
                .multilineTextAlignment(.center)

            HStack(spacing: 5) {
                Image(systemName: "star.fill")
                Text("\(progress.totalStars(for: island)) / \(progress.maxStars(for: island)) stars")
                    .font(Theme.bold(14))
            }
            .foregroundColor(Theme.star)
            .padding(.horizontal, 14)
            .padding(.vertical, 7)
            .background(Capsule().fill(.white))
            .padding(.top, 2)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Trail of levels

    private func trail(width: CGFloat) -> some View {
        let count = island.totalLevels
        let contentHeight = CGFloat(count) * rowHeight + 40

        return ZStack {
            LevelPath(count: count, width: width, rowHeight: rowHeight)
                .stroke(
                    Color.white.opacity(0.7),
                    style: StrokeStyle(lineWidth: 5, lineCap: .round, dash: [2, 14])
                )

            ForEach(1...count, id: \.self) { number in
                let pos = nodePosition(number: number, width: width)
                levelNode(number: number)
                    .position(x: pos.x, y: pos.y)
            }
        }
        .frame(width: width, height: contentHeight)
    }

    private func nodePosition(number: Int, width: CGFloat) -> CGPoint {
        // number is 1-based; alternate sides.
        let x = (number % 2 == 1) ? width * 0.32 : width * 0.68
        let y = CGFloat(number - 1) * rowHeight + rowHeight / 2
        return CGPoint(x: x, y: y)
    }

    @ViewBuilder
    private func levelNode(number: Int) -> some View {
        let authored = number <= island.authoredLevels
        let unlocked = progress.isLevelUnlocked(island: island, level: number,
                                                allIslands: QuizData.islands)
        let stars = progress.stars(islandID: island.id, level: number)

        if authored && unlocked {
            NavigationLink(value: LevelRoute(islandID: island.id, levelNumber: number)) {
                LevelBadge(number: number, state: .playable, stars: stars,
                           tint: island.palette.end)
            }
            .buttonStyle(PressableButtonStyle())
            .simultaneousGesture(TapGesture().onEnded { Haptics.play(.light) })
        } else if authored {
            LevelBadge(number: number, state: .locked, stars: 0, tint: island.palette.end)
        } else {
            LevelBadge(number: number, state: .comingSoon, stars: 0, tint: island.palette.end)
        }
    }
}

// MARK: - Level badge

private struct LevelBadge: View {
    enum State { case playable, locked, comingSoon }

    let number: Int
    let state: State
    let stars: Int
    let tint: Color

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(.white)
                    .frame(width: 78, height: 78)
                    .shadow(color: .black.opacity(0.2), radius: 6, y: 4)

                switch state {
                case .playable:
                    if stars > 0 {
                        Text("\(number)").font(Theme.display(26)).foregroundColor(tint)
                    } else {
                        // The "next up" level gets a play icon to invite a tap.
                        Image(systemName: "play.fill")
                            .font(.system(size: 26))
                            .foregroundColor(tint)
                    }
                case .locked:
                    Image(systemName: "lock.fill")
                        .font(.system(size: 26)).foregroundColor(.gray)
                case .comingSoon:
                    Image(systemName: "hourglass")
                        .font(.system(size: 24)).foregroundColor(.gray.opacity(0.7))
                }
            }

            // Star row for cleared levels.
            if state == .playable && stars > 0 {
                HStack(spacing: 2) {
                    ForEach(0..<3, id: \.self) { i in
                        Image(systemName: i < stars ? "star.fill" : "star")
                            .font(.system(size: 12))
                            .foregroundColor(i < stars ? Theme.star : .white.opacity(0.6))
                    }
                }
            } else if state == .comingSoon {
                Text("Soon")
                    .font(Theme.bold(11))
                    .foregroundColor(.white.opacity(0.9))
            }
        }
        .frame(width: 110)
    }
}

// MARK: - Trail path shape

private struct LevelPath: Shape {
    let count: Int
    let width: CGFloat
    let rowHeight: CGFloat

    func path(in rect: CGRect) -> Path {
        var p = Path()
        for i in 1...count {
            let x = (i % 2 == 1) ? width * 0.32 : width * 0.68
            let y = CGFloat(i - 1) * rowHeight + rowHeight / 2
            let pt = CGPoint(x: x, y: y)
            if i == 1 { p.move(to: pt) } else { p.addLine(to: pt) }
        }
        return p
    }
}

#Preview {
    NavigationStack {
        IslandView(island: QuizData.jungleKingdom)
            .environmentObject(GameProgress())
    }
}
