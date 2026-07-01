//
//  HomeView.swift
//  QuizApp
//
//  Landing screen: a cheerful welcome plus a colorful grid of adventures.
//

import SwiftUI

struct HomeView: View {
    private let quizzes = QuizData.all
    @State private var appeared = false

    private let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.homeBackground
                    .ignoresSafeArea()

                // Floating decorative bubbles in the background.
                decorations

                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        header

                        LazyVGrid(columns: columns, spacing: 14) {
                            ForEach(Array(quizzes.enumerated()), id: \.element.id) { pair in
                                let index = pair.offset
                                let quiz = pair.element
                                NavigationLink(value: quiz) {
                                    CategoryCard(quiz: quiz)
                                }
                                .buttonStyle(PressableButtonStyle())
                                .simultaneousGesture(
                                    TapGesture().onEnded { Haptics.play(.light) }
                                )
                                .opacity(appeared ? 1 : 0)
                                .scaleEffect(appeared ? 1 : 0.8)
                                .animation(
                                    .spring(response: 0.5, dampingFraction: 0.7)
                                        .delay(Double(index) * 0.07),
                                    value: appeared
                                )
                            }
                        }
                    }
                    .padding(20)
                }
            }
            .navigationDestination(for: Quiz.self) { quiz in
                QuizView(quiz: quiz)
            }
        }
        .onAppear { appeared = true }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Text("Hi there!")
                    .font(Theme.display(34))
                    .foregroundColor(Theme.ink)
                Text("👋")
                    .font(.system(size: 32))
                    .rotationEffect(.degrees(appeared ? 0 : -20))
                    .animation(.spring(response: 0.6, dampingFraction: 0.5).delay(0.3), value: appeared)
            }

            Text("Pick a fun adventure and let's play! 🎉")
                .font(Theme.medium(16))
                .foregroundColor(Theme.inkSoft)
        }
        .padding(.top, 8)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : -12)
        .animation(.easeOut(duration: 0.5), value: appeared)
    }

    /// Soft translucent circles that make the background feel playful.
    private var decorations: some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(0.35))
                .frame(width: 140, height: 140)
                .offset(x: -140, y: -260)
            Circle()
                .fill(Color.white.opacity(0.25))
                .frame(width: 90, height: 90)
                .offset(x: 150, y: -180)
            Circle()
                .fill(Color.white.opacity(0.20))
                .frame(width: 120, height: 120)
                .offset(x: 160, y: 320)
        }
        .ignoresSafeArea()
    }
}

#Preview {
    HomeView()
}
