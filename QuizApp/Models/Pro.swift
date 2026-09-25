//
//  Pro.swift
//  QuizApp
//
//  What Pro unlocks, and the one switch that decides it.
//
//  Two things are behind it: the Pro Challenge room, and the sticker shop
//  beyond its free samples. Everything else — all ten adventures, every
//  question, the Trophy Room, the Daily Challenge — stays open to everyone.
//  Anyone who never pays still has the whole game to play; Pro adds ways to
//  play it again and things to collect.
//
//  The sticker book is deliberately not locked shut. A player without Pro can
//  open it, look at every shelf, and buy one sticker from each of the ten
//  adventures. Ten real stickers they chose and paid gems for is a book
//  worth coming back to, and it shows them exactly what the rest would be.
//  A locked door shows them nothing.
//
//  The same goes for its length. All twenty-five pages turn for everyone —
//  the last twenty simply wear a little crown lock and cannot be stuck on
//  until Pro. Five pages is room enough to arrange ten stickers properly,
//  and the crowned twenty show what the rest of the book would be instead of
//  hiding it. The two numbers live in `StickerBookPages`, in StickerBook.swift.
//

import Foundation

enum Pro {
    static let activeKey = "quizspark.pro.active"

    /// TESTING ONLY: forces Pro on or off, whatever is saved on the phone.
    ///
    /// This exists because neither state can otherwise be got back to at will.
    /// There is no way to give Pro back once it has been taken — nothing in the
    /// app undoes `unlock()` — and no way to take it away again short of
    /// deleting the app, so looking at both halves of the game needs a switch
    /// that does not depend on what happens to be saved.
    ///
    /// While an override is on, tapping "Unlock Pro" still writes the saved
    /// flag but changes nothing on screen: the override wins. That is the
    /// point of it, not a fault.
    enum Testing {
        /// The saved flag decides. **This is the setting to ship.**
        case off
        /// Everything Pro reads as locked: the game as a player without Pro
        /// sees it.
        case alwaysLocked
        /// Everything Pro is open: the game as a subscriber sees it.
        case alwaysUnlocked
    }

    /// MUST be `.off` before the App Store build. `.alwaysUnlocked` gives the
    /// whole of Pro away to everyone; `.alwaysLocked` makes a real purchase
    /// appear to do nothing.
    static let testing: Testing = .off

    /// The single source of truth. Everything that gates on Pro reads this
    /// and nothing else, so there is one place to change when the purchase
    /// is real and one place to look when something is unexpectedly locked.
    static var isActive: Bool {
        get {
            switch testing {
            case .alwaysUnlocked: return true
            case .alwaysLocked:   return false
            case .off:            return UserDefaults.standard.bool(forKey: activeKey)
            }
        }
        set { UserDefaults.standard.set(newValue, forKey: activeKey) }
    }

    /// Clears Pro granted by the old free "Unlock Pro" button.
    ///
    /// Before the plan-and-pay screen existed, that button called `unlock()`,
    /// which flips the saved flag and charges nothing. Anyone who tapped it on
    /// one of those builds — every one of us testing, and every device the app
    /// was ever shown on — has `activeKey` saved as true to this day. With
    /// `testing` back to `.off` that flag is what `isActive` reads, so those
    /// devices quietly keep the whole of Pro: the Challenge room opens without
    /// a paywall and all twenty-five sticker pages turn.
    ///
    /// This runs once, the first time a build containing it launches, and
    /// takes that flag away. It is safe for a real subscriber: `Pro.isActive`
    /// is switched back on by `ProStore.refreshEntitlements()` on the App
    /// Store's word, which is the only thing that should ever have set it.
    ///
    /// It cannot be removed later. A device that never runs it keeps the free
    /// Pro forever, and there is no other way to take it back.
    static func clearLegacyFreeUnlock() {
        let done = "quizspark.pro.legacyFreeUnlockCleared"
        let defaults = UserDefaults.standard
        guard !defaults.bool(forKey: done) else { return }
        defaults.removeObject(forKey: activeKey)
        defaults.set(true, forKey: done)
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
