//
//  StickerBook.swift
//  QuizApp
//
//  The child's very own sticker book. Jewels earned from quizzes can be spent
//  in the sticker shop, and owned stickers can be placed anywhere across the
//  book's pages — dragged, resized and peeled off freely.
//
//  Stickers currently use cheerful emoji as placeholders. When real sticker
//  artwork is added to Assets.xcassets, set each Sticker's `imageName` and it
//  will show the picture instead of the emoji automatically.
//

import SwiftUI

// MARK: - Models

/// A collectable sticker sold in the shop.
struct Sticker: Identifiable, Hashable {
    let id: String
    let emoji: String
    let cost: Int
    /// Optional asset name for real sticker art (falls back to the emoji).
    var imageName: String? = nil
}

/// A sticker the child has stuck into their book at a spot on a page.
struct PlacedSticker: Identifiable, Codable, Hashable {
    var id = UUID()
    var stickerID: String
    var page: Int
    /// Position as a fraction of the page (0…1) so it survives rotation/resize.
    var x: Double
    var y: Double
    var scale: Double = 1
    var rotation: Double = 0
}

/// A little text box the child has dropped onto a page. Like a sticker it
/// lives at a fraction of the page so it survives rotation and resizing, and
/// it can be dragged anywhere and written in.
struct PlacedNote: Identifiable, Codable, Hashable {
    var id = UUID()
    var page: Int
    /// Position as a fraction of the page (0…1).
    var x: Double
    var y: Double
    var text: String = ""
}

/// A themed group of stickers in the shop (e.g. "Animal Kingdom"). Each
/// category has a Cute tier (50 jewels) and an Epic tier (100 jewels).
struct StickerCategory: Identifiable {
    let id: String
    let name: String
    let emoji: String
    let cute: [Sticker]
    let epic: [Sticker]

    var count: Int { cute.count + epic.count }
}

/// The stickers available in the shop, organised into themed categories.
/// Every 50 jewels buys one sticker: the Cute tier is 50 jewels each and the
/// fancier Epic tier is 100 jewels each.
enum StickerCatalog {
    static let cuteCost = 50
    static let epicCost = 100

    private static func cuteSticker(_ n: Int) -> Sticker {
        Sticker(id: "animal_c\(n)", emoji: "🐾", cost: cuteCost,
                imageName: String(format: "StickerC%02d", n))
    }
    private static func epicSticker(_ n: Int) -> Sticker {
        Sticker(id: "animal_e\(n)", emoji: "👑", cost: epicCost,
                imageName: String(format: "StickerE%02d", n))
    }

    /// 🦁 Animal Kingdom — a hand-picked set of cute and epic animals.
    static let animalKingdom = StickerCategory(
        id: "animals",
        name: "Animal Kingdom",
        emoji: "🦁",
        cute: [
            cuteSticker(1),   // lion
            cuteSticker(2),   // tiger
            cuteSticker(4),   // monkey
            cuteSticker(5),   // giraffe
            cuteSticker(6),   // panda
            cuteSticker(8),   // cat
            cuteSticker(9),   // dog
            cuteSticker(11),  // otter
            cuteSticker(12),  // hedgehog
            cuteSticker(13)   // raccoon
        ],
        epic: [
            epicSticker(18),  // pink deer
            epicSticker(19),  // gold lion
            epicSticker(20),  // fairy bunny
            epicSticker(21),  // crowned unicorn
            epicSticker(22),  // royal elephant
            epicSticker(23)   // flower deer
        ]
    )

    private static func galaxySticker(_ n: Int) -> Sticker {
        Sticker(id: "galaxy_c\(n)", emoji: "🚀", cost: cuteCost,
                imageName: String(format: "StickerG%02d", n))
    }
    private static func galaxyEpicSticker(_ n: Int) -> Sticker {
        Sticker(id: "galaxy_e\(n)", emoji: "🌌", cost: epicCost,
                imageName: String(format: "StickerGE%02d", n))
    }

