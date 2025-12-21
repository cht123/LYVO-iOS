import Foundation
import SwiftUI
import Combine
import StoreKit

/// Manages premium features and paywall state
/// Toggle DEBUG_BYPASS_PAYWALL to true during development to access all premium features
@MainActor
final class PaywallService: ObservableObject {

    // MARK: - Debug Configuration

    /// Set to true to bypass paywall during development
    #if DEBUG
    static let DEBUG_BYPASS_PAYWALL = false
    #else
    static let DEBUG_BYPASS_PAYWALL = false
    #endif

    // MARK: - Singleton

    static let shared = PaywallService()

    // MARK: - Published State

    @Published private(set) var isPremium: Bool = false
    @Published var showPaywall: Bool = false
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var showRestoreSuccess: Bool = false

    // MARK: - StoreKit Service

    let storeKit = StoreKitService()
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Persistence Keys

    private let premiumKey = "isPremiumUser"

    // MARK: - Premium Features

    enum PremiumFeature: String, CaseIterable {
        case microJournaling = "Micro-Journaling"
        case unlimitedArchive = "Unlimited Archive"
        case triggerTimeNotifications = "Trigger-Time Reminders"
        case multipleCommitments = "Multiple Commitments"

        var description: String {
            switch self {
            case .microJournaling:
                return "Capture your thoughts after each daily ritual"
            case .unlimitedArchive:
                return "Access your complete commitment history"
            case .triggerTimeNotifications:
                return "Set reminders for challenging moments"
            case .multipleCommitments:
                return "Work on multiple identity goals"
            }
        }

        var icon: String {
            switch self {
            case .microJournaling:
                return "square.and.pencil"
            case .unlimitedArchive:
                return "archivebox.fill"
            case .triggerTimeNotifications:
                return "bell.badge.fill"
            case .multipleCommitments:
                return "circle.grid.2x2.fill"
            }
        }
    }

    // MARK: - Initialization

    private init() {
        loadPremiumStatus()
        observeStoreKit()
    }

    // MARK: - StoreKit Observation

    private func observeStoreKit() {
        // Sync premium status when StoreKit purchases change
        storeKit.$purchasedProductIDs
            .receive(on: DispatchQueue.main)
            .sink { [weak self] purchasedIDs in
                guard let self = self else { return }
                if !purchasedIDs.isEmpty {
                    self.isPremium = true
                    self.savePremiumStatus()
                }
            }
            .store(in: &cancellables)

        // Sync loading state
        storeKit.$isLoading
            .receive(on: DispatchQueue.main)
            .assign(to: &$isLoading)

        // Sync error messages
        storeKit.$errorMessage
            .receive(on: DispatchQueue.main)
            .assign(to: &$errorMessage)
    }

    // MARK: - Public API

    /// Check if user has access to a premium feature
    func hasAccess(to feature: PremiumFeature) -> Bool {
        if PaywallService.DEBUG_BYPASS_PAYWALL {
            return true
        }
        return isPremium || storeKit.isPremium
    }

    /// Attempt to use a premium feature, showing paywall if needed
    /// Returns true if access granted, false if paywall shown
    @discardableResult
    func requestAccess(to feature: PremiumFeature) -> Bool {
        if hasAccess(to: feature) {
            return true
        }
        showPaywall = true
        return false
    }

    /// Purchase a product
    func purchase(_ product: Product) async -> Bool {
        let success = await storeKit.purchase(product)
        if success {
            completePurchase()
        }
        return success
    }

    /// Complete a purchase (called after successful IAP)
    func completePurchase() {
        isPremium = true
        savePremiumStatus()
        showPaywall = false
    }

    /// Restore purchases from App Store
    func restorePurchases() async -> Bool {
        let success = await storeKit.restorePurchases()
        if success {
            isPremium = true
            savePremiumStatus()
            showRestoreSuccess = true

            // Auto-dismiss success message after delay
            Task {
                try? await Task.sleep(for: .seconds(2))
                showRestoreSuccess = false
            }
        }
        return success
    }

    /// Clear any error message
    func clearError() {
        errorMessage = nil
    }

    // MARK: - Persistence

    private func loadPremiumStatus() {
        isPremium = UserDefaults.standard.bool(forKey: premiumKey)
    }

    private func savePremiumStatus() {
        UserDefaults.standard.set(isPremium, forKey: premiumKey)
    }

    // MARK: - Debug Helpers

    #if DEBUG
    func debugSetPremium(_ value: Bool) {
        isPremium = value
        savePremiumStatus()
    }

    func debugTogglePremium() {
        isPremium.toggle()
        savePremiumStatus()
    }
    #endif
}
