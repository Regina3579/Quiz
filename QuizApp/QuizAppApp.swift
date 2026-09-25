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

    @Environment(\.scenePhase) private var scenePhase

    init() {
        // Takes back the Pro that the old free "Unlock Pro" button handed out.
        // Runs once per device, and must happen before any view reads
        // `Pro.isActive` — which HomeView does as it draws.
        Pro.clearLegacyFreeUnlock()
    }

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(progress)
                .preferredColorScheme(.light)
        }
        // The music has to follow the app out of the door. Left running it
        // would still be playing under whatever the child opened next, and
        // .ambient means nothing else would stop it.
        //
        // Only on .background, not .inactive: the app goes briefly inactive
        // when Control Centre is pulled down or the app switcher is swiped,
        // and stopping the tune for that would be heard as a stutter.
        .onChange(of: scenePhase) { phase in
            switch phase {
            case .active:     Music.shared.resume()
            case .background: Music.shared.pause()
            default:          break
            }
        }
    }
}