    /// 🚀 Galaxy Quest — cute space explorers and friendly planets.
    static let galaxyQuest = StickerCategory(
        id: "galaxy",
        name: "Galaxy Quest",
        emoji: "🚀",
        cute: [
            galaxySticker(1),  // astronaut penguin
            galaxySticker(2),  // smiling ringed planet
            galaxySticker(3),  // bunny on a rocket
            galaxySticker(4),  // astronaut boy on the moon
            galaxySticker(5)   // astronaut elephant
        ],
        epic: [
            galaxyEpicSticker(1),  // star fighter streaking past a galaxy
            galaxyEpicSticker(2),  // astronaut watching a ringed planet
            galaxyEpicSticker(3),  // star wizard juggling planets
            galaxyEpicSticker(4),  // unicorn astronaut on a cloud
            galaxyEpicSticker(5),  // alien flying a saucer
            galaxyEpicSticker(6)   // robot astronaut hugging a star
        ]
    )

    private static func dinoSticker(_ n: Int) -> Sticker {
        Sticker(id: "dino_c\(n)", emoji: "🦕", cost: cuteCost,
                imageName: String(format: "StickerD%02d", n))
    }
    private static func dinoEpicSticker(_ n: Int) -> Sticker {
        Sticker(id: "dino_e\(n)", emoji: "🦖", cost: epicCost,
                imageName: String(format: "StickerDE%02d", n))
    }

    /// 🦖 Dino Valley — friendly baby dinosaurs from the prehistoric trail.
    static let dinoValley = StickerCategory(
        id: "dino",
        name: "Dino Valley",
        emoji: "🦖",
        cute: [
            dinoSticker(1),  // baby T. rex by a footprint sign
            dinoSticker(2),  // brachiosaurus munching leaves
            dinoSticker(3),  // triceratops with a flower crown
            dinoSticker(4),  // stegosaurus with sunset plates
            dinoSticker(5)   // hatchling in a cracked egg
        ],
        epic: [
            dinoEpicSticker(1),  // crystal ankylosaurus with a gem club
            dinoEpicSticker(2),  // spinosaurus before a volcano
            dinoEpicSticker(3),  // T. rex wearing a leaf necklace
            dinoEpicSticker(4),  // crystal triceratops in blossom
            dinoEpicSticker(5),  // roaring T. rex at sunset
            dinoEpicSticker(6),  // crowned crystal T. rex by a waterfall
            dinoEpicSticker(7)   // chef triceratops with a burger
        ]
    )

    private static func oceanSticker(_ n: Int) -> Sticker {
        Sticker(id: "ocean_c\(n)", emoji: "🐬", cost: cuteCost,
                imageName: String(format: "StickerO%02d", n))
    }
    private static func oceanEpicSticker(_ n: Int) -> Sticker {
        Sticker(id: "ocean_e\(n)", emoji: "🌊", cost: epicCost,
                imageName: String(format: "StickerOE%02d", n))
    }

    /// 🐬 Ocean Paradise — cheerful friends from the reef and the waves.
    static let oceanParadise = StickerCategory(
        id: "ocean",
        name: "Ocean Paradise",
        emoji: "🐬",
        cute: [
            oceanSticker(1),  // leaping dolphin in a splash
            oceanSticker(2),  // spouting whale over a wave
            oceanSticker(3),  // sea turtle above the coral
            oceanSticker(4),  // octopus with a pearl
            oceanSticker(5),   // crab holding a scallop shell
            oceanSticker(6),   // clownfish in a pink anemone
            oceanSticker(7),   // seahorse with a rainbow fin
            oceanSticker(8),   // pufferfish over the coral
            oceanSticker(9),   // seal pup with a starfish friend
            oceanSticker(10)   // squid among the bubbles
        ],
        epic: [
            oceanEpicSticker(1),  // galaxy orca full of stars
            oceanEpicSticker(2),  // crowned whale shark with pearls
            oceanEpicSticker(3),  // jewelled lobster by a treasure chest
            oceanEpicSticker(4),  // angelfish queen before a coral palace
            oceanEpicSticker(5),  // dolphin leaping through a wave
            oceanEpicSticker(6),  // crowned lionfish over the reef
            oceanEpicSticker(7),  // pearl nautilus princess
            oceanEpicSticker(8)   // rainbow mantis shrimp on the gems
        ]
    )

    private static func explorerSticker(_ n: Int) -> Sticker {
        Sticker(id: "explorer_c\(n)", emoji: "🧭", cost: cuteCost,
                imageName: String(format: "StickerX%02d", n))
    }

