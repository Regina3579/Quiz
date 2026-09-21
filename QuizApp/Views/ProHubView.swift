//
//  ProHubView.swift
//  QuizApp
//
//  The Pro Challenge room: four harder ways to play, each paying out in gems
//  so the sticker shop keeps filling up.
//
//  The page is one painted scene — jungle, header, four cards, lanterns and
//  the bridge at the foot — with the wording that has to follow the data laid
//  over it at fractions of the picture. Everything fixed stays part of the
//  painting; everything that could ever differ from what the app knows is
//  live. That is why the taglines and the "up to N gems" payouts are drawn
//  here rather than lettered into the artwork.
//
//  The Timed Challenge is Pro too, but it is not one of these four: it has a
//  button of its own on the adventure map, under the Trophy Room. The room
//  shows `hubModes` rather than `proModes` for exactly that reason.
//
//  The scene paints four cards in a fixed order, so each slot below names the
//  mode it was painted for instead of being matched up by position. A mode
//  leaving `hubModes` then leaves a painted card with nothing behind it,
//  which `slots` filters out, rather than silently relabelling somebody
//  else's picture.
//
//  Three of the four titles are painted. The fourth, whose picture letters
//  "Jewel Rush" where the mode is Gems Rush, has its title lifted off and
//  drawn from mode.title instead.
//

import SwiftUI

struct ProHubView: View {
    @EnvironmentObject private var progress: GameProgress
    @Environment(\.dismiss) private var dismiss

    /// The mode whose "how to play" card is open, if any.
    @State private var briefing: ProMode?

    // MARK: - Where everything sits on the painting
    //
    // The scene is 941 x 1672. Every rectangle below is a fraction of that,
    // measured off the picture itself, so the live pieces land on the painted
    // ones at any width.

    private static let sceneAspect: CGFloat = 941.0 / 1672.0

    /// Deep jungle green from the painting's own edge, for the bars above and
    /// below it on a screen that is a different shape.
    private static let surround = Color(red: 0.035, green: 0.149, blue: 0.145)

    /// Type sizes, as fractions of the picture's width. Each is the largest
    /// that the longest string of its kind still fits, so every card letters
    /// at the same size as its neighbours.
    private static let taglineSize: CGFloat = 0.0215
    private static let payoutSize:  CGFloat = 0.0270
    private static let titleSize:   CGFloat = 0.0730

    private static let backAt   = CGRect(x: 0.022, y: 0.010, width: 0.100, height: 0.050)
    private static let gemsAt   = CGRect(x: 0.800, y: 0.011, width: 0.098, height: 0.033)

    /// One painted card: the mode it shows, the whole card as a tap target,
    /// the parchment plaque, and the dark payout capsule beside the gem.
    private struct Slot {
        let mode: ProMode
        let card: CGRect
        let tagline: CGRect
        let payout: CGRect
        /// Set only on a card whose painted title had to come off, and
        /// which therefore has its name drawn instead.
        var title: CGRect? = nil
    }

    private static let allSlots: [Slot] = [
        Slot(mode: .lightningRound,
             card:    CGRect(x: 0.027, y: 0.264, width: 0.470, height: 0.258),
             tagline: CGRect(x: 0.054, y: 0.417, width: 0.193, height: 0.047),
             payout:  CGRect(x: 0.128, y: 0.477, width: 0.198, height: 0.034)),
        Slot(mode: .perfectRun,
             card:    CGRect(x: 0.503, y: 0.264, width: 0.470, height: 0.258),
             tagline: CGRect(x: 0.550, y: 0.417, width: 0.190, height: 0.047),
             payout:  CGRect(x: 0.628, y: 0.474, width: 0.202, height: 0.037)),
        Slot(mode: .gemRush,
             card:    CGRect(x: 0.027, y: 0.545, width: 0.470, height: 0.258),
             tagline: CGRect(x: 0.054, y: 0.711, width: 0.202, height: 0.049),
             payout:  CGRect(x: 0.128, y: 0.767, width: 0.198, height: 0.039),
             // The picture letters this one "Jewel Rush"; the mode is Gems
             // Rush. The plate behind that title is a smooth wash, so unlike
             // the briefing screen it repaints cleanly and the name is drawn.
             title:   CGRect(x: 0.082, y: 0.548, width: 0.256, height: 0.104)),
        Slot(mode: .categoryMaster,
             card:    CGRect(x: 0.503, y: 0.545, width: 0.470, height: 0.258),
             tagline: CGRect(x: 0.539, y: 0.717, width: 0.218, height: 0.044),
             payout:  CGRect(x: 0.628, y: 0.770, width: 0.202, height: 0.039))
    ]

