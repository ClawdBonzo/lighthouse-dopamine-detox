import SwiftUI

struct PaywallView: View {
    @Bindable var viewModel: OnboardingViewModel
    var onContinue: () -> Void

    @State private var selectedPlan: SubscriptionPlan = .monthly
    @State private var showContent = false
    private let subscriptionService = SubscriptionService.shared

    var body: some View {
        ScrollView {
            VStack(spacing: LHSpacing.lg) {
                Spacer().frame(height: LHSpacing.md)

                // Before/After transformation teaser
                VStack(spacing: LHSpacing.md) {
                    Text("Your Focus\nTransformation Awaits")
                        .font(LHFont.display(28))
                        .foregroundStyle(LHColor.textPrimary)
                        .multilineTextAlignment(.center)

                    // Before/After comparison
                    HStack(spacing: LHSpacing.md) {
                        // Before
                        VStack(spacing: LHSpacing.sm) {
                            Text("BEFORE")
                                .font(LHFont.caption(11))
                                .foregroundStyle(LHColor.streak)

                            VStack(spacing: 6) {
                                statRow("Screen Time", "\(Int(viewModel.dailyScreenTime))h+")
                                statRow("Focus", "Scattered")
                                statRow("Energy", "Drained")
                            }
                        }
                        .padding(LHSpacing.md)
                        .frame(maxWidth: .infinity)
                        .background(LHColor.streak.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: LHRadius.md))
                        .overlay(
                            RoundedRectangle(cornerRadius: LHRadius.md)
                                .stroke(LHColor.streak.opacity(0.2), lineWidth: 1)
                        )

                        Image(systemName: "arrow.right")
                            .foregroundStyle(LHColor.teal)
                            .font(.system(size: 20, weight: .bold))

                        // After
                        VStack(spacing: LHSpacing.sm) {
                            Text("AFTER 30 DAYS")
                                .font(LHFont.caption(11))
                                .foregroundStyle(LHColor.teal)

                            VStack(spacing: 6) {
                                statRow("Screen Time", "-40%")
                                statRow("Focus", "Laser sharp")
                                statRow("Energy", "Restored")
                            }
                        }
                        .padding(LHSpacing.md)
                        .frame(maxWidth: .infinity)
                        .background(LHColor.teal.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: LHRadius.md))
                        .overlay(
                            RoundedRectangle(cornerRadius: LHRadius.md)
                                .stroke(LHColor.teal.opacity(0.3), lineWidth: 1)
                        )
                    }
                    .padding(.horizontal, LHSpacing.lg)
                }

                // Free trial badge
                HStack(spacing: LHSpacing.sm) {
                    Image(systemName: "gift.fill")
                        .foregroundStyle(LHColor.gold)
                    Text("Start with 3-day FREE trial")
                        .font(LHFont.headline(15))
                        .foregroundStyle(LHColor.gold)
                }
                .padding(.horizontal, LHSpacing.lg)
                .padding(.vertical, LHSpacing.sm)
                .background(LHColor.gold.opacity(0.12))
                .clipShape(Capsule())

                // Plan options
                VStack(spacing: LHSpacing.sm) {
                    ForEach(SubscriptionPlan.allCases) { plan in
                        PlanCard(
                            plan: plan,
                            isSelected: selectedPlan == plan
                        ) {
                            withAnimation(.spring(response: 0.3)) {
                                selectedPlan = plan
                            }
                        }
                    }
                }
                .padding(.horizontal, LHSpacing.lg)

                // Premium features
                VStack(alignment: .leading, spacing: LHSpacing.md) {
                    Text("Everything you get:")
                        .font(LHFont.headline(16))
                        .foregroundStyle(LHColor.textSecondary)

                    featureRow("Unlimited daily challenges")
                    featureRow("Advanced progress analytics")
                    featureRow("Custom focus presets")
                    featureRow("PDF progress reports")
                    featureRow("Home screen widgets")
                    featureRow("Priority support")
                }
                .padding(.horizontal, LHSpacing.lg)

                // CTA
                GlowButton(title: "Start Free Trial", icon: "arrow.right") {
                    Task {
                        if let package = subscriptionService.packages.first {
                            let _ = await subscriptionService.purchase(package: package)
                        }
                        onContinue()
                    }
                }
                .padding(.horizontal, LHSpacing.lg)

                // Skip + Restore
                VStack(spacing: LHSpacing.md) {
                    Button("Continue with limited access") {
                        onContinue()
                    }
                    .font(LHFont.caption(14))
                    .foregroundStyle(LHColor.textTertiary)

                    Button("Restore Purchases") {
                        Task {
                            let _ = await subscriptionService.restorePurchases()
                        }
                    }
                    .font(LHFont.caption(13))
                    .foregroundStyle(LHColor.textMuted)

                    // Legal
                    Text("Cancel anytime. Recurring billing after trial.")
                        .font(LHFont.caption(11))
                        .foregroundStyle(LHColor.textMuted)
                        .multilineTextAlignment(.center)

                    HStack(spacing: LHSpacing.md) {
                        Link("Terms", destination: URL(string: "https://example.com/terms")!)
                        Text("·").foregroundStyle(LHColor.textMuted)
                        Link("Privacy", destination: URL(string: "https://example.com/privacy")!)
                    }
                    .font(LHFont.caption(11))
                    .foregroundStyle(LHColor.textMuted)
                }

                Spacer().frame(height: LHSpacing.lg)
            }
        }
        .scrollIndicators(.hidden)
        .opacity(showContent ? 1 : 0)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                showContent = true
            }
        }
    }

    private func statRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .font(LHFont.caption(12))
                .foregroundStyle(LHColor.textTertiary)
            Spacer()
            Text(value)
                .font(LHFont.caption(12))
                .foregroundStyle(LHColor.textPrimary)
        }
    }

    private func featureRow(_ text: String) -> some View {
        HStack(spacing: LHSpacing.sm) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(LHColor.teal)
                .font(.system(size: 16))
            Text(text)
                .font(LHFont.body(14))
                .foregroundStyle(LHColor.textSecondary)
        }
    }
}

// MARK: - Plan Card

struct PlanCard: View {
    let plan: SubscriptionPlan
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: LHSpacing.sm) {
                        Text(plan.displayName)
                            .font(LHFont.headline(16))
                            .foregroundStyle(LHColor.textPrimary)

                        if let savings = plan.savings {
                            Text(savings)
                                .font(LHFont.caption(10))
                                .foregroundStyle(plan.isBestValue ? LHColor.background : LHColor.teal)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(plan.isBestValue ? LHColor.teal : LHColor.teal.opacity(0.15))
                                .clipShape(Capsule())
                        }
                    }

                    Text(plan.price)
                        .font(LHFont.body(14))
                        .foregroundStyle(LHColor.textSecondary)
                }

                Spacer()

                ZStack {
                    Circle()
                        .stroke(isSelected ? LHColor.teal : LHColor.textMuted, lineWidth: 2)
                        .frame(width: 24, height: 24)

                    if isSelected {
                        Circle()
                            .fill(LHColor.teal)
                            .frame(width: 14, height: 14)
                    }
                }
            }
            .padding(LHSpacing.md)
            .background(isSelected ? LHColor.teal.opacity(0.08) : LHColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: LHRadius.md))
            .overlay(
                RoundedRectangle(cornerRadius: LHRadius.md)
                    .stroke(isSelected ? LHColor.teal.opacity(0.5) : Color.white.opacity(0.06), lineWidth: isSelected ? 2 : 1)
            )
        }
    }
}
