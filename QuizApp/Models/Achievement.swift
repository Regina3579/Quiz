//
//  Achievement.swift
//  QuizApp
//
//  Everything the child can win and keep in the Trophy Room.
//
//  There are three kinds. Each adventure has its own ladder — bronze, silver
//  and gold badges as its hundred questions are answered right, an Explorer
//  Cup for clearing all ten levels, and a Master Crown for getting every
//  question in it right. The Grand Cups climb with correct answers across the
//  whole game. The badges are one-off feats. And at the end of it all stands
//  the Ultimate Adventurer Trophy, for filling every pedestal.
//
//  An achievement is only ever a description: what it is called, what has to
//  be done, and which running total that is counted against. GameProgress
//  keeps the totals and decides when one has been earned, so nothing here has
//  to know about saving or about the rest of the game, and adding an award is
//  adding one entry to a list.
//

import SwiftUI

struct Achievement: Identifiable, Hashable {

    enum Kind: Hashable {
        /// One rung of a single adventure's ladder.
        case adventure(islandID: Int)
        /// The game-wide cups.
        case grandCup
        /// A one-off feat.
        case badge
        /// The one at the end.
        case ultimate
    }

    /// Which running total an achievement is measured against.
    enum Measure: Hashable {
        case correctAnswers
        case questionsAnswered
        /// Gems earned over the whole journey — spending them never takes
        /// this back down, or buying a sticker would cost the child an award.
        case gemsEarned
        case bestStreak
        /// Levels finished with every question right.
        case perfectLevels
        /// Rounds finished in one Pro mode.
        case proRounds(ProMode)
        /// Perfect Runs that went all the way without a wrong answer.
        case perfectRunWins
        case islandsComplete
        /// Best-ever correct answers within one adventure, out of its 100.
        case islandCorrect(islandID: Int)
        /// Levels cleared within one adventure.
        case islandLevelsCleared(islandID: Int)
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
    /// Gems handed over when it is won.
    var gemReward: Int = 0
    /// A keepsake sticker handed over with it, by sticker id.
    var stickerReward: String? = nil

    /// True when this is worth opening a treasure chest for.
    var opensChest: Bool { gemReward > 0 || stickerReward != nil }

    /// The rewards as lines for the chest.
    var rewardLines: [String] {
        var lines: [String] = []
        if gemReward > 0 { lines.append("+\(gemReward) 💎") }
        if stickerReward != nil { lines.append("+1 rare sticker") }
        lines.append(title)
        return lines
    }

    /// The island this belongs to, if it is part of an adventure ladder.
    var islandID: Int? {
        if case .adventure(let id) = kind { return id }
        return nil
    }
}

/// The full list, in the order the Trophy Room shows them.
enum AchievementCatalog {

    // MARK: - Adventure ladders

    /// What each adventure's cup and crown are called. The rest of the rungs
    /// are the same everywhere, so only these two need naming.
    private struct Titles {
        let cup: String
        let crown: String
    }

    /// The keepsake sticker each Master Crown comes with — one that belongs to
    /// that adventure, so ten crowns are ten different prizes rather than the
    /// same one ten times.
    private static let crownSticker: [Int: String] = [
        0: "animal_e19",    // gold lion
        1: "galaxy_e3",     // star wizard juggling planets
        2: "dino_e6",       // crowned crystal T. rex
        3: "ocean_e4",      // angelfish queen
        4: "explorer_e3",   // golden globe and world landmarks
        5: "blossom_c4",    // cherry tree
        6: "animal_e21",    // crowned unicorn
        7: "dino_e1",       // crystal ankylosaurus
        8: "ocean_e3",      // jewelled lobster by a treasure chest
        9: "galaxy_e6"      // robot astronaut hugging a star
    ]

    private static let titles: [Int: Titles] = [
        0: Titles(cup: "Jungle Explorer Cup",  crown: "Jungle Master Crown"),
        1: Titles(cup: "Galaxy Explorer Cup",  crown: "Galaxy Master Crown"),
        2: Titles(cup: "Dino Explorer Cup",    crown: "Dino Master Crown"),
        3: Titles(cup: "Ocean Explorer Cup",   crown: "Ocean Master Crown"),
        4: Titles(cup: "Trail Explorer Cup",   crown: "Trail Master Crown"),
        5: Titles(cup: "Garden Explorer Cup",  crown: "Garden Master Crown"),
        6: Titles(cup: "Junior Scientist Cup", crown: "Science Master Crown"),
        7: Titles(cup: "Brain Knight Cup",     crown: "Brain Champion Crown"),
        8: Titles(cup: "Ancient Explorer Cup", crown: "Crown of the Ancients"),
        9: Titles(cup: "Summit Explorer Cup",  crown: "Ultimate Champion Cup")
    ]

