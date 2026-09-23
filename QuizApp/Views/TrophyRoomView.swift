//
//  TrophyRoomView.swift
//  QuizApp
//
//  My Trophy Room — a golden hall, not a list.
//
//  Four great cups stand on the top shelf and climb with every correct answer
//  anywhere in the game. Below them, ten lit alcoves hold the adventures: each
//  fills as its ladder is climbed — bronze, silver and gold badges for
//  answering its hundred questions right, an Explorer Cup for clearing all ten
//  levels, and a Master Crown for getting every question in it right. Fill all
//  ten and the Ultimate Adventurer Trophy lights up at the end.
//
//  Awards not won yet are still shown, with how far along the child is.
//  "7 / 10 — only 3 more!" is the whole point of the room: seeing what is
//  nearly in reach is what brings a child back. So nothing is hidden and
//  nothing is greyed into the background — a locked award keeps its colour
//  and wears a present, because it is a thing to want, not a thing refused.
//

import SwiftUI
import UIKit

// MARK: - Painted pieces, when there are any

/// The room is drawn in code so it works today, but every drawn piece has a
/// painted one it will use instead the moment that artwork is in the bundle.
///
/// Nothing here is required. A missing piece is not a broken screen — it is
/// the drawn version, unchanged. So the artwork can arrive one plate at a
/// time, in any order, with no code change and nothing half-finished on
/// screen in between.
enum VaultArt {
    static let background = "TrophyRoomBG"     // the empty hall
    static let banner     = "TrophyBanner"     // blank carved sign
    static let arch       = "TrophyArch"       // hollow gold niche frame
    static let plate      = "TrophyPlate"      // blank name plaque
    static let chest      = "TrophyChest"      // little treasure chest

    static func cup(_ metal: TrophyCupIcon.Metal) -> String {
        switch metal {
        case .bronze:  return "CupBronze"
        case .silver:  return "CupSilver"
        case .gold:    return "CupGold"
        case .diamond: return "CupDiamond"
        }
    }

    /// UIKit rather than `Image(_:)`, because a SwiftUI Image of a missing
    /// asset draws nothing and says nothing — the fallback has to be chosen
    /// before the view is built, not after it has already come out blank.
    static func has(_ name: String) -> Bool {
        UIImage(named: name) != nil
    }
}

// MARK: - The room's palette

/// Warm stone, gold and lamplight. Kept in one place so the hall, the alcoves
/// and the plaques are lit by the same fire.
enum Vault {
    static let night     = Color(red: 0.17, green: 0.11, blue: 0.31)
    static let stone     = Color(red: 0.45, green: 0.26, blue: 0.27)
    static let stoneDeep = Color(red: 0.27, green: 0.14, blue: 0.19)
    static let carpet    = Color(red: 0.58, green: 0.13, blue: 0.23)

    static let gold     = Color(red: 1.00, green: 0.80, blue: 0.29)
    static let goldDeep = Color(red: 0.80, green: 0.51, blue: 0.11)
    static let goldPale = Color(red: 1.00, green: 0.94, blue: 0.74)

    static let wood     = Color(red: 0.45, green: 0.26, blue: 0.14)
    static let woodDeep = Color(red: 0.28, green: 0.15, blue: 0.08)

    /// The gold of a frame catches the light along its length rather than
    /// sitting flat — that one gradient is most of what makes it read as metal.
    static let metal = LinearGradient(
        colors: [goldPale, gold, goldDeep, gold],
        startPoint: .topLeading, endPoint: .bottomTrailing)

    static let plaque = LinearGradient(
        colors: [wood, woodDeep],
        startPoint: .top, endPoint: .bottom)

    /// The colours the special achievements are painted in, in order. A locked
    /// award keeps its colour; only the seal on the end changes.
    static let cardColours: [Color] = [
        Color(red: 0.95, green: 0.70, blue: 0.16),
        Color(red: 0.24, green: 0.53, blue: 0.92),
        Color(red: 0.89, green: 0.29, blue: 0.28),
        Color(red: 0.55, green: 0.33, blue: 0.85),
        Color(red: 0.22, green: 0.69, blue: 0.44),
        Color(red: 0.92, green: 0.30, blue: 0.56),
        Color(red: 0.19, green: 0.62, blue: 0.86),
        Color(red: 0.95, green: 0.62, blue: 0.20),
        Color(red: 0.44, green: 0.38, blue: 0.88)
    ]

    static func card(_ index: Int) -> Color {
        cardColours[index % cardColours.count]
    }
}

// MARK: - An alcove

/// A rounded arch: flat-ish sides, a domed top, feet slightly rounded. Used
/// for the ten adventure niches, which is what makes the grid read as a wall
/// of lit recesses rather than a page of tiles.
struct ArchShape: InsettableShape {
    var foot: CGFloat = 13
    /// Insettable so the gold frame can be drawn with `strokeBorder`, which
    /// keeps the whole line inside the arch instead of letting half of it
    /// hang over the artwork behind.
    var inset: CGFloat = 0

    func inset(by amount: CGFloat) -> ArchShape {
        ArchShape(foot: foot, inset: inset + amount)
    }

    func path(in outer: CGRect) -> Path {
        let rect = outer.insetBy(dx: inset, dy: inset)
        guard rect.width > 0, rect.height > 0 else { return Path() }

        let radius = rect.width / 2
        let crown = min(radius, max(0, rect.height - foot))
        let f = min(foot, max(0, rect.height - crown))

        var p = Path()
        p.move(to: CGPoint(x: rect.minX, y: rect.maxY - f))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.minY + crown))
        p.addArc(center: CGPoint(x: rect.midX, y: rect.minY + crown),
                 radius: radius,
                 startAngle: .degrees(180), endAngle: .degrees(0),
                 clockwise: false)
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - f))
        p.addQuadCurve(to: CGPoint(x: rect.maxX - f, y: rect.maxY),
                       control: CGPoint(x: rect.maxX, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.minX + f, y: rect.maxY))
        p.addQuadCurve(to: CGPoint(x: rect.minX, y: rect.maxY - f),
                       control: CGPoint(x: rect.minX, y: rect.maxY))
        p.closeSubpath()
        return p
    }
}

// MARK: - The room/// The Trophy Room, as painted: one page that scrolls.
///
/// The room is at the top — the child's name over the door, how many awards
/// are won, the four Grand Cups and the ten adventures. Below it the hall
/// carries straight on into Special Achievements, and the whole thing is one
/// scroll rather than pages to swipe between.
///
/// Everything fixed belongs to the pictures. What the app knows is drawn on
/// top at fractions of them — the name, the counts, the four cup bars — and
/// the achievement rows are drawn outright so the list is as long as the
/// catalogue is, however many that comes to.
///
/// The room's ten island badges are all bright, none of them locked. That is
/// deliberate: this is a room for showing what a child has, and a wall of
/// padlocks is a poor way to say "keep going".
struct TrophyRoomView: View {
    @EnvironmentObject private var progress: GameProgress
    @Environment(\.dismiss) private var dismiss
    @AppStorage(Player.nameKey) private var playerName = ""

    @State private var openIsland: Island?

    private let islands = QuizData.islands
    private var cups: [Achievement] { AchievementCatalog.grandCups }
    private var badges: [Achievement] { AchievementCatalog.badges }

