import Foundation
import SwiftData

@Model
final class UserProfile {
    var id: UUID
    var displayName: String
    var createdAt: Date

    // Onboarding quiz answers
    var dailyScreenTimeHours: Double
    var doomscrollFrequency: String   // "rarely", "sometimes", "often", "constantly"
    var hijackingApps: [String]
    var dailyCommitmentMinutes: Int

    // Subscription
    var isPremium: Bool
    var subscriptionTier: String?     // "weekly", "monthly", "yearly", "lifetime"

    // Streak tracking
    var currentStreak: Int
    var longestStreak: Int
    var lastActiveDate: Date?
    var totalDetoxDays: Int
    var totalFocusMinutes: Int

    // Settings
    var notificationsEnabled: Bool
    var dailyReminderTime: Date?
    var hasCompletedOnboarding: Bool

    init(
        displayName: String = "",
        dailyScreenTimeHours: Double = 4.0,
        doomscrollFrequency: String = "sometimes",
        hijackingApps: [String] = [],
        dailyCommitmentMinutes: Int = 30
    ) {
        self.id = UUID()
        self.displayName = displayName
        self.createdAt = Date()
        self.dailyScreenTimeHours = dailyScreenTimeHours
        self.doomscrollFrequency = doomscrollFrequency
        self.hijackingApps = hijackingApps
        self.dailyCommitmentMinutes = dailyCommitmentMinutes
        self.isPremium = false
        self.subscriptionTier = nil
        self.currentStreak = 0
        self.longestStreak = 0
        self.lastActiveDate = nil
        self.totalDetoxDays = 0
        self.totalFocusMinutes = 0
        self.notificationsEnabled = true
        self.dailyReminderTime = nil
        self.hasCompletedOnboarding = false
    }

    func updateStreak(for date: Date = .now) {
        let calendar = Calendar.current

        if let lastActive = lastActiveDate {
            let daysBetween = calendar.dateComponents([.day], from: calendar.startOfDay(for: lastActive), to: calendar.startOfDay(for: date)).day ?? 0

            if daysBetween == 1 {
                currentStreak += 1
            } else if daysBetween > 1 {
                currentStreak = 1
            }
        } else {
            currentStreak = 1
        }

        longestStreak = max(longestStreak, currentStreak)
        lastActiveDate = date
        totalDetoxDays += 1
    }
}