    /// 🧭 Explorer's Trail — wandering the world, one landmark at a time.
    static let explorersTrail = StickerCategory(
        id: "explorer",
        name: "Explorer's Trail",
        emoji: "🧭",
        cute: [
            explorerSticker(1),  // explorer girl with binoculars and a globe
            explorerSticker(2),  // hot-air balloon over the world
            explorerSticker(3),  // smiling suitcase ready to travel
            explorerSticker(4),  // London bus by Big Ben
            explorerSticker(5)   // Paris and the Eiffel Tower
        ],
        epic: []
    )

    /// All categories shown in the shop (more will be added over time).
    static let categories: [StickerCategory] = [
        animalKingdom, galaxyQuest, dinoValley, oceanParadise, explorersTrail
    ]

    static let all: [Sticker] = categories.flatMap { $0.cute + $0.epic }

    static let byID: [String: Sticker] = Dictionary(
        uniqueKeysWithValues: all.map { ($0.id, $0) })
}

// MARK: - Sticker glyph

/// Draws a sticker: the real artwork if it has one, otherwise the emoji.
struct StickerGlyph: View {
    let sticker: Sticker
    var size: CGFloat

    var body: some View {
        Group {
            if let name = sticker.imageName {
                Image(name).resizable().scaledToFit()
            } else {
                Text(sticker.emoji).font(.system(size: size * 0.9))
            }
        }
        .frame(width: size, height: size)
        .shadow(color: .black.opacity(0.18), radius: 3, y: 2)
    }
}

// MARK: - Map button (a cute little closed book)

/// The "My Sticker Book" cover art used as the button on the Adventure Map.
struct StickerBookIcon: View {
    var body: some View {
        Image("StickerBookCover")
            .resizable()
            .scaledToFit()
            .frame(width: 66, height: 66)
            .shadow(color: .black.opacity(0.3), radius: 5, y: 3)
    }
}

// MARK: - Sticker book

struct StickerBookView: View {
    @EnvironmentObject private var progress: GameProgress
    @Environment(\.dismiss) private var dismiss

    private let totalPages = 25
    @State private var currentPage = 0
    @State private var showShop = false
    /// The leaf currently being turned, if any.
    @State private var flip: FlipState?
    /// How far the turning leaf has rotated, in degrees.
    @State private var leafAngle: Double = 0
    @State private var isFlipping = false

    /// Describes a page turn in progress: which spread we are leaving, which
    /// we are heading to, and whether the leaf is still on its way to the
    /// spine (`.lifting`) or coming back down on the other side (`.landing`).
    private struct FlipState {
        enum Stage { case lifting, landing }
        let forward: Bool
        let from: Int
        let to: Int
        var stage: Stage
    }

    /// The leaf stops just short of edge-on. At exactly 90° the perspective
    /// projection is degenerate and produces non-finite geometry, so the
    /// content swap happens here instead.
    private let leafEdge: Double = 88
    /// The text box currently open for typing, if any.
    @State private var editingNote: UUID?

