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

// MARK: - The room

struct TrophyRoomView: View {
    @EnvironmentObject private var progress: GameProgress
    @Environment(\.dismiss) private var dismiss
    @AppStorage(Player.nameKey) private var playerName = ""

    @State private var appeared = false
    @State private var openIsland: Island?

    private let islands = QuizData.islands

    var body: some View {
        ZStack {
            VaultBackdrop()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 22) {
                    header
                    grandCupShelf
                    pedestalShelf
                    ultimatePedestal
                    badgeShelf
                    Color.clear.frame(height: 20)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
        }
        .overlay(alignment: .topTrailing) { closeButton }
        .sheet(item: $openIsland) { island in
            AdventureLadderSheet(island: island)
                .environmentObject(progress)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.4)) { appeared = true }
        }
    }

    private var closeButton: some View {
        Button {
            Haptics.play(.light)
            dismiss()
        } label: {
            Image(systemName: "xmark")
                .font(Theme.bold(16))
                .foregroundColor(Vault.woodDeep)
                .padding(11)
                .background(Circle().fill(Vault.metal))
                .overlay(Circle().stroke(Vault.goldDeep, lineWidth: 1.5))
                .shadow(color: .black.opacity(0.45), radius: 5, y: 2)
        }
        .buttonStyle(PressableButtonStyle())
        .padding(.trailing, 16)
        .padding(.top, 10)
        .accessibilityLabel("Close the trophy room")
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: 9) {
            Text("👑")
                .font(.system(size: 34))
                .shadow(color: Vault.gold.opacity(0.7), radius: 10)

            VaultBanner(text: playerName.isEmpty
                        ? "My Trophy Room"
                        : "\(playerName)'s Trophy Room",
                        size: 23)

            floatingLine("\(progress.trophyCount) of \(AchievementCatalog.all.count) won",
                         size: 14)

            HStack(spacing: 9) {
                stat("✅", "\(progress.tally.correctAnswers)", "correct")
                stat("📚", "\(progress.tally.questionsAnswered)", "answered")
                stat("🔥", "\(progress.tally.bestStreak)", "best streak")
            }
            .padding(.top, 4)
        }
        .padding(.top, 40)
    }

    private func floatingLine(_ text: String, size: CGFloat) -> some View {
        HallLine(text: text, size: size)
    }

    private func stat(_ icon: String, _ value: String, _ label: String) -> some View {
        VStack(spacing: 2) {
            Text(icon).font(.system(size: 15))
            Text(value)
                .font(Theme.bold(18))
                .foregroundColor(Vault.goldPale)
                .contentTransition(.numericText())
            Text(label)
                .font(Theme.medium(11))
                .foregroundColor(Vault.goldPale.opacity(0.65))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 9)
        .background(RoundedRectangle(cornerRadius: 13, style: .continuous)
            .fill(Vault.plaque))
        .overlay(RoundedRectangle(cornerRadius: 13, style: .continuous)
            .strokeBorder(Vault.metal, lineWidth: 2))
        .shadow(color: .black.opacity(0.35), radius: 4, y: 2)
    }

    // MARK: - The top shelf

    private var grandCupShelf: some View {
        HStack(spacing: 8) {
            ForEach(AchievementCatalog.grandCups) { award in
                GrandCup(award: award,
                         won: progress.hasWon(award),
                         standing: progress.standing(award))
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 10)
        .background(ShelfPlinth())
    }

    // MARK: - The ten alcoves

    private var pedestalShelf: some View {
        VStack(spacing: 13) {
            VaultBanner(text: "Adventure Trophies", size: 19, maxWidth: 310)

            floatingLine("\(progress.pedestalsFilled) of 10 pedestals filled", size: 12)

            LazyVGrid(columns: [GridItem(.flexible(), spacing: 11),
                                GridItem(.flexible(), spacing: 11)], spacing: 11) {
                ForEach(Array(islands.enumerated()), id: \.element.id) { pair in
                    AdventureNiche(island: pair.element)
                        .onTapGesture {
                            Haptics.play(.light)
                            openIsland = pair.element
                        }
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 14)
                        .animation(.spring(response: 0.5, dampingFraction: 0.85)
                            .delay(Double(pair.offset) * 0.035), value: appeared)
                }
            }
        }
    }

    // MARK: - The one at the end

    private var ultimatePedestal: some View {
        let award = AchievementCatalog.ultimate
        let won = progress.hasWon(award)
        let filled = progress.pedestalsFilled

        return VStack(spacing: 8) {
            TrophyCupIcon(metal: .gold, lit: won, height: 74)
                .frame(height: 76)

            Text(award.title)
                .font(Theme.display(20))
                .foregroundColor(Vault.goldPale)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.7)

            Text(won ? "Every pedestal filled!" : "Fill all 10 pedestals")
                .font(Theme.medium(13))
                .foregroundColor(Vault.goldPale.opacity(0.75))

            if won {
                Text("+250 💎 and a legendary sticker")
                    .font(Theme.bold(13))
                    .foregroundColor(Vault.gold)
            } else {
                ProgressTrack(fraction: Double(filled) / 10)
                    .frame(height: 8)
                    .padding(.horizontal, 34)
                    .padding(.top, 2)

                Text(remainingLine(filled, of: 10))
                    .font(Theme.bold(13))
                    .foregroundColor(Vault.gold)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .padding(.horizontal, 14)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(LinearGradient(
                    colors: won ? [Vault.goldDeep.opacity(0.70), Vault.stoneDeep]
                                : [Vault.stone, Vault.stoneDeep],
                    startPoint: .top, endPoint: .bottom))
        )
        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous)
            .strokeBorder(Vault.metal, lineWidth: won ? 3.5 : 2.5))
        .shadow(color: won ? Vault.gold.opacity(0.55) : .black.opacity(0.4),
                radius: won ? 16 : 6, y: 3)
        .accessibilityElement(children: .combine)
    }

    // MARK: - Special achievements

    private var badgeShelf: some View {
        VStack(spacing: 13) {
            VaultBanner(text: "Special Achievements", size: 19, maxWidth: 310)

            VStack(spacing: 10) {
                ForEach(Array(AchievementCatalog.badges.enumerated()), id: \.element.id) { pair in
                    AwardRow(award: pair.element,
                             won: progress.hasWon(pair.element),
                             standing: progress.standing(pair.element),
                             tint: Vault.card(pair.offset))
                }
            }
        }
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
            TrophyCupIcon(metal: metal, lit: won, height: 52)
                .frame(height: 54)

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
    private var alcove: some View {
        ZStack {
            ArchShape()
                .fill(RadialGradient(
                    colors: [Vault.gold.opacity(lit ? 0.42 : 0.26), Vault.night],
                    center: .center, startRadius: 2, endRadius: 58))

            // Always at full colour. An adventure the child has not scored in
            // yet is still a place they can see; draining it grey says the
            // artwork is switched off, and with nothing won that is the whole
            // room. Won and unwon are told apart by the frame, the padlock
            // and the pips — none of which cost the picture its colour.
            if let name = island.imageName {
                Image(name)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 74, height: 84)
                    .clipShape(ArchShape())
            } else {
                Text(island.emoji).font(.system(size: 34))
            }

            if VaultArt.has(VaultArt.arch) {
                Image(VaultArt.arch)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 74, height: 84)
            } else {
                ArchShape()
                    .strokeBorder(Vault.metal, lineWidth: lit ? 3.5 : 2.5)
                    .opacity(lit ? 1 : 0.8)
            }

            // The best rung so far rides on the corner of the arch.
            if let top {
                Text(top.emoji)
                    .font(.system(size: 23))
                    .shadow(color: .black.opacity(0.55), radius: 2)
                    .offset(x: 30, y: 30)
            } else {
                Image(systemName: "lock.fill")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Vault.goldPale.opacity(0.85))
                    .padding(5)
                    .background(Circle().fill(Vault.woodDeep))
                    .overlay(Circle().strokeBorder(Vault.goldDeep, lineWidth: 1))
                    .offset(x: 30, y: 30)
            }
        }
        .frame(width: 74, height: 84)
    }

    private var nameplate: some View {
        Text(island.name)
            .font(Theme.bold(12))
            .foregroundColor(Vault.goldPale)
            .lineLimit(1)
            .minimumScaleFactor(0.6)
            .padding(.horizontal, 8)
            .padding(.vertical, VaultArt.has(VaultArt.plate) ? 7 : 4)
            .frame(maxWidth: .infinity)
            .background(plateBacking)
    }

    @ViewBuilder
    private var plateBacking: some View {
        if VaultArt.has(VaultArt.plate) {
            Image(VaultArt.plate)
                .resizable(capInsets: EdgeInsets(top: 12, leading: 30,
                                                 bottom: 12, trailing: 30),
                           resizingMode: .stretch)
        } else {
            RoundedRectangle(cornerRadius: 7, style: .continuous)
                .fill(Vault.plaque)
                .overlay(RoundedRectangle(cornerRadius: 7, style: .continuous)
                    .strokeBorder(Vault.goldDeep, lineWidth: 1.2))
        }
    }

    /// Five little jewels: the ladder at a glance.
    private var pips: some View {
        HStack(spacing: 5) {
            ForEach(rungs) { rung in
                // An empty pip is a dim socket, not a black hole — it still
                // has to look like a jewel waiting to be set.
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

private struct AdventureLadderSheet: View {
    @EnvironmentObject private var progress: GameProgress
    @Environment(\.dismiss) private var dismiss
    let island: Island

    var body: some View {
        ZStack {
            VaultBackdrop()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 13) {
                    Text(island.emoji)
                        .font(.system(size: 42))
                        .padding(.top, 8)

                    VaultBanner(text: island.name, size: 21, maxWidth: 320)

                    HallLine(text: "\(progress.bestCorrect(inIsland: island.id)) of 100 questions right")

                    VStack(spacing: 10) {
                        ForEach(Array(progress.ladder(for: island).enumerated()),
                                id: \.element.id) { pair in
                            AwardRow(award: pair.element,
                                     won: progress.hasWon(pair.element),
                                     standing: progress.standing(pair.element),
                                     tint: Vault.card(pair.offset))
                        }
                    }
                    .padding(.top, 4)
                }
                .padding(18)
            }
        }
        .overlay(alignment: .topTrailing) {
            Button {
                Haptics.play(.light)
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(Theme.bold(15))
                    .foregroundColor(Vault.woodDeep)
                    .padding(10)
                    .background(Circle().fill(Vault.metal))
                    .overlay(Circle().strokeBorder(Vault.goldDeep, lineWidth: 1.5))
            }
            .buttonStyle(PressableButtonStyle())
            .padding(16)
            .accessibilityLabel("Close")
        }
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
