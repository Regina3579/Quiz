//
//  TrophyRoomView.swift
//  QuizApp
//
//  My Trophy Room — a treasure room with shelves.
//
//  Ten golden pedestals stand along the top, one for each adventure, and each
//  fills as its ladder is climbed: bronze, silver and gold badges for answering
//  its hundred questions right, an Explorer Cup for clearing all ten levels,
//  and a Master Crown for getting every question in it right. Fill all ten and
//  the Ultimate Adventurer Trophy lights up at the end.
//
//  Awards not won yet are still shown, as locked silhouettes with how far
//  along the child is. "7 / 10 — only 3 more!" is the whole point of the room:
//  seeing what is nearly in reach is what brings a child back.
//

import SwiftUI

struct TrophyRoomView: View {
    @EnvironmentObject private var progress: GameProgress
    @Environment(\.dismiss) private var dismiss
    @AppStorage(Player.nameKey) private var playerName = ""

    @State private var appeared = false
    @State private var openIsland: Island?

    private let islands = QuizData.islands

    var body: some View {
        ZStack {
            background

            ScrollView(showsIndicators: false) {
                VStack(spacing: 26) {
                    header
                    pedestalShelf
                    ultimatePedestal
                    grandCupShelf
                    badgeShelf
                    Color.clear.frame(height: 16)
                }
                .padding(.horizontal, 18)
                .padding(.top, 8)
            }
        }
        .overlay(alignment: .topTrailing) { closeButton }
        .sheet(item: $openIsland) { island in
            AdventureLadderSheet(island: island)
                .environmentObject(progress)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.4)) { appeared = true }
        }
    }

    private var background: some View {
        LinearGradient(colors: [
            Color(red: 0.17, green: 0.09, blue: 0.33),
            Color(red: 0.28, green: 0.14, blue: 0.44),
            Color(red: 0.10, green: 0.06, blue: 0.22)
        ], startPoint: .top, endPoint: .bottom)
        .ignoresSafeArea()
    }

    private var closeButton: some View {
        Button {
            Haptics.play(.light)
            dismiss()
        } label: {
            Image(systemName: "xmark")
                .font(Theme.bold(16))
                .foregroundColor(.white)
                .padding(11)
                .background(Circle().fill(.white.opacity(0.22)))
                .overlay(Circle().stroke(.white.opacity(0.45), lineWidth: 1.5))
        }
        .buttonStyle(PressableButtonStyle())
        .padding(.trailing, 18)
        .padding(.top, 10)
        .accessibilityLabel("Close the trophy room")
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: 6) {
            Text("🏆").font(.system(size: 46))

            Text(playerName.isEmpty ? "My Trophy Room" : "\(playerName)'s Trophy Room")
                .font(Theme.display(26))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.6)
                .lineLimit(2)

            Text("\(progress.trophyCount) of \(AchievementCatalog.all.count) won")
                .font(Theme.bold(15))
                .foregroundColor(.white.opacity(0.75))

            HStack(spacing: 10) {
                stat("✅", "\(progress.tally.correctAnswers)", "correct")
                stat("📚", "\(progress.tally.questionsAnswered)", "answered")
                stat("🔥", "\(progress.tally.bestStreak)", "best streak")
            }
            .padding(.top, 8)
        }
        .padding(.top, 44)
    }

    private func stat(_ icon: String, _ value: String, _ label: String) -> some View {
        VStack(spacing: 2) {
            Text(icon).font(.system(size: 15))
            Text(value)
                .font(Theme.bold(17))
                .foregroundColor(.white)
                .contentTransition(.numericText())
            Text(label)
                .font(Theme.medium(11))
                .foregroundColor(.white.opacity(0.65))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 9)
        .background(RoundedRectangle(cornerRadius: 14, style: .continuous)
            .fill(.white.opacity(0.10)))
        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous)
            .stroke(.white.opacity(0.18), lineWidth: 1))
    }

    // MARK: - The ten pedestals

    private var pedestalShelf: some View {
        VStack(alignment: .leading, spacing: 12) {
            shelfTitle("Adventure Trophies",
                       "\(progress.pedestalsFilled) of 10 pedestals filled")

            LazyVGrid(columns: [GridItem(.flexible(), spacing: 11),
                                GridItem(.flexible(), spacing: 11)], spacing: 11) {
                ForEach(Array(islands.enumerated()), id: \.element.id) { pair in
                    AdventurePedestal(island: pair.element)
                        .onTapGesture {
                            Haptics.play(.light)
                            openIsland = pair.element
                        }
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 14)
                        .animation(.spring(response: 0.5, dampingFraction: 0.85)
                            .delay(Double(pair.offset) * 0.035), value: appeared)
                }
            }
        }
    }

    // MARK: - The one at the end

    private var ultimatePedestal: some View {
        let award = AchievementCatalog.ultimate
        let won = progress.hasWon(award)
        let filled = progress.pedestalsFilled

        return VStack(spacing: 9) {
            Text(won ? "✨" : "🔒")
                .font(.system(size: won ? 54 : 38))
                .opacity(won ? 1 : 0.6)

            Text(award.title)
                .font(Theme.display(21))
                .foregroundColor(won ? Theme.star : .white.opacity(0.75))

            Text(won ? "Every pedestal filled!" : "Fill all 10 pedestals")
                .font(Theme.medium(13))
                .foregroundColor(.white.opacity(0.7))

            if !won {
                ProgressTrack(fraction: Double(filled) / 10)
                    .frame(height: 7)
                    .padding(.horizontal, 30)

                Text(remainingLine(filled, of: 10))
                    .font(Theme.bold(13))
                    .foregroundColor(Theme.star)
            } else {
                Text("+250 💎 and a legendary sticker")
                    .font(Theme.bold(13))
                    .foregroundColor(.white.opacity(0.85))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(RoundedRectangle(cornerRadius: 22, style: .continuous)
            .fill(LinearGradient(colors: won
                                 ? [Theme.star.opacity(0.30), .white.opacity(0.08)]
                                 : [.white.opacity(0.08), .white.opacity(0.04)],
                                 startPoint: .top, endPoint: .bottom)))
        .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous)
            .stroke(won ? Theme.star.opacity(0.85) : .white.opacity(0.16),
                    lineWidth: won ? 2.5 : 1))
        .shadow(color: won ? Theme.star.opacity(0.5) : .clear, radius: 12)
    }

    // MARK: - Grand cups

    private var grandCupShelf: some View {
        VStack(alignment: .leading, spacing: 12) {
            shelfTitle("Grand Cups", "Every correct answer counts, everywhere")

            HStack(spacing: 9) {
                ForEach(AchievementCatalog.grandCups) { award in
                    GrandCup(award: award,
                             won: progress.hasWon(award),
                             standing: progress.standing(award))
                }
            }
        }
    }

    // MARK: - Special achievements

    private var badgeShelf: some View {
        VStack(alignment: .leading, spacing: 12) {
            shelfTitle("Special Achievements", "One for every feat")

            VStack(spacing: 9) {
                ForEach(AchievementCatalog.badges) { award in
                    AwardRow(award: award,
                             won: progress.hasWon(award),
                             standing: progress.standing(award))
                }
            }
        }
    }

    private func shelfTitle(_ title: String, _ subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(title)
                .font(Theme.display(20))
                .foregroundColor(.white)
            Text(subtitle)
                .font(Theme.medium(12))
                .foregroundColor(.white.opacity(0.6))
        }
    }
}