    var body: some View {
        GeometryReader { geo in
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.62, green: 0.78, blue: 1.00),
                        Color(red: 0.86, green: 0.80, blue: 1.00),
                        Color(red: 1.00, green: 0.85, blue: 0.95)
                    ],
                    startPoint: .top, endPoint: .bottom
                )
                .ignoresSafeArea()

                // The book, with clear space above and below, then the
                // controls. Only laid out once the container reports a usable
                // size, so the inner padding can never produce a negative
                // dimension.
                if geo.size.width > 120 && geo.size.height > 120 {
                    VStack(spacing: 10) {
                        Spacer(minLength: 6)
                        bookArea
                            .frame(width: geo.size.width - 24,
                                   height: geo.size.height * 0.58)
                        controlBar
                        Spacer(minLength: 6)
                    }
                }
            }
        }
        // Turning the page puts away whatever was being typed.
        .onChange(of: currentPage) { _ in editingNote = nil }
        .sheet(isPresented: $showShop) {
            StickerShopSheet { sticker in
                // Drop the new sticker in the middle of the current page.
                progress.placeSticker(sticker.id, page: currentPage, x: 0.5, y: 0.5)
                Haptics.play(.light)
                Sound.stickerPop()
            }
            .environmentObject(progress)
        }
    }

    /// A pink circular button gradient, matching the storybook look.
    private var pinkButton: LinearGradient {
        LinearGradient(colors: [
            Color(red: 1.00, green: 0.46, blue: 0.72),
            Color(red: 1.00, green: 0.30, blue: 0.58)
        ], startPoint: .top, endPoint: .bottom)
    }

    // MARK: - The virtual book

    /// A thick pink-to-purple book cover.
    private var coverGradient: LinearGradient {
        LinearGradient(colors: [
            Color(red: 1.00, green: 0.44, blue: 0.72),
            Color(red: 0.62, green: 0.36, blue: 0.96)
        ], startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    private var bookArea: some View {
        ZStack {
            bookCover
            pageSpread
            closeOverlay
            arrowsOverlay
        }
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 24)
                .onEnded { value in
                    if value.translation.width < -40 { turn(forward: true) }
                    else if value.translation.width > 40 { turn(forward: false) }
                }
        )
    }

    /// The thick pink/purple book cover.
    private var bookCover: some View {
        RoundedRectangle(cornerRadius: 30, style: .continuous)
            .fill(coverGradient)
            .overlay(
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .stroke(.white.opacity(0.4), lineWidth: 2)
            )
            .shadow(color: .black.opacity(0.3), radius: 16, y: 10)
            .padding(.horizontal, 10)
    }

    /// The open cream two-page spread, inset so the cover shows as a thick
    /// edge. A page turn lifts a single leaf around the spine in the middle,
    /// the way a real book does, rather than swinging the whole spread.
    private var pageSpread: some View {
        ZStack {
            baseSpread
            if let f = flip {
                turningLeaf(f)
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
    }

    /// What lies flat on the table: mid-turn the two halves come from
    /// different spreads, so the page being uncovered shows through.
    @ViewBuilder
    private var baseSpread: some View {
        if let f = flip {
            let leftPage = f.forward ? f.from : f.to
            let rightPage = f.forward ? f.to : f.from
            ZStack {
                leaf(page: leftPage, side: .left)
                leaf(page: rightPage, side: .right)
            }
        } else {
            StickerPageView(page: currentPage, totalPages: totalPages,
                            editing: $editingNote)
        }
    }

    /// The single leaf in the air, rotating about the spine.
    private func turningLeaf(_ f: FlipState) -> some View {
        // Lifting shows the face we are leaving; landing shows the far side of
        // the same leaf, which is a page of the spread we are turning to.
        let side: LeafSide
        let page: Int
        switch (f.forward, f.stage) {
        case (true, .lifting):   side = .right; page = f.from
        case (true, .landing):   side = .left;  page = f.to
        case (false, .lifting):  side = .left;  page = f.from
        case (false, .landing):  side = .right; page = f.to
        }

        // Paper darkens as it stands up, which sells the lift.
        let shade = min(0.45, abs(leafAngle) / leafEdge * 0.45)

        return leaf(page: page, side: side)
            .overlay(LeafClip(side: side).fill(Color.black.opacity(shade)))
            .rotation3DEffect(.degrees(leafAngle),
                              axis: (x: 0, y: 1, z: 0),
                              anchor: .center,
                              perspective: 0.5)
            .shadow(color: .black.opacity(0.35), radius: 10,
                    x: f.forward ? -8 : 8)
    }

    /// One half of a spread, clipped down the spine.
    private func leaf(page: Int, side: LeafSide) -> some View {
        StickerPageView(page: page, totalPages: totalPages, editing: $editingNote)
            .clipShape(LeafClip(side: side))
    }

    /// The small close button in the top-right corner of the book.
    private var closeOverlay: some View {
        VStack {
            HStack {
                Spacer()
                roundButton(system: "xmark", enabled: true) {
                    Haptics.play(.light)
                    dismiss()
                }
            }
            Spacer()
        }
        .padding(.top, 4)
        .padding(.trailing, 2)
    }

    /// The page-turn arrows on the left and right sides.
    private var arrowsOverlay: some View {
        HStack {
            roundButton(system: "chevron.left", enabled: currentPage > 0) {
                turn(forward: false)
            }
            Spacer()
            roundButton(system: "chevron.right", enabled: currentPage < totalPages - 1) {
                turn(forward: true)
            }
        }
    }

    private var controlBar: some View {
        VStack(spacing: 6) {
            HStack(spacing: 10) {
                Button {
                    Haptics.play(.light)
                    showShop = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Stickers")
                    }
                    .font(Theme.bold(17))
                    .foregroundColor(.white)
                    .padding(.vertical, 13)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(Theme.nextButton)
                    )
                    .shadow(color: .black.opacity(0.2), radius: 6, y: 3)
                }
                .buttonStyle(PressableButtonStyle())

                // Drops a fresh text box onto the page, ready to type in.
                Button {
                    Haptics.play(.light)
                    Sound.stickerPop()
                    editingNote = progress.addNote(page: currentPage, x: 0.5, y: 0.42)
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "textformat")
                        Text("Text")
                    }
                    .font(Theme.bold(17))
                    .foregroundColor(.white)
                    .padding(.vertical, 13)
                    .padding(.horizontal, 18)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(pinkButton)
                    )
                    .shadow(color: .black.opacity(0.2), radius: 6, y: 3)
                }
                .buttonStyle(PressableButtonStyle())
                .accessibilityLabel("Add a text box")
            }

            Text("Page \(currentPage + 1) of \(totalPages)  •  Drag a text box anywhere")
                .font(Theme.medium(11))
                .foregroundColor(Theme.inkSoft)
        }
        .padding(.horizontal, 30)
        .padding(.bottom, 8)
    }

    private func roundButton(system: String, enabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: system)
                .font(Theme.bold(18))
                .foregroundColor(.white)
                .frame(width: 46, height: 46)
                .background(Circle().fill(enabled ? AnyShapeStyle(pinkButton)
                                                  : AnyShapeStyle(Color.gray.opacity(0.4))))
                .overlay(Circle().stroke(.white.opacity(0.75), lineWidth: 2))
                .shadow(color: .black.opacity(0.25), radius: 4, y: 2)
        }
        .buttonStyle(PressableButtonStyle())
        .disabled(!enabled)
    }

    /// Turns a single leaf around the spine, the way a real book does: the
    /// half nearest the edge lifts, stands up at the middle, then falls flat
    /// on the other side. Done in two stages so the leaf never crosses the
    /// degenerate 90° point with its content on the wrong face.
    private func turn(forward: Bool) {
        guard !isFlipping else { return }
        let target = currentPage + (forward ? 1 : -1)
        guard target >= 0 && target < totalPages else { return }

        isFlipping = true
        Haptics.play(.light)
        Sound.pageFlip()

        flip = FlipState(forward: forward, from: currentPage, to: target, stage: .lifting)
        leafAngle = 0

        // Stage 1: the leaf lifts off the page and stands up at the spine.
        let lifted = forward ? -leafEdge : leafEdge
        withAnimation(.easeIn(duration: 0.26)) { leafAngle = lifted }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.26) {
            // Stage 2: swap to the leaf's far side and let it fall flat.
            flip?.stage = .landing
            leafAngle = -lifted
            withAnimation(.easeOut(duration: 0.26)) { leafAngle = 0 }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.27) {
                currentPage = target
                flip = nil
                leafAngle = 0
                isFlipping = false
            }
        }
    }
}

