//
//  CelebrationView.swift
//  QuizApp
//
//  The two moments in the adventure worth stopping everything for.
//
//  Finishing all ten levels of an island is the big one: the gold cup with the
//  crown on it comes down out of the light, the confetti falls, and the whole
//  screen belongs to that one adventure. Answering a level ten out of ten is
//  the smaller one, but it is still a cup — the silver one with the star —
//  because a child who has just got every question right should be cheered,
//  not handed a tick and moved along.
//
//  Everything here is decoration over a result screen that has already saved
//  itself. The overlay knows nothing about progress: it is handed a finished
//  `Celebration` and its only job is to be a party about it.
//

import SwiftUI

// MARK: - What is being celebrated

/// One cup-worthy moment, already decided by the time it gets here.
struct Celebration: Identifiable, Equatable {

    enum Kind: Equatable {
        /// All ten levels of an adventure cleared.
        case adventure
        /// A level answered without a single mistake.
        case perfectLevel
    }

    let kind: Kind
    /// The big gold lettering.
    let headline: String
    /// What was won or finished, in gold underneath.
    let subject: String
    /// One warm line telling the child what it means.
    let blurb: String
    /// The island's own badge, when there is one to show.
    var badge: String? = nil
    /// The colours the glow behind the cup is lit in.
    var glow: Color = ResultArt.gold

    var id: String { "\(kind)-\(subject)" }

    /// Which painted cup comes down. The crowned gold one is for an adventure
    /// finished; the star-faced silver one is for a perfect level.
    var cupArt: String {
        kind == .adventure ? "CupGold" : "CupSilver"
    }

    /// Shown if that picture ever goes missing from the bundle.
    var fallbackEmoji: String { kind == .adventure ? "🏆" : "🥈" }

    // MARK: - Deciding

    /// The celebration a just-finished level has earned, if any.
    ///
    /// Clearing the last level of an adventure wins its Explorer Cup, and that
    /// award turning up in what the round just unlocked is the same thing as
    /// "the adventure was finished right now" — so it can only ever happen
    /// once, however many times the level is replayed afterwards. A perfect
    /// level, by contrast, is cheered every single time.
    static func forLevel(island: Island,
                         level: Int,
                         correct: Int,
                         total: Int,
                         awards: [Achievement]) -> Celebration? {

        let cupID = "adv.\(island.id).cup"
        if let cup = awards.first(where: { $0.id == cupID }) {
            return Celebration(
                kind: .adventure,
                headline: "Adventure Complete!",
                subject: island.name,
                blurb: "All 10 levels cleared. The \(cup.title) is yours.",
                badge: island.imageName,
                glow: island.palette.start)
        }

        if total > 0, correct == total {
            return Celebration(
                kind: .perfectLevel,
                headline: "Perfect Level!",
                subject: "Level \(level)",
                blurb: "\(correct) out of \(total) — not one mistake!",
                badge: island.imageName,
                glow: ResultArt.gold)
        }

        return nil
    }
}

// MARK: - The party

struct CelebrationView: View {
    let celebration: Celebration
    /// Called when the child is ready to go back to the result screen.
    let onClose: () -> Void

    @State private var risen = false
    @State private var burst = false
    @State private var spin = false
    @State private var float = false

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width

            ZStack {
                backdrop

                VStack(spacing: w * 0.030) {
                    Spacer(minLength: 0)

                    headline(w)

                    cup(w)
                        .padding(.vertical, w * 0.010)

                    subject(w)
                    blurb(w)

                    Spacer(minLength: 0)

                    Button {
                        Haptics.play(.light)
                        onClose()
                    } label: {
                        GlossyPill(text: "Awesome!", icon: "hands.clap.fill",
                                   face: GlossyPill.pink, width: w, big: true)
                    }
                    .buttonStyle(PressableButtonStyle())
                    .padding(.horizontal, w * 0.12)
                    .padding(.bottom, w * 0.06)
                    .opacity(risen ? 1 : 0)
                }
                .padding(.horizontal, w * 0.07)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                ConfettiView(isActive: burst)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .ignoresSafeArea()
        // Tapping anywhere off the button closes it too — a child who has just
        // been handed a trophy should never have to hunt for the way out.
        .contentShape(Rectangle())
        .onTapGesture { onClose() }
        .onAppear(perform: start)
    }

    // MARK: - Behind everything

