//
//  ProQuizView.swift
//  QuizApp
//
//  Plays one Pro Challenge round: the clock in the corner for timed modes,
//  a live streak badge for Gems Rush, and a warning banner when a single
//  wrong answer is about to end everything.
//

import SwiftUI
import UIKit

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

            if showQuitAlert {
                LeaveChallengeDialog(
                    onKeepPlaying: {
                        showQuitAlert = false
                        model.startClock()
                    },
                    onLeave: { dismiss() })
                    .transition(.opacity)
                    .zIndex(4)
            }
        }
        .animation(.easeInOut(duration: 0.22), value: showQuitAlert)
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
            label = "See My Gems!"
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
        ProQuizView(route: ProRoute(mode: .gemRush))
            .environmentObject(GameProgress())
    }
}

// MARK: - Leaving a challenge

/// The "Leave Challenge?" card, in place of the system alert.
///
/// A grey system alert in the middle of a bright challenge reads as the app
/// breaking rather than the game asking a question. This is the same card the
/// rest of the game is drawn in: the sad star over its cloud, and the two
/// choices plainly different from each other.
///
/// The whole card is one painted picture, wording included, because none of
/// that wording changes — the two buttons are tap targets laid exactly over
/// the painted pills, with a press that lights the pill. Changing any of the
/// words means repainting the picture.
struct LeaveChallengeDialog: View {
    let onKeepPlaying: () -> Void
    let onLeave: () -> Void

    static let art = "LeaveDialog"

    /// 908 x 526, the size the artwork was cut to.
    private static let aspect: CGFloat = 1.7262
    private static let keepAt  = CGRect(x: 0.134, y: 0.665, width: 0.430, height: 0.198)
    private static let leaveAt = CGRect(x: 0.575, y: 0.673, width: 0.306, height: 0.183)

    private static var hasArt: Bool { UIImage(named: art) != nil }

    @State private var appeared = false

    var body: some View {
        ZStack {
            // Barely a dim — the artwork carries its own glow and the mockup
            // shows the challenge still bright behind it. Its real job is to
            // swallow taps, so an answer cannot be chosen through the card.
            Color.black.opacity(0.22)
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture(perform: onKeepPlaying)

            Group {
                if Self.hasArt { painted } else { drawn }
            }
            .scaleEffect(appeared ? 1 : 0.86)
            .opacity(appeared ? 1 : 0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.38, dampingFraction: 0.72)) {
                appeared = true
            }
        }
    }

    private var painted: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = w / Self.aspect

            Image(Self.art)
                .resizable()
                .scaledToFit()
                .frame(width: w, height: h)
                .overlay(alignment: .topLeading) {
                    ZStack(alignment: .topLeading) {
                        target(Self.keepAt,  w, h, action: onKeepPlaying)
                        target(Self.leaveAt, w, h, action: onLeave)
                    }
                }
        }
        .aspectRatio(Self.aspect, contentMode: .fit)
        // The artwork is 908 pixels wide; past this it would only soften.
        .frame(maxWidth: 620)
        .padding(.horizontal, 10)
    }

    /// A tap target sitting exactly on one of the painted pills.
    private func target(_ r: CGRect, _ w: CGFloat, _ h: CGFloat,
                        action: @escaping () -> Void) -> some View {
        Button(action: action) { Color.clear }
            .buttonStyle(PillPressStyle(inset: h * 0.018))
            .frame(width: r.width * w, height: r.height * h)
            .position(x: r.midX * w, y: r.midY * h)
    }

    /// If the picture is ever missing from the bundle.
    private var drawn: some View {
        VStack(spacing: 14) {
            Text("Leave Challenge?")
                .font(Theme.display(26))
                .foregroundColor(Color(red: 0.36, green: 0.16, blue: 0.62))
            Text("If you leave now, the gems from this round won't be saved.")
                .font(Theme.medium(15))
                .foregroundColor(Theme.ink)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 12) {
                Button(action: onKeepPlaying) {
                    Text("Keep Playing")
                        .font(Theme.bold(16))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                        .background(Capsule().fill(Color(red: 0.55, green: 0.15, blue: 0.80)))
                }
                .buttonStyle(PressableButtonStyle())

                Button(action: onLeave) {
                    Text("Leave")
                        .font(Theme.bold(16))
                        .foregroundColor(Theme.incorrect)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                        .background(Capsule().fill(Color(red: 1.00, green: 0.93, blue: 0.94)))
                        .overlay(Capsule().strokeBorder(Theme.incorrect.opacity(0.6), lineWidth: 2))
                }
                .buttonStyle(PressableButtonStyle())
            }
        }
        .padding(22)
        .background(RoundedRectangle(cornerRadius: 28, style: .continuous)
            .fill(Color(red: 1.00, green: 0.98, blue: 0.93)))
        .padding(.horizontal, 26)
        .shadow(color: .black.opacity(0.4), radius: 18, y: 8)
    }
}