    // MARK: - Where things sit on the paintings
    //
    // The room is 941 x 1672 and the two achievement pieces are cut from
    // pictures of the same width, so every rectangle below is a fraction of
    // the picture it belongs to.

    private static let roomAspect: CGFloat = 941.0 / 1672.0
    private static let headAspect: CGFloat = 941.0 / 305.0
    private static let footAspect: CGFloat = 941.0 / 368.0

    /// The hall's own stone, read from the slivers either side of the painted
    /// rows. It backs the drawn rows and fills the screen behind the scroll.
    private static let wall = Color(red: 0.365, green: 0.243, blue: 0.192)

    private static let backAt  = CGRect(x: 0.028, y: 0.013, width: 0.094, height: 0.051)
    private static let closeAt = CGRect(x: 0.878, y: 0.013, width: 0.094, height: 0.051)
    /// The child's name on the plank above "Trophy Room".
    ///
    /// Sized and placed against the glyphs, not the line box. A Text is
    /// centred on its ascender-to-descender box, which sits lower than the
    /// letters look like they do, and at the painted size that dropped the
    /// tail of a "g" fourteen points into "Trophy Room" below. The name is a
    /// shade smaller and higher than the artwork drew it, and clears the
    /// blue lettering — which starts at y 0.108 — by about eleven points.
    private static let nameAt  = CGRect(x: 0.283, y: 0.044, width: 0.362, height: 0.054)
    private static let nameSize: CGFloat = 0.078
    private static let wonAt   = CGRect(x: 0.375, y: 0.193, width: 0.250, height: 0.032)

    /// One Grand Cup card: where its tally is written and where its bar runs.
    private static let cupSlots: [(num: CGRect, bar: CGRect)] = [
        (CGRect(x: 0.240, y: 0.374, width: 0.180, height: 0.021),
         CGRect(x: 0.224, y: 0.396, width: 0.213, height: 0.013)),
        (CGRect(x: 0.567, y: 0.374, width: 0.180, height: 0.021),
         CGRect(x: 0.553, y: 0.396, width: 0.208, height: 0.013)),
        (CGRect(x: 0.240, y: 0.574, width: 0.180, height: 0.021),
         CGRect(x: 0.224, y: 0.596, width: 0.213, height: 0.013)),
        (CGRect(x: 0.567, y: 0.574, width: 0.180, height: 0.021),
         CGRect(x: 0.553, y: 0.596, width: 0.208, height: 0.013))
    ]

    /// The bar fill's colour on each card, taken from the artwork.
    private static let cupFill: [[Color]] = [
        [Color(red: 0.62, green: 0.93, blue: 0.29), Color(red: 0.36, green: 0.78, blue: 0.10)],
        [Color(red: 0.42, green: 0.84, blue: 1.00), Color(red: 0.13, green: 0.62, blue: 0.95)],
        [Color(red: 1.00, green: 0.82, blue: 0.33), Color(red: 0.95, green: 0.60, blue: 0.09)],
        [Color(red: 1.00, green: 0.55, blue: 0.90), Color(red: 0.87, green: 0.26, blue: 0.75)]
    ]

    /// The ten painted adventure badges, in island order.
    private static let islandTiles: [CGRect] = {
        var out: [CGRect] = []
        for (y0, y1) in [(0.672, 0.795), (0.808, 0.930)] {
            for (x0, x1) in [(0.030, 0.215), (0.222, 0.407), (0.414, 0.599),
                             (0.606, 0.791), (0.798, 0.983)] {
                out.append(CGRect(x: x0, y: y0, width: x1 - x0, height: y1 - y0))
            }
        }
        return out
    }()

    /// The nine row colours the artwork uses, in order.
    private static let rowFace: [[Color]] = [
        [Color(red: 1.00, green: 0.95, blue: 0.62), Color(red: 0.97, green: 0.85, blue: 0.36)],
        [Color(red: 0.36, green: 0.82, blue: 0.99), Color(red: 0.13, green: 0.62, blue: 0.93)],
        [Color(red: 0.99, green: 0.65, blue: 0.56), Color(red: 0.94, green: 0.38, blue: 0.33)],
        [Color(red: 0.82, green: 0.55, blue: 0.98), Color(red: 0.62, green: 0.34, blue: 0.92)],
        [Color(red: 0.42, green: 0.85, blue: 0.48), Color(red: 0.13, green: 0.66, blue: 0.27)],
        [Color(red: 0.93, green: 0.24, blue: 0.47), Color(red: 0.78, green: 0.07, blue: 0.31)],
        [Color(red: 0.20, green: 0.55, blue: 0.90), Color(red: 0.02, green: 0.38, blue: 0.76)],
        [Color(red: 0.98, green: 0.62, blue: 0.10), Color(red: 0.88, green: 0.42, blue: 0.01)],
        [Color(red: 0.72, green: 0.52, blue: 0.99), Color(red: 0.52, green: 0.28, blue: 0.90)]
    ]

    // MARK: - Body

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    roomScene(w)

                    Image("TrophyAchieveHead")
                        .resizable().scaledToFit().frame(width: w)

                    VStack(spacing: w * 0.021) {
                        ForEach(Array(badges.enumerated()), id: \.element.id) { pair in
                            awardRow(pair.element,
                                     face: Self.rowFace[pair.offset % Self.rowFace.count],
                                     w: w)
                        }
                    }
                    .padding(.horizontal, w * 0.014)
                    .padding(.vertical, w * 0.021)
                    .frame(width: w)
                    .background(Self.wall)