    private var backdrop: some View {
        ZStack {
            Color.black.opacity(0.80)

            // The light the cup comes down out of.
            RadialGradient(colors: [celebration.glow.opacity(0.55),
                                    celebration.glow.opacity(0.16),
                                    .clear],
                           center: .center, startRadius: 0, endRadius: 320)

            rays
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }

    /// A slow sunburst turning behind the cup. Faint enough that it reads as
    /// light rather than as a drawn wheel.
    private var rays: some View {
        GeometryReader { geo in
            let side = max(geo.size.width, geo.size.height) * 1.5
            ZStack {
                ForEach(0..<18, id: \.self) { i in
                    Capsule()
                        .fill(LinearGradient(
                            colors: [.white.opacity(0.00), .white.opacity(0.13)],
                            startPoint: .top, endPoint: .bottom))
                        .frame(width: side * 0.045, height: side * 0.5)
                        .offset(y: -side * 0.25)
                        .rotationEffect(.degrees(Double(i) / 18 * 360))
                }
            }
            .frame(width: side, height: side)
            .position(x: geo.size.width / 2, y: geo.size.height * 0.42)
            .rotationEffect(.degrees(spin ? 360 : 0))
            .opacity(risen ? 1 : 0)
        }
        .allowsHitTesting(false)
    }

    // MARK: - The pieces

    private func headline(_ w: CGFloat) -> some View {
        OutlinedText(plain: celebration.headline,
                     font: .system(size: w * 0.088, weight: .black, design: .rounded),
                     outline: ResultArt.plumDeep,
                     width: w * 0.005) {
            Text(celebration.headline)
                .foregroundStyle(LinearGradient(
                    colors: [ResultArt.goldPale, ResultArt.gold, ResultArt.goldDeep],
                    startPoint: .top, endPoint: .bottom))
        }
        .shadow(color: ResultArt.gold.opacity(0.7), radius: w * 0.03)
        .scaleEffect(risen ? 1 : 0.6)
        .opacity(risen ? 1 : 0)
    }

    /// The cup itself, with the island's badge tucked into its foot when the
    /// adventure is the thing being finished.
    private func cup(_ w: CGFloat) -> some View {
        ZStack(alignment: .bottomTrailing) {
            Group {
                if ResultArt.has(celebration.cupArt) {
                    Image(celebration.cupArt)
                        .resizable()
                        .scaledToFit()
                } else {
                    Text(celebration.fallbackEmoji)
                        .font(.system(size: w * 0.44))
                }
            }
            .frame(width: w * 0.62)
            .shadow(color: ResultArt.gold.opacity(0.85), radius: w * 0.055)
            .shadow(color: .black.opacity(0.45), radius: w * 0.02, y: w * 0.015)

            if celebration.kind == .adventure, let badge = celebration.badge,
               ResultArt.has(badge) {
                Image(badge)
                    .resizable()
                    .scaledToFill()
                    .frame(width: w * 0.17, height: w * 0.17)
                    .clipShape(Circle())
                    .overlay(Circle().strokeBorder(ResultArt.gold, lineWidth: w * 0.010))
                    .shadow(color: .black.opacity(0.5), radius: w * 0.012, y: 2)
                    // Clear of the cup's foot, so it reads as a medallion set
                    // beside the trophy rather than stuck to its base.
                    .offset(x: w * 0.050, y: w * 0.020)
            }
        }
        .scaleEffect(risen ? 1 : 0.25)
        .rotationEffect(.degrees(risen ? 0 : -18))
        .offset(y: float ? -w * 0.012 : w * 0.012)
    }

    private func subject(_ w: CGFloat) -> some View {
        OutlinedText(plain: celebration.subject,
                     font: .system(size: w * 0.072, weight: .heavy, design: .rounded),
                     outline: ResultArt.plumDeep,
                     width: w * 0.004) {
            Text(celebration.subject).foregroundColor(.white)
        }
        .opacity(risen ? 1 : 0)
    }

    private func blurb(_ w: CGFloat) -> some View {
        Text(celebration.blurb)
            .font(Theme.bold(w * 0.042))
            .foregroundColor(.white.opacity(0.92))
            .multilineTextAlignment(.center)
            .shadow(color: .black.opacity(0.6), radius: 3, y: 1)
            .padding(.horizontal, w * 0.04)
            .opacity(risen ? 1 : 0)
    }

    // MARK: - Starting it off

    private func start() {
        withAnimation(.spring(response: 0.60, dampingFraction: 0.58)) { risen = true }
        withAnimation(.linear(duration: 26).repeatForever(autoreverses: false)) {
            spin = true
        }
        withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
            float = true
        }
        Haptics.play(.success)
        Sound.correct()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) { burst = true }
    }
}

#Preview {
    ZStack {
        QuizData.jungleKingdom.palette.gradient.ignoresSafeArea()
        CelebrationView(celebration: Celebration(
            kind: .adventure,
            headline: "Adventure Complete!",
            subject: "Jungle Kingdom",
            blurb: "All 10 levels cleared. The Jungle Explorer Cup is yours.",
            badge: QuizData.jungleKingdom.imageName,
            glow: QuizData.jungleKingdom.palette.start)) {}
    }
}
