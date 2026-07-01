//
//  AnswerButton.swift
//  QuizApp
//
//  A big, tappable answer bubble that animates to reveal correctness.
//

import SwiftUI

struct AnswerButton: View {
    let text: String
    let index: Int

    /// Whether the player has locked in an answer for this question.
    let hasAnswered: Bool
    /// The option the player tapped (nil if timed out).
    let selectedOption: Int?
    /// The correct option index for the current question.
    let correctIndex: Int

    let action: () -> Void

    private var isSelected: Bool { selectedOption == index }
    private var isCorrect: Bool { index == correctIndex }

    /// Reveal styling only after an answer is locked.
    private var fillColor: Color {
        guard hasAnswered else { return .white }
        if isCorrect { return Theme.correct }
        if isSelected { return Theme.incorrect }
        return .white
    }

    private var textColor: Color {
        guard hasAnswered else { return Theme.ink }
        if isCorrect || isSelected { return .white }
        return Theme.ink.opacity(0.5)
    }

    private var trailingSymbol: String? {
        guard hasAnswered else { return nil }
        if isCorrect { return "checkmark.circle.fill" }
        if isSelected { return "xmark.circle.fill" }
        return nil
    }

    /// Letters A, B, C, D for each option.
    private var label: String {
        String(UnicodeScalar(65 + index)!)
    }

    private var badgeColor: Color {
        guard hasAnswered else { return Theme.ink.opacity(0.10) }
        if isCorrect || isSelected { return Color.white.opacity(0.25) }
        return Theme.ink.opacity(0.06)
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Text(label)
                    .font(Theme.bold(18))
                    .foregroundColor(textColor)
                    .frame(width: 38, height: 38)
                    .background(Circle().fill(badgeColor))

                Text(text)
                    .font(Theme.medium(17))
                    .foregroundColor(textColor)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if let symbol = trailingSymbol {
                    Image(systemName: symbol)
                        .font(.title2)
                        .foregroundColor(.white)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(fillColor)
            )
            .shadow(color: Color.black.opacity(0.12), radius: 6, x: 0, y: 4)
        }
        .buttonStyle(PressableButtonStyle())
        .disabled(hasAnswered)
        .scaleEffect(hasAnswered && isCorrect ? 1.04 : 1.0)
        .animation(.spring(response: 0.35, dampingFraction: 0.6), value: hasAnswered)
    }
}

/// Gives buttons a bouncy press-down animation.
struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
