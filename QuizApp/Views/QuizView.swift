//
//  QuizView.swift
//  QuizApp
//
//  The active gameplay screen: question, options, timer and progress.
//

import SwiftUI

struct QuizView: View {
    @StateObject private var model: QuizViewModel
    @Environment(\.dismiss) private var dismiss

    init(quiz: Quiz) {
        _model = StateObject(wrappedValue: QuizViewModel(quiz: quiz))
    }

    var body: some View {
        ZStack {
            Theme.backgroundGradient
                .ignoresSafeArea()

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
                            .font(.headline)
                            .foregroundStyle(Theme.textPrimary)
                    }
                }
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.85), value: model.isFinished)
    }

    private var gameplay: some View {
        VStack(spacing: 20) {
            // Top bar: progress + timer
            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Question \(model.currentIndex + 1) of \(model.totalQuestions)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Theme.textSecondary)
                    ProgressBar(value: model.progress, gradient: model.quiz.palette.gradient)
                }
                TimerRing(
                    timeRemaining: model.timeRemaining,
                    total: QuizViewModel.secondsPerQuestion
                )
            }
            .padding(.top, 8)

            // Question card
            VStack(alignment: .leading, spacing: 12) {
                Image(systemName: model.quiz.symbol)
                    .font(.title2)
                    .foregroundStyle(model.quiz.palette.end)

                Text(model.currentQuestion.prompt)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(Theme.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(Theme.cardPadding)
            .glassCard()
            .id(model.currentIndex) // re-trigger transition each question
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

            // Explanation + Next
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
                    Image(systemName: "lightbulb.fill")
                        .foregroundStyle(.yellow)
                    Text(explanation)
                        .font(.subheadline)
                        .foregroundStyle(Theme.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(14)
                .glassCard(cornerRadius: 16)
            }

            Button {
                Haptics.play(.light)
                withAnimation { model.next() }
            } label: {
                HStack {
                    Text(model.isLastQuestion ? "See Results" : "Next Question")
                        .font(.headline)
                    Image(systemName: "arrow.right")
                        .font(.headline)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(model.quiz.palette.gradient)
                )
                .shadow(color: model.quiz.palette.end.opacity(0.5), radius: 12, y: 6)
            }
            .buttonStyle(PressableButtonStyle())
        }
    }
}

#Preview {
    NavigationStack {
        QuizView(quiz: QuizData.scienceQuiz)
    }
}
