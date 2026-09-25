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
    /// all be placed for free. Set back to false to restore buying with gems.
    ///
    /// MUST be false before the App Store build. It short-circuits `owns`,
    /// which hands every child the whole book and leaves the Pro sticker lock
    /// doing nothing — the shop still draws its PRO badges, but `owns` is
    /// checked first, so every sticker reads as bought and none of them are.
    /// It takes the paywall off silently, which is exactly why it is written
    /// down here rather than remembered.
    static let unlockAllStickers = true

    /// Stars (0…3) keyed by "islandID-levelNumber".
    @Published private(set) var stars: [String: Int] = [:]

    /// The best number of correct answers ever reached on each level, keyed
    /// the same way. An adventure's "100 out of 100" is the sum of these, so
    /// a child gets there by eventually mastering every level — not by
    /// replaying one easy level over and over.
    @Published private(set) var bestCorrect: [String: Int] = [:]

    /// The player's treasure chest — gems earned for correct answers,
    /// perfect rounds and first-time level clears.
    @Published private(set) var gems: Int = 0

    /// IDs of stickers the child has bought from the sticker shop.
    @Published private(set) var ownedStickers: Set<String> = []

    /// Stickers the child has placed in their sticker book (page + position).
    @Published private(set) var placedStickers: [PlacedSticker] = []

    /// Text boxes the child has dropped onto the sticker-book pages.
    @Published private(set) var placedNotes: [PlacedNote] = []

    /// Best score reached in each Pro Challenge mode.
    @Published private(set) var proBestScores: [String: Int] = [:]

    /// When the Daily Challenge was last completed.
    @Published private(set) var dailyPlayedOn: Date?

    /// Running totals over the whole journey, which the Trophy Room's cups
    /// and badges are measured against.
    @Published private(set) var tally = LifetimeTally()

    /// The ids of every award already won.
    @Published private(set) var unlockedAchievements: Set<String> = []

    /// Awards won by the round that has just finished, for the result screen
    /// to celebrate. Cleared when the next round starts.
    @Published private(set) var recentlyUnlocked: [Achievement] = []

    private let defaultsKey = "quizspark.progress.v1"
    /// Still "jewels" on purpose. The currency was renamed to gems, but
    /// this is the key its balance is saved under — changing it would
    /// orphan the store and every child would open the app to nothing.
    private let gemsKey = "quizspark.jewels.v1"
    private let ownedStickersKey = "quizspark.stickers.owned.v1"
    private let placedStickersKey = "quizspark.stickers.placed.v1"
    private let placedNotesKey = "quizspark.notes.placed.v1"
    private let proScoresKey = "quizspark.pro.best.v1"
    private let dailyPlayedKey = "quizspark.pro.daily.v1"
    private let bestCorrectKey = "quizspark.bestCorrect.v1"
    private let tallyKey = "quizspark.tally.v1"
    private let achievementsKey = "quizspark.achievements.v1"
    /// The retired one-note-per-page store, read once so nothing is lost.
    private let pageNotesKey = "quizspark.stickers.notes.v1"

    // Gem reward amounts live in GemRules, at the bottom of this file.

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

    /// Finishes a level: saves the best star count, awards gems, and returns
    /// a breakdown so the result screen can show the reward. Call once per
    /// completed play-through. Pass the per-question results so the streak
    /// bonuses can be worked out.
    func completeLevel(islandID: Int, level: Int,
                       correct: Int, total: Int, earned: Int,
                       results: [Bool]) -> GemReward {
        record(islandID: islandID, level: level, earned: earned)

        // So tomorrow's Daily Challenge can pass over what was just answered.
        DailyChallenge.noteLevelPlayed(islandID: islandID, level: level,
                                       questionCount: total)

        let reward = GemRules.reward(results: results,
                                       correct: correct,
                                       total: total)
        gems += reward.total
        saveGems()

        // Keep the best run on this level, for the adventure's own ladder.
        let bestKey = key(islandID, level)
        if correct > (bestCorrect[bestKey] ?? 0) {
            bestCorrect[bestKey] = correct
            saveBestCorrect()
        }

        bank(results: results, correct: correct, total: total, earned: reward.total)
        // A "perfect level" is the whole level answered without a mistake —
        // the feat the Perfect Star badge is named for.
        if total > 0, correct == total { tally.perfectLevels += 1 }
        saveTally()
        awardEarnedAchievements()

        return reward
    }

    // MARK: - Trophy Room

    /// Where the child currently stands against one award.
    func standing(_ achievement: Achievement) -> Int {
        switch achievement.measure {
        case .correctAnswers:    return tally.correctAnswers
        case .questionsAnswered: return tally.questionsAnswered
        case .gemsEarned:      return tally.gemsEarned
        case .bestStreak:        return tally.bestStreak
        case .perfectLevels:     return tally.perfectLevels
        case .perfectRunWins:    return tally.perfectRunWins
        case .proRounds(let mode): return tally.proRounds[mode.rawValue] ?? 0
        case .islandsComplete:   return QuizData.islands.filter { isIslandComplete($0) }.count
        case .islandCorrect(let id):       return bestCorrect(inIsland: id)
        case .islandLevelsCleared(let id): return levelsCleared(inIsland: id)
        }
    }

    /// The best-ever correct answers across one adventure's levels — its
    /// score out of 100.
    func bestCorrect(inIsland id: Int) -> Int {
        guard let island = QuizData.island(id: id) else { return 0 }
        return island.levels.reduce(0) { $0 + (bestCorrect[key(id, $1.number)] ?? 0) }
    }

    /// How many of an adventure's levels have been cleared.
    func levelsCleared(inIsland id: Int) -> Int {
        guard let island = QuizData.island(id: id) else { return 0 }
        return island.levels.filter { isCleared(islandID: id, level: $0.number) }.count
    }

    /// The rungs of one adventure's ladder, and where the child is on it.
    func ladder(for island: Island) -> [Achievement] {
        AchievementCatalog.ladder(for: island)
    }

    /// The highest rung won on an adventure's ladder, if any.
    func topRung(for island: Island) -> Achievement? {
        ladder(for: island).last { hasWon($0) }
    }

    /// The next rung still to win on an adventure's ladder.
    func nextRung(for island: Island) -> Achievement? {
        ladder(for: island).first { !hasWon($0) }
    }

    /// How many adventures have their Explorer Cup — the pedestals filled.
    var pedestalsFilled: Int {
        QuizData.islands.filter { island in
            ladder(for: island).first { $0.id.hasSuffix(".cup") }.map { hasWon($0) } ?? false
        }.count
    }

    func hasWon(_ achievement: Achievement) -> Bool {
        unlockedAchievements.contains(achievement.id)
    }

    /// How many awards have been won out of all there are.
    var trophyCount: Int {
        AchievementCatalog.all.filter { hasWon($0) }.count
    }

    /// The best grand cup won so far, for the little badge on the map button.
    var topCup: Achievement? {
        AchievementCatalog.grandCups.last { hasWon($0) }
    }

    /// Adds a finished round to the running totals.
    private func bank(results: [Bool], correct: Int, total: Int, earned: Int) {
        tally.questionsAnswered += total
        tally.correctAnswers += correct
        tally.gemsEarned += earned
        tally.bestStreak = max(tally.bestStreak, GemRules.longestStreak(results))
    }

    /// Hands over every award now earned and records what was new, so the
    /// result screen can show it.
    ///
    /// This loops because an award can pay gems, and paying gems can be
    /// what wins the next one — Gem Hunter falling out of a cup, say. It
    /// settles as soon as a pass finds nothing new.
    private func awardEarnedAchievements() {
        var fresh: [Achievement] = []
        var found = true

        while found {
            found = false
            for award in AchievementCatalog.all where !unlockedAchievements.contains(award.id) {
                guard standing(award) >= award.target else { continue }
                unlockedAchievements.insert(award.id)
                if award.gemReward > 0 {
                    gems += award.gemReward
                    tally.gemsEarned += award.gemReward
                }
                if let sticker = award.stickerReward { ownedStickers.insert(sticker) }
                fresh.append(award)
                found = true
            }
        }

        // Always replaced, empty included — so a result screen reading this
        // right after banking its round can never pick up the last one's.
        recentlyUnlocked = fresh

        guard !fresh.isEmpty else { return }
        saveGems()
        saveStickers()
        saveTally()
        saveAchievements()
    }

    // MARK: - Sticker book

    /// Whether the child already owns a sticker.
    func owns(_ sticker: Sticker) -> Bool {
        if Self.unlockAllStickers { return true }
        return ownedStickers.contains(sticker.id)
    }

    /// Whether Pro is needed before this one can even be bought.
    ///
    /// Only ever about buying. A sticker won from the Trophy Room arrives
    /// through `awardEarnedAchievements` and is owned outright — a Master
    /// Crown earned by getting all hundred questions right is not going to
    /// turn round and ask for money.
    func needsPro(_ sticker: Sticker) -> Bool {
        guard !Pro.isActive else { return false }
        return !StickerCatalog.freeSampleIDs.contains(sticker.id)
    }

    /// Whether the child can afford a sticker they don't already own.
    func canBuy(_ sticker: Sticker) -> Bool {
        !owns(sticker) && !needsPro(sticker) && gems >= sticker.cost
    }

    /// Spends gems on a hint. Returns false when there are not enough, so a
    /// caller never has to check the balance itself.
    ///
    /// This does not touch `tally.gemsEarned`, which only ever counts gems
    /// coming in — buying hints must not walk a child backwards away from the
    /// Gem Hunter badge they are working towards.
    @discardableResult
    func spendOnHint(cost: Int) -> Bool {
        guard gems >= cost else { return false }
        gems -= cost
        saveGems()
        return true
    }

    /// Buys a sticker, spending gems. Returns true on success.
    @discardableResult
    func buySticker(_ sticker: Sticker) -> Bool {
        guard !owns(sticker) else { return true }
        // Checked here and not only in the shop: this is the one door gems
        // leave by, so it is the one place the lock has to hold.
        guard !needsPro(sticker) else { return false }
        guard gems >= sticker.cost else { return false }
        gems -= sticker.cost
        ownedStickers.insert(sticker.id)
        saveGems()
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

    // MARK: - Pro Challenge

    /// The best score reached in each Pro mode, keyed by the mode's raw value.
    func proBest(_ mode: ProMode) -> Int { proBestScores[mode.rawValue] ?? 0 }

    /// Whether a once-a-day mode has already been played today.
    func isPlayedToday(_ mode: ProMode) -> Bool {
        guard mode.isOncePerDay else { return false }
        guard let last = dailyPlayedOn else { return false }
        return Calendar.current.isDateInToday(last)
    }

    /// Marks the Daily Challenge as done for today.
    func markPlayedToday() {
        dailyPlayedOn = Date()
        UserDefaults.standard.set(dailyPlayedOn, forKey: dailyPlayedKey)
    }

    /// Banks the gems from a finished Pro round, remembers the best score
    /// and adds the round to the Trophy Room's tallies. Returns true when this
    /// run beat the previous best.
    ///
    /// `results` is the per-question record; `endedEarly` says the round was
    /// cut short by a wrong answer, which is what separates a Perfect Run that
    /// was won from one that was merely played.
    @discardableResult
    func finishProRound(mode: ProMode, score: Int, gems earned: Int,
                        results: [Bool] = [], endedEarly: Bool = false) -> Bool {
        if earned > 0 {
            gems += earned
            saveGems()
        }
        if mode.isOncePerDay { markPlayedToday() }

        bank(results: results, correct: score, total: results.count, earned: earned)
        tally.proRounds[mode.rawValue, default: 0] += 1
        if mode == .perfectRun, !endedEarly, !results.isEmpty, !results.contains(false) {
            tally.perfectRunWins += 1
        }
        saveTally()
        awardEarnedAchievements()

        let isBest = score > proBest(mode)
        if isBest {
            proBestScores[mode.rawValue] = score
            saveProScores()
        }
        return isBest
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
        gems = 0
        ownedStickers = []
        placedStickers = []
        placedNotes = []
        proBestScores = [:]
        dailyPlayedOn = nil
        bestCorrect = [:]
        tally = LifetimeTally()
        unlockedAchievements = []
        recentlyUnlocked = []
        UserDefaults.standard.removeObject(forKey: dailyPlayedKey)
        // Pro is part of "all saved progress". Leaving it behind meant a reset
        // handed back a brand-new player who somehow already owned Pro, and
        // there was no other way in the app to put it back.
        Pro.lock()
        save()
        saveGems()
        saveStickers()
        saveNotes()
        saveProScores()
        saveBestCorrect()
        saveTally()
        saveAchievements()
    }

    // MARK: - Persistence

    private func load() {
        if let data = UserDefaults.standard.data(forKey: defaultsKey),
           let decoded = try? JSONDecoder().decode([String: Int].self, from: data) {
            stars = decoded
        }
        gems = UserDefaults.standard.integer(forKey: gemsKey)
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
        if let data = UserDefaults.standard.data(forKey: proScoresKey),
           let decoded = try? JSONDecoder().decode([String: Int].self, from: data) {
            proBestScores = decoded
        }
        dailyPlayedOn = UserDefaults.standard.object(forKey: dailyPlayedKey) as? Date
        if let data = UserDefaults.standard.data(forKey: bestCorrectKey),
           let decoded = try? JSONDecoder().decode([String: Int].self, from: data) {
            bestCorrect = decoded
        }
        if let data = UserDefaults.standard.data(forKey: tallyKey),
           let decoded = try? JSONDecoder().decode(LifetimeTally.self, from: data) {
            tally = decoded
        }
        if let data = UserDefaults.standard.data(forKey: achievementsKey),
           let decoded = try? JSONDecoder().decode(Set<String>.self, from: data) {
            unlockedAchievements = decoded
        }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(stars) {
            UserDefaults.standard.set(data, forKey: defaultsKey)
        }
    }

    private func saveGems() {
        UserDefaults.standard.set(gems, forKey: gemsKey)
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

    private func saveProScores() {
        if let data = try? JSONEncoder().encode(proBestScores) {
            UserDefaults.standard.set(data, forKey: proScoresKey)
        }
    }

    private func saveBestCorrect() {
        if let data = try? JSONEncoder().encode(bestCorrect) {
            UserDefaults.standard.set(data, forKey: bestCorrectKey)
        }
    }

    private func saveTally() {
        if let data = try? JSONEncoder().encode(tally) {
            UserDefaults.standard.set(data, forKey: tallyKey)
        }
    }

    private func saveAchievements() {
        if let data = try? JSONEncoder().encode(unlockedAchievements) {
            UserDefaults.standard.set(data, forKey: achievementsKey)
        }
    }
}

/// The one place the gem economy is defined, so the adventure map and the
/// Pro Challenge always pay out by the same rules.
///
///   Correct answer        +5
///   3 correct in a row    +5    once per round
///   5 correct in a row   +10    once per round
///   Perfect round        +20
///
/// The streak bonuses are deliberately awarded at most once each. Paying
/// them every time a run of three comes around again would let a long
/// round snowball far past what a sticker is worth.
enum GemRules {
    static let perCorrect = 5

    /// What each hint costs, in the order they are bought. The second is
    /// dearer because it is worth more: the first narrows four answers to
    /// three, the second takes it down to two.
    static let hintCosts = [10, 20]

    /// The price of the next hint when `used` have been bought already.
    static func hintCost(after used: Int) -> Int {
        hintCosts[min(max(0, used), hintCosts.count - 1)]
    }

    /// 50-50 Magic: both hints at once, for less than buying them one after
    /// the other. Deliberately cheaper than the 30 that two separate hints
    /// come to — a child who already knows they are stuck should not pay a
    /// penalty for saying so up front.
    static let fiftyFiftyCost = 25
    static let streakOfThree = 5
    static let streakOfFive = 10
    static let perfectRound = 20

    /// The longest run of correct answers in a set of results.
    static func longestStreak(_ results: [Bool]) -> Int {
        var best = 0, run = 0
        for correct in results {
            run = correct ? run + 1 : 0
            best = max(best, run)
        }
        return best
    }

    /// Works out the payout for a finished round.
    /// - Parameters:
    ///   - streakMultiplier: doubles the streak bonuses, for Gems Rush.
    ///   - awardsStreakBonuses: false for short rounds like the Daily
    ///     Challenge, where five questions would trigger both milestones at
    ///     once and overpay a deliberately modest round.
    ///   - perfectBonus: overrides the usual perfect-round reward.
    ///   - completionBonus: a flat extra for finishing a Pro mode.
    static func reward(results: [Bool],
                       correct: Int,
                       total: Int,
                       streakMultiplier: Int = 1,
                       awardsStreakBonuses: Bool = true,
                       perfectBonus: Int? = nil,
                       completionBonus: Int = 0) -> GemReward {
        let streak = longestStreak(results)
        let perfect = total > 0 && correct == total
        let three = awardsStreakBonuses && streak >= 3 ? streakOfThree * streakMultiplier : 0
        let five = awardsStreakBonuses && streak >= 5 ? streakOfFive * streakMultiplier : 0
        return GemReward(
            correctCount: correct,
            perCorrect: correct * perCorrect,
            streakThreeBonus: three,
            streakFiveBonus: five,
            perfectBonus: perfect ? (perfectBonus ?? perfectRound) : 0,
            completionBonus: completionBonus,
            longestStreak: streak)
    }

    /// The most a round of this shape can pay, for the "up to N gems" label.
    static func bestPossible(questionCount: Int,
                             streakMultiplier: Int = 1,
                             awardsStreakBonuses: Bool = true,
                             perfectBonus: Int? = nil,
                             completionBonus: Int = 0) -> Int {
        let all = Array(repeating: true, count: questionCount)
        return reward(results: all,
                      correct: questionCount,
                      total: questionCount,
                      streakMultiplier: streakMultiplier,
                      awardsStreakBonuses: awardsStreakBonuses,
                      perfectBonus: perfectBonus,
                      completionBonus: completionBonus).total
    }
}

/// A breakdown of the gems earned from finishing a round.
struct GemReward {
    let correctCount: Int
    let perCorrect: Int
    let streakThreeBonus: Int
    let streakFiveBonus: Int
    let perfectBonus: Int
    let completionBonus: Int
    let longestStreak: Int

    var total: Int {
        perCorrect + streakThreeBonus + streakFiveBonus + perfectBonus + completionBonus
    }
    var isPerfect: Bool { perfectBonus > 0 }
    var hasStreakThree: Bool { streakThreeBonus > 0 }
    var hasStreakFive: Bool { streakFiveBonus > 0 }
}
