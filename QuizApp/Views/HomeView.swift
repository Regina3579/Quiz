//
//  HomeView.swift
//  QuizApp
//
//  Landing screen: a hero header plus a list of quiz categories.
//

import SwiftUI

struct HomeView: View {
    private let quizzes = QuizData.all
    @State private var selectedQuiz: Quiz?
    @State private var appeared = false

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.backgroundGradient
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        header

                        VStack(spacing: 14) {
                            ForEach(Array(quizzes.enumerated()), id: \.element.id) { pair in
                                let index = pair.offset
                                let quiz = pair.element
                                Button {
                                    Haptics.play(.light)
                                    selectedQuiz = quiz
                                } label: {
                                    CategoryCard(quiz: quiz)
                                }
                                .buttonStyle(PressableButtonStyle())
                                .opacity(appeared ? 1 : 0)
                                .offset(y: appeared ? 0 : 20)
                                .animation(
                                    .spring(response: 0.5, dampingFraction: 0.8)
                                        .delay(Double(index) * 0.08),
                                    value: appeared
                                )
                            }
                        }
                    }
                    .padding(20)
                }
            }
            .navigationDestination(item: $selectedQuiz) { quiz in
                QuizView(quiz: quiz)
            }
        }
        .tint(Theme.accent)
        .onAppear { appeared = true }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                Image(systemName: "sparkles")
                    .font(.title)
                    .foregroundStyle(Theme.accent)
                Text("QuizSpark")
                    .font(.largeTitle.weight(.heavy))
                    .foregroundStyle(Theme.textPrimary)
            }

            Text("Pick a category and test your knowledge.")
                .font(.body)
                .foregroundStyle(Theme.textSecondary)
        }
        .padding(.top, 8)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : -10)
        .animation(.easeOut(duration: 0.5), value: appeared)
    }
}

#Preview {
    HomeView()
}
