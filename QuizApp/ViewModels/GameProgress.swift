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

    /// TESTING: when true, every sticker counts as already owned, so they can
    /// all be placed for free. Set back to false to restore buying with jewels.
    static let unlockAllStickers = true

    /// Stars (0…3) keyed by "islandID-levelNumber".
    @Published private(set) var stars: [String: Int] = [:]

    /// The player's treasure chest — jewels earned for correct answers,
    /// perfect rounds and first-time level clears.
    @Published private(set) var jewels: Int = 0

    /// IDs of stickers the child has bought from the sticker shop.
    @Published private(set) var ownedStickers: Set<String> = []

    /// Stickers the child has placed in their sticker book (page + position).
    @Published private(set) var placedStickers: [PlacedSticker] = []

    /// Text boxes the child has dropped onto the sticker-book pages.
    @Published private(set) var placedNotes: [PlacedNote] = []

    private let defaultsKey = "quizspark.progress.v1"
    private let jewelsKey = "quizspark.jewels.v1"
    private let ownedStickersKey = "quizspark.stickers.owned.v1"
    private let placedStickersKey = "quizspark.stickers.placed.v1"
    private let placedNotesKey = "quizspark.notes.placed.v1"
    /// The retired one-note-per-page store, read once so nothing is lost.
    private let pageNotesKey = "quizspark.stickers.notes.v1"

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

    // MARK: - Sticker book

    /// Whether the child already owns a sticker.
    func owns(_ sticker: Sticker) -> Bool {
        if Self.unlockAllStickers { return true }
        return ownedStickers.contains(sticker.id)
    }

    /// Whether the child can afford a sticker they don't already own.
    func canBuy(_ sticker: Sticker) -> Bool {
        !owns(sticker) && jewels >= sticker.cost
    }

    /// Buys a sticker, spending jewels. Returns true on success.
    @discardableResult
    func buySticker(_ sticker: Sticker) -> Bool {
        guard !owns(sticker) else { return true }
        guard jewels >= sticker.cost else { return false }
        jewels -= sticker.cost
        ownedStickers.insert(sticker.id)
        saveJewels()
        saveStickers()
        return true
    }

    /// Places a copy of an owned sticker on a page and returns its id.
    @discardableResult
    func placeSticker(_ stickerID: String, page: Int, x: Double, y: Double) -> UUID {
        let placed = PlacedSticker(stickerID: stickerID, page: page, x: x, y: y)
        placedStickers.append(placed)
        saveStickers()
        return placed.id
    }

    /// Updates the position, scale and rotation of a placed sticker.
    func updatePlaced(_ id: UUID, x: Double, y: Double, scale: Double, rotation: Double) {
        guard let i = placedStickers.firstIndex(where: { $0.id == id }) else { return }
        placedStickers[i].x = x
        placedStickers[i].y = y
        placedStickers[i].scale = scale
        placedStickers[i].rotation = rotation
        saveStickers()
    }

    /// Removes a placed sticker from the book (the sticker stays owned).
    func removePlaced(_ id: UUID) {
        placedStickers.removeAll { $0.id == id }
        saveStickers()
    }

    /// All stickers placed on a given page.
    func stickers(onPage page: Int) -> [PlacedSticker] {
        placedStickers.filter { $0.page == page }
    }

    /// All text boxes on a given page.
    func notes(onPage page: Int) -> [PlacedNote] {
        placedNotes.filter { $0.page == page }
    }

    /// Drops a fresh empty text box on a page and returns its id.
    @discardableResult
    func addNote(page: Int, x: Double, y: Double) -> UUID {
        let note = PlacedNote(page: page, x: x, y: y)
        placedNotes.append(note)
        saveNotes()
        return note.id
    }

    /// Moves a text box to a new spot on its page.
    func moveNote(_ id: UUID, x: Double, y: Double) {
        guard let i = placedNotes.firstIndex(where: { $0.id == id }) else { return }
        placedNotes[i].x = x
        placedNotes[i].y = y
        saveNotes()
    }

    /// Saves what the child wrote in a text box.
    func setNoteText(_ id: UUID, text: String) {
        guard let i = placedNotes.firstIndex(where: { $0.id == id }) else { return }
        placedNotes[i].text = text
        saveNotes()
    }

    /// Peels a text box off the page.
    func removeNote(_ id: UUID) {
        placedNotes.removeAll { $0.id == id }
        saveNotes()
    }

    /// Wipes all saved progress (handy for testing / a "reset" button).
    func resetAll() {
        stars = [:]
        jewels = 0
        ownedStickers = []
        placedStickers = []
        placedNotes = []
        save()
        saveJewels()
        saveStickers()
        saveNotes()
    }

    // MARK: - Persistence

    private func load() {
        if let data = UserDefaults.standard.data(forKey: defaultsKey),
           let decoded = try? JSONDecoder().decode([String: Int].self, from: data) {
            stars = decoded
        }
        jewels = UserDefaults.standard.integer(forKey: jewelsKey)
        if let data = UserDefaults.standard.data(forKey: ownedStickersKey),
           let decoded = try? JSONDecoder().decode(Set<String>.self, from: data) {
            ownedStickers = decoded
        }
        if let data = UserDefaults.standard.data(forKey: placedStickersKey),
           let decoded = try? JSONDecoder().decode([PlacedSticker].self, from: data) {
            placedStickers = decoded
        }
        if let data = UserDefaults.standard.data(forKey: placedNotesKey),
           let decoded = try? JSONDecoder().decode([PlacedNote].self, from: data) {
            placedNotes = decoded
        } else if let data = UserDefaults.standard.data(forKey: pageNotesKey),
                  let old = try? JSONDecoder().decode([String: String].self, from: data) {
            // Carry over notes written against the old one-per-page pad by
            // dropping each onto its page as a text box.
            placedNotes = old.compactMap { key, value in
                guard let page = Int(key), !value.isEmpty else { return nil }
                return PlacedNote(page: page, x: 0.30, y: 0.78, text: value)
            }
            saveNotes()
        }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(stars) {
            UserDefaults.standard.set(data, forKey: defaultsKey)
        }
    }

    private func saveJewels() {
        UserDefaults.standard.set(jewels, forKey: jewelsKey)
    }

    private func saveStickers() {
        if let data = try? JSONEncoder().encode(ownedStickers) {
            UserDefaults.standard.set(data, forKey: ownedStickersKey)
        }
        if let data = try? JSONEncoder().encode(placedStickers) {
            UserDefaults.standard.set(data, forKey: placedStickersKey)
        }
    }

    private func saveNotes() {
        if let data = try? JSONEncoder().encode(placedNotes) {
            UserDefaults.standard.set(data, forKey: placedNotesKey)
        }
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
