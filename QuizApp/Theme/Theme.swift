//
//  Theme.swift
//  QuizApp
//
//  Centralized colors, gradients, fonts and reusable styling.
//  Tuned to be bright, cute and playful for young kids.
//

import SwiftUI

/// App-wide design tokens. Keeping these in one place makes it easy to
/// re-skin the whole app by editing a single file.
enum Theme {

    // MARK: - Backgrounds

    /// Cheerful, candy-colored sky used on the home screen.
    static let homeBackground = LinearGradient(
        colors: [
            Color(red: 0.72, green: 0.86, blue: 1.00),  // soft sky blue
            Color(red: 0.88, green: 0.83, blue: 1.00),  // gentle lavender
            Color(red: 1.00, green: 0.86, blue: 0.92)   // blush pink
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    // MARK: - Text

    /// Dark, friendly ink used on light backgrounds. (#342E6C)
    static let ink = Color(red: 0.204, green: 0.180, blue: 0.424)
    /// Muted secondary text. (#7A74A6)
    static let inkSoft = Color(red: 0.478, green: 0.455, blue: 0.651)

    /// Pure white for text placed on top of vibrant gradients.
    static let onColor = Color.white
    static let onColorSoft = Color.white.opacity(0.85)

    // MARK: - Accents

    /// Correct-answer green. (#4CD964)
    static let correct = Color(red: 0.298, green: 0.851, blue: 0.392)
    /// Wrong-answer red. (#FF6B6B)
    static let incorrect = Color(red: 1.00, green: 0.420, blue: 0.420)
    /// Warm gold used for stars and the progress bar. (#FFD84D)
    static let star = Color(red: 1.00, green: 0.847, blue: 0.302)
    static let progress = Color(red: 1.00, green: 0.847, blue: 0.302)
    static let sunshine = Color(red: 1.00, green: 0.78, blue: 0.30)

    /// Soft cream fill for the "Did you know?" box. (#FFF8D6)
    static let didYouKnow = Color(red: 1.00, green: 0.973, blue: 0.839)

    /// A bright pink used for the jewel gem and jewel counts. (#FF459E)
    static let jewelPink = Color(red: 1.00, green: 0.27, blue: 0.62)

    /// Purple gradient for the primary "Next" button. (#8B5CF6 → #A855F7)
    static let nextButton = LinearGradient(
        colors: [
            Color(red: 0.545, green: 0.361, blue: 0.965),
            Color(red: 0.659, green: 0.333, blue: 0.969)
        ],
        startPoint: .leading,
        endPoint: .trailing
    )

    // MARK: - Metrics

    static let cornerRadius: CGFloat = 26
    static let cardPadding: CGFloat = 18
    static let spacing: CGFloat = 16

    // MARK: - Fonts (rounded = friendlier for kids)

    static func display(_ size: CGFloat) -> Font {
        .system(size: size, weight: .heavy, design: .rounded)
    }
    static func bold(_ size: CGFloat) -> Font {
        .system(size: size, weight: .bold, design: .rounded)
    }
    static func medium(_ size: CGFloat) -> Font {
        .system(size: size, weight: .semibold, design: .rounded)
    }
}

/// The pink-gem jewel icon used everywhere jewels are shown.
struct JewelIcon: View {
    var size: CGFloat = 16
    var body: some View {
        Image("JewelGem")
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
    }
}

/// A soft white "bubble" card with a chunky, playful drop shadow.
struct BubbleCard: ViewModifier {
    var cornerRadius: CGFloat = Theme.cornerRadius
    var fill: Color = .white
    var shadow: Color = Color.black.opacity(0.12)

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(fill)
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .shadow(color: shadow, radius: 12, x: 0, y: 8)
    }
}

extension View {
    /// Applies the soft white bubble-card treatment.
    func bubbleCard(
        cornerRadius: CGFloat = Theme.cornerRadius,
        fill: Color = .white,
        shadow: Color = Color.black.opacity(0.12)
    ) -> some View {
        modifier(BubbleCard(cornerRadius: cornerRadius, fill: fill, shadow: shadow))
    }
}
