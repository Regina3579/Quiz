//
//  QuizView.swift
//  QuizApp
//
//  Plays a single level's questions, themed in the island's colors.
//  A whole round fits on one screen: question, four answers, the fact and
//  the Next button. The last two hold their space from the start, so tapping
//  an answer shows the tick or cross without moving anything.
//

import SwiftUI

struct QuizView: View {
    @StateObject private var model: QuizViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var explanationExpanded = false
    @State private var celebrateTrigger = 0
    /// Live centre of the correct answer button (global coords).
    @State private var correctCenter: CGPoint = .zero
    /// Snapshot of where the burst should start, taken when answered.
    @State private var burstOrigin: CGPoint = .zero

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
            QuizBackground(island: model.island)

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

            // Gold stars bursting from the tapped answer when it's correct.
            CorrectBurst(trigger: celebrateTrigger, origin: burstOrigin)

            if explanationExpanded, let explanation = model.currentQuestion.explanation {
                ExplanationSheet(text: explanation,
                                 accent: model.island.palette.end) {
                    withAnimation(.easeInOut(duration: 0.2)) { explanationExpanded = false }
                }
            }
        }
        .animation(.easeInOut(duration: 0.2), value: explanationExpanded)
        .onPreferenceChange(CorrectButtonCenterKey.self) { correctCenter = $0 }
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

    /// Level name and progress bar.
    private static let topBarHeight: CGFloat = 46

    private var gameplay: some View {
        GeometryReader { geo in
            let layout = QuizScreenLayout(size: geo.size, topBarHeight: Self.topBarHeight)

            VStack(spacing: layout.gap) {
                topBar
                    .frame(height: Self.topBarHeight)

                questionBubble
                    .frame(width: layout.panelWidth, height: layout.panelHeight)

                options(spacing: layout.optionsSpacing)
                    .frame(width: layout.optionsWidth)

                explanationSlot
                    .frame(height: layout.explanationHeight)

                nextButton
                    .frame(height: layout.nextHeight)
            }
            .padding(.horizontal, 20)
            .frame(width: geo.size.width, height: geo.size.height)
            .animation(.spring(response: 0.5, dampingFraction: 0.85), value: model.currentIndex)
        }
        .onChange(of: model.hasAnswered) { answered in
            guard answered, model.selectedOption == model.currentQuestion.correctIndex else { return }
            burstOrigin = correctCenter
            celebrateTrigger += 1
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
        QuestionPanel(prompt: model.currentQuestion.prompt)
            .id(model.currentIndex)
            .transition(.asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .leading).combined(with: .opacity)
            ))
    }

    private func options(spacing: CGFloat) -> some View {
        VStack(spacing: spacing) {
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
                .background(
                    // Report the correct answer's centre so the star burst can
                    // erupt from the button the child tapped.
                    Group {
                        if pair.offset == model.currentQuestion.correctIndex {
                            GeometryReader { g in
                                Color.clear.preference(
                                    key: CorrectButtonCenterKey.self,
                                    value: CGPoint(x: g.frame(in: .global).midX,
                                                   y: g.frame(in: .global).midY))
                            }
                        }
                    }
                )
            }
        }
    }

    /// Keeps its height whether or not there is anything to show, so the
    /// answers never move under the child's finger.
    @ViewBuilder
    private var explanationSlot: some View {
        if model.hasAnswered, let explanation = model.currentQuestion.explanation {
            ExplanationCard(text: explanation,
                            accent: model.island.palette.end,
                            expand: { explanationExpanded = true })
                .transition(.opacity)
                .animation(.easeOut(duration: 0.25), value: model.hasAnswered)
        } else {
            Color.clear
        }
    }

    private var nextButton: some View {
        Button {
            Haptics.play(.light)
            explanationExpanded = false
            withAnimation { model.next() }
        } label: {
            HStack(spacing: 8) {
                Text(model.isLastQuestion ? "See My Stars!" : "Next")
                    .font(Theme.bold(18))
                Image(systemName: "arrow.right.circle.fill").font(.title2)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Theme.nextButton))
            .shadow(color: .black.opacity(0.2), radius: 8, y: 5)
        }
        .buttonStyle(PressableButtonStyle())
        .opacity(model.hasAnswered ? 1 : 0)
        .disabled(!model.hasAnswered)
        .animation(.easeOut(duration: 0.25), value: model.hasAnswered)
    }
}

// MARK: - Did you know?

/// The compact "Did you know?" strip. It shows as much of the fact as its
/// slot allows and offers the rest on a tap, rather than growing and pushing
/// the answers around.
struct ExplanationCard: View {
    let text: String
    let accent: Color
    /// Pro rounds swap the heading for "Time's up!" when the clock beat the
    /// child to it; the fact underneath stays either way.
    var icon: String = "💡"
    var title: String = "Did you know?"
    let expand: () -> Void

    var body: some View {
        Button(action: {
            Haptics.play(.light)
            expand()
        }) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 7) {
                    Text(icon).font(.system(size: 16))
                    Text(title)
                        .font(Theme.bold(15))
                        .foregroundColor(accent)
                    Spacer(minLength: 4)
                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                        .font(Theme.bold(11))
                        .foregroundColor(accent.opacity(0.7))
                }

                Text(text)
                    .font(Theme.medium(13))
                    .foregroundColor(Theme.ink)
                    .lineSpacing(1)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .bubbleCard(cornerRadius: 16, fill: Theme.didYouKnow)
        }
        .buttonStyle(PressableButtonStyle())
        .accessibilityLabel("Did you know? \(text)")
    }
}

/// The whole fact, on a card over the round. Used when the strip is tapped.
struct ExplanationSheet: View {
    let text: String
    let accent: Color
    let dismiss: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.45)
                .ignoresSafeArea()
                .onTapGesture(perform: dismiss)

            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Text("💡").font(.system(size: 24))
                    Text("Did you know?")
                        .font(Theme.bold(20))
                        .foregroundColor(accent)
                    Spacer()
                    Button(action: dismiss) {
                        Image(systemName: "xmark")
                            .font(Theme.bold(14))
                            .foregroundColor(Theme.ink)
                            .padding(8)
                            .background(Circle().fill(.black.opacity(0.08)))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Close")
                }

                Text(text)
                    .font(Theme.medium(17))
                    .foregroundColor(Theme.ink)
                    .lineSpacing(5)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(22)
            .bubbleCard(cornerRadius: 24, fill: Theme.didYouKnow)
            .padding(.horizontal, 24)
        }
        .transition(.opacity)
    }
}

/// Carries the correct answer button's centre (global coords) up to QuizView
/// so the celebration burst can start from there.
private struct CorrectButtonCenterKey: PreferenceKey {
    static var defaultValue: CGPoint = .zero
    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {
        let next = nextValue()
        if next != .zero { value = next }
    }
}

#Preview {
    NavigationStack {
        QuizView(route: LevelRoute(islandID: 2, levelNumber: 1))
            .environmentObject(GameProgress())
    }
}
