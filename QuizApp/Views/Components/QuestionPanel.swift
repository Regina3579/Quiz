//
//  QuestionPanel.swift
//  QuizApp
//
//  The painted scroll a question is written on. Shared by the island
//  levels and the Pro Challenge rounds so both read the same way.
//

import SwiftUI

struct QuestionPanel: View {
    let prompt: String

    /// The artwork is 733 x 478.
    private static let aspect: CGFloat = 733.0 / 478.0

    /// The parchment opening sits inside the gold frame, and the star topper
    /// takes the top of the picture — so the text is placed in that opening
    /// rather than centred on the image as a whole.
    private static let textWidth: CGFloat = 0.76
    private static let textHeight: CGFloat = 0.56
    private static let textCentreY: CGFloat = 0.60

    var body: some View {
        Image("QuizPanel")
            .resizable()
            .scaledToFit()
            .overlay {
                GeometryReader { geo in
                    Text(prompt)
                        .font(Theme.bold(min(23, geo.size.height * 0.115)))
                        .foregroundColor(Theme.ink)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.6)
                        .frame(width: geo.size.width * Self.textWidth,
                               height: geo.size.height * Self.textHeight)
                        .position(x: geo.size.width * 0.5,
                                  y: geo.size.height * Self.textCentreY)
                }
            }
            .aspectRatio(Self.aspect, contentMode: .fit)
            .accessibilityLabel(prompt)
    }
}

// MARK: - Fitting a round onto one screen

/// Divides the play screen's height between the question, the four answers,
/// the explanation and the Next button, so a whole round fits without
/// scrolling.
///
/// The explanation and the button keep their space from the start, even while
/// they are still empty. That costs a little room before the child answers,
/// and buys the thing that matters: tapping an answer never shifts anything
/// already on screen, so the tick or cross appears exactly where they are
/// already looking.
struct QuizScreenLayout {
    let panelWidth: CGFloat
    let panelHeight: CGFloat
    /// The four pills share one width; their height follows from the artwork.
    let optionsWidth: CGFloat
    let optionsSpacing: CGFloat
    let explanationHeight: CGFloat
    let nextHeight: CGFloat
    /// Even spacing between the five bands, absorbing whatever is left over.
    let gap: CGFloat

    /// Answer pill art is 732 x 183; the question panel is 733 x 478.
    private static let pillAspect: CGFloat = 732.0 / 183.0
    private static let panelAspect: CGFloat = 733.0 / 478.0

    /// How much of the space left over after the fixed bands goes to the
    /// answers rather than the question. At this split the panel and the pills
    /// come out close to the same width, which reads as one tidy column.
    private static let answersShare: CGFloat = 0.62

    init(size: CGSize, topBarHeight: CGFloat) {
        let maxWidth = max(120, size.width - 40)
        let next: CGFloat = 50
        let explanation: CGFloat = 98
        let spacing: CGFloat = 8
        let assumedGaps: CGFloat = 48

        let rest = max(160, size.height - topBarHeight - next - explanation - assumedGaps)

        // Answers first: they have a floor to stay tappable, and a ceiling so
        // they never grow wider than the column.
        var pill = (rest * Self.answersShare - spacing * 3) / 4
        pill = min(pill, maxWidth / Self.pillAspect)
        let optionsHeight = pill * 4 + spacing * 3

        // The question takes what is left, never wider than the column.
        let panel = min(rest - optionsHeight, maxWidth / Self.panelAspect)

        panelHeight = panel
        panelWidth = panel * Self.panelAspect
        optionsWidth = pill * Self.pillAspect
        optionsSpacing = spacing
        explanationHeight = explanation
        nextHeight = next

        let used = topBarHeight + panel + optionsHeight + explanation + next
        gap = min(18, max(6, (size.height - used) / 4))
    }
}
