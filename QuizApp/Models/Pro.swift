//
//  Pro.swift
//  QuizApp
//
//  What Pro unlocks, and the one switch that decides it.
//
//  Two things are behind it: the Pro Challenge room, and the sticker shop
//  beyond its free samples. Everything else — all ten adventures, every
//  question, the Trophy Room, the Daily Challenge — stays open to everyone.
//  A child who never pays still has the whole game to play; Pro adds ways to
//  play it again and things to collect.
//
//  The sticker book is deliberately not locked shut. A child without Pro can
//  open it, look at every shelf, and buy one sticker from each of the ten
//  adventures. Ten real stickers they chose and paid gems for is a book
//  worth coming back to, and it shows them exactly what the rest would be.
//  A locked door shows them nothing.
//

import Foundation

enum Pro {
    static let activeKey = "quizspark.pro.active"

    /// TESTING: when true, Pro reads as locked no matter what is saved, so the
    /// whole app can be looked at the way a child without Pro sees it. Set back
    /// to false to let the saved flag decide again.
    ///
    /// This is here because there is no way to give Pro back once it has been
    /// taken: `unlock()` can be reached from the paywall, nothing in the app
    /// undoes it, and a phone that has tapped it once would otherwise never
    /// show the locked state again without deleting the app.
    ///
    /// While it is on, tapping "Unlock Pro" still writes the saved flag but
    /// changes nothing on screen — the override wins. That is the point of it,
    /// not a fault.
    static let forceLocked = true

    /// The single source of truth. Everything that gates on Pro reads this
    /// and nothing else, so there is one place to change when the purchase
    /// is real and one place to look when something is unexpectedly locked.
    static var isActive: Bool {
        get { !forceLocked && UserDefaults.standard.bool(forKey: activeKey) }
        set { UserDefaults.standard.set(newValue, forKey: activeKey) }
    }

    /// Grants Pro.
    ///
    /// THIS IS NOT A PURCHASE. It flips the flag and nothing else — no money
    /// changes hands, and anything calling it gets Pro for free. It is here so
    /// the gating can be built and tested now, and so there is exactly one
    /// function to replace when there is a real product to sell.
    ///
    /// Making it real needs three things this app does not have yet: a product
    /// configured in App Store Connect, StoreKit to buy it with, and a restore
    /// path for a family's second device. Until then, shipping this to the
    /// App Store would give Pro away.
    static func unlock() {
        isActive = true
    }

    static func lock() {
        isActive = false
    }
}
