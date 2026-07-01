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

        Haptics.play(correct ? .success : .error)
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
    }

    func restart() {
        currentIndex = 0
        score = 0
        selectedOption = nil
        hasAnswered = false
        isFinished = false
        results = []
    }
}
