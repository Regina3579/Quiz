//
//  CategoryCard.swift
//  QuizApp
//
//  The colorful card shown for each quiz on the home screen.
//

import SwiftUI

struct CategoryCard: View {
    let quiz: Quiz

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(quiz.palette.gradient)
                    .frame(width: 60, height: 60)
                    .shadow(color: quiz.palette.end.opacity(0.5), radius: 10, y: 4)

                Image(systemName: quiz.symbol)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(quiz.title)
                    .font(.headline)
                    .foregroundStyle(Theme.textPrimary)

                Text(quiz.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(Theme.textSecondary)
                    .lineLimit(1)

                Text("\(quiz.questionCount) questions")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(quiz.palette.end)
                    .padding(.top, 2)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(Theme.textSecondary)
        }
        .padding(Theme.cardPadding)
        .glassCard()
    }
}