    /// Only the painted cards whose mode the app still lists.
    private var slots: [Slot] {
        let listed = Set(ProMode.hubModes)
        return Self.allSlots.filter { listed.contains($0.mode) }
    }

    // MARK: - Body

    var body: some View {
        GeometryReader { geo in
            ScrollView(showsIndicators: false) {
                scene(width: geo.size.width)
            }
            .bounceOnlyWhenScrollable()
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .background(Self.surround.ignoresSafeArea())
        // The bottom only. The painting puts the back arrow and the gem
        // purse hard against its top edge, and running that under a notch
        // would hide both of them behind the clock.
        .ignoresSafeArea(edges: .bottom)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        // Full screen, not a sheet: each mode's briefing is a painted page
        // that runs to all four edges, and a page sheet would crop the top
        // of it and leave the map showing behind the corners.
        .fullScreenCover(item: $briefing) { mode in
            ProBriefingSheet(mode: mode)
                .environmentObject(progress)
        }
        .onAppear { Music.shared.play(Music.proTrack) }
    }

    /// The painting at full width, with everything live laid over it.
    private func scene(width w: CGFloat) -> some View {
        let h = w / Self.sceneAspect

        return ZStack(alignment: .topLeading) {
            Image("ProHubScene")
                .resizable()
                .scaledToFit()
                .frame(width: w, height: h)

            gemCount(w, h)

            ForEach(slots, id: \.mode) { slot in
                card(slot, w, h)
            }

            // Last, so it stays above any card that reaches near it.
            backTarget(w, h)
        }
        .frame(width: w, height: h)
    }

    // MARK: - The live pieces

    /// The gem purse at the top of the page. The painted pill keeps its gem
    /// and its plus; only the number is live, because only the number moves.
    private func gemCount(_ w: CGFloat, _ h: CGFloat) -> some View {
        Text("\(progress.gems)")
            .font(.system(size: w * 0.044, weight: .heavy, design: .rounded))
            .foregroundColor(.white)
            .shadow(color: .black.opacity(0.45), radius: w * 0.004, y: 1)
            .lineLimit(1)
            .minimumScaleFactor(0.4)
            .contentTransition(.numericText())
            .placed(in: Self.gemsAt, w, h)
            .accessibilityLabel("\(progress.gems) gems")
    }

    /// One card: the wording that belongs to its mode, and the whole card as
    /// the thing you tap. The painted play button is inside that target, so a
    /// child who aims for the arrow and misses still starts the round.
    @ViewBuilder
    private func card(_ slot: Slot, _ w: CGFloat, _ h: CGFloat) -> some View {
        let mode = slot.mode

        if let title = slot.title {
            liveTitle(mode, in: title, w, h)
        }

        // The painting breaks each tagline over two lines; the app's own
        // taglines use a middle dot where that break falls.
        //
        // One size for all four rather than letting each shrink to its own
        // plaque: four cards side by side with four different type sizes
        // reads as a mistake, so the size is the one the longest of them
        // can take and the rest simply have room to spare.
        Text(mode.tagline.replacingOccurrences(of: " · ", with: "\n"))
            .font(.system(size: w * Self.taglineSize, weight: .bold, design: .rounded))
            .foregroundColor(Color(red: 0.16, green: 0.14, blue: 0.34))
            .multilineTextAlignment(.center)
            .lineLimit(2)
            .minimumScaleFactor(0.7)
            .placed(in: slot.tagline, w, h)

        Text("up to \(mode.bestPossibleGems) gems")
            .font(.system(size: w * Self.payoutSize, weight: .heavy, design: .rounded))
            .foregroundColor(.white)
            .shadow(color: .black.opacity(0.40), radius: w * 0.003, y: 1)
            .lineLimit(1)
            .minimumScaleFactor(0.45)
            .placed(in: slot.payout, w, h)

        Color.clear
            .contentShape(Rectangle())
            .onTapGesture {
                Haptics.play(.light)
                briefing = mode
            }
            .placed(in: slot.card, w, h)
            .accessibilityElement()
            .accessibilityLabel("\(mode.title). \(mode.tagline). Up to \(mode.bestPossibleGems) gems")
            .accessibilityAddTraits(.isButton)
    }

    /// A card title drawn rather than painted, matching the lettering the
    /// artwork uses for the other three: a heavy rounded face over a thick
    /// dark outline, on the soft plate those titles sit on.
    private func liveTitle(_ mode: ProMode, in r: CGRect, _ w: CGFloat, _ h: CGFloat) -> some View {
        let words = mode.title.split(separator: " ").map(String.init)
        let first = words.first ?? mode.title
        let rest  = words.dropFirst().joined(separator: " ")
        let ink   = Color(red: 0.36, green: 0.09, blue: 0.53)

        return VStack(spacing: -w * 0.004) {
            outlined(first, w * Self.titleSize, ink,
                     [Color(red: 1.00, green: 0.92, blue: 0.98),
                      Color(red: 1.00, green: 0.62, blue: 0.86)])
            if !rest.isEmpty {
                outlined(rest, w * Self.titleSize, ink,
                         [Color(red: 1.00, green: 0.93, blue: 0.60),
                          Color(red: 0.99, green: 0.69, blue: 0.13)])
            }
        }
        .shadow(color: Color(red: 0.26, green: 0.05, blue: 0.40).opacity(0.55),
                radius: w * 0.008, y: w * 0.006)
        .padding(.horizontal, w * 0.012)
        .background(
            // The soft darker blob the painted titles sit on, so this card
            // reads as the same design as the other three rather than a
            // title floating on bare colour.
            RoundedRectangle(cornerRadius: w * 0.05, style: .continuous)
                .fill(Color(red: 0.42, green: 0.16, blue: 0.62).opacity(0.34))
                .blur(radius: w * 0.022)
                .padding(-w * 0.016)
        )
        .placed(in: r, w, h)
    }

    private func outlined(_ text: String, _ size: CGFloat,
                          _ ink: Color, _ face: [Color]) -> some View {
        OutlinedText(plain: text,
                     font: .system(size: size, weight: .black, design: .rounded),
                     outline: ink,
                     width: max(1.5, size * 0.085)) {
            Text(text).foregroundStyle(
                LinearGradient(colors: face, startPoint: .top, endPoint: .bottom))
        }
    }


    /// The painted back arrow, given something to do.
    private func backTarget(_ w: CGFloat, _ h: CGFloat) -> some View {
        Color.clear
            .contentShape(Rectangle())
            .onTapGesture {
                Haptics.play(.light)
                dismiss()
            }
            .placed(in: Self.backAt, w, h)
            .accessibilityLabel("Back to the map")
            .accessibilityAddTraits(.isButton)
    }
}

// MARK: - How to play

/// The screen that explains a mode before the round begins, and starts it.
///
/// Each mode has a painted screen of its own — its hero, its rules laid out
/// in tiles, its reward banner and its start button. As on the Pro room, the
/// picture carries everything fixed and only what the app knows is drawn on
/// top: the "Up to N gems!" line and the two lines under it, because those
/// come from GemRules and a painted number would quietly go stale.
///
/// Not private: the Timed Challenge is launched from the adventure map, so
/// this has to be reachable from HomeView as well as from the Pro room.
struct ProBriefingSheet: View {
    let mode: ProMode
    @EnvironmentObject private var progress: GameProgress
    @Environment(\.dismiss) private var dismiss

