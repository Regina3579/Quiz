//
//  Quiz.swift
//  QuizApp
//
//  Core models for the Adventure Map: Islands made of Levels made of
//  Questions. (Kept in this file so the Xcode project needs no changes.)
//

import SwiftUI

/// One "island" on the adventure map — a themed world of levels.
struct Island: Identifiable, Hashable {
    /// Stable 0-based index used for progress keys and lookups.
    let id: Int

    /// Display name, e.g. "Jungle Kingdom".
    let name: String

    /// A big, cute emoji mascot for the island.
    let emoji: String

    /// A second decorative emoji shown alongside the first.
    let accentEmoji: String

    /// Short, friendly description shown when the island opens.
    let blurb: String

    /// The gradient palette that themes this island everywhere.
    let palette: Palette

    /// Authored levels (each with its own questions).
    let levels: [Level]

    /// How many level stops the trail shows (the full journey).
    let totalLevels = 10

    /// How many levels currently have real questions.
    var authoredLevels: Int { levels.count }

    /// Look up an authored level by its 1-based number.
    func level(_ number: Int) -> Level? {
        levels.first { $0.number == number }
    }

    // Identity by id keeps navigation simple and avoids requiring the
    // nested types to be Hashable.
    static func == (lhs: Island, rhs: Island) -> Bool { lhs.id == rhs.id }
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

/// A single level within an island — a set of questions to answer.
struct Level: Identifiable, Hashable {
    /// 1-based level number (1...10).
    let number: Int

    /// The questions for this level (about ten).
    let questions: [Question]

    var id: Int { number }
    var questionCount: Int { questions.count }

    static func == (lhs: Level, rhs: Level) -> Bool { lhs.number == rhs.number }
    func hash(into hasher: inout Hasher) { hasher.combine(number) }
}

/// A lightweight, Hashable route so we can push a specific level onto the
/// navigation stack and rebuild the view model from it.
struct LevelRoute: Hashable {
    let islandID: Int
    let levelNumber: Int
}
