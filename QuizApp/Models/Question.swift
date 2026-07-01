//
//  Question.swift
//  QuizApp
//
//  A single quiz question with multiple answer options.
//

import Foundation

/// Represents one quiz question with its possible answers.
struct Question: Identifiable, Equatable {
    let id = UUID()

    /// The question prompt shown to the player.
    let prompt: String

    /// The list of answer options. Order is preserved as authored;
    /// shuffle at presentation time if randomization is desired.
    let options: [String]

    /// Index into `options` that holds the correct answer.
    let correctIndex: Int

    /// An optional explanation shown after the player answers.
    let explanation: String?

    init(prompt: String, options: [String], correctIndex: Int, explanation: String? = nil) {
        self.prompt = prompt
        self.explanation = explanation
        // Shuffle the options so the correct answer isn't always in the same
        // spot (kids can't guess by position, and replays stay fresh).
        let correct = options[correctIndex]
        let shuffled = options.shuffled()
        self.options = shuffled
        self.correctIndex = shuffled.firstIndex(of: correct) ?? correctIndex
    }

    /// The text of the correct answer.
    var correctAnswer: String {
        options[correctIndex]
    }

    /// Returns `true` when the supplied option index is the correct one.
    func isCorrect(_ index: Int) -> Bool {
        index == correctIndex
    }
}
