//
//  QuizViewModel.swift
//  QuizApp
//
//  Drives one play-through of a single level (about ten questions).
//  No timer — kids answer at their own pace so it stays fun and educational.
//

import SwiftUI

@MainActor
final class QuizViewModel: ObservableObject {

    let island: Island
    let level: Level

    @Published private(set) var currentIndex = 0
    @Published private(set) var score = 0
    @Published private(set) var selectedOption: Int?
    @Published private(set) var hasAnswered = false
    @Published private(set) var isFinished = false

    /// Answers struck out by a hint on the question showing now. Cleared on
    /// every move to the next question, so a hint is bought per question and
    /// never carries over.
    @Published private(set) var eliminated: Set<Int> = []

    /// Per-question record of correctness, used for the recap row.
    @Published private(set) var results: [Bool] = []

    init(island: Island, level: Level) {
        self.island = island
        self.level = level
    }

    // MARK: - Derived state

    var questions: [Question] { level.questions }
    var currentQuestion: Question { questions[currentIndex] }
    var totalQuestions: Int { questions.count }
    var isLastQuestion: Bool { currentIndex == totalQuestions - 1 }

    var progress: Double {
        guard totalQuestions > 0 else { return 0 }
        return Double(currentIndex) / Double(totalQuestions)
    }

    var scorePercent: Int {
        guard totalQuestions > 0 else { return 0 }
        return Int((Double(score) / Double(totalQuestions) * 100).rounded())
    }

    /// Stars earned for this attempt, 0…3.
    var starsEarned: Int {
        switch scorePercent {
        case 90...: return 3
        case 70...: return 2
        case 50...: return 1
        default: return 0
        }
    }

    // MARK: - Actions

    func select(_ index: Int) {
        guard !hasAnswered else { return }
        selectedOption = index
        hasAnswered = true

        let correct = currentQuestion.isCorrect(index)
        if correct { score += 1 }
        results.append(correct)

        // Cheery sound + vibration for correct, buzzer + vibration for wrong.
        if correct { Sound.correct() } else { Sound.wrong() }
    }

    /// How many hints have been bought for the question showing now, the
    /// written clue included. This is what the price ladder counts.
    var hintsUsed: Int { hintsTaken }

    /// How many hints this question can give up.
    ///
    /// Always two fewer than the number of answers, so the last hint leaves a
    /// choice rather than handing the answer over. Four answers means two
    /// hints; a question with only two answers offers none.
    var hintsPossible: Int { max(0, currentQuestion.options.count - 2) }

    /// The written clue showing now, once Hint 1 has been bought for a
    /// question that has one. Cleared with everything else on the next
    /// question.
    @Published private(set) var clue: String?

    /// Whether this question has a written clue waiting behind Hint 1.
    var hasClue: Bool { HintBook.hasClue(for: currentQuestion.prompt) }

    /// Hints already taken, counting the clue as one of them.
    var hintsTaken: Int { eliminated.count + (clue == nil ? 0 : 1) }

    /// How many hints this question will sell, never more than two.
    ///
    /// The cap matters. Without it, adding a written clue quietly gave a
    /// question a third hint — clue, cross out, cross out — priced 10, 20 and
    /// 20, because the ladder only has two rungs and repeats the last. Two
    /// hints were asked for and two is what there are: a clue then a crossing
    /// out where a clue exists, two crossings out where one does not.
    var hintsForSale: Int {
        min(GemRules.hintCosts.count, hintsPossible + (hasClue ? 1 : 0))
    }

    /// Whether another hint can still be bought.
    var canBuyHint: Bool { !hasAnswered && hintsTaken < hintsForSale }

    /// Strikes out one more wrong answer.
    ///
    /// The right answer is filtered out before anything is picked, so no
    /// shuffle can ever strike it. Call only after the gems have been taken.
    /// Gives the next hint: the written clue first when there is one, then a
    /// crossed-out answer. The clue comes first deliberately — it nudges
    /// without narrowing, which is what a first hint should do.
    func revealHint() {
        guard canBuyHint else { return }
        if hasClue, clue == nil {
            clue = HintBook.clue(for: currentQuestion.prompt)
            return
        }
        let wrong = currentQuestion.options.indices
            .filter { $0 != currentQuestion.correctIndex && !eliminated.contains($0) }
        if let struck = wrong.randomElement() { eliminated.insert(struck) }
    }

    /// Whether 50-50 Magic is worth offering.
    ///
    /// Only on an untouched question. Once a hint has been bought there is
    /// one strike left, which is exactly what the cheaper second hint does —
    /// offering the dearer bundle for the same result would be a trap.
    var canBuyFiftyFifty: Bool { !hasAnswered && hintsUsed == 0 && hintsPossible >= 2 }

    /// Strikes wrong answers until two choices remain.
    func revealFiftyFifty() {
        guard canBuyFiftyFifty else { return }
        let wrong = currentQuestion.options.indices
            .filter { $0 != currentQuestion.correctIndex }
        eliminated = Set(wrong.shuffled().prefix(hintsPossible))
    }

    func next() {
        guard hasAnswered else { return }
        if isLastQuestion {
            isFinished = true
            return
        }
        currentIndex += 1
        selectedOption = nil
        hasAnswered = false
        eliminated = []
        clue = nil
    }

    func restart() {
        currentIndex = 0
        score = 0
        selectedOption = nil
        hasAnswered = false
        isFinished = false
        results = []
        eliminated = []
        clue = nil
    }
}
