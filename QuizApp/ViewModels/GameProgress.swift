//
//  GameProgress.swift
//  QuizApp
//
//  Tracks stars earned per level and the unlock state of levels and
//  islands. Saved to UserDefaults so progress survives app launches.
//

import SwiftUI

/// The player's saved journey. Injected into the environment and observed
/// by the map, the island trails and the result screen.
@MainActor
final class GameProgress: ObservableObject {

    /// TESTING: when true, every island and every authored level is unlocked
    /// so the whole game can be explored freely. Set back to false to restore
    /// the normal "unlock as you go" progression.
    static let unlockEverything = true

    /// Stars (0…3) keyed by "islandID-levelNumber".
    @Published private(set) var stars: [String: Int] = [:]

    /// The player's treasure chest — jewels earned for correct answers,
    /// perfect rounds and first-time level clears.
    @Published private(set) var jewels: Int = 0

    private let defaultsKey = "quizspark.progress.v1"
    private let jewelsKey = "quizspark.jewels.v1"

    // Jewel reward amounts.
    static let jewelsPerCorrect = 5
    static let perfectBonus = 20
    static let firstClearBonus = 10

    init() { load() }

    // MARK: - Keys

    private func key(_ islandID: Int, _ level: Int) -> String {
        "\(islandID)-\(level)"
    }

    // MARK: - Reading

    /// Stars earned on a specific level (0 if never passed).
    func stars(islandID: Int, level: Int) -> Int {
        stars[key(islandID, level)] ?? 0
    }

    /// Total stars collected across all authored levels of an island.
    func totalStars(for island: Island) -> Int {
        island.levels.reduce(0) { $0 + stars(islandID: island.id, level: $1.number) }
    }

    /// The most stars possible on an island right now.
    func maxStars(for island: Island) -> Int { island.authoredLevels * 3 }

    /// A level is *cleared* once it has at least one star.
    func isCleared(islandID: Int, level: Int) -> Bool {
        stars(islandID: islandID, level: level) >= 1
    }

    /// Whether a level can be played: it must be authored, its island
    /// unlocked, and the previous level cleared (level 1 is always open).
    func isLevelUnlocked(island: Island, level: Int, allIslands: [Island]) -> Bool {
        // Still require the level to actually have questions.
        guard level <= island.authoredLevels else { return false }
        if Self.unlockEverything { return true }
        guard isIslandUnlocked(island: island, allIslands: allIslands) else { return false }
        if level <= 1 { return true }
        return isCleared(islandID: island.id, level: level - 1)
    }

    /// An island is complete when every authored level is cleared.
    func isIslandComplete(_ island: Island) -> Bool {
        guard island.authoredLevels > 0 else { return false }
        return island.levels.allSatisfy { isCleared(islandID: island.id, level: $0.number) }
    }

    /// The first island is always open; later islands open once the
    /// previous island is complete.
    func isIslandUnlocked(island: Island, allIslands: [Island]) -> Bool {
        if Self.unlockEverything { return true }
        guard let index = allIslands.firstIndex(where: { $0.id == island.id }) else { return false }
        if index == 0 { return true }
        return isIslandComplete(allIslands[index - 1])
    }

    // MARK: - Writing

    /// Records a level result, keeping the player's best star count.
    func record(islandID: Int, level: Int, earned: Int) {
        let k = key(islandID, level)
        let best = max(stars[k] ?? 0, earned)
        if best != stars[k] {
            stars[k] = best
            save()
        }
    }

    /// Finishes a level: saves the best star count, awards jewels, and returns
    /// a breakdown so the result screen can show the reward. Call once per
    /// completed play-through.
    func completeLevel(islandID: Int, level: Int,
                       correct: Int, total: Int, earned: Int) -> JewelReward {
        // The first-clear bonus applies only the first time a level is cleared.
        let firstClear = !isCleared(islandID: islandID, level: level) && earned >= 1

        record(islandID: islandID, level: level, earned: earned)

        let perCorrect = correct * Self.jewelsPerCorrect
        let perfect = (total > 0 && correct == total) ? Self.perfectBonus : 0
        let firstBonus = firstClear ? Self.firstClearBonus : 0

        let reward = JewelReward(correctCount: correct,
                                 perCorrect: perCorrect,
                                 perfectBonus: perfect,
                                 firstClearBonus: firstBonus)
        jewels += reward.total
        saveJewels()
        return reward
    }

    /// Wipes all saved progress (handy for testing / a "reset" button).
    func resetAll() {
        stars = [:]
        jewels = 0
        save()
        saveJewels()
    }

    // MARK: - Persistence

    private func load() {
        if let data = UserDefaults.standard.data(forKey: defaultsKey),
           let decoded = try? JSONDecoder().decode([String: Int].self, from: data) {
            stars = decoded
        }
        jewels = UserDefaults.standard.integer(forKey: jewelsKey)
    }

    private func save() {
        if let data = try? JSONEncoder().encode(stars) {
            UserDefaults.standard.set(data, forKey: defaultsKey)
        }
    }

    private func saveJewels() {
        UserDefaults.standard.set(jewels, forKey: jewelsKey)
    }
}

/// A breakdown of the jewels earned from finishing a level.
struct JewelReward {
    let correctCount: Int
    let perCorrect: Int
    let perfectBonus: Int
    let firstClearBonus: Int

    var total: Int { perCorrect + perfectBonus + firstClearBonus }
    var isPerfect: Bool { perfectBonus > 0 }
    var isFirstClear: Bool { firstClearBonus > 0 }
}
