//
//  ProMode.swift
//  QuizApp
//
//  The Pro Challenge modes. Each mode is a different way to test what the
//  child has learned on the adventure map: against the clock, without a
//  single slip, or deep inside one category. They all pay out in jewels,
//  which buy stickers for the sticker book.
//

import SwiftUI

/// One of the five Pro Challenge modes.
enum ProMode: String, CaseIterable, Identifiable, Hashable {
    case timedChallenge
    case lightningRound
    case perfectRun
    case jewelRush
    case categoryMaster

    var id: String { rawValue }

    // MARK: - Presentation

    var title: String {
        switch self {
        case .timedChallenge: return "Timed Challenge"
        case .lightningRound: return "Lightning Round"
        case .perfectRun:     return "Perfect Run"
        case .jewelRush:      return "Jewel Rush"
        case .categoryMaster: return "Category Master"
        }
    }

    var emoji: String {
        switch self {
        case .timedChallenge: return "⏱️"
        case .lightningRound: return "⚡️"
        case .perfectRun:     return "🎯"
        case .jewelRush:      return "💎"
        case .categoryMaster: return "🏅"
        }
    }

    /// The one-line promise shown on the mode's card.
    var tagline: String {
        switch self {
        case .timedChallenge: return "10 questions · 15 seconds each"
        case .lightningRound: return "10 easy questions · 8 seconds each"
        case .perfectRun:     return "One wrong answer ends the round"
        case .jewelRush:      return "Build a streak, earn more jewels"
        case .categoryMaster: return "15 questions from one category"
        }
    }

    /// The friendly "how to play" text shown before the round starts.
    var rules: String {
        switch self {
        case .timedChallenge:
            return "Ten questions, and the clock gives you fifteen seconds for "
                 + "each one. Let the timer run out and that question counts as "
                 + "missed, so trust your first instinct and keep moving."
        case .lightningRound:
            return "Ten quick questions with just eight seconds each. They are "
                 + "the easy ones — this round is about speed, not head "
                 + "scratching. Answer fast and keep the lightning going."
        case .perfectRun:
            return "Ten questions that get harder as you go, and there are no "
                 + "second chances: one wrong answer ends the round on the "
                 + "spot. Go slowly and think — nothing is chasing you here."
        case .jewelRush:
            return "Every correct answer pays jewels, and answers in a row pay "
                 + "more and more. Three in a row doubles your jewels, six in a "
                 + "row triples them. One slip and the streak starts again."
        case .categoryMaster:
            return "Pick one island and face fifteen questions drawn from every "
                 + "corner of it, easy through to expert. Prove you really are "
                 + "the master of that category."
        }
    }

    // MARK: - Rules of play

    /// How many questions the round asks.
    var questionCount: Int {
        switch self {
        case .categoryMaster: return 15
        default:              return 10
        }
    }

    /// Seconds allowed per question, or nil when the mode is untimed.
    var secondsPerQuestion: Int? {
        switch self {
        case .timedChallenge: return 15
        case .lightningRound: return 8
        default:              return nil
        }
    }

    /// True when a single wrong answer ends the round immediately.
    var endsOnWrongAnswer: Bool { self == .perfectRun }

    /// True when answering in a row multiplies the jewels earned.
    var hasStreakBonus: Bool { self == .jewelRush }

    /// True when the child picks an island before playing.
    var needsCategory: Bool { self == .categoryMaster }

    // MARK: - Rewards

    /// Jewels for one correct answer, before any streak multiplier.
    var jewelsPerCorrect: Int {
        switch self {
        case .timedChallenge: return 8
        case .lightningRound: return 5
        case .perfectRun:     return 10
        case .jewelRush:      return 5
        case .categoryMaster: return 6
        }
    }

    /// Extra jewels for getting every question right.
    var completionBonus: Int {
        switch self {
        case .timedChallenge: return 30
        case .lightningRound: return 25
        case .perfectRun:     return 50
        case .jewelRush:      return 30
        case .categoryMaster: return 40
        }
    }

    /// The best possible haul, shown on the card so the prize is clear.
    var bestPossibleJewels: Int {
        if hasStreakBonus {
            // Every answer correct means the multiplier climbs to 3×.
            return (0..<questionCount)
                .map { jewelsPerCorrect * ProMode.streakMultiplier(forStreak: $0 + 1) }
                .reduce(0, +) + completionBonus
        }
        return jewelsPerCorrect * questionCount + completionBonus
    }

    /// Jewel Rush pays more the longer the run of correct answers gets.
    static func streakMultiplier(forStreak streak: Int) -> Int {
        switch streak {
        case 6...: return 3
        case 3...: return 2
        default:   return 1
        }
    }

    // MARK: - Look

    var palette: Island.Palette {
        switch self {
        case .timedChallenge:
            return .init(start: Color(red: 0.99, green: 0.45, blue: 0.35),
                         end:   Color(red: 0.93, green: 0.22, blue: 0.45))
        case .lightningRound:
            return .init(start: Color(red: 1.00, green: 0.78, blue: 0.24),
                         end:   Color(red: 0.98, green: 0.49, blue: 0.14))
        case .perfectRun:
            return .init(start: Color(red: 0.35, green: 0.82, blue: 0.63),
                         end:   Color(red: 0.10, green: 0.58, blue: 0.55))
        case .jewelRush:
            return .init(start: Color(red: 1.00, green: 0.46, blue: 0.78),
                         end:   Color(red: 0.72, green: 0.24, blue: 0.86))
        case .categoryMaster:
            return .init(start: Color(red: 0.45, green: 0.63, blue: 1.00),
                         end:   Color(red: 0.33, green: 0.32, blue: 0.85))
        }
    }
}

/// Route to the Pro Challenge hub itself.
struct ProHubRoute: Hashable {}

/// A Hashable route so a Pro round can be pushed onto the navigation stack.
struct ProRoute: Hashable {
    let mode: ProMode
    /// Only used by Category Master, which plays one island's questions.
    var islandID: Int? = nil
}
