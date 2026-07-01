//
//  QuizView.swift
//  QuizApp
//
//  Plays a single level's questions, themed in the island's colors.
//

import SwiftUI

struct QuizView: View {
    @StateObject private var model: QuizViewModel
    @Environment(\.dismiss) private var dismiss

    private let valid: Bool

    init(route: LevelRoute) {
        if let island = QuizData.island(id: route.islandID),
           let level = island.level(route.levelNumber) {
            _model = StateObject(wrappedValue: QuizViewModel(island: island, level: level))
            valid = true
        } else {
            // Fallback so the initializer always has a value.
            let island = QuizData.jungleKingdom
            _model = StateObject(wrappedValue: QuizViewModel(island: island,
                                                             level: island.levels[0]))
            valid = false
        }
    }

    var body: some View {
        ZStack {
            model.island.palette.gradient.ignoresSafeArea()

            if model.isFinished {
                ResultView(model: model) { dismiss() }
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .opacity
                    ))
            } else {
                gameplay
                    .transition(.opacity)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                if !model.isFinished {
                    Button {
                        Haptics.play(.light)
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(Theme.bold(16))
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Circle().fill(Color.white.opacity(0.25)))
                    }
                }
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.85), value: model.isFinished)
    }

    private var gameplay: some View {
        VStack(spacing: 18) {
            // Top: level title + progress
            VStack(spacing: 12) {
                HStack {
                    HStack(spacing: 6) {
                        Text(model.island.emoji)
                        Text("Level \(model.level.number)")
                            .font(Theme.bold(16))
                    }
                    .foregroundColor(.white)
                    Spacer()
                    Text("\(model.currentIndex + 1)/\(model.totalQuestions)")
                        .font(Theme.bold(15))
                        .foregroundColor(.white)
                }
                ProgressBar(value: model.progress)
            }
            .padding(.top, 4)

            // Question bubble
            VStack(spacing: 14) {
                Text(model.island.emoji).font(.system(size: 42))
                Text(model.currentQuestion.prompt)
                    .font(Theme.bold(22))
                    .foregroundColor(Theme.ink)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity)
            .padding(22)
            .bubbleCard()
            .id(model.currentIndex)
            .transition(.asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .leading).combined(with: .opacity)
            ))

            // Options
            VStack(spacing: 12) {
                ForEach(Array(model.currentQuestion.options.enumerated()), id: \.offset) { pair in
                    AnswerButton(
                        text: pair.element,
                        index: pair.offset,
                        hasAnswered: model.hasAnswered,
                        selectedOption: model.selectedOption,
                        correctIndex: model.currentQuestion.correctIndex
                    ) {
                        withAnimation { model.select(pair.offset) }
                    }
                }
            }

            if model.hasAnswered {
                explanationAndNext
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            Spacer(minLength: 0)
        }
        .padding(20)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: model.hasAnswered)
        .animation(.spring(response: 0.5, dampingFraction: 0.85), value: model.currentIndex)
    }

    private var explanationAndNext: some View {
        VStack(spacing: 14) {
            if let explanation = model.currentQuestion.explanation {
                HStack(alignment: .top, spacing: 10) {
                    Text("💡").font(.system(size: 20))
                    Text(explanation)
                        .font(Theme.medium(15))
                        .foregroundColor(Theme.ink)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(16)
                .bubbleCard(cornerRadius: 18, fill: Color.white.opacity(0.92))
            }

            Button {
                Haptics.play(.light)
                withAnimation { model.next() }
            } label: {
                HStack {
                    Text(model.isLastQuestion ? "See My Stars!" : "Next")
                        .font(Theme.bold(18))
                    Image(systemName: "arrow.right.circle.fill").font(.title2)
                }
                .foregroundColor(model.island.palette.end)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(RoundedRectangle(cornerRadius: 20, style: .continuous).fill(.white))
                .shadow(color: .black.opacity(0.15), radius: 8, y: 5)
            }
            .buttonStyle(PressableButtonStyle())
        }
    }
}

#Preview {
    NavigationStack {
        QuizView(route: LevelRoute(islandID: 0, levelNumber: 1))
            .environmentObject(GameProgress())
    }
}
