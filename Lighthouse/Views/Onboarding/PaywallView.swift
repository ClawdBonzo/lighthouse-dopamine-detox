import SwiftUI
import RevenueCat

struct PaywallView: View {
    @Bindable var viewModel: OnboardingViewModel
    var onContinue: () -> Void

    @State private var selectedPlan: SubscriptionPlan = .monthly
    @State private var showContent = false
    @State private var glowPulse = false
    private let subscriptionService = SubscriptionService.shared

    private var ctaTitle: String {
        switch selectedPlan {
        case .monthly, .yearly: return "Start 3-Day Free Trial"
        case .weekly: return "Subscribe Weekly"
        case .lifetime: return "Get Lifetime Access"
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // ── Compact Header ──────────────────────────────────────
            paywallHeader
                .padding(.top, LHSpacing.md)

            Spacer().frame(height: LHSpacing.md)

            // ── Plan Cards ──────────────────────────────────────────
            VStack(spacing: 8) {
                ForEach(SubscriptionPlan.allCases) { plan in
                    PaywallPlanCard(plan: plan, isSelected: selectedPlan == plan) {
                        withAnimation(.spring(response: 0.28, dampingFraction: 0.72)) {
                            selectedPlan = plan
                        }
                    }
                }
            }
            .padding(.horizontal, LHSpacing.md)

            Spacer()

            // ── CTA + Footer ────────────────────────────────────────
            VStack(spacing: 10) {
                // Main CTA
                Button {
                    Task {
                        let package = packageForSelectedPlan
                        if let package {
                            let success = await subscriptionService.purchase(package: package)
                            if success { onContinue() }
                        } else {
                            onContinue()
                        }
                    }
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: LHRadius.lg)
                            .fill(
                                LinearGradient(
                                    colors: [LHColor.teal, LHColor.tealDim],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .shadow(color: LHColor.teal.opacity(glowPulse ? 0.5 : 0.3), radius: glowPulse ? 16 : 10, y: 4)

                        if subscriptionService.isLoading {
                            ProgressView().tint(.white)
                        } else {
                            HStack(spacing: 8) {
                                Text(ctaTitle)
                                    .font(LHFont.headline(16))
                                    .foregroundStyle(.white)
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(.white.opacity(0.8))
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                }
                .disabled(subscriptionService.isLoading)

                // Legal note
                if selectedPlan.hasTrial {
                    Text("3-day free trial, then \(selectedPlan.price). Cancel anytime.")
                        .font(LHFont.caption(10))
                        .foregroundStyle(LHColor.textMuted)
                        .multilineTextAlignment(.center)
                } else {
                    Text("No trial · \(selectedPlan.price). Cancel anytime.")
                        .font(LHFont.caption(10))
                        .foregroundStyle(LHColor.textMuted)
                        .multilineTextAlignment(.center)
                }

                // Skip / Restore / Links row
                HStack(spacing: 16) {
                    Button("Skip") { onContinue() }
                        .font(LHFont.caption(12))
                        .foregroundStyle(LHColor.textTertiary)

                    Text("·").foregroundStyle(LHColor.textMuted)

                    Button("Restore") {
                        Task { let _ = await subscriptionService.restorePurchases() }
                    }
                    .font(LHFont.caption(12))
                    .foregroundStyle(LHColor.textTertiary)

                    Text("·").foregroundStyle(LHColor.textMuted)

                    Link("Terms", destination: URL(string: "https://clawdbonzo.com/terms")!)
                        .font(LHFont.caption(12))
                        .foregroundStyle(LHColor.textTertiary)

                    Text("·").foregroundStyle(LHColor.textMuted)

                    Link("Privacy", destination: URL(string: "https://clawdbonzo.com/privacy")!)
                        .font(LHFont.caption(12))
                        .foregroundStyle(LHColor.textTertiary)
                }
            }
            .padding(.horizontal, LHSpacing.lg)
            .padding(.bottom, LHSpacing.md)
        }
        .opacity(showContent ? 1 : 0)
        .onAppear {
            withAnimation(.easeOut(duration: 0.4)) { showContent = true }
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) { glowPulse = true }
            Task { await subscriptionService.loadOfferings() }
        }
    }

    // MARK: - Compact Header

    private var paywallHeader: some View {
        VStack(spacing: 6) {
            // Icon
            ZStack {
                Circle()
                    .fill(LHColor.teal.opacity(0.12))
                    .frame(width: 56, height: 56)
                Image("BrandIcon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 40)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }

            Text("Unlock Lighthouse Pro")
                .font(LHFont.display(22))
                .foregroundStyle(LHColor.textPrimary)

            // Feature pills
            HStack(spacing: 8) {
                featurePill("flame.fill", "Streaks")
                featurePill("brain.head.profile", "Focus")
                featurePill("chart.line.uptrend.xyaxis", "Progress")
            }
        }
    }

    private func featurePill(_ icon: String, _ label: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 10))
                .foregroundStyle(LHColor.teal)
            Text(label)
                .font(LHFont.caption(11))
                .foregroundStyle(LHColor.textSecondary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(LHColor.surface)
        .clipShape(Capsule())
        .overlay(Capsule().stroke(Color.white.opacity(0.07), lineWidth: 1))
    }

    // MARK: - RevenueCat Package Matching

    private var packageForSelectedPlan: Package? {
        let packages = subscriptionService.packages
        switch selectedPlan {
        case .weekly:   return packages.first { $0.packageType == .weekly }
        case .monthly:  return packages.first { $0.packageType == .monthly }
        case .yearly:   return packages.first { $0.packageType == .annual }
        case .lifetime: return packages.first { $0.packageType == .lifetime }
        }
    }
}

// MARK: - Plan Card

struct PaywallPlanCard: View {
    let plan: SubscriptionPlan
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Radio button
                ZStack {
                    Circle()
                        .stroke(
                            isSelected
                                ? (plan.isBestValue ? LHColor.gold : LHColor.teal)
                                : Color.white.opacity(0.2),
                            lineWidth: 2
                        )
                        .frame(width: 20, height: 20)
                    if isSelected {
                        Circle()
                            .fill(plan.isBestValue ? LHColor.gold : LHColor.teal)
                            .frame(width: 11, height: 11)
                    }
                }

                // Plan info
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(plan.displayName)
                            .font(LHFont.headline(15))
                            .foregroundStyle(LHColor.textPrimary)

                        if let badge = plan.badgeText {
                            Text(badge)
                                .font(.system(size: 9, weight: .bold, design: .rounded))
                                .foregroundStyle(plan.isBestValue ? LHColor.background : LHColor.teal)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(plan.isBestValue ? LHColor.gold : LHColor.teal.opacity(0.2))
                                .clipShape(Capsule())
                        }
                    }

                    HStack(spacing: 6) {
                        Text(plan.price)
                            .font(LHFont.body(13))
                            .foregroundStyle(LHColor.textSecondary)

                        if let perMonth = plan.pricePerMonth {
                            Text("·")
                                .foregroundStyle(LHColor.textMuted)
                            Text(perMonth)
                                .font(LHFont.caption(11))
                                .foregroundStyle(LHColor.textTertiary)
                        }
                    }
                }

                Spacer()

                // Trial badge
                if plan.hasTrial {
                    Text("3-day trial")
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundStyle(LHColor.gold)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(LHColor.gold.opacity(0.12))
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(LHColor.gold.opacity(0.3), lineWidth: 1))
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background {
                if plan.isBestValue && isSelected {
                    RoundedRectangle(cornerRadius: LHRadius.md)
                        .fill(LHColor.gold.opacity(0.07))
                } else if isSelected {
                    RoundedRectangle(cornerRadius: LHRadius.md)
                        .fill(LHColor.teal.opacity(0.07))
                } else {
                    RoundedRectangle(cornerRadius: LHRadius.md)
                        .fill(LHColor.surface)
                }
            }
            .overlay {
                RoundedRectangle(cornerRadius: LHRadius.md)
                    .stroke(
                        isSelected
                            ? (plan.isBestValue ? LHColor.gold.opacity(0.6) : LHColor.teal.opacity(0.5))
                            : Color.white.opacity(0.06),
                        lineWidth: isSelected ? 1.5 : 1
                    )
            }
        }
        .buttonStyle(.plain)
    }
}
