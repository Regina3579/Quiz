# QuizSpark ✨

A beautiful, animated quiz app for iOS, built entirely in **SwiftUI**.

<p align="center">
  <em>Pick a category, beat the clock, and see how much you really know.</em>
</p>

## Features

- 🎨 **Polished, modern UI** — frosted-glass cards, vibrant per-category gradients and a deep space-themed background.
- 🧠 **Four quiz categories** — Science & Nature, World Geography, World History, and Tech & Code.
- ⏱️ **Per-question timer** — a color-shifting countdown ring keeps the pressure on (auto-locks at 0).
- ✅ **Instant feedback** — answers animate to green/red with a checkmark or cross, plus a short explanation.
- 📊 **Animated results screen** — a score ring fills up, a recap grid shows every question, and the headline adapts to your performance.
- 📳 **Haptic feedback** — success/error taps make every answer feel tactile.
- 🌀 **Springy animations & transitions** throughout, with staggered entrances.

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
│  └─ Quiz.swift             # A themed category of questions
├─ ViewModels/
│  └─ QuizViewModel.swift    # Game state machine (timer, score, flow)
├─ Views/
│  ├─ HomeView.swift         # Category list / landing screen
│  ├─ QuizView.swift         # Active gameplay screen
│  ├─ ResultView.swift       # End-of-quiz summary
│  └─ Components/            # Reusable building blocks
│     ├─ AnswerButton.swift
│     ├─ CategoryCard.swift
│     ├─ ProgressBar.swift
│     └─ TimerRing.swift
├─ Data/
│  └─ QuizData.swift         # Bundled sample questions
├─ Theme/
│  ├─ Theme.swift            # Colors, gradients, glass-card styling
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
    title: "Movies",
    subtitle: "Lights, camera, action",
    symbol: "film.fill",                // any SF Symbol
    palette: .init(start: .pink, end: .purple),
    questions: [
        Question(
            prompt: "Who directed Inception?",
            options: ["Spielberg", "Nolan", "Cameron", "Scorsese"],
            correctIndex: 1,
            explanation: "Christopher Nolan directed Inception (2010)."
        )
        // ...more questions
    ]
)
```

No view changes are needed — the new category card and its themed gradient
appear automatically.
