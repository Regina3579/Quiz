//
//  QuizData.swift
//  QuizApp
//
//  Bundled sample content. In a production app this could be replaced by a
//  network service or a local database without touching the views.
//

import SwiftUI

/// Provides the built-in quizzes shipped with the app.
enum QuizData {

    static let all: [Quiz] = [
        scienceQuiz,
        geographyQuiz,
        historyQuiz,
        techQuiz
    ]

    // MARK: - Science

    static let scienceQuiz = Quiz(
        title: "Science & Nature",
        subtitle: "Atoms, animals & the cosmos",
        symbol: "atom",
        palette: .init(
            start: Color(red: 0.30, green: 0.78, blue: 0.95),
            end: Color(red: 0.36, green: 0.45, blue: 0.95)
        ),
        questions: [
            Question(
                prompt: "What planet is known as the Red Planet?",
                options: ["Venus", "Mars", "Jupiter", "Saturn"],
                correctIndex: 1,
                explanation: "Mars looks red because of iron oxide (rust) on its surface."
            ),
            Question(
                prompt: "What gas do plants primarily absorb for photosynthesis?",
                options: ["Oxygen", "Nitrogen", "Carbon dioxide", "Hydrogen"],
                correctIndex: 2,
                explanation: "Plants take in CO₂ and release oxygen during photosynthesis."
            ),
            Question(
                prompt: "How many bones are in the adult human body?",
                options: ["206", "180", "230", "150"],
                correctIndex: 0,
                explanation: "Adults have 206 bones; babies are born with around 270."
            ),
            Question(
                prompt: "What is the chemical symbol for gold?",
                options: ["Go", "Gd", "Au", "Ag"],
                correctIndex: 2,
                explanation: "Au comes from the Latin word for gold, 'aurum'."
            ),
            Question(
                prompt: "What is the speed of light in a vacuum (approx.)?",
                options: ["300,000 km/s", "150,000 km/s", "1,080 km/h", "30,000 km/s"],
                correctIndex: 0,
                explanation: "Light travels about 299,792 km per second."
            )
        ]
    )

    // MARK: - Geography

    static let geographyQuiz = Quiz(
        title: "World Geography",
        subtitle: "Capitals, rivers & continents",
        symbol: "globe.europe.africa.fill",
        palette: .init(
            start: Color(red: 0.20, green: 0.82, blue: 0.60),
            end: Color(red: 0.12, green: 0.55, blue: 0.46)
        ),
        questions: [
            Question(
                prompt: "What is the capital of Australia?",
                options: ["Sydney", "Melbourne", "Canberra", "Perth"],
                correctIndex: 2,
                explanation: "Canberra was purpose-built as the capital in 1913."
            ),
            Question(
                prompt: "Which is the longest river in the world?",
                options: ["Amazon", "Nile", "Yangtze", "Mississippi"],
                correctIndex: 1,
                explanation: "The Nile stretches roughly 6,650 km through Africa."
            ),
            Question(
                prompt: "Mount Everest lies on the border of Nepal and which country?",
                options: ["India", "Bhutan", "China", "Pakistan"],
                correctIndex: 2,
                explanation: "Everest sits on the Nepal–China (Tibet) border."
            ),
            Question(
                prompt: "How many continents are there on Earth?",
                options: ["5", "6", "7", "8"],
                correctIndex: 2,
                explanation: "Asia, Africa, North & South America, Antarctica, Europe, Australia."
            ),
            Question(
                prompt: "Which country has the most natural lakes?",
                options: ["USA", "Russia", "Canada", "Finland"],
                correctIndex: 2,
                explanation: "Canada holds more than half of the world's natural lakes."
            )
        ]
    )

    // MARK: - History

    static let historyQuiz = Quiz(
        title: "World History",
        subtitle: "Empires, events & icons",
        symbol: "building.columns.fill",
        palette: .init(
            start: Color(red: 0.98, green: 0.70, blue: 0.35),
            end: Color(red: 0.93, green: 0.42, blue: 0.30)
        ),
        questions: [
            Question(
                prompt: "In which year did World War II end?",
                options: ["1943", "1945", "1947", "1950"],
                correctIndex: 1,
                explanation: "WWII ended in 1945 with the surrender of Japan in September."
            ),
            Question(
                prompt: "Who was the first President of the United States?",
                options: ["Thomas Jefferson", "John Adams", "George Washington", "Abraham Lincoln"],
                correctIndex: 2,
                explanation: "George Washington served from 1789 to 1797."
            ),
            Question(
                prompt: "The Great Wall is located in which country?",
                options: ["Japan", "China", "Mongolia", "India"],
                correctIndex: 1,
                explanation: "The Great Wall of China spans thousands of kilometers."
            ),
            Question(
                prompt: "Which ancient civilization built the pyramids of Giza?",
                options: ["Romans", "Greeks", "Egyptians", "Persians"],
                correctIndex: 2,
                explanation: "The pyramids were built by the ancient Egyptians around 2560 BC."
            ),
            Question(
                prompt: "Who painted the Mona Lisa?",
                options: ["Michelangelo", "Leonardo da Vinci", "Raphael", "Donatello"],
                correctIndex: 1,
                explanation: "Leonardo da Vinci painted it in the early 16th century."
            )
        ]
    )

    // MARK: - Technology

    static let techQuiz = Quiz(
        title: "Tech & Code",
        subtitle: "Apps, languages & gadgets",
        symbol: "laptopcomputer",
        palette: .init(
            start: Color(red: 0.65, green: 0.45, blue: 0.98),
            end: Color(red: 0.90, green: 0.35, blue: 0.70)
        ),
        questions: [
            Question(
                prompt: "Which language is primarily used to build native iOS apps today?",
                options: ["Java", "Swift", "Kotlin", "Ruby"],
                correctIndex: 1,
                explanation: "Swift, introduced by Apple in 2014, is the modern choice."
            ),
            Question(
                prompt: "What does 'HTTP' stand for?",
                options: [
                    "HyperText Transfer Protocol",
                    "High Transfer Text Protocol",
                    "HyperText Transmission Process",
                    "Home Tool Transfer Protocol"
                ],
                correctIndex: 0,
                explanation: "HTTP is the foundation of data communication on the web."
            ),
            Question(
                prompt: "Who is widely credited as a co-founder of Apple?",
                options: ["Bill Gates", "Steve Wozniak", "Elon Musk", "Jeff Bezos"],
                correctIndex: 1,
                explanation: "Steve Wozniak co-founded Apple with Steve Jobs in 1976."
            ),
            Question(
                prompt: "What does 'CPU' stand for?",
                options: [
                    "Central Process Unit",
                    "Computer Personal Unit",
                    "Central Processing Unit",
                    "Core Processing Utility"
                ],
                correctIndex: 2,
                explanation: "The CPU is often called the 'brain' of the computer."
            ),
            Question(
                prompt: "Which framework does this app use for its UI?",
                options: ["UIKit", "AppKit", "SwiftUI", "Flutter"],
                correctIndex: 2,
                explanation: "SwiftUI is Apple's declarative UI framework."
            )
        ]
    )
}
