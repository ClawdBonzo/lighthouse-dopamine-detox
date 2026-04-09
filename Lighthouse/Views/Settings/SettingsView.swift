import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @State private var showDeleteConfirmation = false
    @State private var showExportSheet = false

    private var profile: UserProfile? { profiles.first }
    private let subscriptionService = SubscriptionService.shared

    var body: some View {
        NavigationStack {
            ZStack {
                LighthouseParticleBackground().ignoresSafeArea()
                ScrollView {
                VStack(spacing: LHSpacing.lg) {
                    // Profile section
                    profileSection

                    // Subscription
                    subscriptionSection

                    // Preferences
                    preferencesSection

                    // Data & Privacy
                    dataSection

                    // About
                    aboutSection

                    Spacer().frame(height: LHSpacing.xxl)
                }
                .padding(.horizontal, LHSpacing.lg)
                .padding(.top, LHSpacing.md)
            }
            .scrollIndicators(.hidden)
            } // ZStack
            .background(LHColor.background)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .alert("Reset All Data?", isPresented: $showDeleteConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Reset", role: .destructive) {
                    resetAllData()
                }
            } message: {
                Text("This will permanently delete all your progress, streaks, and logs. This cannot be undone.")
            }
        }
    }

    // MARK: - Profile

    private var profileSection: some View {
        VStack(spacing: LHSpacing.md) {
            HStack(spacing: LHSpacing.md) {
                Image("BrandIcon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 56, height: 56)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .shadow(color: LHColor.teal.opacity(0.2), radius: 8)

                VStack(alignment: .leading, spacing: 4) {
                    Text(profile?.displayName ?? "User")
                        .font(LHFont.headline(18))
                        .foregroundStyle(LHColor.textPrimary)

                    let joinDate = profile?.createdAt ?? Date()
                    Text("Member since \(joinDate.formatted(.dateTime.month(.wide).year()))")
                        .font(LHFont.caption(13))
                        .foregroundStyle(LHColor.textTertiary)
                }

                Spacer()
            }

            // Stats summary
            HStack(spacing: LHSpacing.md) {
                miniStat("Streak", "\(profile?.currentStreak ?? 0)", LHColor.streak)
                miniStat("Days", "\(profile?.totalDetoxDays ?? 0)", LHColor.teal)
                miniStat("Focus", "\(formatMinutes(profile?.totalFocusMinutes ?? 0))", LHColor.gold)
            }
        }
        .lhCard()
    }

    // MARK: - Subscription

    private var subscriptionSection: some View {
        VStack(alignment: .leading, spacing: LHSpacing.md) {
            settingSectionHeader("Subscription")

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(subscriptionService.isPremium ? "Premium Active" : "Free Plan")
                        .font(LHFont.headline(15))
                        .foregroundStyle(LHColor.textPrimary)
                    Text(subscriptionService.isPremium ? "All features unlocked" : "Upgrade for full access")
                        .font(LHFont.caption(13))
                        .foregroundStyle(LHColor.textTertiary)
                }

                Spacer()

                if subscriptionService.isPremium {
                    Image(systemName: "crown.fill")
                        .foregroundStyle(LHColor.gold)
                        .font(.system(size: 22))
                } else {
                    Button("Upgrade") {
                        // Show paywall
                    }
                    .font(LHFont.headline(14))
                    .foregroundStyle(LHColor.background)
                    .padding(.horizontal, LHSpacing.md)
                    .padding(.vertical, LHSpacing.sm)
                    .background(LHColor.teal)
                    .clipShape(Capsule())
                }
            }
            .padding(LHSpacing.md)
            .background(LHColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: LHRadius.md))

            Button("Restore Purchases") {
                Task {
                    let _ = await subscriptionService.restorePurchases()
                }
            }
            .font(LHFont.caption(13))
            .foregroundStyle(LHColor.teal)
        }
    }

    // MARK: - Preferences

    private var preferencesSection: some View {
        VStack(alignment: .leading, spacing: LHSpacing.md) {
            settingSectionHeader("Preferences")

            // Notifications toggle
            settingRow(
                icon: "bell.fill",
                title: "Daily Reminders",
                subtitle: profile?.notificationsEnabled == true ? "On" : "Off"
            ) {
                Toggle("", isOn: Binding(
                    get: { profile?.notificationsEnabled ?? false },
                    set: { profile?.notificationsEnabled = $0; try? modelContext.save() }
                ))
                .tint(LHColor.teal)
            }

            // Commitment
            settingRow(
                icon: "clock.fill",
                title: "Daily Commitment",
                subtitle: "\(profile?.dailyCommitmentMinutes ?? 30) minutes"
            ) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundStyle(LHColor.textMuted)
            }
        }
    }

    // MARK: - Data

    private var dataSection: some View {
        VStack(alignment: .leading, spacing: LHSpacing.md) {
            settingSectionHeader("Data & Privacy")

            Button {
                showExportSheet = true
            } label: {
                settingRowContent(icon: "square.and.arrow.up", title: "Export Report (PDF)", subtitle: "Share your progress")
            }

            Button {
                showDeleteConfirmation = true
            } label: {
                HStack(spacing: LHSpacing.md) {
                    Image(systemName: "trash.fill")
                        .foregroundStyle(LHColor.danger)
                        .frame(width: 32)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Reset All Data")
                            .font(LHFont.headline(14))
                            .foregroundStyle(LHColor.danger)
                        Text("Permanently delete all progress")
                            .font(LHFont.caption(12))
                            .foregroundStyle(LHColor.textTertiary)
                    }
                    Spacer()
                }
                .padding(LHSpacing.md)
                .background(LHColor.surface)
                .clipShape(RoundedRectangle(cornerRadius: LHRadius.md))
            }

            // Privacy note
            HStack(spacing: LHSpacing.sm) {
                Image(systemName: "lock.shield.fill")
                    .foregroundStyle(LHColor.teal)
                    .font(.system(size: 14))
                Text("All your data stays on this device. Nothing is sent to any server.")
                    .font(LHFont.caption(12))
                    .foregroundStyle(LHColor.textTertiary)
            }
            .padding(.top, LHSpacing.sm)
        }
    }

    // MARK: - About

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: LHSpacing.md) {
            settingSectionHeader("About")

            settingRowContent(icon: "info.circle", title: "Version", subtitle: "1.0.0")
            settingRowContent(icon: "applewatch", title: "Apple Watch", subtitle: "Coming soon")

            HStack(spacing: LHSpacing.md) {
                Link("Terms of Service", destination: URL(string: "https://example.com/terms")!)
                Text("·").foregroundStyle(LHColor.textMuted)
                Link("Privacy Policy", destination: URL(string: "https://example.com/privacy")!)
            }
            .font(LHFont.caption(13))
            .foregroundStyle(LHColor.textTertiary)
        }
    }

    // MARK: - Components

    private func settingSectionHeader(_ title: String) -> some View {
        Text(title)
            .font(LHFont.headline(16))
            .foregroundStyle(LHColor.textSecondary)
    }

    private func settingRow<Trailing: View>(icon: String, title: String, subtitle: String, @ViewBuilder trailing: () -> Trailing) -> some View {
        HStack(spacing: LHSpacing.md) {
            Image(systemName: icon)
                .foregroundStyle(LHColor.teal)
                .frame(width: 32)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(LHFont.headline(14))
                    .foregroundStyle(LHColor.textPrimary)
                Text(subtitle)
                    .font(LHFont.caption(12))
                    .foregroundStyle(LHColor.textTertiary)
            }
            Spacer()
            trailing()
        }
        .padding(LHSpacing.md)
        .background(LHColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: LHRadius.md))
    }

    private func settingRowContent(icon: String, title: String, subtitle: String) -> some View {
        HStack(spacing: LHSpacing.md) {
            Image(systemName: icon)
                .foregroundStyle(LHColor.teal)
                .frame(width: 32)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(LHFont.headline(14))
                    .foregroundStyle(LHColor.textPrimary)
                Text(subtitle)
                    .font(LHFont.caption(12))
                    .foregroundStyle(LHColor.textTertiary)
            }
            Spacer()
        }
        .padding(LHSpacing.md)
        .background(LHColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: LHRadius.md))
    }

    private func miniStat(_ label: String, _ value: String, _ color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(LHFont.headline(16))
                .foregroundStyle(color)
            Text(label)
                .font(LHFont.caption(11))
                .foregroundStyle(LHColor.textTertiary)
        }
        .frame(maxWidth: .infinity)
    }

    private func formatMinutes(_ minutes: Int) -> String {
        if minutes >= 60 {
            return "\(minutes / 60)h"
        }
        return "\(minutes)m"
    }

    private func resetAllData() {
        try? modelContext.delete(model: DailyLog.self)
        try? modelContext.delete(model: DetoxChallenge.self)
        try? modelContext.delete(model: FocusSession.self)
        try? modelContext.delete(model: ScreenTimeLog.self)
        try? modelContext.delete(model: FocusPreset.self)
        try? modelContext.delete(model: UserProfile.self)
        try? modelContext.save()
    }
}