/// "Only 3 more!" — said the way a child would hear it.
func remainingLine(_ standing: Int, of target: Int) -> String {
    let left = max(0, target - standing)
    if left == 0 { return "Done!" }
    return "\(standing)/\(target) — only \(left) more!"
}

// MARK: - A thin progress bar

struct ProgressTrack: View {
    let fraction: Double

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(.white.opacity(0.15))
                Capsule().fill(Theme.star)
                    .frame(width: max(4, geo.size.width * min(1, max(0, fraction))))
            }
        }
    }
}

// MARK: - One adventure's pedestal

private struct AdventurePedestal: View {
    @EnvironmentObject private var progress: GameProgress
    let island: Island

    private var rungs: [Achievement] { progress.ladder(for: island) }
    private var wonCount: Int { rungs.filter { progress.hasWon($0) }.count }
    private var top: Achievement? { progress.topRung(for: island) }
    private var next: Achievement? { progress.nextRung(for: island) }

    var body: some View {
        VStack(spacing: 7) {
            ZStack {
                Circle()
                    .fill(.white.opacity(wonCount > 0 ? 0.14 : 0.06))
                    .frame(width: 64, height: 64)

                if let name = island.imageName {
                    Image(name)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 58, height: 58)
                        .clipShape(Circle())
                        .grayscale(wonCount > 0 ? 0 : 1)
                        .opacity(wonCount > 0 ? 1 : 0.45)
                } else {
                    Text(island.emoji).font(.system(size: 30))
                }

                Circle()
                    .stroke(wonCount > 0 ? Theme.star.opacity(0.9) : .white.opacity(0.18),
                            lineWidth: wonCount > 0 ? 2.5 : 1.5)
                    .frame(width: 64, height: 64)

                // The best rung so far rides on the corner.
                if let top {
                    Text(top.emoji)
                        .font(.system(size: 22))
                        .offset(x: 24, y: 20)
                        .shadow(color: .black.opacity(0.4), radius: 2)
                } else {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white.opacity(0.8))
                        .padding(5)
                        .background(Circle().fill(.black.opacity(0.45)))
                        .offset(x: 24, y: 20)
                }
            }

