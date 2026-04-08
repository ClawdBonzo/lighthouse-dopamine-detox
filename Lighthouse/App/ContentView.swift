import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @State private var hasCompletedOnboarding = false
    @State private var selectedTab: AppTab = .dashboard

    enum AppTab: String, CaseIterable {
        case dashboard = "Dashboard"
        case log = "Log"
        case quests = "Quests"
        case progress = "Progress"
        case settings = "Settings"

        /// Asset catalog image name (template-rendered)
        var assetIcon: String {
            switch self {
            case .dashboard: "Tab-Dashboard"
            case .log: "Tab-DailyLogger"
            case .quests: "Tab-Challenges"
            case .progress: "Tab-Progress"
            case .settings: "Tab-Settings"
            }
        }
    }

    @State private var engine = GamificationEngine.shared

    var body: some View {
        Group {
            if hasCompletedOnboarding || profiles.first?.hasCompletedOnboarding == true {
                ZStack {
                    mainTabView

                    // Level-up overlay
                    if engine.showLevelUp, let data = engine.levelUpData {
                        LevelUpOverlay(data: data) {
                            engine.showLevelUp = false
                        }
                        .transition(.opacity)
                        .zIndex(10)
                    }

                    // Badge unlock toast
                    if engine.showBadgeUnlock, let badge = engine.newBadge {
                        VStack {
                            BadgeToast(badge: badge)
                                .transition(.move(edge: .top).combined(with: .opacity))
                            Spacer()
                        }
                        .zIndex(9)
                        .animation(.spring(response: 0.4), value: engine.showBadgeUnlock)
                    }

                    // XP gain toast
                    if engine.showXPGain {
                        VStack {
                            Spacer()
                            HStack(spacing: 6) {
                                Image(systemName: "bolt.fill")
                                    .foregroundStyle(LHColor.gold)
                                    .font(.system(size: 12))
                                Text("+\(engine.recentXPGain) XP")
                                    .font(LHFont.headline(13))
                                    .foregroundStyle(LHColor.gold)
                            }
                            .padding(.horizontal, LHSpacing.md)
                            .padding(.vertical, 8)
                            .background(LHColor.surface)
                            .clipShape(Capsule())
                            .shadow(color: LHColor.gold.opacity(0.3), radius: 8)
                            .padding(.bottom, 90)
                        }
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .zIndex(8)
                        .animation(.spring(response: 0.3), value: engine.showXPGain)
                    }
                }
            } else {
                OnboardingContainerView(
                    viewModel: OnboardingViewModel(),
                    onComplete: {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            hasCompletedOnboarding = true
                        }
                    }
                )
            }
        }
        .onAppear {
            hasCompletedOnboarding = profiles.first?.hasCompletedOnboarding ?? false
        }
    }

    // MARK: - Main Tab View

    private var mainTabView: some View {
        TabView(selection: $selectedTab) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                tabContent(for: tab)
                    .tabItem {
                        Label {
                            Text(tab.rawValue)
                        } icon: {
                            Image(tab.assetIcon)
                                .renderingMode(.template)
                        }
                    }
                    .tag(tab)
            }
        }
        .tint(LHColor.teal)
        .onAppear {
            // Style the tab bar
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(LHColor.surface)

            appearance.stackedLayoutAppearance.normal.iconColor = UIColor(LHColor.textTertiary)
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
                .foregroundColor: UIColor(LHColor.textTertiary)
            ]
            appearance.stackedLayoutAppearance.selected.iconColor = UIColor(LHColor.teal)
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
                .foregroundColor: UIColor(LHColor.teal)
            ]

            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }

    @ViewBuilder
    private func tabContent(for tab: AppTab) -> some View {
        switch tab {
        case .dashboard:
            DashboardView()
        case .log:
            DailyLoggerView()
        case .quests:
            GamificationView()
        case .progress:
            ProgressChartsView()
        case .settings:
            SettingsView()
        }
    }
}
