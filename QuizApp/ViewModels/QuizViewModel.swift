//
//  QuizViewModel.swift
//  QuizApp
//
//  Owns the state machine for a single play-through of a quiz.
//

import SwiftUI

/// Drives one game session: tracks the current question, the score,
/// selection state and the timer. Views observe this object and stay dumb.
@MainActor
final class QuizViewModel: ObservableObject {

    /// Seconds allowed per question before it auto-locks.
    /// Generous so young kids never feel rushed.
    static let secondsPerQuestion = 30

    let quiz: Quiz

    @Published private(set) var currentIndex = 0
    @Published private(set) var score = 0
    @Published private(set) var selectedOption: Int?
    @Published private(set) var hasAnswered = false
    @Published private(set) var isFinished = false
    @Published private(set) var timeRemaining = secondsPerQuestion

    /// Per-question record of whether the player got it right (for the recap).
    @Published private(set) var results: [Bool] = []

    private var timer: Timer?

    init(quiz: Quiz) {
        self.quiz = quiz
        startTimer()
    }

    // MARK: - Derived state

    var questions: [Question] { quiz.questions }
    var currentQuestion: Question { questions[currentIndex] }
    var totalQuestions: Int { questions.count }
    var isLastQuestion: Bool { currentIndex == totalQuestions - 1 }

    /// Progress from 0…1 for the progress bar.
    var progress: Double {
        guard totalQuestions > 0 else { return 0 }
        return Double(currentIndex) / Double(totalQuestions)
    }

    /// Percentage score 0…100.
    var scorePercent: Int {
        guard totalQuestions > 0 else { return 0 }
        return Int((Double(score) / Double(totalQuestions) * 100).rounded())
    }

    // MARK: - Actions

    /// Records the player's selection and reveals correctness.
    func select(_ index: Int) {
        guard !hasAnswered else { return }
        stopTimer()
        selectedOption = index
        hasAnswered = true

        let correct = currentQuestion.isCorrect(index)
        if correct { score += 1 }
        results.append(correct)

        Haptics.play(correct ? .success : .error)
    }

    /// Advances to the next question, or finishes the quiz.
    func next() {
        guard hasAnswered else { return }

        if isLastQuestion {
            finish()
            return
        }

        currentIndex += 1
        selectedOption = nil
        hasAnswered = false
        timeRemaining = Self.secondsPerQuestion
        startTimer()
    }

    /// Resets everything for another attempt of the same quiz.
    func restart() {
        currentIndex = 0
        score = 0
        selectedOption = nil
        hasAnswered = false
        isFinished = false
        results = []
        timeRemaining = Self.secondsPerQuestion
        startTimer()
    }

    // MARK: - Timer

    private func startTimer() {
        stopTimer()
        timeRemaining = Self.secondsPerQuestion
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.tick() }
        }
    }

    private func tick() {
        guard !hasAnswered else { return }
        if timeRemaining > 0 {
            timeRemaining -= 1
        }
        if timeRemaining == 0 {
            // Time's up: lock the question as unanswered/incorrect.
            timeOut()
        }
    }

    private func timeOut() {
        stopTimer()
        hasAnswered = true
        selectedOption = nil
        results.append(false)
        Haptics.play(.error)
    }

    private func finish() {
        stopTimer()
        isFinished = true
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    deinit {
        timer?.invalidate()
    }
}
