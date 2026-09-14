//
//  TrophyRoomView.swift
//  QuizApp
//
//  My Trophy Room — where everything the child has won is kept. The four cups
//  stand along the top, climbing with the number of questions answered right
//  over the whole journey; the badges fill the shelf below, one for each feat.
//
//  Awards that are not won yet are still shown, greyed, with how far along the
//  child is. Seeing what is nearly in reach is most of the point.
//

import SwiftUI

struct TrophyRoomView: View {
    @EnvironmentObject private var progress: GameProgress
    @Environment(\.dismiss) private var dismiss
    @AppStorage(Player.nameKey) private var playerName = ""

    @State private var appeared = false

    private let cups = AchievementCatalog.cups
    private let badges = AchievementCatalog.badges

    var body: some View {
        ZStack {
            background

            ScrollView(showsIndicators: false) {
                VStack(spacing: 22) {
                    header
                    cupShelf
                    badgeShelf
                    Color.clear.frame(height: 12)
                }
                .padding(.horizontal, 18)
                .padding(.top, 8)
            }
        }
        .overlay(alignment: .topTrailing) { closeButton }
        .onAppear {
            withAnimation(.easeOut(duration: 0.4)) { appeared = true }
        }
    }

    private var background: some View {
        LinearGradient(colors: [
            Color(red: 0.16, green: 0.09, blue: 0.34),
            Color(red: 0.26, green: 0.13, blue: 0.42),
            Color(red: 0.10, green: 0.07, blue: 0.24)
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

            statsRow
                .padding(.top, 8)
        }
        .padding(.top, 44)
    }

    private var statsRow: some View {
        HStack(spacing: 10) {
            stat("✅", "\(progress.tally.correctAnswers)", "correct")
            stat("📚", "\(progress.tally.questionsAnswered)", "answered")
            stat("🔥", "\(progress.tally.bestStreak)", "best streak")
        }
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

    // MARK: - Cups

    private var cupShelf: some View {
        VStack(alignment: .leading, spacing: 12) {
            shelfTitle("The Cups", "Every correct answer counts, everywhere")

            HStack(spacing: 10) {
                ForEach(Array(cups.enumerated()), id: \.element.id) { pair in
                    CupPlinth(award: pair.element,
                              won: progress.hasWon(pair.element),
                              standing: progress.standing(pair.element))
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 14)
                        .animation(.spring(response: 0.5, dampingFraction: 0.8)
                            .delay(Double(pair.offset) * 0.06), value: appeared)
                }
            }
        }
    }

    // MARK: - Badges

    private var badgeShelf: some View {
        VStack(alignment: .leading, spacing: 12) {
            shelfTitle("Achievements", "One for every feat")

            VStack(spacing: 9) {
                ForEach(Array(badges.enumerated()), id: \.element.id) { pair in
                    BadgeRow(award: pair.element,
                             won: progress.hasWon(pair.element),
                             standing: progress.standing(pair.element))
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 14)
                        .animation(.spring(response: 0.5, dampingFraction: 0.8)
                            .delay(0.24 + Double(pair.offset) * 0.04), value: appeared)
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

// MARK: - One cup on its plinth

private struct CupPlinth: View {
    let award: Achievement
    let won: Bool
    let standing: Int

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(won ? AnyShapeStyle(LinearGradient(
                        colors: [.white.opacity(0.34), .white.opacity(0.10)],
                        startPoint: .top, endPoint: .bottom))
                        : AnyShapeStyle(Color.white.opacity(0.07)))
                    .frame(width: 62, height: 62)
                    .overlay(Circle().stroke(won ? .white.opacity(0.65)
                                                 : .white.opacity(0.16), lineWidth: 2))

                Text(award.emoji)
                    .font(.system(size: 32))
                    .grayscale(won ? 0 : 1)
                    .opacity(won ? 1 : 0.40)

                if won {
                    Circle()
                        .stroke(Theme.star.opacity(0.9), lineWidth: 3)
                        .frame(width: 62, height: 62)
                        .shadow(color: Theme.star.opacity(0.8), radius: 7)
                }
            }

            Text(shortTitle)
                .font(Theme.bold(12))
                .foregroundColor(won ? .white : .white.opacity(0.55))
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(won ? "Won!" : "\(standing)/\(award.target)")
                .font(Theme.bold(11))
                .foregroundColor(won ? Theme.star : .white.opacity(0.5))
                .contentTransition(.numericText())
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(.white.opacity(won ? 0.13 : 0.06)))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous)
            .stroke(.white.opacity(won ? 0.30 : 0.12), lineWidth: 1))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(won ? "\(award.title), won"
                                : "\(award.title). \(award.detail). \(standing) of \(award.target)")
    }

