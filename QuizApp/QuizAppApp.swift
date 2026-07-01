//
//  QuizAppApp.swift
//  QuizApp
//
//  Application entry point.
//

import SwiftUI

@main
struct QuizAppApp: App {
    var body: some Scene {
        WindowGroup {
            HomeView()
                .preferredColorScheme(.light)
        }
    }
}