// MARK: - Leaf clipping

/// Which half of the spread a leaf is.
private enum LeafSide { case left, right }

/// Clips a spread down the spine so only one leaf shows.
private struct LeafClip: Shape {
    let side: LeafSide

    func path(in rect: CGRect) -> Path {
        let half = rect.width / 2
        let r = side == .left
            ? CGRect(x: rect.minX, y: rect.minY, width: half, height: rect.height)
            : CGRect(x: rect.midX, y: rect.minY, width: half, height: rect.height)
        return Path(r)
    }
}

// MARK: - A single book page

private struct StickerPageView: View {
    let page: Int
    let totalPages: Int
    /// The text box open for typing, shared so only one is ever open.
    @Binding var editing: UUID?
    @EnvironmentObject private var progress: GameProgress

    /// A soft pastel tint that varies gently from page to page.
    private var pageTint: Color {
        let tints: [Color] = [
            Color(red: 1.00, green: 0.98, blue: 0.92),
            Color(red: 0.94, green: 0.99, blue: 0.95),
            Color(red: 0.95, green: 0.96, blue: 1.00),
            Color(red: 1.00, green: 0.95, blue: 0.97),
            Color(red: 0.98, green: 0.97, blue: 1.00)
        ]
        return tints[page % tints.count]
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // The open two-page book spread (cream paper).
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(pageTint)
                    .overlay(
                        // Soft shadow down the centre — the book's spine/gutter.
                        LinearGradient(
                            colors: [.clear, .black.opacity(0.20), .black.opacity(0.20), .clear],
                            startPoint: .leading, endPoint: .trailing)
                            .frame(width: 40)
                            .blur(radius: 4)
                    )
                    .overlay(
                        // A crisp centre crease line.
                        Rectangle()
                            .fill(.black.opacity(0.10))
                            .frame(width: 1.5)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(.white, lineWidth: 3)
                    )
                    .shadow(color: .black.opacity(0.25), radius: 14, y: 8)

                // One faint page number per spread, so the book counts the same
                // way the caption underneath it does.
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Text("\(page + 1)")
                            .font(Theme.bold(14))
                            .foregroundColor(Theme.inkSoft.opacity(0.30))
                            .padding(.trailing, 22)
                    }
                    .padding(.bottom, 14)
                }

                // Plain paper — stickers go wherever the child wants them.
                ForEach(progress.stickers(onPage: page)) { placed in
                    PlacedStickerView(placed: placed, pageSize: geo.size)
                }

                // Text boxes sit above the stickers so they stay readable.
                ForEach(progress.notes(onPage: page)) { note in
                    PlacedNoteView(note: note, pageSize: geo.size, editing: $editing)
                }
            }
        }
    }
}

