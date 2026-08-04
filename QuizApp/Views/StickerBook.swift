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

    /// 🦁 Animal Kingdom — the ten hand-picked cute animal stickers.
    static let animalKingdom = StickerCategory(
        id: "animals",
        name: "Animal Kingdom",
        emoji: "🦁",
        cute: (1...10).map { n in
            Sticker(id: "animal_c\(n)", emoji: "🐾", cost: cuteCost,
                    imageName: String(format: "StickerC%02d", n))
        },
        epic: []
    )

    /// All categories shown in the shop (more will be added over time).
    static let categories: [StickerCategory] = [animalKingdom]

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
    @State private var flipAngle: Double = 0
    @State private var isFlipping = false

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

                // The book, centred with clear space above and below.
                bookArea
                    .frame(width: geo.size.width - 24,
                           height: geo.size.height * 0.60)
                    .position(x: geo.size.width / 2, y: geo.size.height * 0.46)

                // Add Stickers button sits in the space below the book.
                VStack {
                    Spacer()
                    controlBar
                        .padding(.bottom, 20)
                }
            }
        }
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
    /// edge, flipping around the spine on the left.
    private var pageSpread: some View {
        let liftShadow = abs(flipAngle) > 1 ? 0.35 : 0.0
        let shadowX: CGFloat = flipAngle < 0 ? -10 : 10
        return StickerPageView(page: currentPage, totalPages: totalPages)
            .rotation3DEffect(.degrees(flipAngle),
                              axis: (x: 0, y: 1, z: 0),
                              anchor: .leading,
                              perspective: 0.35)
            .shadow(color: .black.opacity(liftShadow), radius: 12, x: shadowX)
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
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

            Text("Page \(currentPage + 1) of \(totalPages)  •  Swipe or tap the arrows")
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

    /// Flips one page like a real book, around the spine on the left.
    private func turn(forward: Bool) {
        guard !isFlipping else { return }
        if forward && currentPage >= totalPages - 1 { return }
        if !forward && currentPage <= 0 { return }
        isFlipping = true
        Haptics.play(.light)
        Sound.pageFlip()

        let awayAngle: Double = forward ? -105 : 105
        withAnimation(.easeIn(duration: 0.22)) { flipAngle = awayAngle }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
            currentPage += forward ? 1 : -1
            flipAngle = -awayAngle
            withAnimation(.easeOut(duration: 0.22)) { flipAngle = 0 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.24) { isFlipping = false }
        }
    }
}

// MARK: - A single book page

private struct StickerPageView: View {
    let page: Int
    let totalPages: Int
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

                // Faint page numbers in the outer bottom corners.
                VStack {
                    Spacer()
                    HStack {
                        Text("\(page * 2 + 1)")
                            .padding(.leading, 22)
                        Spacer()
                        Text("\(page * 2 + 2)")
                            .padding(.trailing, 22)
                    }
                    .font(Theme.bold(14))
                    .foregroundColor(Theme.inkSoft.opacity(0.30))
                    .padding(.bottom, 14)
                }

                // Cute empty sticker spaces dotted across both pages.
                ForEach(Array(spaceSpots.enumerated()), id: \.offset) { pair in
                    stickerSpace(pair.element, pageSize: geo.size)
                }

                // Placed stickers, spread across both pages (on top of the spaces).
                ForEach(progress.stickers(onPage: page)) { placed in
                    PlacedStickerView(placed: placed, pageSize: geo.size)
                }
            }
        }
    }

    /// One decorative dashed sticker slot.
    private func stickerSpace(_ spot: Spot, pageSize: CGSize) -> some View {
        let side = pageSize.width * 0.13
        return RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(spot.tint.opacity(0.10))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(spot.tint.opacity(0.55),
                                  style: StrokeStyle(lineWidth: 2, dash: [6, 5]))
            )
            .overlay(
                Image(systemName: "sparkle")
                    .font(.system(size: 15))
                    .foregroundColor(spot.tint.opacity(0.55))
            )
            .frame(width: side, height: side)
            .position(x: spot.x * pageSize.width, y: spot.y * pageSize.height)
    }

    /// Positions and pastel tints for the decorative empty sticker spaces.
    private struct Spot { let x: Double; let y: Double; let tint: Color }
    private var spaceSpots: [Spot] {
        [
            Spot(x: 0.17, y: 0.32, tint: Color(red: 1.00, green: 0.50, blue: 0.70)),
            Spot(x: 0.34, y: 0.60, tint: Color(red: 0.55, green: 0.60, blue: 1.00)),
            Spot(x: 0.17, y: 0.75, tint: Color(red: 0.45, green: 0.80, blue: 0.55)),
            Spot(x: 0.66, y: 0.32, tint: Color(red: 1.00, green: 0.68, blue: 0.35)),
            Spot(x: 0.83, y: 0.60, tint: Color(red: 0.72, green: 0.48, blue: 1.00)),
            Spot(x: 0.66, y: 0.75, tint: Color(red: 1.00, green: 0.50, blue: 0.70))
        ]
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