                    Image("TrophyAchieveFoot")
                        .resizable().scaledToFit().frame(width: w)
                }
            }
            // Always reachable, however far down the hall you have scrolled,
            // and sitting exactly where the room's painted cross is so that
            // at the top of the scroll it reads as that one button.
            .overlay(alignment: .topTrailing) {
                closeButton(w)
                    .padding(.trailing, w * 0.028)
                    .padding(.top, w * 0.023)
            }
        }
        .background(Self.wall.ignoresSafeArea())
        .sheet(item: $openIsland) { island in
            AdventureLadderSheet(island: island)
                .environmentObject(progress)
        }
    }

    // MARK: - The room

    private func roomScene(_ w: CGFloat) -> some View {
        let h = w / Self.roomAspect

        return ZStack(alignment: .topLeading) {
            Image("TrophyRoomScene")
                .resizable().scaledToFit().frame(width: w, height: h)
            roomLayer(w, h)
        }
        .frame(width: w, height: h)
    }

    @ViewBuilder
    private func roomLayer(_ w: CGFloat, _ h: CGFloat) -> some View {
        let won = progress.trophyCount
        let all = AchievementCatalog.all.count

        if !playerName.isEmpty {
            OutlinedText(plain: "\(playerName)'s",
                         font: .system(size: w * Self.nameSize, weight: .black, design: .rounded),
                         outline: Color(red: 0.36, green: 0.16, blue: 0.05),
                         width: max(2, w * 0.007)) {
                Text("\(playerName)'s").foregroundStyle(LinearGradient(
                    colors: [Color(red: 1.00, green: 0.95, blue: 0.62),
                             Color(red: 1.00, green: 0.78, blue: 0.20),
                             Color(red: 0.93, green: 0.55, blue: 0.06)],
                    startPoint: .top, endPoint: .bottom))
            }
            .placed(in: Self.nameAt, w, h)
        }

        Text("\(won) of \(all) won")
            .font(.system(size: w * 0.034, weight: .heavy, design: .rounded))
            .foregroundColor(Color(red: 1.00, green: 0.93, blue: 0.78))
            .lineLimit(1)
            .minimumScaleFactor(0.5)
            .placed(in: Self.wonAt, w, h)
            .accessibilityLabel("\(won) of \(all) awards won")

        ForEach(Array(cups.enumerated()), id: \.element.id) { pair in
            let slot = Self.cupSlots[min(pair.offset, Self.cupSlots.count - 1)]
            cupCard(pair.element, slot: slot,
                    face: Self.cupFill[pair.offset % Self.cupFill.count], w, h)
        }

        ForEach(Array(islands.prefix(Self.islandTiles.count).enumerated()),
                id: \.element.id) { pair in
            let rect = Self.islandTiles[pair.offset]
            let island = pair.element
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    Haptics.play(.light)
                    openIsland = island
                }
                .placed(in: rect, w, h)
                .accessibilityLabel(ladderLabel(island))
                .accessibilityAddTraits(.isButton)
        }

        Color.clear
            .contentShape(Rectangle())
            .onTapGesture {
                Haptics.play(.light)
                dismiss()
            }
            .placed(in: Self.backAt, w, h)
            .accessibilityLabel("Back")
            .accessibilityAddTraits(.isButton)
    }

    /// The tally and the bar on one Grand Cup card. The card, its trophy and
    /// its name are all painted; only how far along it is can change.
    @ViewBuilder
    private func cupCard(_ cup: Achievement, slot: (num: CGRect, bar: CGRect),
                         face: [Color], _ w: CGFloat, _ h: CGFloat) -> some View {
        let standing = min(progress.standing(cup), cup.target)
        let share = cup.target > 0 ? CGFloat(standing) / CGFloat(cup.target) : 0

        Text("\(standing) / \(cup.target)")
            .font(.system(size: w * 0.040, weight: .heavy, design: .rounded))
            .foregroundColor(.white)
            .shadow(color: .black.opacity(0.45), radius: w * 0.003, y: 1)
            .lineLimit(1)
            .minimumScaleFactor(0.5)
            .placed(in: slot.num, w, h)

        GeometryReader { bar in
            Capsule()
                .fill(LinearGradient(colors: face, startPoint: .top, endPoint: .bottom))
                .frame(width: share > 0
                       ? max(bar.size.height, bar.size.width * share)
                       : 0)
        }
        .placed(in: slot.bar, w, h)
        .accessibilityHidden(true)
    }

    private func ladderLabel(_ island: Island) -> String {
        let rungs = progress.ladder(for: island)
        let won = rungs.filter { progress.hasWon($0) }.count
        return "\(island.name), \(won) of \(rungs.count) trophies won"
    }

    // MARK: - Special achievements

    /// One achievement, in the shape both painted lists use.
    private func awardRow(_ award: Achievement, face: [Color], w: CGFloat) -> some View {
        AwardCard(award: award, face: face, w: w,
                  won: progress.hasWon(award),
                  standing: progress.standing(award))
    }

    // MARK: - Shared

    /// Drawn to match the cross the room is painted with, so that at the top
    /// of the scroll the two read as one button and further down it is the
    /// only one there.
    private func closeButton(_ w: CGFloat) -> some View {
        Button {
            Haptics.play(.light)
            dismiss()
        } label: {
            Image(systemName: "xmark")
                .font(.system(size: w * 0.042, weight: .black))
                .foregroundColor(.white)
                .frame(width: w * 0.094, height: w * 0.094)
                .background(
                    Circle().fill(LinearGradient(
                        colors: [Color(red: 0.37, green: 0.22, blue: 0.13),
                                 Color(red: 0.22, green: 0.12, blue: 0.07)],
                        startPoint: .top, endPoint: .bottom))
                )
                .overlay(Circle().strokeBorder(Color(red: 0.85, green: 0.65, blue: 0.30),
                                               lineWidth: max(2, w * 0.005)))
                .shadow(color: .black.opacity(0.4), radius: w * 0.010, y: w * 0.004)
        }
        .buttonStyle(PressableButtonStyle())
        .accessibilityLabel("Close the trophy room")
    }
}

/// "Only 3 more!" — said the way a child would hear it.
func remainingLine(_ standing: Int, of target: Int) -> String {
    let left = max(0, target - standing)
    if left == 0 { return "Done!" }
    return "\(standing)/\(target) — only \(left) more!"
}

// MARK: - The hall itself

/// Warm stone lit from the middle, a night sky high up, carpet underfoot and
/// a pillar down each edge. Drawn rather than photographed so it costs nothing
/// to ship and stretches to any screen.
private struct VaultBackdrop: View {
    var body: some View {
        if VaultArt.has(VaultArt.background) {
            painted
        } else {
            drawn
        }
    }

    /// The painted hall, filling the screen and cropping at whichever edge it
    /// has to. It is behind the scroll view rather than inside it, so the room
    /// holds still and the shelves travel past it — the way it would look to
    /// someone walking along the hall, and the only way a single painting can
    /// cover a page that scrolls much further than it is tall.
    private var painted: some View {
        Image(VaultArt.background)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .ignoresSafeArea()
    }

    private var drawn: some View {
        ZStack {
            LinearGradient(colors: [Vault.night, Vault.stone,
                                    Vault.stoneDeep, Vault.carpet.opacity(0.55)],
                           startPoint: .top, endPoint: .bottom)

            // Lamplight, so the middle of the room is the bright part.
            RadialGradient(colors: [Vault.gold.opacity(0.34), .clear],
                           center: .init(x: 0.5, y: 0.34),
                           startRadius: 8, endRadius: 460)

            HStack {
                pillar
                Spacer()
                pillar
            }

            // Edges settle a little so the shelves read as the lit part. Kept
            // light: any more and it drags the colour out of the artwork,
            // which is the one thing this room must not do.
            RadialGradient(colors: [.clear, .black.opacity(0.26)],
                           center: .center, startRadius: 200, endRadius: 600)
        }
        .ignoresSafeArea()
    }

    private var pillar: some View {
        LinearGradient(colors: [Vault.stoneDeep.opacity(0.0),
                                Vault.woodDeep.opacity(0.55),
                                Vault.stoneDeep.opacity(0.0)],
                       startPoint: .leading, endPoint: .trailing)
            .frame(width: 26)
    }
}

/// A line of text with nothing but the hall behind it.
///
/// The painted room is lit stone — a twentieth of it is brighter than the pale
/// gold this text is written in, and a drop shadow does not save cream on
/// cream. So the line carries its own small patch of shade. That is cheaper
/// than darkening the whole painting, which is the mistake that made the room
/// look switched off before.
private struct HallLine: View {
    let text: String
    var size: CGFloat = 13

    var body: some View {
        Text(text)
            .font(Theme.bold(size))
            .foregroundColor(Vault.goldPale)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .background(Capsule().fill(.black.opacity(0.42)))
            .overlay(Capsule().strokeBorder(Vault.goldDeep.opacity(0.55), lineWidth: 1))
    }
}

