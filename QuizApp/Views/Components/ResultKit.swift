//
//  ResultKit.swift
//  QuizApp
//
//  The furniture both end-of-round screens are built from.
//
//  A Pro Challenge and an island level finish differently — one banks a gem
//  haul, the other awards stars on a trail — but they should plainly be the
//  same game. Everything they have in common lives here: the painted pieces,
//  the gold plate, the tick marks, the glossy buttons and the lettering.
//
//  Sizes are always passed in as the screen's width and used as fractions of
//  it, so a piece keeps its proportions on any device.
//

import SwiftUI
import UIKit

// MARK: - The painted pieces

enum ResultArt {
    static let background = "ProResultBG"
    static let star       = "ProResultStar"
    static let banner     = "ProResultBanner"
    static let crest      = "ProResultCrest"

    /// Only the crest's shape is needed in code; the star and the ribbon are
    /// laid out by `scaledToFit` alone.
    static let crestAspect: CGFloat = 2.4791

    /// The ribbon's writing area, as a fraction of the banner picture.
    static let bannerTitleAt = CGRect(x: 0.10, y: 0.235, width: 0.80, height: 0.52)
    /// The blank gold scroll on the crest, likewise.
    static let crestTextAt   = CGRect(x: 0.15, y: 0.565, width: 0.70, height: 0.29)

    static func has(_ name: String) -> Bool { UIImage(named: name) != nil }

    // Sampled from the artwork, so the drawn parts belong to the same picture.
    static let gold     = Color(red: 1.00, green: 0.82, blue: 0.30)
    static let goldDeep = Color(red: 0.87, green: 0.56, blue: 0.09)
    static let goldPale = Color(red: 1.00, green: 0.95, blue: 0.72)
    static let plum     = Color(red: 0.28, green: 0.12, blue: 0.46)
    static let plumDeep = Color(red: 0.16, green: 0.07, blue: 0.31)
    static let night    = Color(red: 0.07, green: 0.09, blue: 0.27)
}

extension View {
    /// Puts a live part where the artwork leaves room for it, given that room
    /// as fractions of the picture it sits on.
    func placed(in r: CGRect, _ w: CGFloat, _ h: CGFloat) -> some View {
        frame(width: r.width * w, height: r.height * h)
            .position(x: r.midX * w, y: r.midY * h)
    }
}

// MARK: - Lettering

/// A line of white wording with some parts picked out in gold — the score,
/// the child's name — outlined so it reads over a painted scene.
struct ResultLine: View {
    /// Each piece of the line and whether it is one of the gold parts.
    let pieces: [(String, Bool)]
    let size: CGFloat
    var weight: Font.Weight = .heavy
    var outline: Color = ResultArt.plumDeep
    var outlineWidth: CGFloat = 1.5

    private var whole: String { pieces.map(\.0).joined() }

    var body: some View {
        OutlinedText(plain: whole,
                     font: .system(size: size, weight: weight, design: .rounded),
                     outline: outline,
                     width: outlineWidth) {
            pieces.reduce(Text("")) { acc, piece in
                acc + Text(piece.0).foregroundColor(piece.1 ? ResultArt.gold : .white)
            }
        }
    }
}

// MARK: - The cheering star

struct ResultStarMascot: View {
    let width: CGFloat
    let appeared: Bool
    /// Shown only if the picture is missing from the bundle.
    var fallback: String = "🎉"
    /// How much of the screen's width it takes. The level result shows three
    /// rating stars underneath it, so there it gives up a little room.
    var scale: CGFloat = 0.50

    var body: some View {
        Group {
            if ResultArt.has(ResultArt.star) {
                Image(ResultArt.star)
                    .resizable()
                    .scaledToFit()
                    .frame(width: width * scale)
            } else {
                Text(fallback).font(.system(size: width * 0.19))
            }
        }
        .scaleEffect(appeared ? 1 : 0.35)
        .animation(.spring(response: 0.55, dampingFraction: 0.55), value: appeared)
    }
}

// MARK: - The title ribbon

struct ResultBanner: View {
    /// The greeting, split so the child's own name can be the gold part.
    let lead: String
    let name: String
    let width: CGFloat

    private var whole: String { lead + name }

    var body: some View {
        if ResultArt.has(ResultArt.banner) {
            Image(ResultArt.banner)
                .resizable()
                .scaledToFit()
                .overlay(alignment: .topLeading) {
                    GeometryReader { g in
                        OutlinedText(plain: whole,
                                     font: .system(size: width * 0.076,
                                                   weight: .black, design: .rounded),
                                     outline: ResultArt.plumDeep,
                                     width: max(1.5, width * 0.006)) {
                            (Text(lead).foregroundColor(.white)
                             + Text(name).foregroundColor(ResultArt.gold))
                        }
                        .placed(in: ResultArt.bannerTitleAt, g.size.width, g.size.height)
                    }
                    .allowsHitTesting(false)
                }
                .frame(width: width * 0.98)
        } else {
            Text(whole)
                .font(.system(size: width * 0.076, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.75), radius: 6, y: 2)
        }
    }
}

