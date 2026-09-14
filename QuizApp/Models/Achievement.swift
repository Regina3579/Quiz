//
//  Achievement.swift
//  QuizApp
//
//  Everything the child can win and keep in the Trophy Room: the four cups,
//  which climb with the number of questions answered correctly over the whole
//  journey, and the badges, each for one particular feat.
//
//  An achievement is only ever a description — what it is called, what has to
//  be done, and which tally that is counted against. GameProgress keeps the
//  tallies and decides when one has been earned, so nothing here has to know
//  about saving or about the rest of the game.
//

import SwiftUI

struct Achievement: Identifiable, Hashable {

    /// The cups are the main ladder; badges sit beside them for one-off feats.
    enum Kind: Hashable {
        case cup
        case badge
    }

    /// Which running total an achievement is measured against.
    enum Measure: Hashable {
        case correctAnswers
        case questionsAnswered
        /// Jewels earned over the whole journey — spending them never takes
        /// this back down, or buying a sticker would cost the child an award.
        case jewelsEarned
        case bestStreak
        /// Levels finished with every question right.
        case perfectLevels
        /// Rounds finished in one Pro mode.
        case proRounds(ProMode)
        /// Perfect Runs that went all the way without a wrong answer.
        case perfectRunWins
        case islandsComplete
    }

    let id: String
    let emoji: String
    let title: String
    /// What has to be done, in the child's own words.
    let detail: String
    let kind: Kind
    let measure: Measure
    /// How many are needed.
    let target: Int
    /// Jewels handed over when it is won.
    var jewelReward: Int = 0
    /// A keepsake sticker handed over with it, by sticker id.
    var stickerReward: String? = nil

    /// A short line for the award card: what it pays.
    var rewardLine: String? {
        var parts: [String] = []
        if jewelReward > 0 { parts.append("+\(jewelReward) jewels") }
        if stickerReward != nil { parts.append("a keepsake sticker") }
        return parts.isEmpty ? nil : parts.joined(separator: " and ")
    }
}

/// The full list, in the order the Trophy Room shows them.
enum AchievementCatalog {

    /// The ladder. Every correct answer anywhere in the game counts, so the
    /// cups keep climbing whether the child plays the map or the Pro room.
    static let cups: [Achievement] = [
        Achievement(id: "cup.bronze", emoji: "🥉", title: "Bronze Cup",
                    detail: "Answer 50 questions correctly",
                    kind: .cup, measure: .correctAnswers, target: 50,
                    jewelReward: 25),
        Achievement(id: "cup.silver", emoji: "🥈", title: "Silver Cup",
                    detail: "Answer 150 questions correctly",
                    kind: .cup, measure: .correctAnswers, target: 150,
                    jewelReward: 50),
        Achievement(id: "cup.gold", emoji: "🥇", title: "Gold Cup",
                    detail: "Answer 300 questions correctly",
                    kind: .cup, measure: .correctAnswers, target: 300,
                    jewelReward: 75),
        Achievement(id: "cup.diamond", emoji: "💎", title: "Diamond Trophy",
                    detail: "Answer 750 questions correctly",
                    kind: .cup, measure: .correctAnswers, target: 750,
                    stickerReward: "explorer_e1")
    ]

    /// One badge for each particular feat.
    static let badges: [Achievement] = [
        Achievement(id: "badge.perfectStar", emoji: "⭐️", title: "Perfect Star",
                    detail: "Get 10 out of 10 in one level",
                    kind: .badge, measure: .perfectLevels, target: 1),
        Achievement(id: "badge.streakMaster", emoji: "🔥", title: "Streak Master",
                    detail: "Get 10 correct answers in a row",
                    kind: .badge, measure: .bestStreak, target: 10),
        Achievement(id: "badge.lightningHero", emoji: "⚡️", title: "Lightning Hero",
                    detail: "Finish 10 Lightning Rounds",
                    kind: .badge, measure: .proRounds(.lightningRound), target: 10),
        Achievement(id: "badge.speedChampion", emoji: "⏱️", title: "Speed Champion",
                    detail: "Finish 10 Timed Challenges",
                    kind: .badge, measure: .proRounds(.timedChallenge), target: 10),
        Achievement(id: "badge.perfectRunner", emoji: "🎯", title: "Perfect Runner",
                    detail: "Win 5 Perfect Runs",
                    kind: .badge, measure: .perfectRunWins, target: 5),
        Achievement(id: "badge.jewelHunter", emoji: "💎", title: "Jewel Hunter",
                    detail: "Earn 1,000 jewels altogether",
                    kind: .badge, measure: .jewelsEarned, target: 1000),
        Achievement(id: "badge.quizExplorer", emoji: "📚", title: "Quiz Explorer",
                    detail: "Answer 100 questions",
                    kind: .badge, measure: .questionsAnswered, target: 100),
        Achievement(id: "badge.quizMaster", emoji: "👑", title: "Quiz Master",
                    detail: "Answer 500 questions",
                    kind: .badge, measure: .questionsAnswered, target: 500),
        Achievement(id: "badge.grandChampion", emoji: "🏆", title: "Grand Champion",
                    detail: "Finish all 10 adventures",
                    kind: .badge, measure: .islandsComplete, target: 10)
    ]

    static let all: [Achievement] = cups + badges
}

/// The running totals every achievement is judged against. Kept as one value
/// so the whole trophy cabinet saves and loads in a single step.
struct LifetimeTally: Codable, Equatable {
    var questionsAnswered = 0
    var correctAnswers = 0
    /// Never goes down. See `Achievement.Measure.jewelsEarned`.
    var jewelsEarned = 0
    var bestStreak = 0
    var perfectLevels = 0
    var perfectRunWins = 0
    /// Rounds finished, keyed by `ProMode.rawValue`.
    var proRounds: [String: Int] = [:]
}