/// A carved wooden sign in a gold frame, with a stud at each end. Used for the
/// room's name and for each shelf heading.
private struct VaultBanner: View {
    let text: String
    var size: CGFloat = 20
    var maxWidth: CGFloat = .infinity

    /// The painted sign is 3:1 and can only ever be scaled whole. Its crown
    /// and its bottom gem both sit in the middle, which is precisely the part
    /// a nine-slice stretches — cap insets would have pulled the crown wide.
    private static let aspect: CGFloat = 3.0

    /// Where the bare wood is, as a fraction of the whole plate: inside the
    /// gold rails, under the crown's overlap, clear of the gem below.
    /// Measured off the artwork rather than guessed.
    private static let inner = CGRect(x: 0.12, y: 0.34, width: 0.76, height: 0.38)

    var body: some View {
        if VaultArt.has(VaultArt.banner) { painted } else { drawn }
    }

    private var painted: some View {
        Image(VaultArt.banner)
            .resizable()
            .aspectRatio(Self.aspect, contentMode: .fit)
            .frame(maxWidth: maxWidth)
            .overlay(
                GeometryReader { geo in
                    Text(text)
                        .font(Theme.display(size))
                        .foregroundColor(Vault.goldPale)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.5)
                        .lineLimit(2)
                        .shadow(color: .black.opacity(0.6), radius: 2, y: 1)
                        .frame(width: geo.size.width * Self.inner.width,
                               height: geo.size.height * Self.inner.height)
                        .position(x: geo.size.width * Self.inner.midX,
                                  y: geo.size.height * Self.inner.midY)
                }
            )
            .shadow(color: .black.opacity(0.4), radius: 7, y: 4)
    }

    private var drawn: some View {
        Text(text)
            .font(Theme.display(size))
            .foregroundColor(Vault.goldPale)
            .multilineTextAlignment(.center)
            .minimumScaleFactor(0.6)
            .lineLimit(2)
            .shadow(color: Vault.woodDeep, radius: 1, y: 1)
            .padding(.horizontal, 26)
            .padding(.vertical, 10)
            .background(RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Vault.plaque))
            .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(Vault.metal, lineWidth: 3))
            .overlay(alignment: .leading) { stud }
            .overlay(alignment: .trailing) { stud }
            .shadow(color: .black.opacity(0.45), radius: 6, y: 3)
    }

    private var stud: some View {
        Circle()
            .fill(Vault.metal)
            .frame(width: 9, height: 9)
            .padding(.horizontal, 7)
    }
}

/// The stone ledge the four great cups stand on.
private struct ShelfPlinth: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
            .fill(LinearGradient(colors: [Vault.stone.opacity(0.92),
                                          Vault.stoneDeep.opacity(0.94)],
                                 startPoint: .top, endPoint: .bottom))
            .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(Vault.metal, lineWidth: 2))
            .shadow(color: .black.opacity(0.4), radius: 7, y: 4)
    }
}

// MARK: - A thin progress bar

struct ProgressTrack: View {
    var fraction: Double
    var tint: Color = Vault.gold

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(.black.opacity(0.42))
                Capsule()
                    .fill(LinearGradient(colors: [tint, Vault.goldPale],
                                         startPoint: .leading, endPoint: .trailing))
                    .frame(width: max(5, geo.size.width * min(1, max(0, fraction))))
            }
            .overlay(Capsule().strokeBorder(.white.opacity(0.22), lineWidth: 1))
        }
    }
}

// MARK: - A drawn trophy cup

/// The bowl: a wide rim falling away to a narrow foot.
struct CupBowl: Shape {
    func path(in rect: CGRect) -> Path {
        let topHalf = rect.width / 2
        let footHalf = rect.width * 0.19
        let waist = rect.minY + rect.height * 0.58

        var p = Path()
        p.move(to: CGPoint(x: rect.midX - topHalf, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.midX + topHalf, y: rect.minY))
        p.addCurve(to: CGPoint(x: rect.midX + footHalf, y: rect.maxY),
                   control1: CGPoint(x: rect.midX + topHalf, y: waist),
                   control2: CGPoint(x: rect.midX + footHalf * 1.7, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.midX - footHalf, y: rect.maxY))
        p.addCurve(to: CGPoint(x: rect.midX - topHalf, y: rect.minY),
                   control1: CGPoint(x: rect.midX - footHalf * 1.7, y: rect.maxY),
                   control2: CGPoint(x: rect.midX - topHalf, y: waist))
        p.closeSubpath()
        return p
    }
}