    /// Category Master asks which island to be tested on.
    @State private var chosenIsland: Island?
    @State private var playing = false

    private var islands: [Island] { QuizData.islands }

    // MARK: - Where everything sits on each painting

    /// One mode's painted screen and the handful of places something live
    /// has to land on it. Every rectangle is a fraction of the picture.
    ///
    /// Named Placement, not Layout: SwiftUI has a Layout protocol, and a
    /// nested type of that name shadows it inside this struct.
    private struct Placement {
        let art: String
        let aspect: CGFloat
        /// The close cross, or the back chevron on Category Master.
        let close: CGRect
        /// The big action button along the foot of the screen.
        let start: CGRect
        /// The three lines inside the purple reward banner.
        let head: CGRect
        let sub1: CGRect
        let sub2: CGRect
        /// The gem purse, on the screen that paints one.
        var purse: CGRect? = nil
        /// True where the painted screen lays out the island grid.
        var picksCategory = false
    }

    private static let tall: CGFloat = 941.0 / 1671.0
    private static let tall2: CGFloat = 941.0 / 1672.0
    /// Category Master's screen was drawn to a different shape from the rest.
    private static let tallCat: CGFloat = 852.0 / 1846.0

    private static func placement(_ mode: ProMode) -> Placement? {
        switch mode {
        case .timedChallenge:
            return Placement(art: "ProBriefTimed", aspect: tall,
                          close: CGRect(x: 0.862, y: 0.008, width: 0.126, height: 0.080),
                          start: CGRect(x: 0.034, y: 0.758, width: 0.932, height: 0.114),
                          head:  CGRect(x: 0.245, y: 0.620, width: 0.550, height: 0.056),
                          sub1:  CGRect(x: 0.245, y: 0.679, width: 0.550, height: 0.029),
                          sub2:  CGRect(x: 0.245, y: 0.708, width: 0.550, height: 0.030))
        case .lightningRound:
            return Placement(art: "ProBriefLightning", aspect: tall,
                          close: CGRect(x: 0.862, y: 0.008, width: 0.126, height: 0.080),
                          start: CGRect(x: 0.060, y: 0.752, width: 0.880, height: 0.100),
                          head:  CGRect(x: 0.245, y: 0.623, width: 0.550, height: 0.056),
                          sub1:  CGRect(x: 0.245, y: 0.681, width: 0.550, height: 0.029),
                          sub2:  CGRect(x: 0.245, y: 0.710, width: 0.550, height: 0.030))
        case .perfectRun:
            return Placement(art: "ProBriefPerfect", aspect: tall,
                          close: CGRect(x: 0.862, y: 0.008, width: 0.126, height: 0.082),
                          start: CGRect(x: 0.150, y: 0.728, width: 0.710, height: 0.117),
                          head:  CGRect(x: 0.245, y: 0.606, width: 0.545, height: 0.054),
                          sub1:  CGRect(x: 0.245, y: 0.663, width: 0.545, height: 0.028),
                          sub2:  CGRect(x: 0.245, y: 0.691, width: 0.545, height: 0.029))
        case .gemRush:
            return Placement(art: "ProBriefGemsRush", aspect: tallCat,
                          close: CGRect(x: 0.026, y: 0.013, width: 0.092, height: 0.042),
                          start: CGRect(x: 0.130, y: 0.690, width: 0.740, height: 0.060),
                          head:  CGRect(x: 0.250, y: 0.588, width: 0.510, height: 0.037),
                          sub1:  CGRect(x: 0.250, y: 0.626, width: 0.510, height: 0.021),
                          sub2:  CGRect(x: 0.250, y: 0.647, width: 0.510, height: 0.021))
        case .categoryMaster:
            return Placement(art: "ProBriefCategory", aspect: tallCat,
                          close: CGRect(x: 0.026, y: 0.013, width: 0.092, height: 0.042),
                          start: CGRect(x: 0.245, y: 0.848, width: 0.510, height: 0.060),
                          head:  CGRect(x: 0.245, y: 0.291, width: 0.515, height: 0.036),
                          sub1:  CGRect(x: 0.245, y: 0.328, width: 0.515, height: 0.020),
                          sub2:  CGRect(x: 0.245, y: 0.348, width: 0.515, height: 0.020),
                          purse: CGRect(x: 0.800, y: 0.011, width: 0.100, height: 0.032),
                          picksCategory: true)
        case .dailyChallenge:
            // Free, played from the map, and has no painted screen of its own.
            return nil
        }
    }