// MARK: - A text box the child can move around the page and write in

/// A little card of paper the child drops on a page. Drag it anywhere; tap it
/// to type. Long-press removes it, matching how stickers behave.
private struct PlacedNoteView: View {
    let note: PlacedNote
    let pageSize: CGSize
    @Binding var editing: UUID?
    @EnvironmentObject private var progress: GameProgress

    @State private var dragOffset: CGSize = .zero
    @State private var draft = ""
    @FocusState private var focused: Bool

    /// Enough for a couple of lines in a child's handwriting.
    private let limit = 120

    private var isEditing: Bool { editing == note.id }
    private var boxWidth: CGFloat { max(120, pageSize.width * 0.30) }

    var body: some View {
        let baseX = note.x * pageSize.width
        let baseY = note.y * pageSize.height

        card
            .frame(width: boxWidth)
            .overlay(alignment: .topTrailing) { closeButton }
            .position(x: baseX + dragOffset.width, y: baseY + dragOffset.height)
            // While typing, the box stays put so the drag can't fight the
            // keyboard or the text selection.
            .gesture(isEditing ? nil : dragGesture(baseX: baseX, baseY: baseY))
            .simultaneousGesture(isEditing ? nil : deleteGesture)
            .onAppear {
                draft = note.text
                if isEditing { focused = true }
            }
            .onChange(of: isEditing) { nowEditing in
                if nowEditing {
                    draft = note.text
                    focused = true
                } else {
                    focused = false
                }
            }
    }

    private var card: some View {
        VStack(alignment: .leading, spacing: 6) {
            if isEditing {
                TextField("Write here…", text: $draft, axis: .vertical)
                    .font(Theme.medium(13))
                    .foregroundColor(Theme.ink)
                    .lineLimit(1...4)
                    .focused($focused)
                    .onChange(of: draft) { value in
                        if value.count > limit {
                            draft = String(value.prefix(limit))
                            return
                        }
                        progress.setNoteText(note.id, text: value)
                    }

                Button("Done") {
                    Haptics.play(.light)
                    progress.setNoteText(note.id, text: draft)
                    editing = nil
                }
                .font(Theme.bold(12))
                .foregroundColor(Color(red: 0.545, green: 0.361, blue: 0.965))
            } else {
                Text(note.text.isEmpty ? "Tap to write…" : note.text)
                    .font(Theme.medium(13))
                    .foregroundColor(note.text.isEmpty ? Theme.inkSoft : Theme.ink)
                    .lineLimit(4)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Theme.didYouKnow)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(isEditing ? Color(red: 0.545, green: 0.361, blue: 0.965)
                                  : Theme.inkSoft.opacity(0.35),
                        lineWidth: isEditing ? 2 : 1.5)
        )
        .shadow(color: .black.opacity(0.18), radius: 5, y: 3)
        .contentShape(Rectangle())
        .onTapGesture {
            if !isEditing {
                Haptics.play(.light)
                editing = note.id
            }
        }
    }

