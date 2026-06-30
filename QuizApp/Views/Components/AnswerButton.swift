//
//  AnswerButton.swift
//  QuizApp
//
//  A single tappable answer option that animates to reflect correctness.
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
        guard hasAnswered else { return Theme.cardBackground }
        if isCorrect { return Theme.correct.opacity(0.85) }
        if isSelected { return Theme.incorrect.opacity(0.85) }
        return Theme.cardBackground
    }

    private var strokeColor: Color {
        guard hasAnswered else { return Theme.cardStroke }
        if isCorrect { return Theme.correct }
        if isSelected { return Theme.incorrect }
        return Theme.cardStroke
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

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Text(label)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(Theme.textPrimary)
                    .frame(width: 34, height: 34)
                    .background(Circle().fill(Color.white.opacity(0.12)))

                Text(text)
                    .font(.body.weight(.medium))
                    .foregroundStyle(Theme.textPrimary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if let symbol = trailingSymbol {
                    Image(systemName: symbol)
                        .font(.title3)
                        .foregroundStyle(Theme.textPrimary)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 18)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(fillColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(strokeColor, lineWidth: 1.5)
            )
        }
        .buttonStyle(PressableButtonStyle())
        .disabled(hasAnswered)
        .scaleEffect(hasAnswered && isCorrect ? 1.03 : 1.0)
        .animation(.spring(response: 0.35, dampingFraction: 0.7), value: hasAnswered)
    }
}

/// Gives buttons a subtle press-down animation.
struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}