/// The plinth: a shallow trapezium, wider at the floor.
struct CupBase: Shape {
    func path(in rect: CGRect) -> Path {
        let inset = rect.width * 0.17
        var p = Path()
        p.move(to: CGPoint(x: rect.minX + inset, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX - inset, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        p.closeSubpath()
        return p
    }
}

/// A trophy cup, drawn rather than borrowed from the emoji font.
///
/// The emoji this replaced were medals, not cups, and they arrive in whatever
/// shape the system font feels like — three different silhouettes in a row
/// that is meant to read as one shelf of four. Drawing it means the four
/// really are the same cup in four metals, and the gradient runs across all
/// of them together, which is what makes them look cast rather than printed.
struct TrophyCupIcon: View {
    enum Metal { case bronze, silver, gold, diamond }

    let metal: Metal
    var lit: Bool = true
    var height: CGFloat = 54

    /// Pale highlight, body, shadow, body again — a metal reads as metal
    /// because the light crosses it twice.
    private var shades: [Color] {
        switch metal {
        case .bronze:
            return [Color(red: 0.96, green: 0.79, blue: 0.58),
                    Color(red: 0.81, green: 0.50, blue: 0.24),
                    Color(red: 0.49, green: 0.26, blue: 0.10),
                    Color(red: 0.86, green: 0.58, blue: 0.31)]
        case .silver:
            return [Color(red: 1.00, green: 1.00, blue: 1.00),
                    Color(red: 0.84, green: 0.88, blue: 0.93),
                    Color(red: 0.48, green: 0.54, blue: 0.62),
                    Color(red: 0.90, green: 0.93, blue: 0.97)]
        case .gold:
            return [Color(red: 1.00, green: 0.96, blue: 0.72),
                    Color(red: 1.00, green: 0.79, blue: 0.24),
                    Color(red: 0.66, green: 0.44, blue: 0.05),
                    Color(red: 1.00, green: 0.85, blue: 0.38)]
        case .diamond:
            return [Color(red: 0.94, green: 0.99, blue: 1.00),
                    Color(red: 0.62, green: 0.89, blue: 1.00),
                    Color(red: 0.24, green: 0.56, blue: 0.76),
                    Color(red: 0.82, green: 0.96, blue: 1.00)]
        }
    }

    /// Always the real metal. A bronze cup is bronze whether or not it has
    /// been won — washing it out only made a shelf of four look switched off,
    /// which is exactly what it looked like with none of them won yet. What
    /// winning adds is the halo underneath, not the colour.
    private var finish: LinearGradient {
        LinearGradient(colors: shades,
                       startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    private var emblem: String {
        switch metal {
        case .bronze, .silver: return "star.fill"
        case .gold:            return "crown.fill"
        case .diamond:         return "diamond.fill"
        }
    }

    var body: some View {
        if VaultArt.has(VaultArt.cup(metal)) {
            Image(VaultArt.cup(metal))
                .resizable()
                .scaledToFit()
                .frame(height: height)
                .shadow(color: shades[1].opacity(lit ? 0.75 : 0.30),
                        radius: lit ? 12 : 5)
                .shadow(color: .black.opacity(0.35), radius: 2, y: 2)
        } else {
            drawn
        }
    }

    private var drawn: some View {
        let w = height * 0.74

        return VStack(spacing: 0) {
            // Rim — a little wider than the bowl, which is what gives a cup
            // its lip instead of a funnel's edge.
            Capsule()
                .fill(finish)
                .frame(width: w * 1.08, height: height * 0.09)

            ZStack {
                handle(mirrored: false, w: w, h: height)
                handle(mirrored: true,  w: w, h: height)

                CupBowl()
                    .fill(finish)
                    .overlay(
                        CupBowl().stroke(shadeLine.opacity(0.7), lineWidth: 1)
                    )

                Image(systemName: emblem)
                    .font(.system(size: height * 0.20, weight: .bold))
                    .foregroundColor(shadeLine.opacity(0.7))
                    .offset(y: -height * 0.04)
            }
            .frame(width: w, height: height * 0.46)

            Rectangle()
                .fill(finish)
                .frame(width: w * 0.17, height: height * 0.13)

            Capsule()
                .fill(finish)
                .frame(width: w * 0.40, height: height * 0.06)

            CupBase()
                .fill(finish)
                .frame(width: w * 0.66, height: height * 0.15)
        }
        .frame(height: height)
        // Winning lights the cup from behind rather than colouring it in.
        .shadow(color: shades[1].opacity(lit ? 0.75 : 0.30), radius: lit ? 12 : 5)
        .shadow(color: .black.opacity(0.35), radius: 2, y: 2)
    }

    private var shadeLine: Color { shades[2] }

    /// Drawn behind the bowl so the inner half is hidden and the arc reads as
    /// a handle looping out of the side.
    private func handle(mirrored: Bool, w: CGFloat, h: CGFloat) -> some View {
        Ellipse()
            .strokeBorder(finish, lineWidth: max(2, h * 0.05))
            .frame(width: w * 0.52, height: h * 0.34)
            // Sits high on the bowl, where a handle is actually gripped —
            // centred, it droops and the cup reads as a sugar bowl.
            .offset(x: mirrored ? w * 0.42 : -w * 0.42,
                    y: -h * 0.037)
    }
}

// MARK: - One of the four great cups

private struct GrandCup: View {
    let award: Achievement
    let won: Bool
    let standing: Int

    /// The cup's short name — "Bronze Cup" and "Diamond Trophy" both want to
    /// be one word on a plaque this narrow.
    private var shortName: String {
        award.title
            .replacingOccurrences(of: " Trophy", with: "")
            .replacingOccurrences(of: " Cup", with: "")
    }

    /// Which metal this cup is cast in. Driven off the award's own id so the
    /// shelf cannot drift out of step with the catalogue.
    private var metal: TrophyCupIcon.Metal {
        switch award.id {
        case "cup.bronze":  return .bronze
        case "cup.silver":  return .silver
        case "cup.diamond": return .diamond
        default:            return .gold
        }
    }

    var body: some View {
        VStack(spacing: 6) {
            TrophyCupIcon(metal: metal, lit: won, height: 56)
                .frame(height: 58)

            VStack(spacing: 1) {
                Text(shortName)
                    .font(Theme.bold(11))
                    .foregroundColor(Vault.goldPale)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)

                Text("\(standing) / \(award.target)")
                    .font(Theme.bold(11))
                    .foregroundColor(Vault.gold)
                    .contentTransition(.numericText())
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 5)
            .padding(.horizontal, 3)
            .background(RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Vault.plaque))
            .overlay(RoundedRectangle(cornerRadius: 8, style: .continuous)
                .strokeBorder(Vault.metal, lineWidth: 1.5))
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(won ? "\(award.title), won"
                                : "\(award.title). \(award.detail). \(standing) of \(award.target)")
    }
}

// MARK: - One adventure's alcove

private struct AdventureNiche: View {
    @EnvironmentObject private var progress: GameProgress
    let island: Island

    private var rungs: [Achievement] { progress.ladder(for: island) }
    private var wonCount: Int { rungs.filter { progress.hasWon($0) }.count }
    private var top: Achievement? { progress.topRung(for: island) }
    private var next: Achievement? { progress.nextRung(for: island) }
    private var lit: Bool { wonCount > 0 }

    var body: some View {
        VStack(spacing: 7) {
            alcove
            nameplate
            pips

            if let next {
                Text("\(progress.standing(next))/\(next.target) \(unit(next))")
                    .font(Theme.bold(11))
                    .foregroundColor(Vault.goldPale.opacity(0.75))
                    .contentTransition(.numericText())
            } else {
                Text("Mastered! 👑")
                    .font(Theme.bold(11))
                    .foregroundColor(Vault.gold)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 11)
        .padding(.horizontal, 8)
        .background(RoundedRectangle(cornerRadius: 17, style: .continuous)
            // Very slightly see-through, so the hall's lamplight comes up
            // through the stone and the alcove sits in the room rather than
            // on top of a picture of one.
            .fill(LinearGradient(colors: [Vault.stone.opacity(0.92),
                                          Vault.stoneDeep.opacity(0.94)],
                                 startPoint: .top, endPoint: .bottom)))
        .overlay(RoundedRectangle(cornerRadius: 17, style: .continuous)
            .strokeBorder(Vault.metal, lineWidth: lit ? 2.5 : 1.8)
            .opacity(lit ? 1 : 0.75))
        .shadow(color: .black.opacity(0.35), radius: 5, y: 3)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(island.name), \(wonCount) of \(rungs.count) trophies won")
    }

    /// The lit recess: the adventure's own artwork set back into the wall,
    /// behind a gold arch. Unlit until the first trophy, so the room visibly
    /// wakes up one alcove at a time.
    /// The carved frame's size on screen, and where its hole is inside it.
    /// The hole was measured off the artwork: it is the one transparent
    /// region that does not reach the edge of the plate.
    private static let frameSize = CGSize(width: 104, height: 119)
    private static let opening = CGRect(x: 0.2217, y: 0.1544,
                                        width: 0.5558, height: 0.7718)

    /// The picture behind is cut a little larger than the hole. Two reasons,
    /// both visible the moment it is not: a square picture pokes its top
    /// corners out beside the dome, and an ordinary semicircle falls short of
    /// this frame's slightly pointed one, leaving a sliver of nothing at the
    /// apex. Oversized, both ends of the problem tuck under the gold.
    private static let overlap: CGFloat = 1.08

    /// The drawn frame's size, kept smaller — it has no carving to show off.
    private static let drawnSize = CGSize(width: 74, height: 84)

    @ViewBuilder
    private var alcove: some View {
        if VaultArt.has(VaultArt.arch) { paintedAlcove } else { drawnAlcove }
    }

    private var paintedAlcove: some View {
        let f = Self.frameSize
        let o = Self.opening

        return ZStack {
            ZStack {
                RadialGradient(colors: [Vault.gold.opacity(lit ? 0.42 : 0.26),
                                        Vault.night],
                               center: .center, startRadius: 2, endRadius: 70)
                islandPicture
            }
            .frame(width: f.width * o.width * Self.overlap,
                   height: f.height * o.height * Self.overlap)
            .clipShape(ArchShape(foot: 7))
            // The hole sits a little below the plate's middle.
            .offset(y: (o.midY - 0.5) * f.height)

            Image(VaultArt.arch)
                .resizable()
                .frame(width: f.width, height: f.height)

            cornerBadge.offset(x: f.width * 0.36, y: f.height * 0.33)
        }
        .frame(width: f.width, height: f.height)
    }

    private var drawnAlcove: some View {
        let f = Self.drawnSize

        return ZStack {
            ArchShape()
                .fill(RadialGradient(
                    colors: [Vault.gold.opacity(lit ? 0.42 : 0.26), Vault.night],
                    center: .center, startRadius: 2, endRadius: 58))

            islandPicture
                .frame(width: f.width, height: f.height)
                .clipShape(ArchShape())

            ArchShape()
                .strokeBorder(Vault.metal, lineWidth: lit ? 3.5 : 2.5)
                .opacity(lit ? 1 : 0.8)

            cornerBadge.offset(x: 30, y: 30)
        }
        .frame(width: f.width, height: f.height)
    }

    /// Always at full colour. An adventure the child has not scored in yet is
    /// still a place they can see; draining it grey says the artwork is
    /// switched off, and with nothing won that is the whole room. Won and
    /// unwon are told apart by the frame, the pips and the count — none of
    /// which cost the picture its colour.
    @ViewBuilder
    private var islandPicture: some View {
        if let name = island.imageName {
            Image(name).resizable().scaledToFill()
        } else {
            Text(island.emoji).font(.system(size: 34))
        }
    }

    /// The best rung so far rides on the corner of the arch — and nothing
    /// rides there until there is one.
    ///
    /// This used to show a padlock instead, which said the wrong thing. None
    /// of these adventures is locked: every one can be played, and the room
    /// is open to everyone. The padlock only meant "no trophy here yet", and
    /// the pips and the count underneath already say that without implying a
    /// door that does not exist.
    @ViewBuilder
    private var cornerBadge: some View {
        if let top {
            Text(top.emoji)
                .font(.system(size: 23))
                .shadow(color: .black.opacity(0.55), radius: 2)
        }
    }

    /// The painted plaque, cropped of its transparent margin, and the bare
    /// wood inside its gold rail — both measured off the artwork.
    private static let plateAspect: CGFloat = 4.38
    private static let plateInner = CGRect(x: 0.075, y: 0.15,
                                           width: 0.85, height: 0.70)

    @ViewBuilder
    private var nameplate: some View {
        if VaultArt.has(VaultArt.plate) { paintedPlate } else { drawnPlate }
    }

    /// Scaled whole rather than nine-sliced, even though this plaque — unlike
    /// the big sign — has nothing in its middle to protect. A nine-slice keeps
    /// its caps at a fixed point size, and the source is four times the size
    /// this is drawn at, so the flared ends would arrive far too big for the
    /// plank between them.
    private var paintedPlate: some View {
        Image(VaultArt.plate)
            .resizable()
            .aspectRatio(Self.plateAspect, contentMode: .fit)
            .frame(maxWidth: .infinity)
            .overlay(
                GeometryReader { geo in
                    Text(island.name)
                        .font(Theme.bold(12))
                        .foregroundColor(Vault.goldPale)
                        .lineLimit(1)
                        .minimumScaleFactor(0.55)
                        .shadow(color: .black.opacity(0.5), radius: 1, y: 1)
                        .frame(width: geo.size.width * Self.plateInner.width,
                               height: geo.size.height * Self.plateInner.height)
                        .position(x: geo.size.width * Self.plateInner.midX,
                                  y: geo.size.height * Self.plateInner.midY)
                }
            )
    }

    private var drawnPlate: some View {
        Text(island.name)
            .font(Theme.bold(12))
            .foregroundColor(Vault.goldPale)
            .lineLimit(1)
            .minimumScaleFactor(0.6)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .frame(maxWidth: .infinity)
            .background(RoundedRectangle(cornerRadius: 7, style: .continuous)
                .fill(Vault.plaque))
            .overlay(RoundedRectangle(cornerRadius: 7, style: .continuous)
                .strokeBorder(Vault.goldDeep, lineWidth: 1.2))
    }

    /// Five little gems: the ladder at a glance.
    private var pips: some View {
        HStack(spacing: 5) {
            ForEach(rungs) { rung in
                // An empty pip is a dim socket, not a black hole — it still
                // has to look like a gem waiting to be set.
                Circle()
                    .fill(progress.hasWon(rung)
                          ? AnyShapeStyle(Vault.metal)
                          : AnyShapeStyle(Vault.goldDeep.opacity(0.40)))
                    .frame(width: 7, height: 7)
                    .overlay(Circle().strokeBorder(Vault.gold.opacity(0.7),
                                                   lineWidth: 0.8))
            }
        }
    }

    private func unit(_ award: Achievement) -> String {
        if case .islandLevelsCleared = award.measure { return "levels" }
        return "right"
    }
}

// MARK: - One adventure's ladder, in full


// MARK: - One award, as both lists draw it

/// A single achievement laid out the way the paintings do: a coloured card
/// with a gold medal at the left, what it asks in the middle, and the chest
/// it pays out at the right.
///
/// Shared by the Trophy Room's Special Achievements and by an adventure's
/// own ladder, which draw the same row from different catalogues.
struct AwardCard: View {
    let award: Achievement
    let face: [Color]
    let w: CGFloat
    let won: Bool
    let standing: Int

    private var share: CGFloat {
        award.target > 0 ? min(1, CGFloat(standing) / CGFloat(award.target)) : 0
    }

    var body: some View {

        HStack(spacing: w * 0.018) {
            medal(award, w: w)

            VStack(alignment: .leading, spacing: w * 0.007) {
                Text(award.title)
                    .font(.system(size: w * 0.046, weight: .black, design: .rounded))
                    .foregroundColor(Color(red: 0.13, green: 0.09, blue: 0.25))
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)

                Text(award.detail)
                    .font(.system(size: w * 0.030, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(red: 0.18, green: 0.14, blue: 0.30))
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)

                trackBar(share: won ? 1 : share, w: w)

                Text(won ? "Completed!" : remainingLine(standing, of: award.target))
                    .font(.system(size: w * 0.032, weight: .heavy, design: .rounded))
                    .foregroundColor(Color(red: 0.13, green: 0.09, blue: 0.25))
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            reward(award, won: won, w: w)
        }
        .padding(.horizontal, w * 0.022)
        .padding(.vertical, w * 0.016)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: w * 0.042, style: .continuous)
                .fill(LinearGradient(colors: face, startPoint: .topLeading,
                                     endPoint: .bottomTrailing))
                .overlay(
                    RoundedRectangle(cornerRadius: w * 0.042, style: .continuous)
                        .strokeBorder(.white.opacity(0.85), lineWidth: max(2, w * 0.005))
                )
                .shadow(color: .black.opacity(0.35), radius: w * 0.014, y: w * 0.005)
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(won
            ? "\(award.title), completed. \(award.detail)"
            : "\(award.title). \(award.detail). \(remainingLine(standing, of: award.target))")
    }

    private func medal(_ award: Achievement, w: CGFloat) -> some View {
        let gold = LinearGradient(colors: [Color(red: 1.00, green: 0.91, blue: 0.48),
                                           Color(red: 0.93, green: 0.62, blue: 0.09)],
                                  startPoint: .top, endPoint: .bottom)
        return ZStack {
            Circle().fill(gold)
            Circle().strokeBorder(.white.opacity(0.9), lineWidth: max(2, w * 0.005))
            Circle()
                .fill(RadialGradient(colors: [.white.opacity(0.75), .clear],
                                     center: .topLeading, startRadius: 0, endRadius: w * 0.09))
            Text(award.emoji).font(.system(size: w * 0.055))
        }
        .frame(width: w * 0.115, height: w * 0.115)
        .shadow(color: .black.opacity(0.28), radius: w * 0.008, y: w * 0.003)
    }

    private func trackBar(share: CGFloat, w: CGFloat) -> some View {
        GeometryReader { bar in
            ZStack(alignment: .leading) {
                Capsule().fill(Color.black.opacity(0.32))
                Capsule()
                    .fill(LinearGradient(colors: [Color(red: 0.70, green: 0.98, blue: 0.42),
                                                  Color(red: 0.32, green: 0.80, blue: 0.16)],
                                         startPoint: .top, endPoint: .bottom))
                    .frame(width: share > 0
                           ? max(bar.size.height, bar.size.width * share)
                           : 0)
            }
            .overlay(Capsule().strokeBorder(.white.opacity(0.6), lineWidth: 1.5))
        }
        .frame(height: w * 0.028)
    }

    @ViewBuilder
    private func reward(_ award: Achievement, won: Bool, w: CGFloat) -> some View {
        if won {
            HStack(spacing: w * 0.010) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: w * 0.036, weight: .black))
                Text("Done!")
                    .font(.system(size: w * 0.034, weight: .heavy, design: .rounded))
            }
            .foregroundColor(.white)
            .padding(.horizontal, w * 0.024)
            .padding(.vertical, w * 0.014)
            .background(Capsule().fill(LinearGradient(
                colors: [Color(red: 0.40, green: 0.86, blue: 0.40),
                         Color(red: 0.10, green: 0.66, blue: 0.26)],
                startPoint: .top, endPoint: .bottom)))
            .overlay(Capsule().strokeBorder(.white, lineWidth: max(1.5, w * 0.004)))
            .shadow(color: .black.opacity(0.28), radius: w * 0.008, y: w * 0.003)
        } else if award.opensChest {
            Image("TrophyChest")
                .resizable().scaledToFit().frame(width: w * 0.115)
                .shadow(color: .black.opacity(0.3), radius: w * 0.008, y: w * 0.003)
        } else {
            Image(systemName: "chevron.right")
                .font(.system(size: w * 0.050, weight: .black))
                .foregroundColor(.white.opacity(0.9))
                .shadow(color: .black.opacity(0.35), radius: 2, y: 1)
                .frame(width: w * 0.070)
        }
    }

}

