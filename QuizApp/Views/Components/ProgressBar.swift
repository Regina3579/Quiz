//
//  ProgressBar.swift
//  QuizApp
//
//  A smooth, animated progress indicator for quiz advancement.
//

import SwiftUI

struct ProgressBar: View {
    /// Progress value from 0…1.
    let value: Double
    let gradient: LinearGradient

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.white.opacity(0.12))

                Capsule()
                    .fill(gradient)
                    .frame(width: max(0, geo.size.width * value))
                    .animation(.spring(response: 0.5, dampingFraction: 0.8), value: value)
            }
        }
        .frame(height: 10)
    }
}
