//
//  ProQuizViewModel.swift
//  QuizApp
//
//  Drives one Pro Challenge round. Unlike the island levels, a Pro round
//  can be racing a clock, can end the moment an answer is wrong, and can
//  pay out more jewels the longer a streak runs.
//

import SwiftUI

@MainActor
final class ProQuizViewModel: ObservableObject {

    let mode: ProMode
    /// The island being tested, for Category Master only.
    let island: Island?

    @Published private(set) var questions: [Question] = []
    @Published private(set) var currentIndex = 0
    @Published private(set) var score = 0
    @Published private(set) var selectedOption: Int?
    @Published private(set) var hasAnswered = false
    @Published private(set) var isFinished = false

    /// Per-question record, used for the recap row on the results screen.
    @Published private(set) var results: [Bool] = []

    /// Jewels banked so far this round, before any completion bonus.
    @Published private(set) var jewelsEarned = 0

    /// How many correct answers in a row right now.
    @Published private(set) var streak = 0
    /// The best streak reached during the round.
    @Published private(set) var bestStreak = 0

    /// Seconds left on the current question (timed modes only).
    @Published private(set) var timeRemaining = 0
    /// True when the round stopped early because of a wrong answer.
    @Published private(set) var endedEarly = false
    /// True when the last question ran out of time rather than being answered.
    @Published private(set) var timedOut = false

    private var timer: Timer?

    init(mode: ProMode, island: Island? = nil) {
        self.mode = mode
        self.island = island
        self.questions = ProQuestions.draw(for: mode, islandID: island?.id)
        resetClock()
    }

    // The clock is torn down from the view's onDisappear rather than deinit:
    // a nonisolated deinit cannot touch main-actor state.

    // MARK: - Derived state

    var currentQuestion: Question {
        // Guarded so a short or empty draw can never crash a round.
        guard questions.indices.contains(currentIndex) else {
            return Question(prompt: "—", options: ["—", "—", "—", "—"], correctIndex: 0)
        }
        return questions[currentIndex]
    }

    var totalQuestions: Int { questions.count }
    var isLastQuestion: Bool { currentIndex >= totalQuestions - 1 }
    var isTimed: Bool { mode.secondsPerQuestion != nil }

    var progress: Double {
        guard totalQuestions > 0 else { return 0 }
        return Double(currentIndex) / Double(totalQuestions)
    }

    /// How many questions were actually faced (a Perfect Run can stop early).
    var questionsFaced: Int { results.count }

    var isPerfect: Bool {
        score == totalQuestions && totalQuestions > 0
    }

    /// The jewels for finishing everything correctly, added at the end.
    var completionBonus: Int { isPerfect ? mode.completionBonus : 0 }

    var totalJewels: Int { jewelsEarned + completionBonus }

    /// What the next correct answer is currently worth.
    var nextAnswerValue: Int {
        guard mode.hasStreakBonus else { return mode.jewelsPerCorrect }
        return mode.jewelsPerCorrect * ProMode.streakMultiplier(forStreak: streak + 1)
    }

    /// The live streak multiplier, for the badge on screen.
    var streakMultiplier: Int {
        guard mode.hasStreakBonus else { return 1 }
        return ProMode.streakMultiplier(forStreak: streak)
    }

    // MARK: - Playing

    func select(_ index: Int) {
        guard !hasAnswered, !isFinished else { return }
        stopClock()

        selectedOption = index
        hasAnswered = true

        let correct = currentQuestion.isCorrect(index)
        record(correct: correct)

        if correct {
            Sound.correct()
        } else {
            Sound.wrong()
            if mode.endsOnWrongAnswer {
                // Perfect Run is over the moment an answer is wrong. The
                // explanation still shows first, so there is something to
                // learn from the slip.
                endedEarly = true
            }
        }
    }

    /// Called when the clock reaches zero — counts as a missed question.
    private func handleTimeout() {
        guard !hasAnswered, !isFinished else { return }
        stopClock()
        timedOut = true
        selectedOption = nil
        hasAnswered = true
        record(correct: false)
        Sound.wrong()
        if mode.endsOnWrongAnswer { endedEarly = true }
    }

    private func record(correct: Bool) {
        results.append(correct)
        if correct {
            score += 1
            streak += 1
            bestStreak = max(bestStreak, streak)
            jewelsEarned += nextAnswerValueForJustScored()
        } else {
            streak = 0
        }
    }

    /// The streak has already been incremented by the time we pay out, so the
    /// multiplier is read at its new value.
    private func nextAnswerValueForJustScored() -> Int {
        guard mode.hasStreakBonus else { return mode.jewelsPerCorrect }
        return mode.jewelsPerCorrect * ProMode.streakMultiplier(forStreak: streak)
    }

    func next() {
        guard hasAnswered else { return }

        if endedEarly || isLastQuestion {
            finish()
            return
        }

        currentIndex += 1
        selectedOption = nil
        hasAnswered = false
        timedOut = false
        resetClock()
        startClock()
    }

    private func finish() {
        stopClock()
        isFinished = true
    }

    /// Quits the round early without banking anything.
    func abandon() { stopClock() }

    func restart() {
        stopClock()
        questions = ProQuestions.draw(for: mode, islandID: island?.id)
        currentIndex = 0
        score = 0
        selectedOption = nil
        hasAnswered = false
        isFinished = false
        results = []
        jewelsEarned = 0
        streak = 0
        bestStreak = 0
        endedEarly = false
        timedOut = false
        resetClock()
        startClock()
    }

    // MARK: - The clock

    /// Starts counting down. Call when the round's first question appears.
    func startClock() {
        guard let seconds = mode.secondsPerQuestion, !isFinished else { return }
        timer?.invalidate()
        timeRemaining = seconds
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.tick() }
        }
    }

    func stopClock() {
        timer?.invalidate()
        timer = nil
    }

    private func resetClock() {
        timeRemaining = mode.secondsPerQuestion ?? 0
    }

    private func tick() {
        guard !hasAnswered, !isFinished else { return }
        if timeRemaining > 0 { timeRemaining -= 1 }
        if timeRemaining == 0 { handleTimeout() }
    }
}