    /// The five rungs of one adventure's ladder, smallest first.
    static func ladder(for island: Island) -> [Achievement] {
        let id = island.id
        let name = titles[id] ?? Titles(cup: "\(island.name) Cup",
                                        crown: "\(island.name) Crown")
        let kind = Achievement.Kind.adventure(islandID: id)

        return [
            Achievement(id: "adv.\(id).bronze", emoji: "🥉",
                        title: "Bronze Badge",
                        detail: "25 right in \(island.name)",
                        kind: kind, measure: .islandCorrect(islandID: id), target: 25,
                        gemReward: 15),
            Achievement(id: "adv.\(id).silver", emoji: "🥈",
                        title: "Silver Badge",
                        detail: "50 right in \(island.name)",
                        kind: kind, measure: .islandCorrect(islandID: id), target: 50,
                        gemReward: 25),
            Achievement(id: "adv.\(id).gold", emoji: "🥇",
                        title: "Gold Badge",
                        detail: "75 right in \(island.name)",
                        kind: kind, measure: .islandCorrect(islandID: id), target: 75,
                        gemReward: 40),
            Achievement(id: "adv.\(id).cup", emoji: "🏆",
                        title: name.cup,
                        detail: "Finish all 10 levels of \(island.name)",
                        kind: kind, measure: .islandLevelsCleared(islandID: id), target: 10,
                        gemReward: 60),
            Achievement(id: "adv.\(id).crown", emoji: "👑",
                        title: name.crown,
                        detail: "Get all 100 questions right in \(island.name)",
                        kind: kind, measure: .islandCorrect(islandID: id), target: 100,
                        gemReward: 100, stickerReward: crownSticker[id])
        ]
    }

    static let adventure: [Achievement] = QuizData.islands.flatMap { ladder(for: $0) }

    // MARK: - Grand cups

    /// Every correct answer anywhere in the game counts towards these, so they
    /// keep climbing whether the child plays the map or the Pro room.
    static let grandCups: [Achievement] = [
        Achievement(id: "cup.bronze", emoji: "🥉", title: "Bronze Cup",
                    detail: "Answer 50 questions correctly",
                    kind: .grandCup, measure: .correctAnswers, target: 50,
                    gemReward: 25),
        Achievement(id: "cup.silver", emoji: "🥈", title: "Silver Cup",
                    detail: "Answer 150 questions correctly",
                    kind: .grandCup, measure: .correctAnswers, target: 150,
                    gemReward: 50),
        Achievement(id: "cup.gold", emoji: "🥇", title: "Gold Cup",
                    detail: "Answer 300 questions correctly",
                    kind: .grandCup, measure: .correctAnswers, target: 300,
                    gemReward: 75),
        Achievement(id: "cup.diamond", emoji: "💎", title: "Diamond Trophy",
                    detail: "Answer 750 questions correctly",
                    kind: .grandCup, measure: .correctAnswers, target: 750,
                    gemReward: 100, stickerReward: "explorer_e1")
    ]

    // MARK: - Special achievements

    static let badges: [Achievement] = [
        Achievement(id: "badge.perfectStar", emoji: "⭐️", title: "Perfect Star",
                    detail: "Get 10 out of 10 in one level",
                    kind: .badge, measure: .perfectLevels, target: 1),
        Achievement(id: "badge.perfectMaster", emoji: "🌟", title: "Perfect Master",
                    detail: "Get 10 perfect levels",
                    kind: .badge, measure: .perfectLevels, target: 10,
                    gemReward: 50),
        Achievement(id: "badge.streakMaster", emoji: "🔥", title: "Streak Master",
                    detail: "Get 10 correct answers in a row",
                    kind: .badge, measure: .bestStreak, target: 10),
        Achievement(id: "badge.lightningHero", emoji: "⚡️", title: "Lightning Hero",
                    detail: "Finish 10 Lightning Rounds",
                    kind: .badge, measure: .proRounds(.lightningRound), target: 10,
                    gemReward: 40),
        Achievement(id: "badge.speedChampion", emoji: "⏱️", title: "Speed Champion",
                    detail: "Finish 10 Timed Challenges",
                    kind: .badge, measure: .proRounds(.timedChallenge), target: 10,
                    gemReward: 40),
        Achievement(id: "badge.perfectRunner", emoji: "🎯", title: "Perfect Runner",
                    detail: "Win 5 Perfect Runs",
                    kind: .badge, measure: .perfectRunWins, target: 5,
                    gemReward: 40),
        // The id stays "jewelHunter": it is saved in unlockedAchievements, and
        // renaming it would take the badge back off anyone who had won it.
        Achievement(id: "badge.jewelHunter", emoji: "💎", title: "Gem Hunter",
                    detail: "Earn 1,000 gems altogether",
                    kind: .badge, measure: .gemsEarned, target: 1000),
        Achievement(id: "badge.quizExplorer", emoji: "📚", title: "Quiz Explorer",
                    detail: "Answer 100 questions",
                    kind: .badge, measure: .questionsAnswered, target: 100),
        Achievement(id: "badge.quizMaster", emoji: "👑", title: "Quiz Master",
                    detail: "Answer 500 questions",
                    kind: .badge, measure: .questionsAnswered, target: 500,
                    gemReward: 50)
    ]

    // MARK: - The one at the end

    static let ultimate = Achievement(
        id: "ultimate.adventurer", emoji: "✨", title: "Ultimate Adventurer",
        detail: "Finish all 10 adventures",
        kind: .ultimate, measure: .islandsComplete, target: 10,
        gemReward: 250, stickerReward: "ocean_e2")

    static let all: [Achievement] = adventure + grandCups + badges + [ultimate]
}

/// The running totals every achievement is judged against. Kept as one value
/// so the whole trophy cabinet saves and loads in a single step.
struct LifetimeTally: Codable, Equatable {
    var questionsAnswered = 0
    var correctAnswers = 0
    /// Never goes down. See `Achievement.Measure.gemsEarned`.
    var gemsEarned = 0
    var bestStreak = 0
    var perfectLevels = 0
    var perfectRunWins = 0
    /// Rounds finished, keyed by `ProMode.rawValue`.
    var proRounds: [String: Int] = [:]
}
