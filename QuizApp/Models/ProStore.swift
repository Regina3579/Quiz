//
//  ProStore.swift
//  QuizApp
//
//  The two ways to subscribe, and the App Store plumbing behind them.
//
//  BEFORE THIS CAN TAKE A PAYMENT, two things have to happen outside this
//  file. Neither can be done from here.
//
//  1. The two subscriptions in `Plan.productID` must exist in App Store
//     Connect, in one subscription group, with the prices set there. The
//     identifiers below are placeholders and almost certainly not the ones
//     the account will use.
//  2. `Pro.testing` must go back to `.off`. While it is `.alwaysLocked`,
//     `isActive` reads false whatever is bought, so a real purchase would be
//     recorded and then ignored; while it is `.alwaysUnlocked`, everyone has
//     the whole of Pro and there is nothing left to sell.
//
//  Until the products exist, `Product.products(for:)` returns nothing. The
//  screen then shows the prices it was designed with, says plainly that
//  purchasing is not set up yet, and refuses to pretend otherwise — it does
//  not hand out Pro for free and it does not show a spinner that never ends.
//

import Foundation
import StoreKit

@MainActor
final class ProStore: ObservableObject {

    enum Plan: String, CaseIterable, Identifiable {
        case monthly
        case yearly

        var id: String { rawValue }

        /// Placeholders. Replace with the real identifiers from App Store
        /// Connect — nothing can be sold until these match.
        var productID: String {
            switch self {
            case .monthly: return "com.quizspark.pro.monthly"
            case .yearly:  return "com.quizspark.pro.yearly"
            }
        }

        var title: String {
            switch self {
            case .monthly: return "Monthly"
            case .yearly:  return "Yearly"
            }
        }

        var period: String {
            switch self {
            case .monthly: return "/ month"
            case .yearly:  return "/ year"
            }
        }

        /// Shown only until the App Store answers with the real price in the
        /// buyer's own currency. Hard-coding rupees for everyone would be
        /// wrong in every other country.
        var placeholderPrice: String {
            switch self {
            case .monthly: return "₹99"
            case .yearly:  return "₹599"
            }
        }

        var note: String {
            switch self {
            case .monthly: return "Cancel anytime"
            case .yearly:  return "Cancel anytime"
            }
        }
    }

    @Published private(set) var products: [String: Product] = [:]
    @Published private(set) var loading = true
    @Published private(set) var working = false
    @Published var selected: Plan = .yearly
    /// Something to tell the buyer: a failure, or that this is not live yet.
    @Published var notice: String?
    /// Set once the App Store confirms this account is entitled to Pro.
    /// `Pro.isActive` is a plain UserDefaults read, which SwiftUI cannot
    /// watch, so the screen watches this instead.
    @Published private(set) var unlocked = false

    /// True once the App Store has answered with real products to sell.
    var canPurchase: Bool { products[Plan.monthly.productID] != nil
                         || products[Plan.yearly.productID] != nil }

    private var updates: Task<Void, Never>?

    init() {
        // A purchase can also finish outside this screen — asked for on
        // another device, or approved later by a parent under Ask to Buy.
        updates = Task { [weak self] in
            for await result in Transaction.updates {
                await self?.settle(result)
            }
        }
    }

    deinit { updates?.cancel() }

    // MARK: - Prices

    func price(_ plan: Plan) -> String {
        products[plan.productID]?.displayPrice ?? plan.placeholderPrice
    }

    /// What a year works out at per month, and what that saves against
    /// paying monthly. Worked from the real prices when they are known, so
    /// the claim holds in every currency rather than only in rupees.
    var yearlyBreakdown: (perMonth: String, savedPercent: Int)? {
        guard let year = products[Plan.yearly.productID] else {
            // The figures the screen was designed with: 599 a year against
            // 99 a month is 49.92 a month, and 50% saved.
            return ("₹50", 50)
        }
        let perMonth = year.price / 12
        let formatted = perMonth.formatted(year.priceFormatStyle)
        guard let month = products[Plan.monthly.productID], month.price > 0 else {
            return (formatted, 0)
        }
        let full = month.price * 12
        let saved = (full - year.price) / full
        return (formatted, Int((saved as NSDecimalNumber).doubleValue * 100))
    }

    // MARK: - Buying

    func load() async {
        loading = true
        defer { loading = false }
        do {
            let found = try await Product.products(for: Plan.allCases.map(\.productID))
            products = Dictionary(uniqueKeysWithValues: found.map { ($0.id, $0) })
            if products.isEmpty {
                notice = "Subscriptions are not set up on this build yet."
            }
        } catch {
            products = [:]
            notice = "Could not reach the App Store. Please try again."
        }
    }

    func buy() async {
        guard let product = products[selected.productID] else {
            notice = "Subscriptions are not set up on this build yet."
            return
        }
        working = true
        defer { working = false }
        do {
            switch try await product.purchase() {
            case .success(let verification):
                await settle(verification)
            case .userCancelled:
                break
            case .pending:
                // Ask to Buy: a parent has to approve it first.
                notice = "Waiting for approval. Pro will start once it is approved."
            @unknown default:
                break
            }
        } catch {
            notice = "That purchase could not be completed."
        }
    }

    func restore() async {
        working = true
        defer { working = false }
        do {
            try await AppStore.sync()
            await refreshEntitlements()
            notice = Pro.isActive ? "Your Pro subscription is back."
                                  : "No previous purchase was found on this account."
        } catch {
            notice = "Could not restore purchases just now."
        }
    }

    /// Asks the App Store what this account is currently entitled to, which
    /// is the only thing that should ever switch Pro on.
    func refreshEntitlements() async {
        var entitled = false
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }
            guard Plan.allCases.map(\.productID).contains(transaction.productID) else { continue }
            if transaction.revocationDate == nil { entitled = true }
        }
        if entitled {
            Pro.isActive = true
            unlocked = true
        } else if canPurchase {
            // Only take Pro away on the word of a store that actually has
            // these subscriptions. Before they exist, every account looks
            // unentitled, and merely opening this page would switch Pro off.
            Pro.isActive = false
            unlocked = false
        }
    }

    private func settle(_ result: VerificationResult<Transaction>) async {
        guard case .verified(let transaction) = result else { return }
        guard Plan.allCases.map(\.productID).contains(transaction.productID) else { return }
        if transaction.revocationDate == nil {
            Pro.isActive = true
            unlocked = true
        }
        await transaction.finish()
    }
}
