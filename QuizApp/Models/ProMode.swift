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

/// One of the Pro Challenge modes.
enum ProMode: String, CaseIterable, Identifiable, Hashable {
    case dailyChallenge
    case timedChallenge
    case lightningRound
    case perfectRun
    case jewelRush
    case categoryMaster

    var id: String { rawValue }

    // MARK: - Presentation

    var title: String {
        switch self {
        case .dailyChallenge: return "Daily Challenge"
        case .timedChallenge: return "Timed Challenge"
        case .lightningRound: return "Lightning Round"
        case .perfectRun:     return "Perfect Run"
        case .jewelRush:      return "Jewel Rush"
        case .categoryMaster: return "Category Master"
        }
    }

    var emoji: String {
        switch self {
        case .dailyChallenge: return "📅"
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
        case .dailyChallenge: return "5 questions from today's adventure · once a day"
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
        case .dailyChallenge:
            return "Every day of the week has its own adventure — Monday is "
                 + "the jungle, Wednesday is the ocean — and the weekend is a "
                 + "surprise. Five questions from that world, easy through to "
                 + "hard, no clock. One go a day, so come back tomorrow."
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
            return "Every correct answer pays jewels, and this is the mode where "
                 + "streaks count double: reach three in a row and five in a row "
                 + "for twice the usual bonus. A wrong answer resets the run."
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
        case .dailyChallenge: return 5
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

    /// True when streak bonuses are worth double in this mode.
    var hasStreakBonus: Bool { self == .jewelRush }

    /// True when the mode may only be played once a day.
    var isOncePerDay: Bool { self == .dailyChallenge }

    /// True when the child picks an island before playing.
    var needsCategory: Bool { self == .categoryMaster }

    // MARK: - Rewards

    /// Every correct answer is worth the same everywhere in the app.
    var jewelsPerCorrect: Int { JewelRules.perCorrect }

    /// A flat reward for finishing the mode, on top of the usual streak and
    /// perfect-round bonuses.
    var completionBonus: Int {
        switch self {
        case .dailyChallenge: return 20
        case .timedChallenge: return 10
        case .lightningRound: return 10
        case .perfectRun:     return 20
        case .jewelRush:      return 10
        case .categoryMaster: return 20
        }
    }

    /// Jewel Rush is the streak mode, so its streak bonuses count double.
    /// The bonuses themselves are still paid at most once each.
    var streakMultiplier: Int { self == .jewelRush ? 2 : 1 }

    /// The Daily Challenge is only five questions long, so a clean sweep
    /// would trip both streak milestones at once. It skips them and pays a
    /// small perfect bonus instead, keeping the round deliberately modest.
    var awardsStreakBonuses: Bool { self != .dailyChallenge }

    /// What a flawless round is worth, where it differs from the usual +20.
    var perfectBonus: Int {
        self == .dailyChallenge ? 5 : JewelRules.perfectRound
    }

    /// The best possible haul, shown on the card so the prize is clear.
    var bestPossibleJewels: Int {
        JewelRules.bestPossible(questionCount: questionCount,
                                streakMultiplier: streakMultiplier,
                                awardsStreakBonuses: awardsStreakBonuses,
                                perfectBonus: perfectBonus,
                                completionBonus: completionBonus)
    }

    // MARK: - Look

    var palette: Island.Palette {
        switch self {
        case .dailyChallenge:
            return .init(start: Color(red: 0.42, green: 0.80, blue: 0.96),
                         end:   Color(red: 0.20, green: 0.45, blue: 0.86))
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