// MARK: - Ticks and crosses

struct ResultMark: View {
    let right: Bool
    let size: CGFloat

    var body: some View {
        let face: [Color] = right
            ? [Color(red: 0.46, green: 0.91, blue: 0.42), Color(red: 0.13, green: 0.68, blue: 0.24)]
            : [Color(red: 1.00, green: 0.48, blue: 0.51), Color(red: 0.86, green: 0.16, blue: 0.27)]
        return Image(systemName: right ? "checkmark" : "xmark")
            .font(.system(size: size * 0.46, weight: .black))
            .foregroundColor(.white)
            .shadow(color: .black.opacity(0.35), radius: 1, y: 1)
            .frame(width: size, height: size)
            .background(Circle().fill(LinearGradient(colors: face,
                                                     startPoint: .top, endPoint: .bottom)))
            .overlay(Circle().strokeBorder(.white.opacity(0.85), lineWidth: size * 0.06))
            .shadow(color: .black.opacity(0.35), radius: size * 0.10, y: size * 0.05)
    }
}

/// The row of marks. A grid rather than a row because Category Master shows
/// fifteen of them and they have to wrap onto a second line.
struct ResultMarkRow: View {
    let results: [Bool]
    let width: CGFloat

    var body: some View {
        // Sized so a ten-question round still fits on one line.
        let d = width * 0.074
        return LazyVGrid(columns: [GridItem(.adaptive(minimum: d), spacing: width * 0.011)],
                         spacing: width * 0.011) {
            ForEach(0..<results.count, id: \.self) { i in
                ResultMark(right: results[i], size: d)
            }
        }
        .padding(.horizontal, width * 0.01)
    }
}

// MARK: - Stars

/// The level's one to three stars, gold and lit when won, dim when not.
struct StarRating: View {
    /// How many of the three are lit. It animates up to the number won,
    /// which is why this and not the final score is what the view reads.
    let shown: Int
    let width: CGFloat

    var body: some View {
        HStack(spacing: width * 0.035) {
            ForEach(0..<3, id: \.self) { i in
                let lit = i < shown
                Image(systemName: "star.fill")
                    .font(.system(size: width * 0.105))
                    .foregroundStyle(lit
                        ? AnyShapeStyle(LinearGradient(
                            colors: [ResultArt.goldPale, ResultArt.gold, ResultArt.goldDeep],
                            startPoint: .top, endPoint: .bottom))
                        : AnyShapeStyle(Color.white.opacity(0.22)))
                    .overlay(
                        Image(systemName: "star")
                            .font(.system(size: width * 0.105, weight: .light))
                            .foregroundColor(lit ? ResultArt.goldDeep : .white.opacity(0.35))
                    )
                    .shadow(color: lit ? ResultArt.gold.opacity(0.85) : .clear,
                            radius: width * 0.035)
                    .scaleEffect(lit ? 1 : 0.78)
                    .animation(.spring(response: 0.4, dampingFraction: 0.5)
                        .delay(Double(i) * 0.2), value: shown)
            }
        }
    }
}

// MARK: - The gem panel

/// The dark plate the breakdown sits on, in a bevelled gold frame.
struct ResultPlate: View {
    let width: CGFloat

    var body: some View {
        let r = width * 0.085
        return RoundedRectangle(cornerRadius: r, style: .continuous)
            .fill(LinearGradient(colors: [ResultArt.plum.opacity(0.94),
                                          ResultArt.plumDeep.opacity(0.96)],
                                 startPoint: .top, endPoint: .bottom))
            .overlay(
                RoundedRectangle(cornerRadius: r, style: .continuous)
                    .strokeBorder(LinearGradient(
                        colors: [ResultArt.goldPale, ResultArt.gold,
                                 ResultArt.goldDeep, ResultArt.gold],
                        startPoint: .topLeading, endPoint: .bottomTrailing),
                        lineWidth: width * 0.022)
            )
            .overlay(
                RoundedRectangle(cornerRadius: r, style: .continuous)
                    .inset(by: width * 0.022)
                    .strokeBorder(.white.opacity(0.14), lineWidth: 1)
            )
            .shadow(color: ResultArt.gold.opacity(0.35), radius: width * 0.045)
            .shadow(color: .black.opacity(0.45), radius: width * 0.03, y: width * 0.012)
    }
}

/// One line of the breakdown: what earned the gems, and how many.
struct RewardRow: View {
    let icon: String
    let label: String
    let amount: Int?
    let width: CGFloat

