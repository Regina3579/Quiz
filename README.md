# QuizSpark ✨ — A Fun Quiz Adventure for Kids

A bright, cute and playful quiz app for kids, built entirely in **SwiftUI**.

<p align="center">
  <em>Pick a fun adventure, answer cheerful questions, and earn shiny stars!</em>
</p>

## Features

- 🎨 **Kid-friendly design** — candy-colored backgrounds, big emoji mascots, rounded bubbly typography and bouncy springy animations.
- 🗺️ **Eight playful adventures** — 🌍 Explore the World, 🚀 Journey to Space, 🦁 Wild Kingdom, 🦕 Dino Adventure, 🔬 Science Lab, ⏰ Time Machine, 🧠 Brain Challenge and ⭐ Daily Challenge.
- ⭐ **Star rewards** — kids earn up to 3 stars per quiz, revealed with a fun pop animation.
- 🎉 **Confetti celebration** — a shower of emoji confetti rains down for great scores.
- ✅ **Gentle, encouraging feedback** — answers turn green/red with friendly explanations and cheerful messages ("Superstar!", "Great Job!").
- ⏱️ **Relaxed timer** — a soft 30-second ring so little ones never feel rushed.
- 📳 **Haptic feedback** and a colorful, immersive per-category theme throughout.

## Requirements

- Xcode 16 or later
- iOS 17.0+
- Swift 5

## Getting Started

1. Open `QuizApp.xcodeproj` in Xcode.
2. Select an iOS Simulator (e.g. iPhone 15 Pro) or your device.
3. Press **⌘R** to build and run.

## Project Structure

```
QuizApp/
├─ QuizAppApp.swift          # App entry point
├─ Models/
│  ├─ Question.swift         # A single question + answers
│  └─ Quiz.swift             # A themed adventure (emoji, colors, questions)
├─ ViewModels/
│  └─ QuizViewModel.swift    # Game state machine (timer, score, flow)
├─ Views/
│  ├─ HomeView.swift         # Cheerful welcome + grid of adventures
│  ├─ QuizView.swift         # Colorful gameplay screen
│  ├─ ResultView.swift       # Star rewards + confetti celebration
│  └─ Components/            # Reusable building blocks
│     ├─ AnswerButton.swift
│     ├─ CategoryCard.swift
│     ├─ ConfettiView.swift
│     ├─ ProgressBar.swift
│     └─ TimerRing.swift
├─ Data/
│  └─ QuizData.swift         # The eight kid-friendly adventures
├─ Theme/
│  ├─ Theme.swift            # Bright colors, rounded fonts, bubble cards
│  └─ Haptics.swift          # Haptic feedback helper
└─ Assets.xcassets          # App icon & accent color
```

## Architecture

The app follows a lightweight **MVVM** pattern:

- **Models** are plain value types describing the content.
- **`QuizViewModel`** owns all gameplay state (current question, score, timer,
  selection) and exposes intent methods (`select`, `next`, `restart`). It is an
  `@MainActor ObservableObject`, so the views stay declarative and stateless.
- **Views** observe the view model and render. Reusable pieces live in
  `Views/Components`.

## Adding Your Own Questions

Everything is data-driven. To add a category, append a new `Quiz` to
`QuizData.all` in `Data/QuizData.swift`:

```swift
Quiz(
    title: "Under the Sea",
    subtitle: "Fish, waves & treasure",
    emoji: "🐠",                        // big cute mascot
    symbol: "water.waves",              // any SF Symbol
    palette: .init(start: .cyan, end: .blue),
    questions: [
        Question(
            prompt: "Which sea animal has eight arms?",
            options: ["Fish", "Octopus", "Crab", "Whale"],
            correctIndex: 1,
            explanation: "An octopus has eight wiggly arms!"
        )
        // ...more questions
    ]
)
```

No view changes are needed — the new category card and its themed gradient
appear automatically.
