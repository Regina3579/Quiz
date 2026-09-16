//
//  ProQuizView.swift
//  QuizApp
//
//  Plays one Pro Challenge round: the clock in the corner for timed modes,
//  a live streak badge for Jewel Rush, and a warning banner when a single
//  wrong answer is about to end everything.
//

import SwiftUI

struct ProQuizView: View {
    @StateObject private var model: ProQuizViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var explanationExpanded = false
    @State private var celebrateTrigger = 0
    @State private var correctCenter: CGPoint = .zero
    @State private var burstOrigin: CGPoint = .zero
    @State private var showQuitAlert = false

    private let mode: ProMode

    init(route: ProRoute) {
        let island = route.islandID.flatMap { QuizData.island(id: $0) }
        mode = route.mode
        _model = StateObject(wrappedValue: ProQuizViewModel(mode: route.mode, island: island))
    }

    var body: some View {
        ZStack {
            ProBackground()

            if model.isFinished {
                ProResultView(model: model) { dismiss() }
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .opacity))
            } else {
                gameplay.transition(.opacity)
            }

            CorrectBurst(trigger: celebrateTrigger, origin: burstOrigin)

            if explanationExpanded, let explanation = model.currentQuestion.explanation {
                ExplanationSheet(text: explanation, accent: mode.palette.end) {
                    withAnimation(.easeInOut(duration: 0.2)) { explanationExpanded = false }
                }
            }
        }
        .animation(.easeInOut(duration: 0.2), value: explanationExpanded)
        .onPreferenceChange(ProCorrectCenterKey.self) { correctCenter = $0 }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                if !model.isFinished { quitButton }
            }
        }
        .onAppear {
            model.startClock()
            Music.shared.play(Music.track(for: mode))
        }
        .onDisappear { model.abandon() }
        .alert("Leave the challenge?", isPresented: $showQuitAlert) {
            Button("Keep playing", role: .cancel) { model.startClock() }
            Button("Leave", role: .destructive) { dismiss() }
        } message: {
            Text("Your jewels from this round won't be saved.")
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.85), value: model.isFinished)
    }

    private var quitButton: some View {
        Button {
            Haptics.play(.light)
            model.stopClock()
            showQuitAlert = true
        } label: {
            Image(systemName: "xmark")
                .font(Theme.bold(16))
                .foregroundColor(.white)
                .padding(8)
                .background(Circle().fill(Color.white.opacity(0.25)))
        }
    }

    // MARK: - Gameplay

    /// Mode name, clock and progress bar — plus the one-life warning in the
    /// modes that have it.
    private var topBarHeight: CGFloat { mode.endsOnWrongAnswer ? 86 : 52 }

    private var gameplay: some View {
        GeometryReader { geo in
            let layout = QuizScreenLayout(size: geo.size, topBarHeight: topBarHeight)

            VStack(spacing: layout.gap) {
                topBar
                    .frame(height: topBarHeight)

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
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                HStack(spacing: 6) {
                    Text(mode.emoji)
                    Text(mode.title).font(Theme.bold(15))
                }
                .foregroundColor(.white)

                Spacer(minLength: 4)

                if mode.hasStreakBonus { streakBadge }

                Text("\(min(model.currentIndex + 1, model.totalQuestions))/\(model.totalQuestions)")
                    .font(Theme.bold(15))
                    .foregroundColor(.white)

                if model.isTimed {
                    TimerRing(timeRemaining: model.timeRemaining,
                              total: mode.secondsPerQuestion ?? 1)
                }
            }

            ProgressBar(value: model.progress)

            if mode.endsOnWrongAnswer { suddenDeathBanner }
        }
    }

    private var streakBadge: some View {
        HStack(spacing: 5) {
            Text("🔥").font(.system(size: 13))
            Text("\(model.streak)")
                .font(Theme.bold(14))
                .contentTransition(.numericText())
            if model.streakMultiplier > 1 {
                Text("×\(model.streakMultiplier)")
                    .font(Theme.bold(13))
                    .foregroundColor(Theme.star)
            }
        }
        .foregroundColor(.white)
        .padding(.horizontal, 9)
        .frame(height: 28)
        .background(Capsule().fill(.black.opacity(0.28)))
        .overlay(Capsule().stroke(.white.opacity(0.4), lineWidth: 1))
        .animation(.spring(response: 0.35, dampingFraction: 0.7), value: model.streak)
    }

    private var suddenDeathBanner: some View {
        HStack(spacing: 6) {
            Image(systemName: "heart.fill").font(.system(size: 11))
            Text("One life — a wrong answer ends the run")
                .font(Theme.bold(12))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 12)
        .padding(.vertical, 5)
        .background(Capsule().fill(Theme.incorrect.opacity(0.85)))
    }

    private var questionBubble: some View {
        QuestionPanel(prompt: model.currentQuestion.prompt)
            .id(model.currentIndex)
            .transition(.asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .leading).combined(with: .opacity)))
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
                .background(correctCenterReporter(for: pair.offset))
            }
        }
    }

    @ViewBuilder
    private func correctCenterReporter(for index: Int) -> some View {
        if index == model.currentQuestion.correctIndex {
            GeometryReader { g in
                Color.clear.preference(
                    key: ProCorrectCenterKey.self,
                    value: CGPoint(x: g.frame(in: .global).midX,
                                   y: g.frame(in: .global).midY))
            }
        }
    }

    /// Holds its height from the start so answering never shifts the pills.
    /// When the clock won, the heading says so and the fact still follows.
    @ViewBuilder
    private var explanationSlot: some View {
        if model.hasAnswered, let explanation = model.currentQuestion.explanation {
            ExplanationCard(text: explanation,
                            accent: model.timedOut ? Theme.incorrect : mode.palette.end,
                            icon: model.timedOut ? "⏰" : "💡",
                            title: model.timedOut ? "Time's up!" : "Did you know?",
                            expand: { explanationExpanded = true })
                .transition(.opacity)
                .animation(.easeOut(duration: 0.25), value: model.hasAnswered)
        } else {
            Color.clear
        }
    }

    private var nextButton: some View {
        let label: String
        if model.endedEarly {
            label = "See How You Did"
        } else if model.isLastQuestion {
            label = "See My Jewels!"
        } else {
            label = "Next"
        }

        return Button {
            Haptics.play(.light)
            explanationExpanded = false
            withAnimation { model.next() }
        } label: {
            HStack(spacing: 8) {
                Text(label).font(Theme.bold(18))
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

/// Carries the correct answer button's centre up so the star burst can start
/// from the button the child actually tapped.
private struct ProCorrectCenterKey: PreferenceKey {
    static var defaultValue: CGPoint = .zero
    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {
        let next = nextValue()
        if next != .zero { value = next }
    }
}

#Preview {
    NavigationStack {
        ProQuizView(route: ProRoute(mode: .jewelRush))
            .environmentObject(GameProgress())
    }
}