/// One adventure's ladder: its five rungs, over that island's own scenery.
///
/// Every island is built the same way — its drifting background dimmed
/// right down, its badge and name above, and the five cards in front. The
/// Jungle page was painted for a while and the rest generated to match it;
/// seen side by side the generated ones read better, so the painting went
/// and all ten are drawn.
private struct AdventureLadderSheet: View {
    @EnvironmentObject private var progress: GameProgress
    @Environment(\.dismiss) private var dismiss
    let island: Island

    /// "Jungle" out of "BgJungle".
    private var key: String {
        guard let bg = island.backgroundImageName, bg.hasPrefix("Bg") else { return "" }
        return String(bg.dropFirst(2))
    }

    /// The island's round badge, where the catalogue has one.
    private var badge: String? {
        let name = "Island" + key
        return key.isEmpty || UIImage(named: name) == nil ? nil : name
    }

    /// The five rungs' colours, taken off the painted page: bronze, silver,
    /// gold, then the Explorer Cup and the Master Crown.
    private static let rungFace: [[Color]] = [
        [Color(red: 0.72, green: 0.48, blue: 0.25), Color(red: 0.49, green: 0.22, blue: 0.06)],
        [Color(red: 0.40, green: 0.70, blue: 0.95), Color(red: 0.01, green: 0.38, blue: 0.76)],
        [Color(red: 0.98, green: 0.80, blue: 0.30), Color(red: 0.76, green: 0.46, blue: 0.04)],
        [Color(red: 0.66, green: 0.42, blue: 0.95), Color(red: 0.39, green: 0.09, blue: 0.80)],
        [Color(red: 0.40, green: 0.82, blue: 0.45), Color(red: 0.02, green: 0.54, blue: 0.19)]
    ]

