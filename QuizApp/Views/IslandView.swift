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
        GeometryReader { geo in
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    header
                        .padding(.horizontal, 20)
                        .padding(.top, 4)
                        .padding(.bottom, 8)

                    trail(width: geo.size.width)
                }
                // Anchor the trail to the top of the scroll view so level 1 is
                // always the first thing on screen, however tall the device is.
                .frame(maxWidth: .infinity, alignment: .top)
            }
        }
        // A background never influences the size of what it sits behind, so the
        // scenic artwork can't shift the level trail no matter the screen size.
        .background(IslandBackground(island: island))
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
            // (Round island icon intentionally omitted — the scenic
            // background already shows the theme; just show the name.)
            Text(island.name)
                .font(Theme.display(28))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.4), radius: 4, y: 2)
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

    /// The lowest level that is open and not yet cleared — the one to play
    /// next. It is the only badge that wears the ring, so the trail still
    /// points somewhere now that every stop keeps its number.
    private var nextLevel: Int? {
        guard island.authoredLevels > 0 else { return nil }
        return (1...island.authoredLevels).first { n in
            progress.isLevelUnlocked(island: island, level: n,
                                     allIslands: QuizData.islands)
                && progress.stars(islandID: island.id, level: n) == 0
        }
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
                           tint: island.palette.end, isNext: number == nextLevel)
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

/// One stop on the trail.
///
/// The number is always on the face of it. It used to be swapped out for a
/// play arrow on any level not yet cleared, which on a fresh island meant
/// nine stops in a row with no number on them at all — you could not tell
/// level 4 from level 9 without counting down the trail.
///
/// Everything else the badge has to say now lives on a small mark in the
/// corner: a play arrow on the level to do next, a padlock on one not open
/// yet, an hourglass on one not written yet. The invitation the play arrow
/// used to give is carried by the ring instead, which does not cost the
/// number its place.
private struct LevelBadge: View {
    enum State { case playable, locked, comingSoon }

    let number: Int
    let state: State
    let stars: Int
    let tint: Color
    /// The lowest level that is open and not yet cleared: the one to play now.
    var isNext: Bool = false

    @State private var pulse = false

    private var numberColour: Color {
        state == .playable ? tint : .gray.opacity(0.55)
    }

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(.white)
                    .frame(width: 78, height: 78)
                    .shadow(color: .black.opacity(0.2), radius: 6, y: 4)

                Text("\(number)")
                    .font(Theme.display(30))
                    .foregroundColor(numberColour)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            }
            .overlay {
                if isNext {
                    Circle()
                        .strokeBorder(tint, lineWidth: 4)
                        .frame(width: 78, height: 78)
                        .shadow(color: tint.opacity(0.9), radius: pulse ? 10 : 3)
                        .scaleEffect(pulse ? 1.06 : 1)
                }
            }
            .overlay(alignment: .bottomTrailing) { cornerMark }
            .frame(width: 78, height: 78)

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
        .onAppear {
            guard isNext else { return }
            withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(spokenLabel)
    }

    /// The small badge on the rim, saying what this stop is doing.
    @ViewBuilder
    private var cornerMark: some View {
        switch state {
        case .playable where isNext:
            mark("play.fill", tint, .white)
        case .locked:
            mark("lock.fill", .white, .gray)
        case .comingSoon:
            mark("hourglass", .white, .gray.opacity(0.8))
        default:
            EmptyView()
        }
    }

    private func mark(_ symbol: String, _ fill: Color, _ ink: Color) -> some View {
        Image(systemName: symbol)
            .font(.system(size: 12, weight: .black))
            .foregroundColor(ink)
            .frame(width: 26, height: 26)
            .background(Circle().fill(fill))
            .overlay(Circle().strokeBorder(.white.opacity(0.9), lineWidth: 2))
            .shadow(color: .black.opacity(0.3), radius: 3, y: 1)
            .offset(x: 3, y: 3)
    }

    private var spokenLabel: String {
        switch state {
        case .comingSoon: return "Level \(number), coming soon"
        case .locked:     return "Level \(number), locked"
        case .playable:
            if stars > 0 { return "Level \(number), \(stars) of 3 stars" }
            return isNext ? "Level \(number), play next" : "Level \(number), not played yet"
        }
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