            Text(island.name)
                .font(Theme.bold(13))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.65)

            // Five little pips: the ladder at a glance.
            HStack(spacing: 4) {
                ForEach(rungs) { rung in
                    Circle()
                        .fill(progress.hasWon(rung) ? Theme.star : .white.opacity(0.18))
                        .frame(width: 6, height: 6)
                }
            }

            if let next {
                let standing = progress.standing(next)
                Text("\(standing)/\(next.target) \(pipIcon(next))")
                    .font(Theme.bold(11))
                    .foregroundColor(.white.opacity(0.7))
                    .contentTransition(.numericText())
            } else {
                Text("Mastered! 👑")
                    .font(Theme.bold(11))
                    .foregroundColor(Theme.star)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(RoundedRectangle(cornerRadius: 18, style: .continuous)
            .fill(.white.opacity(wonCount > 0 ? 0.11 : 0.05)))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous)
            .stroke(.white.opacity(wonCount > 0 ? 0.26 : 0.12), lineWidth: 1))
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(island.name), \(wonCount) of \(rungs.count) trophies won")
    }

    private func pipIcon(_ award: Achievement) -> String {
        if case .islandLevelsCleared = award.measure { return "levels" }
        return "right"
    }
}

// MARK: - One adventure's ladder, in full

private struct AdventureLadderSheet: View {
    @EnvironmentObject private var progress: GameProgress
    @Environment(\.dismiss) private var dismiss
    let island: Island

    var body: some View {
        ZStack {
            LinearGradient(colors: [
                Color(red: 0.17, green: 0.09, blue: 0.33),
                Color(red: 0.10, green: 0.06, blue: 0.22)
            ], startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    Text(island.emoji).font(.system(size: 44))
                    Text(island.name)
                        .font(Theme.display(24))
                        .foregroundColor(.white)
                    Text("\(progress.bestCorrect(inIsland: island.id)) of 100 questions right")
                        .font(Theme.bold(14))
                        .foregroundColor(.white.opacity(0.75))

                    VStack(spacing: 9) {
                        ForEach(progress.ladder(for: island)) { award in
                            AwardRow(award: award,
                                     won: progress.hasWon(award),
                                     standing: progress.standing(award))
                        }
                    }
                    .padding(.top, 4)
                }
                .padding(20)
            }
        }
        .overlay(alignment: .topTrailing) {
            Button {
                Haptics.play(.light)
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(Theme.bold(15))
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Circle().fill(.white.opacity(0.22)))
            }
            .buttonStyle(PressableButtonStyle())
            .padding(16)
            .accessibilityLabel("Close")
        }
    }
}