    private var tally: String {
        "\(progress.bestCorrect(inIsland: island.id)) of 100 questions right"
    }

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    header(w)

                    VStack(spacing: w * 0.022) {
                        ForEach(Array(progress.ladder(for: island).enumerated()),
                                id: \.element.id) { pair in
                            AwardCard(award: pair.element,
                                      face: Self.rungFace[pair.offset % Self.rungFace.count],
                                      w: w,
                                      won: progress.hasWon(pair.element),
                                      standing: progress.standing(pair.element))
                        }
                    }
                    .padding(.horizontal, w * 0.016)
                    .padding(.vertical, w * 0.022)

                    footer(w)
                }
            }
            .background(backdrop)
            // Always there, however far down the page you are.
            .overlay(alignment: .topLeading) {
                backButton(w)
                    .padding(.leading, w * 0.030)
                    .padding(.top, w * 0.020)
            }
        }
    }

    /// The island's own scenery, behind everything. On a painted page it only
    /// shows between and around the rows.
    private var backdrop: some View {
        ZStack {
            IslandBackground(island: island)
            Color.black.opacity(0.18)
        }
        .ignoresSafeArea()
    }

    // MARK: - Header

    /// The island's badge, its name and its tally, over its own scenery.
    private func header(_ w: CGFloat) -> some View {
        VStack(spacing: w * 0.020) {
            // Clipped round with a gold ring. The badges are not consistent
            // about transparency — some carry an alpha cut-out and some are
            // opaque squares — so left as they are, a few islands would show
            // a square pasted on the scenery and the rest would not.
            Group {
                if let badge {
                    Image(badge).resizable().scaledToFill()
                } else {
                    Text(island.emoji).font(.system(size: w * 0.150))
                }
            }
            .frame(width: w * 0.260, height: w * 0.260)
            .clipShape(Circle())
            .overlay(
                Circle().strokeBorder(LinearGradient(
                    colors: [Color(red: 1.00, green: 0.91, blue: 0.48),
                             Color(red: 0.93, green: 0.62, blue: 0.09)],
                    startPoint: .top, endPoint: .bottom),
                    lineWidth: max(3, w * 0.010))
            )
            .shadow(color: .black.opacity(0.40), radius: w * 0.016, y: w * 0.006)

            OutlinedText(plain: island.name,
                         font: .system(size: w * 0.084, weight: .black, design: .rounded),
                         outline: Color(red: 0.24, green: 0.12, blue: 0.03),
                         width: max(2, w * 0.006)) {
                Text(island.name).foregroundStyle(LinearGradient(
                    colors: [Color(red: 1.00, green: 0.95, blue: 0.62),
                             Color(red: 1.00, green: 0.78, blue: 0.20),
                             Color(red: 0.93, green: 0.55, blue: 0.06)],
                    startPoint: .top, endPoint: .bottom))
            }

            Text(tally)
                .font(.system(size: w * 0.040, weight: .heavy, design: .rounded))
                .foregroundColor(Color(red: 0.28, green: 0.16, blue: 0.05))
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .padding(.horizontal, w * 0.055)
                .padding(.vertical, w * 0.020)
                .background(plank(w))

            Text("EXPLORE  ·  LEARN  ·  GROW")
                .font(.system(size: w * 0.034, weight: .heavy, design: .rounded))
                .foregroundColor(Color(red: 0.30, green: 0.18, blue: 0.06))
                .padding(.horizontal, w * 0.055)
                .padding(.vertical, w * 0.014)
                .background(plank(w))
        }
        .padding(.top, w * 0.130)
        .padding(.bottom, w * 0.020)
        .frame(width: w)
    }

    private func plank(_ w: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: w * 0.030, style: .continuous)
            .fill(LinearGradient(colors: [Color(red: 0.99, green: 0.95, blue: 0.84),
                                          Color(red: 0.92, green: 0.85, blue: 0.68)],
                                 startPoint: .top, endPoint: .bottom))
            .overlay(
                RoundedRectangle(cornerRadius: w * 0.030, style: .continuous)
                    .strokeBorder(Color(red: 0.55, green: 0.38, blue: 0.16),
                                  lineWidth: max(2, w * 0.005))
            )
            .shadow(color: .black.opacity(0.30), radius: w * 0.012, y: w * 0.004)
    }

    // MARK: - Footer

    private func footer(_ w: CGFloat) -> some View {
        Text("Every Question\nMakes You Stronger!")
                .font(.system(size: w * 0.048, weight: .black, design: .rounded))
                .foregroundColor(Color(red: 0.30, green: 0.18, blue: 0.06))
                .multilineTextAlignment(.center)
                .padding(.horizontal, w * 0.060)
                .padding(.vertical, w * 0.028)
                .background(plank(w))
                .padding(.vertical, w * 0.050)
    }

    private func backButton(_ w: CGFloat) -> some View {
        Button {
            Haptics.play(.light)
            dismiss()
        } label: {
            Image(systemName: "chevron.left")
                .font(.system(size: w * 0.046, weight: .black))
                .foregroundColor(.white)
                .frame(width: w * 0.100, height: w * 0.100)
                .background(
                    Circle().fill(LinearGradient(
                        colors: [Color(red: 0.36, green: 0.70, blue: 0.98),
                                 Color(red: 0.13, green: 0.46, blue: 0.88)],
                        startPoint: .top, endPoint: .bottom))
                )
                .overlay(Circle().strokeBorder(.white, lineWidth: max(2, w * 0.006)))
                .shadow(color: .black.opacity(0.4), radius: w * 0.010, y: w * 0.004)
        }
        .buttonStyle(PressableButtonStyle())
        .accessibilityLabel("Back to the trophy room")
    }
}