    var body: some View {
        HStack(spacing: width * 0.028) {
            Text(icon).font(.system(size: width * 0.050))
            Text(label)
                .font(.system(size: width * 0.044, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            Spacer(minLength: width * 0.02)
            if let amount {
                Text("+\(amount)")
                    .font(.system(size: width * 0.052, weight: .black, design: .rounded))
                    .foregroundColor(ResultArt.gold)
                    .shadow(color: ResultArt.goldDeep.opacity(0.8), radius: 0, y: 1.5)
            }
        }
    }
}

/// The gem crest hanging over the plate that holds the breakdown.
///
/// The crest is painted and the plate is drawn, because the plate has to grow
/// with the number of bonus lines and a painted one could not.
struct GemPanel<Rows: View>: View {
    let total: Int
    let width: CGFloat
    @ViewBuilder var rows: () -> Rows

    var body: some View {
        let crestW = width * 0.76
        let crestH = crestW / ResultArt.crestAspect
        // The crest hangs over the plate's top edge, so the plate is pushed
        // down by the part of it that stands above.
        let overhang = crestH * 0.62

        return ZStack(alignment: .top) {
            rows()
                .padding(.top, crestH - overhang + width * 0.03)
                .padding(.horizontal, width * 0.055)
                .padding(.bottom, width * 0.05)
                .frame(maxWidth: .infinity)
                .background(ResultPlate(width: width))
                .padding(.top, overhang)

            if ResultArt.has(ResultArt.crest) {
                Image(ResultArt.crest)
                    .resizable()
                    .scaledToFit()
                    .frame(width: crestW)
                    .overlay(alignment: .topLeading) {
                        GeometryReader { g in
                            gemTotal.placed(in: ResultArt.crestTextAt,
                                            g.size.width, g.size.height)
                        }
                        .allowsHitTesting(false)
                    }
            } else {
                gemTotal.padding(.top, width * 0.02)
            }
        }
    }

    private var gemTotal: some View {
        OutlinedText(plain: "+\(total) Gems",
                     font: .system(size: width * 0.072, weight: .black, design: .rounded),
                     outline: ResultArt.goldDeep,
                     width: max(1, width * 0.004)) {
            (Text("+\(total)").foregroundColor(Theme.gemPink)
             + Text(" Gems").foregroundColor(ResultArt.plum))
        }
        .contentTransition(.numericText())
    }
}

// MARK: - Buttons

/// A glossy capsule with a gold rim, a highlight along the top and a glow
/// under it — drawn rather than painted, because the wording it has to hold
/// runs from "Play Again" to "Come back tomorrow for a new set".
struct GlossyPill: View {
    let text: String
    let icon: String
    let face: [Color]
    let width: CGFloat
    var big: Bool = false

    static let pink = [Color(red: 1.00, green: 0.42, blue: 0.85),
                       Color(red: 0.92, green: 0.15, blue: 0.62)]
    static let blue = [Color(red: 0.24, green: 0.44, blue: 0.96),
                       Color(red: 0.12, green: 0.20, blue: 0.72)]
    static let calm = [Color(red: 0.45, green: 0.36, blue: 0.72),
                       Color(red: 0.26, green: 0.18, blue: 0.52)]

    var body: some View {
        HStack(spacing: width * 0.028) {
            Image(systemName: icon)
                .font(.system(size: width * (big ? 0.054 : 0.046), weight: .black))
            Text(text)
                .font(.system(size: width * (big ? 0.060 : 0.052),
                              weight: .black, design: .rounded))
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        }
        .foregroundColor(.white)
        .shadow(color: .black.opacity(0.35), radius: 1, y: 1.5)
        .frame(maxWidth: .infinity)
        .padding(.vertical, width * (big ? 0.045 : 0.038))
        .background(
            Capsule().fill(LinearGradient(colors: face, startPoint: .top, endPoint: .bottom))
        )
        // The shine across the upper half is what makes it look like a sweet
        // rather than a rectangle with a colour in it.
        .overlay(
            Capsule()
                .fill(LinearGradient(colors: [.white.opacity(0.45), .white.opacity(0.02)],
                                     startPoint: .top, endPoint: .bottom))
                .padding(.horizontal, width * 0.020)
                .padding(.top, width * 0.014)
                .padding(.bottom, width * 0.070)
                .allowsHitTesting(false)
        )
        .overlay(
            Capsule().strokeBorder(LinearGradient(
                colors: [ResultArt.goldPale, ResultArt.gold, ResultArt.goldPale],
                startPoint: .topLeading, endPoint: .bottomTrailing),
                lineWidth: width * 0.011)
        )
        .shadow(color: (face.last ?? .black).opacity(0.65),
                radius: width * 0.045, y: width * 0.012)
        .shadow(color: .black.opacity(0.35), radius: width * 0.02, y: width * 0.010)
    }
}
