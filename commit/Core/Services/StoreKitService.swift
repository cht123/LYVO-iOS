import Foundation
import StoreKit
import Combine

/// Handles all StoreKit 2 operations: loading products, purchasing, and restoring
@MainActor
final class StoreKitService: ObservableObject {

    // MARK: - Product IDs

    enum ProductID: String, CaseIterable {
        case annual = "com.taylor.lyvo.annual"
        case lifetime = "com.taylor.lyvo.lifetime"
    }

    // MARK: - Published State

    @Published private(set) var products: [Product] = []
    @Published private(set) var purchasedProductIDs: Set<String> = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String?

    // MARK: - Computed Properties

    var isPremium: Bool {
        !purchasedProductIDs.isEmpty
    }

    var annualProduct: Product? {
        products.first { $0.id == ProductID.annual.rawValue }
    }

    var lifetimeProduct: Product? {
        products.first { $0.id == ProductID.lifetime.rawValue }
    }

    // MARK: - Private Properties

    private var transactionListener: Task<Void, Error>?

    // MARK: - Initialization

    init() {
        transactionListener = listenForTransactions()

        Task {
            await loadProducts()
            await updatePurchasedProducts()
        }
    }

    deinit {
        transactionListener?.cancel()
    }

    // MARK: - Public API

    /// Load available products from the App Store
    func loadProducts() async {
        isLoading = true
        errorMessage = nil

        do {
            let productIDs = ProductID.allCases.map { $0.rawValue }
            products = try await Product.products(for: productIDs)

            // Sort: annual first, then lifetime
            products.sort { first, second in
                if first.id == ProductID.annual.rawValue { return true }
                if second.id == ProductID.annual.rawValue { return false }
                return first.id < second.id
            }
        } catch {
            errorMessage = "Failed to load products: \(error.localizedDescription)"
            #if DEBUG
            print("StoreKit Error: Failed to load products - \(error)")
            #endif
        }

        isLoading = false
    }

    /// Purchase a product
    func purchase(_ product: Product) async -> Bool {
        isLoading = true
        errorMessage = nil

        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await updatePurchasedProducts()
                await transaction.finish()
                isLoading = false
                return true

            case .userCancelled:
                isLoading = false
                return false

            case .pending:
                errorMessage = "Purchase is pending approval"
                isLoading = false
                return false

            @unknown default:
                isLoading = false
                return false
            }
        } catch {
            errorMessage = "Purchase failed: \(error.localizedDescription)"
            #if DEBUG
            print("StoreKit Error: Purchase failed - \(error)")
            #endif
            isLoading = false
            return false
        }
    }

    /// Restore previous purchases
    func restorePurchases() async -> Bool {
        isLoading = true
        errorMessage = nil

        do {
            // Sync with App Store to get latest transaction info
            try await AppStore.sync()
            await updatePurchasedProducts()
            isLoading = false
            return !purchasedProductIDs.isEmpty
        } catch {
            errorMessage = "Restore failed: \(error.localizedDescription)"
            #if DEBUG
            print("StoreKit Error: Restore failed - \(error)")
            #endif
            isLoading = false
            return false
        }
    }

    // MARK: - Private Methods

    /// Listen for transaction updates (renewals, refunds, etc.)
    private func listenForTransactions() -> Task<Void, Error> {
        Task.detached { [weak self] in
            for await result in Transaction.updates {
                do {
                    let transaction = try self?.checkVerified(result)
                    await self?.updatePurchasedProducts()
                    await transaction?.finish()
                } catch {
                    #if DEBUG
                    print("StoreKit Error: Transaction verification failed - \(error)")
                    #endif
                }
            }
        }
    }

    /// Update the set of purchased product IDs by checking current entitlements
    private func updatePurchasedProducts() async {
        var purchased: Set<String> = []

        // Check for current entitlements
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)

                // Check if subscription is still active or if it's a lifetime purchase
                if transaction.revocationDate == nil {
                    purchased.insert(transaction.productID)
                }
            } catch {
                #if DEBUG
                print("StoreKit Error: Failed to verify transaction - \(error)")
                #endif
            }
        }

        purchasedProductIDs = purchased
    }

    /// Verify a transaction result
    private nonisolated func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(_, let error):
            throw error
        case .verified(let safe):
            return safe
        }
    }
}

// MARK: - Product Extensions

extension Product {
    /// Formatted price string (e.g., "$19.99/year" or "$14.99")
    var formattedPrice: String {
        if let subscription = subscription {
            let period = subscription.subscriptionPeriod
            let periodString: String

            switch period.unit {
            case .day:
                periodString = period.value == 1 ? "/day" : "/\(period.value) days"
            case .week:
                periodString = period.value == 1 ? "/week" : "/\(period.value) weeks"
            case .month:
                periodString = period.value == 1 ? "/month" : "/\(period.value) months"
            case .year:
                periodString = period.value == 1 ? "/year" : "/\(period.value) years"
            @unknown default:
                periodString = ""
            }

            return displayPrice + periodString
        }

        return displayPrice
    }
}