    /// "Bronze Cup" is too wide for a quarter of the screen; the metal alone
    /// says which one it is, with the cup drawn right above it.
    private var shortTitle: String {
        award.title
            .replacingOccurrences(of: " Cup", with: "")
            .replacingOccurrences(of: " Trophy", with: "")
    }
}

// MARK: - One badge on its row

private struct BadgeRow: View {
    let award: Achievement
    let won: Bool
    let standing: Int

    private var fraction: Double {
        guard award.target > 0 else { return 0 }
        return min(1, Double(standing) / Double(award.target))
    }

    var body: some View {
        HStack(spacing: 12) {
            Text(award.emoji)
                .font(.system(size: 25))
                .grayscale(won ? 0 : 1)
                .opacity(won ? 1 : 0.45)
                .frame(width: 44, height: 44)
                .background(Circle().fill(.white.opacity(won ? 0.16 : 0.06)))
                .overlay(Circle().stroke(.white.opacity(won ? 0.45 : 0.14), lineWidth: 1.5))

            VStack(alignment: .leading, spacing: 3) {
                Text(award.title)
                    .font(Theme.bold(15))
                    .foregroundColor(won ? .white : .white.opacity(0.7))

                Text(award.detail)
                    .font(Theme.medium(12))
                    .foregroundColor(.white.opacity(0.6))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                if !won {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule().fill(.white.opacity(0.14))
                            Capsule().fill(Theme.star)
                                .frame(width: max(4, geo.size.width * fraction))
                        }
                    }
                    .frame(height: 5)
                    .padding(.top, 2)
                }
            }

            Spacer(minLength: 4)

            if won {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 21))
                    .foregroundColor(Theme.star)
            } else {
                Text("\(standing)/\(award.target)")
                    .font(Theme.bold(12))
                    .foregroundColor(.white.opacity(0.55))
                    .contentTransition(.numericText())
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
                                : "\(award.title). \(award.detail). \(standing) of \(award.target)")
    }
}

// MARK: - "You won an award!" card for the result screens

/// Shown under the jewels on a result screen when a round wins something.
struct AwardWonCard: View {
    let awards: [Achievement]

    var body: some View {
        VStack(spacing: 9) {
            Text(awards.count == 1 ? "New award!" : "\(awards.count) new awards!")
                .font(Theme.display(17))
                .foregroundColor(Theme.star)

            ForEach(awards) { award in
                HStack(spacing: 10) {
                    Text(award.emoji).font(.system(size: 26))
                    VStack(alignment: .leading, spacing: 1) {
                        Text(award.title)
                            .font(Theme.bold(15))
                            .foregroundColor(.white)
                        if let line = award.rewardLine {
                            Text(line)
                                .font(Theme.medium(12))
                                .foregroundColor(.white.opacity(0.7))
                        } else {
                            Text(award.detail)
                                .font(Theme.medium(12))
                                .foregroundColor(.white.opacity(0.7))
                                .lineLimit(1)
                        }
                    }
                    Spacer(minLength: 0)
                }
            }

            Text("Kept in your Trophy Room")
                .font(Theme.medium(11))
                .foregroundColor(.white.opacity(0.55))
        }
        .padding(15)
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 18, style: .continuous)
            .fill(.black.opacity(0.28)))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous)
            .stroke(Theme.star.opacity(0.55), lineWidth: 2))
    }
}

#Preview {
    TrophyRoomView().environmentObject(GameProgress())
}
