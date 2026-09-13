//
//  HomeView.swift
//  QuizApp
//
//  The Adventure Map — the app's home. The painted frame fills the screen:
//  parchment in the middle, jungle around the edges, and the jewel purse,
//  Daily Challenge card, Pro crown and sticker book drawn into the corners.
//  The ten islands scroll inside the parchment window.
//
//  The controls are part of the picture, so the code only adds what has to
//  be live: the jewel number, the child's name, the tap targets, the sound
//  toggle, and the "done today" state on the Daily card.
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

    /// Dark sepia ink that reads on the aged paper.
    private let mapInk = Color(red: 0.30, green: 0.17, blue: 0.05)
    /// Deep jungle green from the artwork's own edge, for the letterbox bars
    /// on screens that are a different shape from the picture.
    private let surround = Color(red: 0.012, green: 0.165, blue: 0.145)

    // MARK: - Where things sit on the artwork
    //
    // The frame is 851 x 1847. Everything below is a fraction of that, read
    // off the picture itself. The picture is always shown whole (never
    // cropped), so these fractions land the live pieces on the drawn ones at
    // any screen size.

    private static let frameAspect: CGFloat = 851.0 / 1847.0

    /// The empty parchment the islands scroll inside — kept clear of the torn
    /// left edge, the painted galleon on the right, and the parrot at the
    /// bottom.
    private static let window = (x0: 0.115, y0: 0.215, x1: 0.745, y1: 0.803)

    /// The inside of the jewel purse, to the right of the painted gem.
    private static let jewelNumber = (x: 0.193, y: 0.084, w: 0.150, h: 0.027)
    /// The words inside the cream name chip, left of the painted pencil.
    private static let nameText = (x: 0.491, y: 0.193, w: 0.182, h: 0.024)

    /// Tap targets over the drawn buttons.
    private static let dailyRect = (x0: 0.029, y0: 0.106, x1: 0.294, y1: 0.209)
    private static let proRect   = (x0: 0.752, y0: 0.092, x1: 0.958, y1: 0.166)
    private static let bookRect  = (x0: 0.764, y0: 0.184, x1: 0.969, y1: 0.255)
    /// The sound toggle sits low on the jungle border, out of the map's way.
    private static let muteAt    = (x: 0.085, y: 0.930)

    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                let fit = Self.fittedSize(in: geo.size)

                ZStack {
                    surround

                    ZStack(alignment: .topLeading) {
                        mapFrame(width: fit.width, height: fit.height)
                        islandWindow(width: fit.width, height: fit.height)
                        liveJewelCount(width: fit.width, height: fit.height)
                        liveName(width: fit.width, height: fit.height)
                        tapTargets(width: fit.width, height: fit.height)
                        muteToggle(width: fit.width, height: fit.height)
                    }
                    .frame(width: fit.width, height: fit.height)
                }
                .frame(width: geo.size.width, height: geo.size.height)
            }
            .ignoresSafeArea()
            .navigationDestination(for: Island.self) { island in
                IslandView(island: island)
            }
            .navigationDestination(for: LevelRoute.self) { route in
                QuizView(route: route)
            }
            .navigationDestination(for: ProHubRoute.self) { _ in
                ProHubView()
            }
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
            if playerName.isEmpty { showNameEntry = true }
        }
    }

    /// The largest whole copy of the artwork that fits the screen. Showing it
    /// whole — rather than filling and cropping — is what keeps the painted
    /// purse, Daily card, crown and sticker book on screen on a tall phone
    /// and on a squarer iPad alike.
    private static func fittedSize(in size: CGSize) -> CGSize {
        let byWidth = min(size.width, size.height * frameAspect)
        return CGSize(width: byWidth, height: byWidth / frameAspect)
    }

    // MARK: - The painted frame

    private func mapFrame(width w: CGFloat, height h: CGFloat) -> some View {
        Image("BgMapFrame")
            .resizable()
            .scaledToFill()
            .frame(width: w, height: h)
            .clipped()
            .allowsHitTesting(false)
    }

    // MARK: - The islands, scrolling inside the parchment

    private func islandWindow(width w: CGFloat, height h: CGFloat) -> some View {
        let x0 = w * Self.window.x0
        let y0 = h * Self.window.y0
        let ww = w * (Self.window.x1 - Self.window.x0)
        let wh = h * (Self.window.y1 - Self.window.y0)

        return ScrollView(showsIndicators: false) {
            trail(width: ww)
                .padding(.vertical, 14)
        }
        .frame(width: ww, height: wh)
        .offset(x: x0, y: y0)
    }

    /// The winding line of islands. It is taller than the parchment window,
    /// so it scrolls; the dashed path is drawn in because this artwork leaves
    /// the parchment empty.
    ///
    /// The row height is set so four islands land inside the parchment as
    /// soon as the map opens, with the fifth peeking in to invite a scroll.
    private func trail(width: CGFloat) -> some View {
        let count = islands.count
        let rowHeight = width * 0.48
        let contentHeight = CGFloat(count) * rowHeight + 30
        let diameter = width * 0.30

        return ZStack {
            IslandPath(count: count, width: width, rowHeight: rowHeight)
                .stroke(mapInk.opacity(0.45),
                        style: StrokeStyle(lineWidth: 5, lineCap: .round, dash: [2, 15]))

            ForEach(Array(islands.enumerated()), id: \.element.id) { pair in
                let pos = nodePosition(index: pair.offset, width: width, rowHeight: rowHeight)
                islandNode(island: pair.element, index: pair.offset, diameter: diameter)
                    .position(x: pos.x, y: pos.y)
            }
        }
        .frame(width: width, height: contentHeight)
    }

    private func nodePosition(index: Int, width: CGFloat, rowHeight: CGFloat) -> CGPoint {
        CGPoint(x: index.isMultiple(of: 2) ? width * 0.30 : width * 0.70,
                y: CGFloat(index) * rowHeight + rowHeight / 2)
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
                                earned: earned, maxStars: maxStars, diameter: diameter)
                }
                .buttonStyle(PressableButtonStyle())
                .simultaneousGesture(TapGesture().onEnded { Haptics.play(.light) })
            } else {
                IslandBadge(island: island, number: index + 1,
                            unlocked: false, complete: false,
                            earned: 0, maxStars: maxStars, diameter: diameter)
            }
        }
        .opacity(appeared ? 1 : 0)
        .scaleEffect(appeared ? 1 : 0.75)
        .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(Double(index) * 0.05),
                   value: appeared)
    }

    // MARK: - The live bits laid over the painted ones

    /// Covers the painted "200" with the real balance.
    private func liveJewelCount(width w: CGFloat, height h: CGFloat) -> some View {
        let box = CGSize(width: w * Self.jewelNumber.w, height: h * Self.jewelNumber.h)

        return Text("\(progress.jewels)")
            .font(Theme.display(min(27, box.height * 0.82)))
            .foregroundColor(.white)
            .minimumScaleFactor(0.5)
            .lineLimit(1)
            .contentTransition(.numericText())
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: progress.jewels)
            .frame(width: box.width, height: box.height)
            .background(
                // Matched to the inside of the painted purse, so the drawn
                // number underneath is hidden.
                Capsule()
                    .fill(Color(red: 0.290, green: 0.102, blue: 0.022))
                    .blur(radius: 2)
            )
            .position(x: w * Self.jewelNumber.x, y: h * Self.jewelNumber.y)
            .accessibilityLabel("\(progress.jewels) jewels")
    }

    /// Covers the painted "Hi, Regi!" with the child's own name. The drawn
    /// pencil to the right stays visible and is part of the tap area.
    private func liveName(width w: CGFloat, height h: CGFloat) -> some View {
        let box = CGSize(width: w * Self.nameText.w, height: h * Self.nameText.h)

        return Button {
            Haptics.play(.light)
            showNameEntry = true
        } label: {
            Text(playerName.isEmpty ? "Hi there!" : "Hi, \(playerName)!")
                .font(Theme.display(min(23, box.height * 0.86)))
                .foregroundColor(mapInk)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                .frame(width: box.width, height: box.height)
                .background(
                    Rectangle()
                        .fill(Color(red: 0.992, green: 0.980, blue: 0.955))
                        .blur(radius: 1.5)
                )
                // Reaches across to the painted pencil so tapping it works.
                .frame(width: box.width * 1.35, height: box.height * 1.6)
                .contentShape(Rectangle())
        }
        .buttonStyle(PressableButtonStyle())
        .position(x: w * Self.nameText.x, y: h * Self.nameText.y)
        .accessibilityLabel("Change your name")
    }

    private func muteToggle(width w: CGFloat, height h: CGFloat) -> some View {
        let side = min(46, w * 0.105)

        return Button {
            isMuted.toggle()
            Haptics.play(.light)
        } label: {
            Image(systemName: isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                .font(.system(size: side * 0.44, weight: .bold))
                .foregroundColor(mapInk)
                .frame(width: side, height: side)
                .background(Circle().fill(Color(red: 0.99, green: 0.94, blue: 0.80)))
                .overlay(Circle().stroke(Color(red: 0.60, green: 0.44, blue: 0.22), lineWidth: 2))
                .shadow(color: .black.opacity(0.35), radius: 4, y: 2)
        }
        .buttonStyle(PressableButtonStyle())
        .position(x: w * Self.muteAt.x, y: h * Self.muteAt.y)
        .accessibilityLabel(isMuted ? "Unmute sounds" : "Mute sounds")
    }

    // MARK: - Tap targets over the painted buttons
    //
    // These sit over buttons that are part of the background picture, so they
    // have nothing of their own to draw. Every one of them needs an explicit
    // `contentShape`: SwiftUI does not hit-test fully transparent content, so
    // without it the whole button is invisible to a finger as well as to the
    // eye.

    @ViewBuilder
    private func tapTargets(width w: CGFloat, height h: CGFloat) -> some View {
        let daily = ProMode.dailyChallenge
        let doneToday = progress.isPlayedToday(daily)

        // Daily Challenge
        NavigationLink(value: ProRoute(mode: daily)) {
            Color.clear
                .overlay {
                    if doneToday {
                        // Dimmed with a tick, so the card still reads as the
                        // Daily Challenge once today's round is done.
                        ZStack {
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(.black.opacity(0.42))
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: min(34, h * 0.038)))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.5), radius: 3)
                        }
                        .padding(8)
                    }
                }
                .contentShape(Rectangle())
        }
        .buttonStyle(PressableButtonStyle())
        .disabled(doneToday)
        .simultaneousGesture(TapGesture().onEnded { Haptics.play(.light) })
        .frame(width: w * (Self.dailyRect.x1 - Self.dailyRect.x0),
               height: h * (Self.dailyRect.y1 - Self.dailyRect.y0))
        .position(x: w * (Self.dailyRect.x0 + Self.dailyRect.x1) / 2,
                  y: h * (Self.dailyRect.y0 + Self.dailyRect.y1) / 2)
        .accessibilityLabel(doneToday ? "Daily Challenge, already played today"
                                      : "Play today's Daily Challenge")

        // Pro Challenge
        NavigationLink(value: ProHubRoute()) {
            Color.clear.contentShape(Rectangle())
        }
        .buttonStyle(PressableButtonStyle())
        .simultaneousGesture(TapGesture().onEnded { Haptics.play(.light) })
        .frame(width: w * (Self.proRect.x1 - Self.proRect.x0),
               height: h * (Self.proRect.y1 - Self.proRect.y0))
        .position(x: w * (Self.proRect.x0 + Self.proRect.x1) / 2,
                  y: h * (Self.proRect.y0 + Self.proRect.y1) / 2)
        .accessibilityLabel("Open the Pro Challenge")

        // Sticker book
        Button {
            Haptics.play(.light)
            showStickerBook = true
        } label: {
            Color.clear.contentShape(Rectangle())
        }
        .buttonStyle(PressableButtonStyle())
        .frame(width: w * (Self.bookRect.x1 - Self.bookRect.x0),
               height: h * (Self.bookRect.y1 - Self.bookRect.y0))
        .position(x: w * (Self.bookRect.x0 + Self.bookRect.x1) / 2,
                  y: h * (Self.bookRect.y0 + Self.bookRect.y1) / 2)
        .accessibilityLabel("Open my sticker book")
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
    let diameter: CGFloat

    var body: some View {
        VStack(spacing: diameter * 0.06) {
            ZStack {
                if let imageName = island.imageName {
                    Image(imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: diameter, height: diameter)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(.white, lineWidth: diameter * 0.055))
                        .grayscale(unlocked ? 0 : 1)
                        .opacity(unlocked ? 1 : 0.55)
                        .shadow(color: .black.opacity(0.3), radius: 7, y: 4)
                } else {
                    Circle()
                        .fill(unlocked ? AnyShapeStyle(island.palette.gradient)
                                       : AnyShapeStyle(Color.gray.opacity(0.55)))
                        .frame(width: diameter, height: diameter)
                        .overlay(Circle().stroke(.white, lineWidth: diameter * 0.055))
                        .shadow(color: .black.opacity(0.3), radius: 7, y: 4)
                    if unlocked {
                        Text(island.emoji).font(.system(size: diameter * 0.48))
                    }
                }

                if !unlocked {
                    Image(systemName: "lock.fill")
                        .font(.system(size: diameter * 0.34, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.5), radius: 3)
                }

                Text("\(number)")
                    .font(Theme.bold(diameter * 0.17))
                    .foregroundColor(island.palette.end)
                    .frame(width: diameter * 0.30, height: diameter * 0.30)
                    .background(Circle().fill(.white))
                    .overlay(Circle().stroke(island.palette.end.opacity(0.3), lineWidth: 1))
                    .offset(x: -diameter * 0.40, y: -diameter * 0.36)

                // The star count rides on the island's rim rather than sitting
                // in a row of its own, so more of the map fits on screen.
                if unlocked {
                    HStack(spacing: diameter * 0.035) {
                        Image(systemName: "star.fill")
                            .font(.system(size: diameter * 0.115))
                            .foregroundColor(Theme.star)
                        Text("\(earned)/\(maxStars)")
                            .font(Theme.bold(diameter * 0.125))
                            .foregroundColor(Theme.ink)
                    }
                    .padding(.horizontal, diameter * 0.10)
                    .padding(.vertical, diameter * 0.045)
                    .background(Capsule().fill(.white))
                    .overlay(Capsule().stroke(Color(red: 0.60, green: 0.44, blue: 0.22),
                                              lineWidth: 1))
                    .shadow(color: .black.opacity(0.25), radius: 2, y: 1)
                    .offset(x: diameter * 0.31, y: diameter * 0.35)
                }

                if complete {
                    Text("👑")
                        .font(.system(size: diameter * 0.26))
                        .offset(y: -diameter * 0.54)
                }
            }

            // Name on a little parchment banner so it reads on the map.
            Text(island.name)
                .font(Theme.bold(diameter * 0.16))
                .foregroundColor(Color(red: 0.28, green: 0.15, blue: 0.04))
                .lineLimit(1)
                .minimumScaleFactor(0.65)
                .padding(.horizontal, diameter * 0.10)
                .padding(.vertical, diameter * 0.05)
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
        }
        .frame(width: diameter * 1.62)
    }
}

// MARK: - Connecting path shape

/// The dashed zig-zag linking the islands.
private struct IslandPath: Shape {
    let count: Int
    let width: CGFloat
    let rowHeight: CGFloat

    func path(in rect: CGRect) -> Path {
        var p = Path()
        for i in 0..<count {
            let pt = CGPoint(x: i.isMultiple(of: 2) ? width * 0.30 : width * 0.70,
                             y: CGFloat(i) * rowHeight + rowHeight / 2)
            if i == 0 { p.move(to: pt) } else { p.addLine(to: pt) }
        }
        return p
    }
}

#Preview {
    HomeView().environmentObject(GameProgress())
}
