//
//  QuizAppApp.swift
//  QuizApp
//
//  Application entry point.
//

import SwiftUI

@main
struct QuizAppApp: App {
    /// Shared save-progress store, injected into the whole view tree.
    @StateObject private var progress = GameProgress()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(progress)
                .preferredColorScheme(.light)
        }
    }
}
