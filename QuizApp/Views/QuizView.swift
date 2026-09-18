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
    @EnvironmentObject private var progress: GameProgress
    @Environment(\.dismiss) private var dismiss
    @State private var explanationExpanded = false
    @State private var celebrateTrigger = 0
    /// Live centre of the correct answer button (global coords).
    @State private var correctCenter: CGPoint = .zero
    /// Snapshot of where the burst should start, taken when answered.
    @State private var burstOrigin: CGPoint = .zero
    @State private var showHintPrompt = false
    @State private var showBrokeNotice = false

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
        // Asked before the gems go, not after. A child should never find out
        // what a tap cost them by watching the number drop.
        .alert(model.hintsUsed > 0 ? "Need More Help? \u{2728}"
                                   : "Need a Little Help? \u{1F4A1}",
               isPresented: $showHintPrompt) {
            Button("Use \(nextHintCost) Gems") { buyHint() }
            Button("Not Now", role: .cancel) { }
        } message: {
            Text(model.hintsUsed > 0
                 ? "Use \(nextHintCost) Gems \u{1F48E} for a stronger clue. It will "
                   + "cross out another wrong answer, leaving just two."
                 : "Use \(nextHintCost) Gems \u{1F48E} to unlock a hint for this question. "
                   + "It will cross out one wrong answer.")
        }
        .alert("Not enough Gems yet", isPresented: $showBrokeNotice) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("This hint costs \(nextHintCost) Gems, and you have "
                 + "\(progress.gems). Keep playing — every right answer earns more!")
        }
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
        // The same tune as the map, played on this island's instruments.
        .onAppear { Music.shared.play(Music.track(forIsland: model.island.id)) }
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
                    correctIndex: model.currentQuestion.correctIndex,
                    eliminated: model.eliminated.contains(pair.offset)
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
        } else if !model.hasAnswered {
            // This strip is empty until an answer is given, so the hint lives
            // here rather than costing the screen a row of its own. The quiz
            // fits one screen exactly, and it has to keep fitting.
            hintRow
        } else {
            Color.clear
        }
    }

    /// The price of the hint the button is currently offering.
    private var nextHintCost: Int { GemRules.hintCost(after: model.hintsUsed) }

    /// Takes the gems first and only strikes an answer if that succeeded, so a
    /// child who cannot afford it never sees a hint they did not pay for.
    private func buyHint() {
        guard progress.spendOnHint(cost: nextHintCost) else {
            Haptics.play(.error)
            showBrokeNotice = true
            return
        }
        Haptics.play(.success)
        Sound.play("stickerpop")
        withAnimation(.easeOut(duration: 0.3)) { model.revealHint() }
    }

    /// One thing at a time in a 56pt strip: the offer, or, once there is
    /// nothing left to offer, what the hints did. The crossed-out answers are
    /// already on screen, so the strip does not have to report them as well.
    @ViewBuilder
    private var hintRow: some View {
        if model.canBuyHint {
            hintButton
        } else if model.hintsUsed > 0 {
            hintDone
        } else {
            Color.clear
        }
    }

    private var hintButton: some View {
        let second = model.hintsUsed > 0

        return Button {
            Haptics.play(.light)
            showHintPrompt = true
        } label: {
            HStack(spacing: 6) {
                Text(second ? "\u{2728}" : "\u{1F4A1}").font(.system(size: 15))
                Text(second ? "Need more help? Hint 2" : "Get Hint")
                    .font(Theme.bold(15))
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                GemIcon(size: 15)
                Text("\(nextHintCost)").font(Theme.bold(15))
            }
            .foregroundColor(Theme.ink)
            .padding(.horizontal, 18)
            // A set height, centred in the strip. Filling it would make a
            // 56pt lozenge out of a four-word button.
            .frame(height: 40)
            .background(Capsule().fill(Theme.didYouKnow))
            .overlay(Capsule().stroke(Theme.star, lineWidth: 2))
        }
        .buttonStyle(PressableButtonStyle())
        .frame(maxWidth: .infinity)
        .transition(.opacity)
    }

    private var hintDone: some View {
        HStack(spacing: 7) {
            Text("\u{1F31F}").font(.system(size: 16))
            VStack(alignment: .leading, spacing: 1) {
                Text("Hint Unlocked!")
                    .font(Theme.bold(14))
                    .foregroundColor(Theme.ink)
                Text("It is down to two answers now — you can do this!")
                    .font(Theme.medium(12))
                    .foregroundColor(Theme.inkSoft)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 13)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(Theme.didYouKnow))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous)
            .stroke(Theme.star.opacity(0.7), lineWidth: 2))
        .transition(.opacity)
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

/// The "Did you know?" strip: the heading, a one-line taste of the fact, and
/// a "Read it" nudge. Keeping it to one line leaves the question and the
/// answers properly big; the whole fact opens on a card over the round rather
/// than growing in place and pushing the answers around.
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
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(icon).font(.system(size: 14))
                    Text(title)
                        .font(Theme.bold(14))
                        .foregroundColor(accent)
                        .lineLimit(1)
                    Spacer(minLength: 4)
                    Text("Read it")
                        .font(Theme.bold(11))
                        .foregroundColor(accent.opacity(0.85))
                    Image(systemName: "chevron.right")
                        .font(Theme.bold(9))
                        .foregroundColor(accent.opacity(0.85))
                }

                Text(text)
                    .font(Theme.medium(12.5))
                    .foregroundColor(Theme.ink)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
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
