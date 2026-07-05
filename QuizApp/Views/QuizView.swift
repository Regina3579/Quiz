//
//  QuizView.swift
//  QuizApp
//
//  Plays a single level's questions, themed in the island's colors.
//  The question, options and a rich explanation scroll so nothing is cut off.
//

import SwiftUI

struct QuizView: View {
    @StateObject private var model: QuizViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var explanationExpanded = false

    private let valid: Bool

    init(route: LevelRoute) {
        if let island = QuizData.island(id: route.islandID),
           let level = island.level(route.levelNumber) {
            _model = StateObject(wrappedValue: QuizViewModel(island: island, level: level))
            valid = true
        } else {
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

    // MARK: - Gameplay

    private var gameplay: some View {
        VStack(spacing: 0) {
            topBar
                .padding(.horizontal, 20)
                .padding(.top, 6)
                .padding(.bottom, 10)

            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        Color.clear.frame(height: 1).id("top")

                        questionBubble

                        options

                        if model.hasAnswered {
                            explanationAndNext
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                        }

                        Color.clear.frame(height: 1).id("bottom")
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
                    .animation(.spring(response: 0.4, dampingFraction: 0.85), value: model.hasAnswered)
                    .animation(.spring(response: 0.5, dampingFraction: 0.85), value: model.currentIndex)
                }
                .onChange(of: model.hasAnswered) { answered in
                    if answered {
                        withAnimation(.easeOut(duration: 0.45)) {
                            proxy.scrollTo("bottom", anchor: .bottom)
                        }
                    }
                }
                .onChange(of: model.currentIndex) { _ in
                    withAnimation { proxy.scrollTo("top", anchor: .top) }
                }
            }
        }
    }

    private var topBar: some View {
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
    }

    private var questionBubble: some View {
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
    }

    private var options: some View {
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
    }

    private var explanationAndNext: some View {
        VStack(spacing: 14) {
            if let explanation = model.currentQuestion.explanation {
                VStack(alignment: .leading, spacing: 8) {
                    Button {
                        Haptics.play(.light)
                        withAnimation(.easeInOut(duration: 0.25)) {
                            explanationExpanded.toggle()
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Text("💡").font(.system(size: 20))
                            Text("Did you know?")
                                .font(Theme.bold(16))
                                .foregroundColor(model.island.palette.end)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .font(Theme.bold(14))
                                .foregroundColor(model.island.palette.end)
                                .rotationEffect(.degrees(explanationExpanded ? 180 : 0))
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)

                    if explanationExpanded {
                        Text(explanation)
                            .font(Theme.medium(15))
                            .foregroundColor(Theme.ink)
                            .lineSpacing(4)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .fixedSize(horizontal: false, vertical: true)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
                .padding(18)
                .bubbleCard(cornerRadius: 18)
            }

            Button {
                Haptics.play(.light)
                explanationExpanded = false
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
        QuizView(route: LevelRoute(islandID: 2, levelNumber: 1))
            .environmentObject(GameProgress())
    }
}
