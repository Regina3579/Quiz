//
//  Quiz.swift
//  QuizApp
//
//  A themed collection of questions.
//

import SwiftUI

/// A category of quiz, bundling questions with presentation metadata.
struct Quiz: Identifiable, Hashable {
    let id = UUID()

    /// Display name, e.g. "Science & Nature".
    let title: String

    /// Short tagline shown on the category card.
    let subtitle: String

    /// SF Symbol name used as the category icon.
    let symbol: String

    /// The gradient palette used to theme this quiz throughout the app.
    let palette: Palette

    /// The questions belonging to this quiz.
    let questions: [Question]

    /// Number of questions, surfaced on the category card.
    var questionCount: Int { questions.count }

    // Identity is based on the unique `id`, which is enough for navigation
    // and avoids requiring every nested type to be Hashable.
    static func == (lhs: Quiz, rhs: Quiz) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }

    /// A two-color gradient used for cards, headers and accents.
    struct Palette: Equatable {
        let start: Color
        let end: Color

        var gradient: LinearGradient {
            LinearGradient(
                colors: [start, end],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}
