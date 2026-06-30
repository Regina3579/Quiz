//
//  Theme.swift
//  QuizApp
//
//  Centralized colors, gradients, fonts and reusable view styling.
//

import SwiftUI

/// App-wide design tokens. Keeping these in one place makes it easy to
/// re-skin the whole app by editing a single file.
enum Theme {

    // MARK: - Colors

    /// Deep background gradient used behind every screen.
    static let backgroundGradient = LinearGradient(
        colors: [
            Color(red: 0.07, green: 0.08, blue: 0.18),
            Color(red: 0.12, green: 0.09, blue: 0.26),
            Color(red: 0.05, green: 0.06, blue: 0.14)
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    static let cardBackground = Color.white.opacity(0.08)
    static let cardStroke = Color.white.opacity(0.14)

    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.65)

    static let correct = Color(red: 0.20, green: 0.80, blue: 0.55)
    static let incorrect = Color(red: 0.95, green: 0.36, blue: 0.42)
    static let accent = Color(red: 0.55, green: 0.45, blue: 0.98)

    // MARK: - Metrics

    static let cornerRadius: CGFloat = 22
    static let cardPadding: CGFloat = 18
    static let spacing: CGFloat = 16
}

/// A frosted-glass card background used across the app.
struct GlassCard: ViewModifier {
    var cornerRadius: CGFloat = Theme.cornerRadius

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .environment(\.colorScheme, .dark)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Theme.cardStroke, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}

extension View {
    /// Applies the standard frosted-glass card treatment.
    func glassCard(cornerRadius: CGFloat = Theme.cornerRadius) -> some View {
        modifier(GlassCard(cornerRadius: cornerRadius))
    }
}