// MARK: - One grand cup

private struct GrandCup: View {
    let award: Achievement
    let won: Bool
    let standing: Int

    var body: some View {
        VStack(spacing: 5) {
            ZStack {
                Circle()
                    .fill(.white.opacity(won ? 0.16 : 0.06))
                    .frame(width: 54, height: 54)
                    .overlay(Circle().stroke(won ? Theme.star.opacity(0.9)
                                                 : .white.opacity(0.16),
                                             lineWidth: won ? 2.5 : 1.5))
                if won {
                    Text(award.emoji).font(.system(size: 27))
                } else {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.white.opacity(0.45))
                }
            }

            Text(award.title.replacingOccurrences(of: " Cup", with: "")
                            .replacingOccurrences(of: " Trophy", with: ""))
                .font(Theme.bold(11))
                .foregroundColor(won ? .white : .white.opacity(0.6))
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(won ? "Won!" : "\(standing)/\(award.target)")
                .font(Theme.bold(10))
                .foregroundColor(won ? Theme.star : .white.opacity(0.5))
                .contentTransition(.numericText())
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 9)
        .background(RoundedRectangle(cornerRadius: 15, style: .continuous)
            .fill(.white.opacity(won ? 0.12 : 0.05)))
        .overlay(RoundedRectangle(cornerRadius: 15, style: .continuous)
            .stroke(.white.opacity(won ? 0.28 : 0.11), lineWidth: 1))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(won ? "\(award.title), won"
                                : "\(award.title), locked. \(award.detail). \(standing) of \(award.target)")
    }
}

// MARK: - One award on a row

/// Used for the special achievements and for an adventure's ladder. Locked
/// awards show a padlock in place of the trophy, with the progress underneath.
struct AwardRow: View {
    let award: Achievement
    let won: Bool
    let standing: Int

    private var fraction: Double {
        guard award.target > 0 else { return 0 }
        return min(1, Double(standing) / Double(award.target))
    }

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(.white.opacity(won ? 0.16 : 0.06))
                    .frame(width: 44, height: 44)
                    .overlay(Circle().stroke(.white.opacity(won ? 0.45 : 0.14),
                                             lineWidth: 1.5))
                if won {
                    Text(award.emoji).font(.system(size: 24))
                } else {
                    // A silhouette, so the shape is a promise rather than a
                    // blank: the trophy is there, just not lit yet.
                    Text(award.emoji)
                        .font(.system(size: 24))
                        .saturation(0)
                        .opacity(0.22)
                    Image(systemName: "lock.fill")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white.opacity(0.65))
                }
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(award.title)
                    .font(Theme.bold(15))
                    .foregroundColor(won ? .white : .white.opacity(0.72))

                Text(award.detail)
                    .font(Theme.medium(12))
                    .foregroundColor(.white.opacity(0.6))
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)

                if !won {
                    ProgressTrack(fraction: fraction)
                        .frame(height: 5)
                        .padding(.top, 2)
                    Text(remainingLine(standing, of: award.target))
                        .font(Theme.bold(11))
                        .foregroundColor(Theme.star.opacity(0.9))
                }
            }

            Spacer(minLength: 4)

            if won {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 21))
                    .foregroundColor(Theme.star)
            }
        }
        .padding(.horizontal, 13)
        .padding(.vertical, 10)
        .background(RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(.white.opacity(won ? 0.13 : 0.06)))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous)
            .stroke(.white.opacity(won ? 0.30 : 0.12), lineWidth: 1))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(won ? "\(award.title), won"
                                : "\(award.title), locked. \(award.detail). \(standing) of \(award.target)")
    }
}

#Preview {
    TrophyRoomView().environmentObject(GameProgress())
}
