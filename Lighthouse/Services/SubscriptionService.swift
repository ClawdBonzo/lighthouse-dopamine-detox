import Foundation
import RevenueCat

// MARK: - Subscription Plans

enum SubscriptionPlan: String, CaseIterable, Identifiable {
    case weekly = "com.clawdbonzo.lighthouse.weekly"
    case monthly = "com.clawdbonzo.lighthouse.monthly"
    case yearly = "com.clawdbonzo.lighthouse.yearly"
    case lifetime = "com.clawdbonzo.lighthouse.lifetime"

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
        case .weekly: "$4.99/week"
        case .monthly: "$8.99/month"
        case .yearly: "$49.99/year"
        case .lifetime: "$79.99 once"
        }
    }

    var pricePerMonth: String? {
        switch self {
        case .weekly: nil
        case .monthly: nil
        case .yearly: "~$4.17/month"
        case .lifetime: nil
        }
    }

    /// Plans that include a 3-day free trial
    var hasTrial: Bool {
        switch self {
        case .weekly: false
        case .monthly: true
        case .yearly: true
        case .lifetime: false
        }
    }

    var badgeText: String? {
        switch self {
        case .weekly: nil
        case .monthly: "BEST VALUE"
        case .yearly: "Save 54%"
        case .lifetime: "Pay Once"
        }
    }

    var isBestValue: Bool { self == .monthly }
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
        // ─────────────────────────────────────────────────────────────────────
        // RevenueCat API Key
        //
        // The RevenueCat project for Lighthouse has not yet been created in the
        // dashboard (app.revenuecat.com). Once the project is set up:
        //
        //   1. Go to app.revenuecat.com → Your Project → API Keys
        //   2. Copy the iOS Public Key  (format: appl_XXXXXXXXXXXXXXXXXXXX)
        //   3. Replace the placeholder below with that key
        //   4. Delete the #if DEBUG guard so the live key is always used
        //
        // The test key below ONLY works in sandbox — it will NOT process real
        // purchases in production. Do NOT ship with this key.
        // ─────────────────────────────────────────────────────────────────────
        #if DEBUG
        let rcKey = "test_AFpuFmRxwiYCSJV0rgzxFqKjZDa"
        #else
        let rcKey = "REPLACE_WITH_PRODUCTION_KEY_appl_XXXX" // <- swap before release
        #endif

        Purchases.configure(
            with: .builder(withAPIKey: rcKey)
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
            isPremium = customerInfo.entitlements["pro"]?.isActive == true
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
            isPremium = result.customerInfo.entitlements["pro"]?.isActive == true
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
            isPremium = customerInfo.entitlements["pro"]?.isActive == true
            return isPremium
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
