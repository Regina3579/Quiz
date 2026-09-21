//
//  HomeView.swift
//  QuizApp
//
//  The Adventure Map — the app's home. The painted frame fills the screen:
//  parchment in the middle, jungle around the edges, and the gem purse,
//  Daily Challenge card, Pro crown and sticker book drawn into the corners.
//  The ten islands scroll inside the parchment window.
//
//  The controls are part of the picture, so the code only adds what has to
//  be live: the gem number, the child's name, the tap targets, the sound
//  toggle, and the "done today" state on the Daily card.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var progress: GameProgress
    private let islands = QuizData.islands

    @State private var appeared = false
    @State private var showStickerBook = false
    @State private var showNameEntry = false
    @State private var showTrophyRoom = false
    @State private var showSettings = false
    @State private var showPro = false
    /// The mode whose rules card is open, if any. Only the Timed Challenge
    /// uses it from here — the map's other round, the Daily Challenge, has
    /// no clock to be surprised by and goes straight in.
    @State private var briefing: ProMode?

    /// How far the trail has been pulled up, and how far the finger has moved
    /// since it went down. The two are kept apart so the map can follow a
    /// drag live and then carry the flick on when it lifts.
    @State private var scrollY: CGFloat = 0
    @GestureState private var dragY: CGFloat = 0

    /// Navigation is driven by hand rather than by NavigationLink, because the
    /// map is dragged with a gesture of its own. A link would still fire when
    /// a swipe that began on an island ended there — a real ScrollView cancels
    /// the touches underneath it, and our gesture cannot. A tap gesture fails
    /// as soon as the finger travels, which is exactly the behaviour wanted.
    @State private var path = NavigationPath()
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
    /// The bottom is where the sea, the leaves and the stones actually start
    /// in the columns the islands sit in — measured by walking down each one
    /// rather than by eye, because the paper is shadowed near the tear and
    /// looks like it ends higher than it does.
    private static let window = (x0: 0.115, y0: 0.215, x1: 0.745, y1: 0.828)

    /// The inside of the gem purse, to the right of the painted gem.
    private static let gemNumber = (x: 0.193, y: 0.084, w: 0.150, h: 0.027)
    /// The words inside the cream name chip, left of the painted pencil.
    private static let nameText = (x: 0.491, y: 0.193, w: 0.182, h: 0.024)

    /// Tap targets over the drawn buttons.
    private static let dailyRect = (x0: 0.029, y0: 0.106, x1: 0.294, y1: 0.209)
    private static let proRect   = (x0: 0.752, y0: 0.092, x1: 0.958, y1: 0.166)
    private static let bookRect  = (x0: 0.764, y0: 0.184, x1: 0.969, y1: 0.255)
    /// The sound toggle sits low on the left jungle border, out of the way.
    private static let muteAt   = (x: 0.085, y: 0.930)
    // The right-hand column of buttons, in the order they are stacked:
    // the painted sticker book, then the Timed Challenge, then the Trophy
    // Room. All three are the same width so they read as one set, and the
    // two live ones are spaced to land in the parchment between the book
    // above them and the painted galleon, which sails in at y 0.475.

    /// The Timed Challenge, second in the column. Its artwork is square and
    /// carries its own name and PRO tag, so nothing is drawn over it.
    private static let timedAt = (x: 0.866, y: 0.312)
    private static let timedWidth: CGFloat = 0.195
    private static let timedAspect: CGFloat = 1

    /// The Trophy Room, third. Its artwork is 583 x 600 and carries its own
    /// banner, so the only thing laid over it is the count of awards won.
    private static let trophyAt = (x: 0.866, y: 0.415)
    private static let trophyWidth: CGFloat = 0.195
    private static let trophyAspect: CGFloat = 583.0 / 600.0

    var body: some View {
        NavigationStack(path: $path) {
            GeometryReader { geo in
                let fit = Self.fittedSize(in: geo.size)

                ZStack {
                    surround

                    ZStack(alignment: .topLeading) {
                        mapFrame(width: fit.width, height: fit.height)
                        islandWindow(width: fit.width, height: fit.height)
                        liveGemCount(width: fit.width, height: fit.height)
                        liveName(width: fit.width, height: fit.height)
                        tapTargets(width: fit.width, height: fit.height)
                        settingsButton(width: fit.width, height: fit.height)
                        trophyButton(width: fit.width, height: fit.height)
                        timedButton(width: fit.width, height: fit.height)
                    }
                    .frame(width: fit.width, height: fit.height)
                }
                .frame(width: geo.size.width, height: geo.size.height)
                // The drag lives out here, on the whole screen, rather than on
                // the paper: a child swiping over the jungle border or down by
                // the parrot is still trying to move the map.
                .contentShape(Rectangle())
                .simultaneousGesture(mapDrag(maxScroll: maxScroll(fit: fit)))
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
        .fullScreenCover(isPresented: $showTrophyRoom) {
            TrophyRoomView().environmentObject(progress)
        }
        .sheet(isPresented: $showPro) {
            ProUnlockView(reason: .proChallenges)
        }
        .fullScreenCover(item: $briefing) { mode in
            ProBriefingSheet(mode: mode)
                .environmentObject(progress)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .onAppear {
            appeared = true
            if playerName.isEmpty { showNameEntry = true }
            // One switch used to mute everything; split it in two without
            // losing whatever the family had already chosen.
            AudioSettings.migrateLegacyMute()
            Music.shared.beginWatchingForSpeech()
            // Back on the map, whichever adventure they came from.
            Music.shared.play(Music.mapTrack)
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

        let contentH = trailHeight(windowWidth: ww)
        let limit = max(0, contentH - wh)
        let y = min(0, max(-limit, scrollY + dragY))

        return trail(width: ww)
            .padding(.vertical, Self.trailPad)
            .frame(width: ww, height: contentH, alignment: .top)
            .offset(y: y)
            .frame(width: ww, height: wh, alignment: .top)
            .clipped()
            .contentShape(Rectangle())
            // The paper's own edge is where the trail has to stop, so soften
            // the cut: islands dissolve into the parchment instead of being
            // sliced through, which reads as "the map carries on" rather than
            // "the map ends here".
            .mask(
                LinearGradient(stops: [
                    .init(color: .clear, location: 0),
                    .init(color: .black, location: 0.025),
                    .init(color: .black, location: 0.975),
                    .init(color: .clear, location: 1)
                ], startPoint: .top, endPoint: .bottom)
            )
            .offset(x: x0, y: y0)
    }

    /// Padding above the first island and below the last.
    private static let trailPad: CGFloat = 14
    private static let rowFactor: CGFloat = 0.397
    private static let islandFactor: CGFloat = 0.291

    private func trailHeight(windowWidth ww: CGFloat) -> CGFloat {
        CGFloat(islands.count) * ww * Self.rowFactor + 30 + Self.trailPad * 2
    }

    /// How far up the trail can be pulled before its end reaches the water.
    private func maxScroll(fit: CGSize) -> CGFloat {
        let ww = fit.width * (Self.window.x1 - Self.window.x0)
        let wh = fit.height * (Self.window.y1 - Self.window.y0)
        return max(0, trailHeight(windowWidth: ww) - wh)
    }

    /// Follows the finger while it is down, then carries the flick on and
    /// settles inside the paper. `minimumDistance` is what keeps taps on the
    /// islands and the painted buttons working — a tap never becomes a drag.
    private func mapDrag(maxScroll limit: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 8)
            .updating($dragY) { value, state, _ in
                state = value.translation.height
            }
            .onEnded { value in
                // Take over from the live drag at exactly where the finger
                // left, so nothing jumps as dragY falls back to zero.
                scrollY = min(0, max(-limit, scrollY + value.translation.height))
                let carry = value.predictedEndTranslation.height - value.translation.height
                withAnimation(.easeOut(duration: 0.5)) {
                    scrollY = min(0, max(-limit, scrollY + carry))
                }
            }
    }

    /// The winding line of islands. It is taller than the parchment window,
    /// so it scrolls; the dashed path is drawn in because this artwork leaves
    /// the parchment empty.
    ///
    /// Five islands land whole on the paper, reaching down to the water, with
    /// the sixth breaking into the bottom fade so the trail is plainly still
    /// going. Five rather than six is deliberate: the paper only holds so
    /// much, and a sixth row would cost every island a fifth of its size and
    /// shrink the names with it. At five, the islands are as big as the paper
    /// allows. Rows sit close together, which the zig-zag absorbs — neighbours
    /// are on opposite sides of the paper, so they never actually meet.
    /// Checked at 375x667, 375x812, 393x852 and 430x932.
    private func trail(width: CGFloat) -> some View {
        let count = islands.count
        let rowHeight = width * Self.rowFactor
        let contentHeight = CGFloat(count) * rowHeight + 30
        let diameter = width * Self.islandFactor

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

        IslandBadge(island: island, number: index + 1,
                    unlocked: unlocked, complete: unlocked && complete,
                    earned: unlocked ? earned : 0,
                    maxStars: maxStars, diameter: diameter)
            .contentShape(Rectangle())
            .onTapGesture {
                guard unlocked else { return }
                Haptics.play(.light)
                path.append(island)
            }
            .opacity(appeared ? 1 : 0)
            .scaleEffect(appeared ? 1 : 0.75)
            .animation(.spring(response: 0.5, dampingFraction: 0.7)
                .delay(Double(index) * 0.05), value: appeared)
    }

    // MARK: - The live bits laid over the painted ones

    /// Covers the painted "200" with the real balance.
    private func liveGemCount(width w: CGFloat, height h: CGFloat) -> some View {
        let box = CGSize(width: w * Self.gemNumber.w, height: h * Self.gemNumber.h)

        return Text("\(progress.gems)")
            .font(Theme.display(min(27, box.height * 0.82)))
            .foregroundColor(.white)
            .minimumScaleFactor(0.5)
            .lineLimit(1)
            .contentTransition(.numericText())
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: progress.gems)
            .frame(width: box.width, height: box.height)
            .background(
                // Matched to the inside of the painted purse, so the drawn
                // number underneath is hidden.
                Capsule()
                    .fill(Color(red: 0.290, green: 0.102, blue: 0.022))
                    .blur(radius: 2)
            )
            .position(x: w * Self.gemNumber.x, y: h * Self.gemNumber.y)
            .accessibilityLabel("\(progress.gems) gems")
    }

    /// Covers the painted "Hi, Regi!" with the child's own name. The drawn
    /// pencil to the right stays visible and is part of the tap area.
    private func liveName(width w: CGFloat, height h: CGFloat) -> some View {
        let box = CGSize(width: w * Self.nameText.w, height: h * Self.nameText.h)

        return Text(playerName.isEmpty ? "Hi there!" : "Hi, \(playerName)!")
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
            .onTapGesture {
                Haptics.play(.light)
                showNameEntry = true
            }
            .position(x: w * Self.nameText.x, y: h * Self.nameText.y)
            .accessibilityLabel("Change your name")
    }

    /// Opens the sound settings. This was a single mute button; music and
    /// effects now have a switch each, which is more than one icon can say.
    private func settingsButton(width w: CGFloat, height h: CGFloat) -> some View {
        let side = min(46, w * 0.105)

        return Image(systemName: "slider.horizontal.3")
            .font(.system(size: side * 0.44, weight: .bold))
            .foregroundColor(mapInk)
            .frame(width: side, height: side)
            .background(Circle().fill(Color(red: 0.99, green: 0.94, blue: 0.80)))
            .overlay(Circle().stroke(Color(red: 0.60, green: 0.44, blue: 0.22), lineWidth: 2))
            .shadow(color: .black.opacity(0.35), radius: 4, y: 2)
            .contentShape(Circle())
            .onTapGesture {
                Haptics.play(.light)
                showSettings = true
            }
            .position(x: w * Self.muteAt.x, y: h * Self.muteAt.y)
            .accessibilityLabel("Sound settings")
    }

    /// Opens the Trophy Room, sitting under the painted sticker book. The
    /// artwork carries its own banner, so the only thing laid over it is the
    /// count of awards won — the map shows the child's haul without them
    /// having to go and look.
    private func trophyButton(width w: CGFloat, height h: CGFloat) -> some View {
        let iconW = w * Self.trophyWidth
        let iconH = iconW / Self.trophyAspect
        let won = progress.trophyCount

        return Image("TrophyRoomIcon")
            .resizable()
            .scaledToFit()
            .frame(width: iconW, height: iconH)
            .overlay(alignment: .topTrailing) {
                if won > 0 {
                    Text("\(won)")
                        .font(Theme.bold(iconH * 0.135))
                        .foregroundColor(.white)
                        .padding(.horizontal, iconH * 0.085)
                        .padding(.vertical, iconH * 0.030)
                        .background(Capsule().fill(Color(red: 0.85, green: 0.24, blue: 0.42)))
                        .overlay(Capsule().stroke(.white, lineWidth: 1.5))
                        .shadow(color: .black.opacity(0.35), radius: 2, y: 1)
                        .offset(x: iconH * 0.02, y: iconH * 0.06)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                Haptics.play(.light)
                showTrophyRoom = true
            }
            .position(x: w * Self.trophyAt.x, y: h * Self.trophyAt.y)
            .accessibilityLabel("My trophy room, \(won) award\(won == 1 ? "" : "s") won")
    }

    /// The Timed Challenge, given a button of its own between the sticker
    /// book and the Trophy Room.
    ///
    /// It used to be the first card inside the Pro room, which meant three
    /// taps and a scroll to reach the round people replay most. Here it is
    /// one tap from home.
    ///
    /// The artwork carries its own name and its own gold PRO tag, so nothing
    /// is laid over it — the badge says it is Pro whether or not the family
    /// has subscribed. Without Pro the tap opens the page that explains what
    /// Pro is, exactly as the crown does; the button never simply ignores a
    /// child.
    private func timedButton(width w: CGFloat, height h: CGFloat) -> some View {
        let iconW = w * Self.timedWidth
        let iconH = iconW / Self.timedAspect
        let mode = ProMode.timedChallenge

        return Image("TimedChallengeIcon")
            .resizable()
            .scaledToFit()
            .frame(width: iconW, height: iconH)
            .contentShape(Rectangle())
            .onTapGesture {
                Haptics.play(.light)
                if Pro.isActive { briefing = mode } else { showPro = true }
            }
            .position(x: w * Self.timedAt.x, y: h * Self.timedAt.y)
            .accessibilityLabel(Pro.isActive
                ? "Timed Challenge. \(mode.tagline)"
                : "Timed Challenge. Pro — tap to see what Pro includes")
    }

    // MARK: - Tap targets over the painted buttons
    //
    // These sit over buttons that are part of the background picture, so they
    // have nothing of their own to draw. Every one needs an explicit
    // `contentShape`: SwiftUI does not hit-test fully transparent content, so
    // without it the button is invisible to a finger as well as to the eye.
    //
    // They answer to a tap gesture rather than a Button for the same reason
    // the islands do — a swipe of the map that happens to start here must
    // move the map, not open the page.

    @ViewBuilder
    private func tapTargets(width w: CGFloat, height h: CGFloat) -> some View {
        let daily = ProMode.dailyChallenge
        let doneToday = progress.isPlayedToday(daily)

        // Daily Challenge
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
            .onTapGesture {
                guard !doneToday else { return }
                Haptics.play(.light)
                path.append(ProRoute(mode: daily))
            }
            .frame(width: w * (Self.dailyRect.x1 - Self.dailyRect.x0),
                   height: h * (Self.dailyRect.y1 - Self.dailyRect.y0))
            .position(x: w * (Self.dailyRect.x0 + Self.dailyRect.x1) / 2,
                      y: h * (Self.dailyRect.y0 + Self.dailyRect.y1) / 2)
            .accessibilityLabel(doneToday ? "Daily Challenge, already played today"
                                          : "Play today's Daily Challenge")

        // Pro Challenge — the crown is always tappable. Without Pro it opens
        // the page explaining what is behind it rather than doing nothing,
        // because a button that ignores a child is worse than one that says no.
        Color.clear
            .contentShape(Rectangle())
            .onTapGesture {
                Haptics.play(.light)
                if Pro.isActive {
                    path.append(ProHubRoute())
                } else {
                    showPro = true
                }
            }
            .frame(width: w * (Self.proRect.x1 - Self.proRect.x0),
                   height: h * (Self.proRect.y1 - Self.proRect.y0))
            .position(x: w * (Self.proRect.x0 + Self.proRect.x1) / 2,
                      y: h * (Self.proRect.y0 + Self.proRect.y1) / 2)
            .accessibilityLabel(Pro.isActive ? "Open the Pro Challenge"
                                             : "Pro Challenge. Locked — tap to see what Pro includes")

        // Sticker book
        Color.clear
            .contentShape(Rectangle())
            .onTapGesture {
                Haptics.play(.light)
                showStickerBook = true
            }
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
                    HStack(spacing: diameter * 0.04) {
                        Image(systemName: "star.fill")
                            .font(.system(size: diameter * 0.135))
                            .foregroundColor(Theme.star)
                        Text("\(earned)/\(maxStars)")
                            .font(Theme.bold(diameter * 0.145))
                            .foregroundColor(Theme.ink)
                    }
                    .padding(.horizontal, diameter * 0.10)
                    .padding(.vertical, diameter * 0.04)
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

            // Name on a little parchment banner so it reads on the map. This
            // is the part a child actually has to read, so it gets a generous
            // share of the island rather than whatever is left over.
            Text(island.name)
                .font(Theme.bold(diameter * 0.19))
                .foregroundColor(Color(red: 0.28, green: 0.15, blue: 0.04))
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .padding(.horizontal, diameter * 0.10)
                .padding(.vertical, diameter * 0.04)
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