    /// The ten islands the Category Master screen paints: three rows of
    /// three, then Champion's Summit on its own underneath. They are in the
    /// same order as `QuizData.islands`, which is what pairs each tile with
    /// the island it shows.
    private static let paintedTiles: [CGRect] = {
        var out: [CGRect] = []
        for (y0, y1) in [(0.375, 0.478), (0.487, 0.590), (0.598, 0.701)] {
            for (x0, x1) in [(0.030, 0.325), (0.345, 0.655), (0.675, 0.970)] {
                out.append(CGRect(x: x0, y: y0, width: x1 - x0, height: y1 - y0))
            }
        }
        out.append(CGRect(x: 0.290, y: 0.710, width: 0.420, height: 0.103))
        return out
    }()

    // MARK: - Body

    var body: some View {
        if let spot = Self.placement(mode) {
            painted(spot)
        } else {
            plain
        }
    }

    private func painted(_ spot: Placement) -> some View {
        NavigationStack {
            GeometryReader { geo in
                ScrollView(showsIndicators: false) {
                    scene(spot, width: geo.size.width)
                }
                .bounceOnlyWhenScrollable()
                .frame(width: geo.size.width, height: geo.size.height)
            }
            .background(backdrop.ignoresSafeArea())
            .ignoresSafeArea(edges: .bottom)
            .navigationDestination(isPresented: $playing) {
                ProQuizView(route: ProRoute(mode: mode, islandID: chosenIsland?.id))
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    /// A flat colour taken from the picture's own edge, for the strip above
    /// it on a screen taller than the artwork.
    private var backdrop: Color {
        switch mode {
        case .timedChallenge: return Color(red: 0.294, green: 0.510, blue: 0.706)
        case .lightningRound: return Color(red: 0.180, green: 0.475, blue: 0.788)
        case .perfectRun:     return Color(red: 0.310, green: 0.596, blue: 0.831)
        case .gemRush:        return Color(red: 0.157, green: 0.110, blue: 0.290)
        default:              return Color(red: 0.180, green: 0.475, blue: 0.788)
        }
    }

    private func scene(_ spot: Placement, width w: CGFloat) -> some View {
        let h = w / spot.aspect
        let bonus = mode.bestPossibleGems - mode.questionCount * GemRules.perCorrect

        return ZStack(alignment: .topLeading) {
            Image(spot.art)
                .resizable()
                .scaledToFit()
                .frame(width: w, height: h)

            // The reward banner: the total and the two lines under it all
            // come from GemRules, so none of them can drift from what a
            // round actually pays.
            ResultLine(pieces: [("Up to ", false),
                                ("\(mode.bestPossibleGems)", true),
                                (" gems!", false)],
                       size: w * 0.058, outlineWidth: max(2, w * 0.006))
                .placed(in: spot.head, w, h)

            ResultLine(pieces: [("\(GemRules.perCorrect) gems", true),
                                (" per correct answer", false)],
                       size: w * 0.030, weight: .bold, outlineWidth: max(1, w * 0.003))
                .placed(in: spot.sub1, w, h)

            ResultLine(pieces: [("+ \(bonus) bonus gems", true),
                                (" for a perfect run!", false)],
                       size: w * 0.030, weight: .bold, outlineWidth: max(1, w * 0.003))
                .placed(in: spot.sub2, w, h)

            if let purse = spot.purse {
                Text("\(progress.gems)")
                    .font(.system(size: w * 0.044, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.45), radius: w * 0.004, y: 1)
                    .lineLimit(1)
                    .minimumScaleFactor(0.4)
                    .placed(in: purse, w, h)
                    .accessibilityLabel("\(progress.gems) gems")
            }

            if spot.picksCategory { categoryTiles(w, h) }

            startTarget(spot, w, h)
            closeTarget(spot, w, h)
        }
        .frame(width: w, height: h)
    }

    // MARK: - Live pieces

    private func closeTarget(_ spot: Placement, _ w: CGFloat, _ h: CGFloat) -> some View {
        Color.clear
            .contentShape(Rectangle())
            .onTapGesture {
                Haptics.play(.light)
                dismiss()
            }
            .placed(in: spot.close, w, h)
            .accessibilityLabel("Close")
            .accessibilityAddTraits(.isButton)
    }

    /// The painted action button. On Category Master it cannot do anything
    /// until an island is chosen, so it says so rather than going quiet.
    private func startTarget(_ spot: Placement, _ w: CGFloat, _ h: CGFloat) -> some View {
        let ready = !mode.needsCategory || chosenIsland != nil

        return Color.clear
            .contentShape(Rectangle())
            .onTapGesture {
                guard ready else { Haptics.play(.error); return }
                Haptics.play(.light)
                playing = true
            }
            .overlay(alignment: .bottom) {
                if !ready {
                    Text("Pick a category first")
                        .font(.system(size: w * 0.030, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.6), radius: 3, y: 1)
                        .offset(y: h * 0.052)
                }
            }
            .placed(in: spot.start, w, h)
            .accessibilityLabel(ready ? "Start the challenge" : "Pick a category first")
            .accessibilityAddTraits(.isButton)
    }

    // MARK: - Category Master's island grid

    /// The painted tiles, made to answer to a tap.
    ///
    /// Paired with the islands by position, and cut short by `zip` if the
    /// two ever stop matching: a game with an eleventh island would leave it
    /// off this screen until the picture catches up, which is better than
    /// putting its name on somebody else's tile.
    private func categoryTiles(_ w: CGFloat, _ h: CGFloat) -> some View {
        ForEach(Array(zip(islands, Self.paintedTiles)), id: \.0.id) { island, rect in
            tileTarget(island, in: rect, w, h)
        }
    }

    /// Nothing to draw — the picture already shows this island. All this
    /// adds is somewhere to tap, and a ring round the one chosen.
    private func tileTarget(_ island: Island, in rect: CGRect,
                            _ w: CGFloat, _ h: CGFloat) -> some View {
        let picked = chosenIsland?.id == island.id

        return Color.clear
        .overlay {
            if picked {
                RoundedRectangle(cornerRadius: w * 0.032, style: .continuous)
                    .strokeBorder(LinearGradient(
                        colors: [Color(red: 1.00, green: 0.93, blue: 0.55),
                                 Color(red: 0.98, green: 0.68, blue: 0.10)],
                        startPoint: .top, endPoint: .bottom),
                        lineWidth: max(3, w * 0.010))
                    .shadow(color: Color(red: 1.00, green: 0.80, blue: 0.20).opacity(0.9),
                            radius: w * 0.02)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            Haptics.play(.light)
            chosenIsland = island
        }
        .placed(in: rect, w, h)
        .accessibilityLabel("\(island.name)\(picked ? ", chosen" : "")")
        .accessibilityAddTraits(.isButton)
    }

    // MARK: - The plain screen

    /// The Daily Challenge has no painted screen, so it keeps a simple one.
    /// It is free and lives on the map, and it is the only mode that lands
    /// here.
    private var plain: some View {
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
            GemIcon(size: 24, sparkle: true)
            VStack(alignment: .leading, spacing: 2) {
                Text("Up to \(mode.bestPossibleGems) gems")
                    .font(Theme.bold(17))
                    .foregroundColor(.white)
                Text("\(mode.gemsPerCorrect) per correct answer"
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

/// A deep gem-toned backdrop with slow drifting sparkles, so the Pro room
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
            // Sampled from the artwork itself: the header's top edge, the
            // colour between the cards, and the footer's bottom edge. The
            // strips behind the status bar and home indicator then look like
            // a continuation of the picture rather than a band around it.
            LinearGradient(stops: [
                .init(color: Color(red: 0.098, green: 0.078, blue: 0.404), location: 0.00),
                .init(color: Color(red: 0.180, green: 0.102, blue: 0.475), location: 0.30),
                .init(color: Color(red: 0.180, green: 0.102, blue: 0.475), location: 0.72),
                .init(color: Color(red: 0.008, green: 0.129, blue: 0.165), location: 1.00)
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

// MARK: - Bounce

extension View {
    /// Stops a short page from rubber-banding. `scrollBounceBehavior` only
    /// arrived in iOS 16.4 and the app ships back to 16.0, so older phones
    /// simply keep the standard bounce.
    @ViewBuilder
    func bounceOnlyWhenScrollable() -> some View {
        if #available(iOS 16.4, *) {
            self.scrollBounceBehavior(.basedOnSize)
        } else {
            self
        }
    }
}

#Preview {
    NavigationStack {
        ProHubView().environmentObject(GameProgress())
    }
}