    /// A little red cross on the corner that throws the text box away.
    private var closeButton: some View {
        Button {
            Haptics.play(.light)
            if isEditing { editing = nil }
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                progress.removeNote(note.id)
            }
        } label: {
            Image(systemName: "xmark")
                .font(.system(size: 10, weight: .heavy))
                .foregroundColor(.white)
                .frame(width: 22, height: 22)
                .background(Circle().fill(Theme.incorrect))
                .overlay(Circle().stroke(.white, lineWidth: 1.5))
                .shadow(color: .black.opacity(0.25), radius: 2, y: 1)
        }
        .buttonStyle(.plain)
        .offset(x: 9, y: -9)
        .accessibilityLabel("Delete this text box")
    }

    private func dragGesture(baseX: CGFloat, baseY: CGFloat) -> some Gesture {
        DragGesture()
            .onChanged { value in dragOffset = value.translation }
            .onEnded { value in
                let nx = clamp((baseX + value.translation.width) / pageSize.width)
                let ny = clamp((baseY + value.translation.height) / pageSize.height)
                dragOffset = .zero
                progress.moveNote(note.id, x: nx, y: ny)
            }
    }

    private var deleteGesture: some Gesture {
        LongPressGesture(minimumDuration: 0.6)
            .onEnded { _ in
                Haptics.play(.success)
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    progress.removeNote(note.id)
                }
            }
    }

    private func clamp(_ v: CGFloat) -> Double {
        Double(min(max(v, 0.08), 0.92))
    }
}

// MARK: - A placed sticker the child can move, resize and remove

private struct PlacedStickerView: View {
    let placed: PlacedSticker
    let pageSize: CGSize
    @EnvironmentObject private var progress: GameProgress

    @State private var dragOffset: CGSize = .zero
    @State private var liveScale: CGFloat = 1

    private var sticker: Sticker? { StickerCatalog.byID[placed.stickerID] }

    var body: some View {
        if let sticker {
            let baseX = placed.x * pageSize.width
            let baseY = placed.y * pageSize.height

            StickerGlyph(sticker: sticker, size: 74)
                .scaleEffect(CGFloat(placed.scale) * liveScale)
                .position(x: baseX + dragOffset.width, y: baseY + dragOffset.height)
                .gesture(
                    DragGesture()
                        .onChanged { value in dragOffset = value.translation }
                        .onEnded { value in
                            let nx = clamp((baseX + value.translation.width) / pageSize.width)
                            let ny = clamp((baseY + value.translation.height) / pageSize.height)
                            dragOffset = .zero
                            progress.updatePlaced(placed.id, x: nx, y: ny,
                                                  scale: placed.scale, rotation: placed.rotation)
                        }
                )
                .simultaneousGesture(
                    MagnificationGesture()
                        .onChanged { value in liveScale = value }
                        .onEnded { value in
                            let newScale = min(max(placed.scale * Double(value), 0.5), 2.6)
                            liveScale = 1
                            progress.updatePlaced(placed.id, x: placed.x, y: placed.y,
                                                  scale: newScale, rotation: placed.rotation)
                        }
                )
                .simultaneousGesture(
                    LongPressGesture(minimumDuration: 0.6)
                        .onEnded { _ in
                            Haptics.play(.success)
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                progress.removePlaced(placed.id)
                            }
                        }
                )
        }
    }

    private func clamp(_ v: CGFloat) -> Double {
        Double(min(max(v, 0.05), 0.95))
    }
}

// MARK: - Sticker shop

struct StickerShopSheet: View {
    @EnvironmentObject private var progress: GameProgress
    @Environment(\.dismiss) private var dismiss

    /// Called when the child taps an owned sticker to place it in the book.
    let onPlace: (Sticker) -> Void

    /// The category being browsed, or nil while choosing a category.
    @State private var selected: StickerCategory?

    private let columns = [GridItem(.adaptive(minimum: 96), spacing: 14)]

    var body: some View {
        VStack(spacing: 12) {
            topBar

            if let category = selected {
                stickerList(category)
            } else {
                categoryList
            }
        }
        .background(Theme.homeBackground.ignoresSafeArea())
    }

    private var topBar: some View {
        HStack(spacing: 10) {
            if selected != nil {
                Button {
                    Haptics.play(.light)
                    withAnimation(.easeInOut(duration: 0.2)) { selected = nil }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(Theme.bold(16))
                        .foregroundColor(Theme.ink)
                        .frame(width: 34, height: 34)
                        .background(Circle().fill(Color.black.opacity(0.06)))
                }
            }

            Text(selected?.name ?? "Sticker Shop")
                .font(Theme.display(22))
                .foregroundColor(Theme.ink)

            Spacer()

            HStack(spacing: 5) {
                JewelIcon(size: 18)
                Text("\(progress.jewels)")
                    .font(Theme.bold(15))
                    .foregroundStyle(Theme.jewelPink)
            }
            .padding(.horizontal, 12)
            .frame(height: 36)
            .background(Capsule().fill(Color.black.opacity(0.06)))
        }
        .padding(.horizontal, 18)
        .padding(.top, 18)
    }

