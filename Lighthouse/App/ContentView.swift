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
        case streak = "Challenges"
        case progress = "Progress"
        case settings = "Settings"

        /// Asset catalog image name (template-rendered)
        var assetIcon: String {
            switch self {
            case .dashboard: "Tab-Dashboard"
            case .log: "Tab-DailyLogger"
            case .streak: "Tab-Challenges"
            case .progress: "Tab-Progress"
            case .settings: "Tab-Settings"
            }
        }
    }

    var body: some View {
        Group {
            if hasCompletedOnboarding || profiles.first?.hasCompletedOnboarding == true {
                mainTabView
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
        case .streak:
            StreakCalendarView()
        case .progress:
            ProgressChartsView()
        case .settings:
            SettingsView()
        }
    }
}