private struct VaultCloseButton: View {
    var label: String = "Close"
    let action: () -> Void

    var body: some View {
        Button {
            Haptics.play(.light)
            action()
        } label: {
            Image(systemName: "xmark")
                .font(.system(size: 19, weight: .black))
                .foregroundColor(Vault.goldPale)
                .frame(width: 46, height: 46)
                .background(Circle().fill(Vault.woodDeep.opacity(0.94)))
                .overlay(Circle().strokeBorder(Vault.gold, lineWidth: 2.5))
                .shadow(color: .black.opacity(0.55), radius: 7, y: 3)
        }
        .buttonStyle(PressableButtonStyle())
        .padding(.trailing, 18)
        .padding(.top, 18)
        .accessibilityLabel(label)
    }
}

// MARK: - One award on a row

/// A painted card, one colour each. A locked award keeps its colour and shows
/// how close it is, with a present on the end for the prize waiting inside —
/// greying it out would say "no", and the whole point of this room is "nearly".
struct AwardRow: View {
    let award: Achievement
    let won: Bool
    let standing: Int
    var tint: Color = Vault.card(0)

    private var fraction: Double {
        guard award.target > 0 else { return 0 }
        return min(1, Double(standing) / Double(award.target))
    }

    var body: some View {
        HStack(spacing: 12) {
            medallion

            VStack(alignment: .leading, spacing: 3) {
                Text(award.title)
                    .font(Theme.bold(16))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.35), radius: 1, y: 1)

                Text(award.detail)
                    .font(Theme.medium(12))
                    .foregroundColor(.white.opacity(0.85))
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .fixedSize(horizontal: false, vertical: true)

                if won {
                    Text("Completed!")
                        .font(Theme.bold(12))
                        .foregroundColor(Vault.goldPale)
                        .padding(.top, 1)
                } else {
                    ProgressTrack(fraction: fraction)
                        .frame(height: 7)
                        .padding(.top, 3)
                    Text(remainingLine(standing, of: award.target))
                        .font(Theme.bold(12))
                        .foregroundColor(Vault.goldPale)
                        .shadow(color: .black.opacity(0.4), radius: 1)
                }
            }

            Spacer(minLength: 2)

            seal
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 11)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                // The lower stop is only a shade down, not a fade to the wall.
                // Taking it much further let the dark room through and turned
                // every card muddy at the bottom.
                .fill(LinearGradient(colors: [tint, tint.opacity(0.80)],
                                     startPoint: .top, endPoint: .bottom))
        )
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous)
            .strokeBorder(won ? AnyShapeStyle(Vault.metal)
                              : AnyShapeStyle(Color.black.opacity(0.28)),
                          lineWidth: won ? 2.5 : 1.5))
        .shadow(color: .black.opacity(0.4), radius: 5, y: 3)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(won ? "\(award.title), won"
                                : "\(award.title). \(award.detail). \(standing) of \(award.target)")
    }

    private var medallion: some View {
        ZStack {
            Circle()
                .fill(RadialGradient(colors: [.white.opacity(0.42), .white.opacity(0.12)],
                                     center: .topLeading,
                                     startRadius: 2, endRadius: 46))
                .frame(width: 46, height: 46)
                .overlay(Circle().strokeBorder(
                    won ? AnyShapeStyle(Vault.metal)
                        : AnyShapeStyle(Color.white.opacity(0.35)),
                    lineWidth: won ? 2.5 : 1.5))

            Text(award.emoji)
                .font(.system(size: 25))
                .shadow(color: .black.opacity(0.3), radius: 1, y: 1)
        }
    }

    @ViewBuilder
    private var seal: some View {
        if won {
            ZStack {
                // A white disc behind it, or a green tick on a green card
                // would disappear into it.
                Circle().fill(.white).frame(width: 21, height: 21)
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 27))
                    .foregroundColor(Theme.correct)
            }
            .shadow(color: .black.opacity(0.3), radius: 2, y: 1)
        } else if award.opensChest {
            HStack(spacing: 2) {
                if VaultArt.has(VaultArt.chest) {
                    Image(VaultArt.chest)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 26, height: 26)
                } else {
                    Text("🎁").font(.system(size: 21))
                }
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white.opacity(0.8))
            }
        }
    }
}

#Preview {
    TrophyRoomView().environmentObject(GameProgress())
}
