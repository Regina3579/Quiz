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

/// The stickers available in the shop, split into two collections.
/// Every 50 jewels buys one sticker: the Cute collection is 50 jewels each
/// and the fancier Epic collection is 100 jewels each.
enum StickerCatalog {
    static let cuteCost = 50
    static let epicCost = 100

    /// The friendly, free-to-reach Cute collection (50 jewels each).
    static let cute: [Sticker] = (1...20).map { n in
        Sticker(id: "cute\(n)", emoji: "🐾", cost: cuteCost,
                imageName: String(format: "StickerC%02d", n))
    }

    /// The premium Epic collection (100 jewels each).
    static let epic: [Sticker] = (1...20).map { n in
        Sticker(id: "epic\(n)", emoji: "👑", cost: epicCost,
                imageName: String(format: "StickerE%02d", n))
    }

    static let all: [Sticker] = cute + epic

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

/// A small standing sticker book used as the button on the Adventure Map.
struct StickerBookIcon: View {
    var body: some View {
        VStack(spacing: 3) {
            ZStack(alignment: .leading) {
                // Pages peeking out behind the cover.
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(.white)
                    .frame(width: 50, height: 60)
                    .offset(x: 6)
                    .shadow(color: .black.opacity(0.25), radius: 3, y: 2)

                // The colourful cover.
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(
                        LinearGradient(colors: [
                            Color(red: 1.00, green: 0.45, blue: 0.72),
                            Color(red: 0.66, green: 0.42, blue: 0.98)
                        ], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .frame(width: 52, height: 64)
                    .overlay(alignment: .leading) {
                        // The spine.
                        Rectangle().fill(.black.opacity(0.18)).frame(width: 7)
                    }
                    .overlay {
                        VStack(spacing: 2) {
                            Text("⭐️").font(.system(size: 20))
                            Text("Stickers")
                                .font(.system(size: 8, weight: .heavy, design: .rounded))
                                .foregroundColor(.white)
                        }
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .stroke(.white.opacity(0.6), lineWidth: 1.5)
                    )
                    .shadow(color: .black.opacity(0.3), radius: 4, y: 3)
            }

            Text("My Book")
                .font(Theme.bold(11))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.4), radius: 2, y: 1)
        }
        .frame(width: 62)
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

            VStack(spacing: 10) {
                header

                bookArea

                controlBar
            }
            .padding(.top, 6)
        }
        .sheet(isPresented: $showShop) {
            StickerShopSheet { sticker in
                // Drop the new sticker in the middle of the current page.
                progress.placeSticker(sticker.id, page: currentPage, x: 0.5, y: 0.5)
                Haptics.play(.light)
            }
            .environmentObject(progress)
        }
    }

    private var header: some View {
        HStack {
            Button {
                Haptics.play(.light)
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(Theme.bold(16))
                    .foregroundColor(Theme.ink)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(.white.opacity(0.8)))
            }

            Spacer()

            VStack(spacing: 1) {
                Text("My Sticker Book")
                    .font(Theme.display(20))
                    .foregroundColor(Theme.ink)
                Text("Page \(currentPage + 1) of \(totalPages)")
                    .font(Theme.medium(12))
                    .foregroundColor(Theme.inkSoft)
            }

            Spacer()

            HStack(spacing: 5) {
                Image(systemName: "diamond.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(Theme.jewelPink)
                Text("\(progress.jewels)")
                    .font(Theme.bold(15))
                    .foregroundStyle(Theme.jewelPink)
            }
            .padding(.horizontal, 12)
            .frame(height: 40)
            .background(Capsule().fill(.white.opacity(0.8)))
        }
        .padding(.horizontal, 16)
    }

    // MARK: - The virtual book

    private var bookArea: some View {
        ZStack {
            // Leather book cover behind the page.
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(
                    LinearGradient(colors: [
                        Color(red: 0.55, green: 0.28, blue: 0.60),
                        Color(red: 0.40, green: 0.18, blue: 0.48)
                    ], startPoint: .top, endPoint: .bottom)
                )
                .shadow(color: .black.opacity(0.3), radius: 12, y: 8)

            // Stacked page edges peeking out on the right for a booky look.
            HStack {
                Spacer()
                RoundedRectangle(cornerRadius: 8)
                    .fill(.white.opacity(0.85))
                    .frame(width: 10)
                    .padding(.vertical, 26)
                    .offset(x: 3)
            }

            // The current page, flipping around the spine on the left.
            StickerPageView(page: currentPage, totalPages: totalPages)
                .rotation3DEffect(.degrees(flipAngle),
                                  axis: (x: 0, y: 1, z: 0),
                                  anchor: .leading,
                                  perspective: 0.35)
                .shadow(color: .black.opacity(abs(flipAngle) > 1 ? 0.35 : 0),
                        radius: 12, x: flipAngle < 0 ? -10 : 10)
                .padding(14)
        }
        .padding(.horizontal, 14)
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 24)
                .onEnded { value in
                    if value.translation.width < -40 { turn(forward: true) }
                    else if value.translation.width > 40 { turn(forward: false) }
                }
        )
    }

    private var controlBar: some View {
        VStack(spacing: 6) {
            HStack(spacing: 12) {
                pageArrow(system: "chevron.left", enabled: currentPage > 0) {
                    turn(forward: false)
                }

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

                pageArrow(system: "chevron.right", enabled: currentPage < totalPages - 1) {
                    turn(forward: true)
                }
            }

            Text("Swipe or tap the arrows to turn the page")
                .font(Theme.medium(11))
                .foregroundColor(Theme.inkSoft)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }

    private func pageArrow(system: String, enabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: system)
                .font(Theme.bold(20))
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .background(Circle().fill(enabled ? AnyShapeStyle(Theme.nextButton)
                                                  : AnyShapeStyle(Color.gray.opacity(0.4))))
                .shadow(color: .black.opacity(0.2), radius: 4, y: 2)
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
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(pageTint)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(.white, lineWidth: 3)
                    )
                    .shadow(color: .black.opacity(0.15), radius: 10, y: 6)

                // Faint page number watermark in the corner.
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Text("\(page + 1)")
                            .font(Theme.display(30))
                            .foregroundColor(Theme.inkSoft.opacity(0.18))
                            .padding(18)
                    }
                }

                // Placed stickers on this page.
                ForEach(progress.stickers(onPage: page)) { placed in
                    PlacedStickerView(placed: placed, pageSize: geo.size)
                }
            }
        }
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

    private let columns = [GridItem(.adaptive(minimum: 96), spacing: 14)]

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Sticker Shop")
                    .font(Theme.display(22))
                    .foregroundColor(Theme.ink)
                Spacer()
                HStack(spacing: 5) {
                    Image(systemName: "diamond.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(Theme.jewelPink)
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

            Text("Buy stickers with your jewels, then tap one to stick it in your book!")
                .font(Theme.medium(13))
                .foregroundColor(Theme.inkSoft)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)

            ScrollView {
                section(title: "🌸 Cute Collection",
                        subtitle: "50 jewels each",
                        stickers: StickerCatalog.cute)

                section(title: "✨ Epic Collection",
                        subtitle: "100 jewels each",
                        stickers: StickerCatalog.epic)
                    .padding(.top, 4)
            }
        }
        .background(Theme.homeBackground.ignoresSafeArea())
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
                    Image(systemName: "diamond.fill").font(.system(size: 11))
                    Text("\(sticker.cost)").font(Theme.bold(13))
                }
                .foregroundStyle(affordable ? AnyShapeStyle(Theme.jewelPink)
                                            : AnyShapeStyle(Theme.inkSoft))
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