    private var categoryList: some View {
        VStack(spacing: 14) {
            Text("Pick a collection to explore!")
                .font(Theme.medium(13))
                .foregroundColor(Theme.inkSoft)

            ScrollView {
                VStack(spacing: 14) {
                    ForEach(StickerCatalog.categories) { category in
                        categoryCard(category)
                    }
                }
                .padding(.horizontal, 18)
                .padding(.bottom, 24)
            }
        }
    }

    private func categoryCard(_ category: StickerCategory) -> some View {
        Button {
            Haptics.play(.light)
            withAnimation(.easeInOut(duration: 0.2)) { selected = category }
        } label: {
            HStack(spacing: 14) {
                Text(category.emoji).font(.system(size: 44))
                VStack(alignment: .leading, spacing: 3) {
                    Text(category.name)
                        .font(Theme.display(20))
                        .foregroundColor(Theme.ink)
                    Text("\(category.count) stickers")
                        .font(Theme.medium(13))
                        .foregroundColor(Theme.inkSoft)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(Theme.bold(16))
                    .foregroundColor(Theme.inkSoft)
            }
            .padding(18)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(.white.opacity(0.8))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(.white, lineWidth: 2)
            )
            .shadow(color: .black.opacity(0.1), radius: 6, y: 3)
        }
        .buttonStyle(PressableButtonStyle())
    }

    private func stickerList(_ category: StickerCategory) -> some View {
        VStack(spacing: 8) {
            Text("Buy stickers with your jewels, then tap one to stick it in your book!")
                .font(Theme.medium(13))
                .foregroundColor(Theme.inkSoft)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)

            ScrollView {
                if !category.cute.isEmpty {
                    section(title: "🌸 Cute Collection",
                            subtitle: "50 jewels each",
                            stickers: category.cute)
                }

                if !category.epic.isEmpty {
                    section(title: "✨ Epic Collection",
                            subtitle: "100 jewels each",
                            stickers: category.epic)
                        .padding(.top, 4)
                }
            }
        }
    }

    private func section(title: String, subtitle: String, stickers: [Sticker]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Text(title).font(Theme.display(18)).foregroundColor(Theme.ink)
                Text(subtitle)
                    .font(Theme.bold(12))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10).padding(.vertical, 3)
                    .background(Capsule().fill(Theme.inkSoft.opacity(0.8)))
                Spacer()
            }
            .padding(.horizontal, 18)

            LazyVGrid(columns: columns, spacing: 14) {
                ForEach(stickers) { shopCell($0) }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 18)
        }
    }

    private func shopCell(_ sticker: Sticker) -> some View {
        let owned = progress.owns(sticker)
        let affordable = progress.jewels >= sticker.cost

        return VStack(spacing: 8) {
            StickerGlyph(sticker: sticker, size: 58)
                .opacity(owned || affordable ? 1 : 0.5)
                .grayscale(owned || affordable ? 0 : 0.6)

            if owned {
                Label("Place", systemImage: "hand.tap.fill")
                    .font(Theme.bold(12))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12).padding(.vertical, 5)
                    .background(Capsule().fill(Theme.correct))
            } else {
                HStack(spacing: 4) {
                    JewelIcon(size: 15)
                    Text("\(sticker.cost)")
                        .font(Theme.bold(13))
                        .foregroundStyle(affordable ? AnyShapeStyle(Theme.jewelPink)
                                                    : AnyShapeStyle(Theme.inkSoft))
                }
                .padding(.horizontal, 12).padding(.vertical, 5)
                .background(Capsule().fill(Color.white.opacity(0.85)))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.white.opacity(0.7))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(owned ? Theme.correct.opacity(0.6) : .white, lineWidth: 2)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            if owned {
                onPlace(sticker)
                dismiss()
            } else if affordable {
                Haptics.play(.success)
                progress.buySticker(sticker)
            } else {
                Haptics.play(.error)
            }
        }
    }
}

#Preview {
    StickerBookView().environmentObject(GameProgress())
}
