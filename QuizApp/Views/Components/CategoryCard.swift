//
//  CategoryCard.swift
//  QuizApp
//
//  A big, colorful, cute grid tile for each quiz category.
//

import SwiftUI

struct CategoryCard: View {
    let quiz: Quiz

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Emoji mascot inside a soft white bubble.
            Text(quiz.emoji)
                .font(.system(size: 42))
                .frame(width: 74, height: 74)
                .background(
                    Circle().fill(Color.white.opacity(0.28))
                )
                .overlay(
                    Circle().stroke(Color.white.opacity(0.5), lineWidth: 2)
                )

            Spacer(minLength: 4)

            Text(quiz.title)
                .font(Theme.bold(19))
                .foregroundColor(Theme.onColor)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)

            Text(quiz.subtitle)
                .font(Theme.medium(12))
                .foregroundColor(Theme.onColorSoft)
                .lineLimit(2)
                .multilineTextAlignment(.leading)

            // "Let's play" pill with the question count.
            HStack(spacing: 5) {
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 13))
                Text("\(quiz.questionCount) questions")
                    .font(Theme.bold(11))
            }
            .foregroundColor(quiz.palette.end)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Capsule().fill(Color.white))
            .padding(.top, 2)
        }
        .frame(maxWidth: .infinity, minHeight: 190, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous)
                .fill(quiz.palette.gradient)
        )
        .overlay(
            // A soft decorative sparkle in the corner for extra cuteness.
            Image(systemName: "sparkle")
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.5))
                .padding(14),
            alignment: .topTrailing
        )
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
        .shadow(color: quiz.palette.end.opacity(0.45), radius: 12, x: 0, y: 8)
    }
}
