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
