//
//  ProgressBar.swift
//  QuizApp
//
//  A chunky, cute progress indicator for quiz advancement.
//

import SwiftUI

struct ProgressBar: View {
    /// Progress value from 0…1.
    let value: Double

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.white.opacity(0.30))

                Capsule()
                    .fill(Color.white)
                    .frame(width: max(12, geo.size.width * value))
                    .animation(.spring(response: 0.5, dampingFraction: 0.8), value: value)
            }
        }
        .frame(height: 12)
    }
}
