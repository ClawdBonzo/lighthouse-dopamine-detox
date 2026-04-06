import Foundation
import RevenueCat

// MARK: - Subscription Plans

enum SubscriptionPlan: String, CaseIterable, Identifiable {
    case weekly = "lighthouse_weekly"
    case monthly = "lighthouse_monthly"
    case yearly = "lighthouse_yearly"
    case lifetime = "lighthouse_lifetime"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .weekly: "Weekly"
        case .monthly: "Monthly"
        case .yearly: "Yearly"
        case .lifetime: "Lifetime"
        }
    }

    var price: String {
        switch self {
        case .weekly: "$4.99/wk"
        case .monthly: "$9.99/mo"
        case .yearly: "$49.99/yr"
        case .lifetime: "$79.99"
        }
    }

    var savings: String? {
        switch self {
        case .weekly: nil
        case .monthly: "BEST VALUE"
        case .yearly: "Save 58%"
        case .lifetime: "Pay Once"
        }
    }

    var isBestValue: Bool {
        self == .monthly
    }
}

// MARK: - Subscription Service

@MainActor
@Observable
final class SubscriptionService {
    static let shared = SubscriptionService()

    var isPremium = false
    var currentOffering: Offering?
    var packages: [Package] = []
    var isLoading = false
    var errorMessage: String?

    private init() {}

    func configure() {
        Purchases.configure(
            with: .builder(withAPIKey: "test_sFENrwZfHzvrXkRADvKBeBUBpDx")
                .with(appUserID: nil)
                .build()
        )

        Task {
            await checkSubscriptionStatus()
            await loadOfferings()
        }
    }

    func checkSubscriptionStatus() async {
        do {
            let customerInfo = try await Purchases.shared.customerInfo()
            isPremium = !customerInfo.entitlements.active.isEmpty
        } catch {
            print("Error checking subscription: \(error.localizedDescription)")
        }
    }

    func loadOfferings() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let offerings = try await Purchases.shared.offerings()
            currentOffering = offerings.current
            packages = offerings.current?.availablePackages ?? []
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func purchase(package: Package) async -> Bool {
        isLoading = true
        defer { isLoading = false }

        do {
            let result = try await Purchases.shared.purchase(package: package)
            isPremium = !result.customerInfo.entitlements.active.isEmpty
            return isPremium
        } catch {
            if let purchaseError = error as? RevenueCat.ErrorCode {
                if purchaseError == .purchaseCancelledError {
                    return false
                }
            }
            errorMessage = error.localizedDescription
            return false
        }
    }

    func restorePurchases() async -> Bool {
        isLoading = true
        defer { isLoading = false }

        do {
            let customerInfo = try await Purchases.shared.restorePurchases()
            isPremium = !customerInfo.entitlements.active.isEmpty
            return isPremium
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
