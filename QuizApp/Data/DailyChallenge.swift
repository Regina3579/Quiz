//
//  DailyChallenge.swift
//  QuizApp
//
//  Picks the five questions for today's Daily Challenge out of one
//  adventure's own 100-question bank.
//
//  The aim is that it feels fresh rather than "level 2 again":
//
//    * the adventure rotates, a different island each day
//    * five questions drawn at random from that island's hundred
//    * spread across the difficulty ladder — two gentle, two middling,
//      one that stretches them
//    * questions answered recently are skipped where possible
//    * the set is fixed for the whole day, so closing the app and
//      coming back does not reshuffle it
//

import Foundation

enum DailyChallenge {

    static let questionCount = 5

    /// How long a question stays "recently seen" and gets passed over.
    private static let recentWindowDays = 21

    private static let recentKey = "quizspark.daily.recent.v1"
    private static let todaysSetKey = "quizspark.daily.set.v1"

    // MARK: - Which day, which adventure

    /// Whole days since 1970, so every device agrees on what "today" is and
    /// the set rolls over at local midnight.
    static func dayNumber(for date: Date = Date()) -> Int {
        let startOfDay = Calendar.current.startOfDay(for: date)
        return Int((startOfDay.timeIntervalSince1970 / 86_400).rounded(.down))
    }

    /// Today's adventure. With ten islands this cycles every ten days, so a
    /// child sees each world regularly without it being the same every week.
    static func island(on date: Date = Date()) -> Island? {
        let all = QuizData.islands
        guard !all.isEmpty else { return nil }
        let index = ((dayNumber(for: date) % all.count) + all.count) % all.count
        return all[index]
    }

    // MARK: - Question identity

    /// A stable way to name one question. `Question.id` is a fresh UUID on
    /// every launch, so it cannot be used to remember anything.
    static func key(islandID: Int, level: Int, index: Int) -> String {
        "\(islandID).\(level).\(index)"
    }

    private static func question(forKey key: String) -> Question? {
        let parts = key.split(separator: ".").compactMap { Int($0) }
        guard parts.count == 3,
              let island = QuizData.island(id: parts[0]),
              let level = island.level(parts[1]),
              level.questions.indices.contains(parts[2]) else { return nil }
        return level.questions[parts[2]]
    }

    // MARK: - Recently seen

    /// Question keys the child has met lately, with the day they met them.
    private static func recent() -> [String: Int] {
        let raw = UserDefaults.standard.dictionary(forKey: recentKey) as? [String: Int]
        let cutoff = dayNumber() - recentWindowDays
        return (raw ?? [:]).filter { $0.value >= cutoff }
    }

    /// Remembers that a set of questions has just been answered.
    static func noteSeen(keys: [String], on date: Date = Date()) {
        var store = recent()
        let today = dayNumber(for: date)
        for key in keys { store[key] = today }
        UserDefaults.standard.set(store, forKey: recentKey)
    }

    /// Convenience for a whole island level, all of whose questions were met.
    static func noteLevelPlayed(islandID: Int, level: Int, questionCount count: Int) {
        noteSeen(keys: (0..<count).map { key(islandID: islandID, level: level, index: $0) })
    }

    // MARK: - Today's five

    /// The questions for today, drawn once and then kept for the rest of the
    /// day so the set never changes underneath the child.
    static func todaysQuestions(on date: Date = Date()) -> [Question] {
        let today = dayNumber(for: date)

        if let saved = UserDefaults.standard.dictionary(forKey: todaysSetKey),
           saved["day"] as? Int == today,
           let keys = saved["keys"] as? [String] {
            let restored = keys.compactMap(question(forKey:))
            // Only trust the snapshot if every question still resolves; the
            // banks can change between app versions.
            if restored.count == keys.count, !restored.isEmpty { return restored }
        }

        let keys = pickKeys(for: today, date: date)
        UserDefaults.standard.set(["day": today, "keys": keys], forKey: todaysSetKey)
        noteSeen(keys: keys, on: date)
        return keys.compactMap(question(forKey:))
    }

    /// Chooses today's question keys: a spread across the difficulty ladder,
    /// avoiding anything seen lately, from different levels where possible.
    private static func pickKeys(for day: Int, date: Date) -> [String] {
        guard let island = island(on: date) else { return [] }

        var rng = SeededGenerator(seed: UInt64(bitPattern: Int64(day &* 2_654_435_761)))
        let seen = Set(recent().keys)

        // The island's own difficulty ladder, as laid out in CLAUDE.md.
        let bands: [(levels: ClosedRange<Int>, take: Int)] = [
            (1...2,  2),   // comfortable
            (3...5,  2),   // needs some thinking
            (6...10, 1)    // genuinely hard
        ]

        var chosen: [String] = []
        var usedLevels: Set<Int> = []

        for band in bands {
            let levels = island.levels
                .filter { band.levels.contains($0.number) }
                .shuffled(using: &rng)
            guard !levels.isEmpty else { continue }

            var taken = 0
            // Two passes: first prefer a level we haven't drawn from yet.
            for preferFreshLevel in [true, false] {
                for level in levels where taken < band.take {
                    if preferFreshLevel && usedLevels.contains(level.number) { continue }

                    let candidates = level.questions.indices
                        .map { key(islandID: island.id, level: level.number, index: $0) }
                        .filter { !chosen.contains($0) }
                    guard !candidates.isEmpty else { continue }

                    // Skip recently answered questions unless that would leave
                    // nothing to ask.
                    let fresh = candidates.filter { !seen.contains($0) }
                    let pool = fresh.isEmpty ? candidates : fresh

                    if let pick = pool.shuffled(using: &rng).first {
                        chosen.append(pick)
                        usedLevels.insert(level.number)
                        taken += 1
                    }
                }
                if taken >= band.take { break }
            }
        }

        // If a band came up short, top up from anywhere on the island.
        if chosen.count < questionCount {
            let everything = island.levels.flatMap { level in
                level.questions.indices.map {
                    key(islandID: island.id, level: level.number, index: $0)
                }
            }
            let spare = everything
                .filter { !chosen.contains($0) }
                .sorted { (seen.contains($0) ? 1 : 0) < (seen.contains($1) ? 1 : 0) }
            for candidate in spare.shuffled(using: &rng) where chosen.count < questionCount {
                chosen.append(candidate)
            }
        }

        return Array(chosen.prefix(questionCount))
    }
}

// MARK: - Repeatable randomness

/// A small deterministic generator (SplitMix64). Seeding it with the day
/// number means today's draw is the same every time it is worked out, while
/// tomorrow's is completely different.
struct SeededGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) { state = seed }

    mutating func next() -> UInt64 {
        state = state &+ 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }
}
