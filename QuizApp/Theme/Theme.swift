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

    /// Dark, friendly ink used on light backgrounds.
    static let ink = Color(red: 0.20, green: 0.17, blue: 0.42)
    static let inkSoft = Color(red: 0.42, green: 0.40, blue: 0.58)

    /// Pure white for text placed on top of vibrant gradients.
    static let onColor = Color.white
    static let onColorSoft = Color.white.opacity(0.85)

    // MARK: - Accents

    static let correct = Color(red: 0.28, green: 0.80, blue: 0.45)
    static let incorrect = Color(red: 1.00, green: 0.44, blue: 0.48)
    static let star = Color(red: 1.00, green: 0.80, blue: 0.20)
    static let sunshine = Color(red: 1.00, green: 0.78, blue: 0.30)

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
