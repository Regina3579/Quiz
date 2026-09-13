//
//  AnswerButton.swift
//  QuizApp
//
//  One answer choice, drawn on the painted pill artwork. The four pills
//  cycle by position so every question shows the same run of colours, and
//  the result of an answer is shown with a tick or a cross rather than by
//  recolouring the pill, which would fight the artwork.
//

import SwiftUI

struct AnswerButton: View {
    let text: String
    let index: Int
    let hasAnswered: Bool
    let selectedOption: Int?
    let correctIndex: Int
    let action: () -> Void

    /// The pill artwork, in the order the design shows them.
    private static let pills = ["QuizPillTeal", "QuizPillRed",
                                "QuizPillGold", "QuizPillPurple"]
    /// 732 x 183 in the design.
    private static let pillAspect: CGFloat = 732.0 / 183.0

    private var pillName: String { Self.pills[index % Self.pills.count] }

    private var isCorrect: Bool { index == correctIndex }
    private var isChosen: Bool { selectedOption == index }

    /// Once answered, the right answer and a wrong pick stay lit and the
    /// others step back, so the page reads at a glance.
    private var dimmed: Bool { hasAnswered && !isCorrect && !isChosen }

    var body: some View {
        Button(action: action) {
            GeometryReader { geo in
                let w = geo.size.width
                let h = w / Self.pillAspect

                ZStack {
                    Image(pillName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: w, height: h)

                    // The bead on the left is part of the picture, so the
                    // text sits in the cream area to its right.
                    Text(text)
                        .font(Theme.bold(min(20, h * 0.30)))
                        .foregroundColor(Theme.ink)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.6)
                        .lineLimit(2)
                        .padding(.leading, w * 0.20)
                        .padding(.trailing, w * 0.09)
                        .frame(width: w, height: h)

                    if hasAnswered && (isCorrect || isChosen) {
                        marker(height: h)
                            .frame(width: w, height: h, alignment: .trailing)
                            .padding(.trailing, w * 0.035)
                    }
                }
                .frame(width: w, height: h)
                .saturation(dimmed ? 0.35 : 1)
                .opacity(dimmed ? 0.6 : 1)
                .overlay {
                    // A soft halo marks the outcome without hiding the art.
                    if hasAnswered && (isCorrect || isChosen) {
                        Capsule()
                            .stroke(isCorrect ? Theme.correct : Theme.incorrect,
                                    lineWidth: 4)
                            .frame(width: w - 4, height: h - 4)
                            .shadow(color: (isCorrect ? Theme.correct : Theme.incorrect)
                                .opacity(0.7), radius: 7)
                    }
                }
            }
            .aspectRatio(Self.pillAspect, contentMode: .fit)
        }
        .buttonStyle(PressableButtonStyle())
        .disabled(hasAnswered)
        .animation(.easeOut(duration: 0.25), value: hasAnswered)
        .accessibilityLabel(text)
    }

    private func marker(height: CGFloat) -> some View {
        Image(systemName: isCorrect ? "checkmark" : "xmark")
            .font(.system(size: height * 0.26, weight: .heavy))
            .foregroundColor(.white)
            .frame(width: height * 0.46, height: height * 0.46)
            .background(Circle().fill(isCorrect ? Theme.correct : Theme.incorrect))
            .overlay(Circle().stroke(.white, lineWidth: 2.5))
            .shadow(color: .black.opacity(0.25), radius: 3, y: 2)
    }
}

// MARK: - Press feedback

/// Gives every button in the app the same gentle squeeze when pressed.
struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.6),
                       value: configuration.isPressed)
    }
}
