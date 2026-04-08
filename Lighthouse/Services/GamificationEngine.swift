import Foundation
import SwiftData
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

// MARK: - Level Up Data

struct LevelUpData {
    let newLevel: LevelDefinition
    let previousLevel: LevelDefinition
}

// MARK: - Gamification Engine

@MainActor
@Observable
final class GamificationEngine {
    static let shared = GamificationEngine()

    var showLevelUp = false
    var levelUpData: LevelUpData?
    var showBadgeUnlock = false
    var newBadge: BadgeDefinition?
    var recentXPGain: Int = 0
    var showXPGain = false

    private init() {}

    // MARK: - Streak Helpers

    func streakMultiplier(for streak: Int) -> Double {
        switch streak {
        case 0..<3: return 1.0
        case 3..<7: return 1.5
        case 7..<14: return 2.0
        default: return 3.0
        }
    }

    func streakFlameColor(for streak: Int) -> Color {
        switch streak {
        case 0..<3: return .orange
        case 3..<7: return Color(red: 1, green: 0.82, blue: 0.4)
        case 7..<14: return Color(red: 0, green: 0.83, blue: 0.67)
        default: return Color(red: 0.6, green: 0.4, blue: 1.0)
        }
    }

    // MARK: - XP Awarding

    func awardXP(_ base: Int, source: String, profile: UserProfile, context: ModelContext) {
        let multiplier = streakMultiplier(for: profile.currentStreak)
        let finalXP = Int(Double(base) * multiplier)

        let previousLevel = LevelDefinition.current(for: profile.xp)
        profile.xp += finalXP
        profile.totalXPEarned += finalXP

        let record = XPRecord(amount: finalXP, source: source)
        context.insert(record)

        // Show XP gain
        recentXPGain = finalXP
        showXPGain = true
        hapticXPGain()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.showXPGain = false
        }

        // Check level up
        let newLevel = LevelDefinition.current(for: profile.xp)
        if newLevel.level > previousLevel.level {
            levelUpData = LevelUpData(newLevel: newLevel, previousLevel: previousLevel)
            showLevelUp = true
            hapticLevelUp()
            checkAndUnlock("level_\(newLevel.level)", profile: profile, context: context)
        }

        // Check XP milestone badge
        if profile.totalXPEarned >= 500 {
            checkAndUnlock("xp_500", profile: profile, context: context)
        }

        try? context.save()
    }

    // MARK: - Specific Award Helpers

    func awardChallengeXP(difficulty: String, profile: UserProfile, context: ModelContext) {
        let base: Int
        switch difficulty.lowercased() {
        case "easy": base = 15
        case "medium": base = 25
        case "hard": base = 40
        default: base = 20
        }
        awardXP(base, source: "challenge", profile: profile, context: context)
        progressQuests(metric: .challengesCompleted, by: 1, profile: profile, context: context)

        profile.totalChallengesCompleted += 1

        // Challenge badges
        if profile.totalChallengesCompleted == 1 {
            checkAndUnlock("challenge_first", profile: profile, context: context)
        } else if profile.totalChallengesCompleted == 10 {
            checkAndUnlock("challenge_10", profile: profile, context: context)
        } else if profile.totalChallengesCompleted == 50 {
            checkAndUnlock("challenge_50", profile: profile, context: context)
        }

        try? context.save()
    }

    func awardFocusXP(minutes: Int, profile: UserProfile, context: ModelContext) {
        let base = 20 + minutes
        awardXP(base, source: "focus", profile: profile, context: context)
        progressQuests(metric: .focusMinutes, by: minutes, profile: profile, context: context)

        // First focus badge
        if profile.totalFocusMinutes <= minutes {
            checkAndUnlock("focus_first", profile: profile, context: context)
        }

        // Deep focus badge (45+ min session)
        if minutes >= 45 {
            checkAndUnlock("focus_deep", profile: profile, context: context)
        }

        // Early bird badge (before 8am)
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 8 {
            checkAndUnlock("focus_early_bird", profile: profile, context: context)
        }

        // 10 hours total badge
        if profile.totalFocusMinutes >= 600 {
            checkAndUnlock("focus_10hrs", profile: profile, context: context)
        }
    }

    func awardMoodLogXP(profile: UserProfile, context: ModelContext) {
        awardXP(5, source: "mood_log", profile: profile, context: context)
        progressQuests(metric: .moodLogged, by: 1, profile: profile, context: context)
    }

    func awardStreakBonus(profile: UserProfile, context: ModelContext) {
        let bonus = profile.currentStreak * 2
        awardXP(bonus, source: "streak_bonus", profile: profile, context: context)
        progressQuests(metric: .streakMaintained, by: 1, profile: profile, context: context)

        // Streak badges
        switch profile.currentStreak {
        case 3: checkAndUnlock("streak_3", profile: profile, context: context)
        case 7: checkAndUnlock("streak_7", profile: profile, context: context)
        case 14: checkAndUnlock("streak_14", profile: profile, context: context)
        case 30: checkAndUnlock("streak_30", profile: profile, context: context)
        default: break
        }

        if [3, 7, 14, 30].contains(profile.currentStreak) {
            hapticStreakMilestone()
        }
    }

    // MARK: - Quest Management

    func ensureQuestsExist(context: ModelContext) {
        let today = Calendar.current.startOfDay(for: .now)

        // Check daily quests
        let dailyDescriptor = FetchDescriptor<Quest>(
            predicate: #Predicate { $0.questTypeRaw == "daily" && $0.assignedDate >= today }
        )
        let existingDaily = (try? context.fetch(dailyDescriptor)) ?? []

        if existingDaily.isEmpty {
            let defs = QuestDefinition.dailyQuests(for: today)
            for def in defs {
                let quest = Quest(definition: def, assignedDate: today)
                context.insert(quest)
            }
        }

        // Check weekly quests
        let weekStart = Calendar.current.dateInterval(of: .weekOfYear, for: .now)?.start ?? today
        let weeklyDescriptor = FetchDescriptor<Quest>(
            predicate: #Predicate { $0.questTypeRaw == "weekly" && $0.assignedDate >= weekStart }
        )
        let existingWeekly = (try? context.fetch(weeklyDescriptor)) ?? []

        if existingWeekly.isEmpty {
            let defs = QuestDefinition.weeklyQuests(for: today)
            for def in defs {
                let quest = Quest(definition: def, assignedDate: weekStart)
                context.insert(quest)
            }
        }

        try? context.save()
    }

    func progressQuests(metric: QuestMetric, by amount: Int, profile: UserProfile, context: ModelContext) {
        let now = Date()
        let activeDescriptor = FetchDescriptor<Quest>(
            predicate: #Predicate { !$0.isCompleted }
        )
        let activeQuests = (try? context.fetch(activeDescriptor)) ?? []

        for quest in activeQuests where !quest.isExpired && quest.metric == metric {
            quest.currentCount = min(quest.targetCount, quest.currentCount + amount)

            if quest.currentCount >= quest.targetCount && !quest.isCompleted {
                quest.isCompleted = true
                quest.completedAt = now
                profile.questsCompleted += 1
                awardXP(quest.xpReward, source: "quest_\(quest.questID)", profile: profile, context: context)
                hapticQuestComplete()

                // Quest badges
                if profile.questsCompleted == 1 {
                    checkAndUnlock("quest_first", profile: profile, context: context)
                } else if profile.questsCompleted == 10 {
                    checkAndUnlock("quest_10", profile: profile, context: context)
                }
            }
        }

        // Track XP-based quest progress separately
        if metric == .xpEarned {
            // Already handled via direct xp updates — skip to avoid double count
        }

        try? context.save()
    }

    // MARK: - Badge Management

    func checkAndUnlock(_ badgeID: String, profile: UserProfile, context: ModelContext) {
        // Check if already earned
        let descriptor = FetchDescriptor<Badge>(
            predicate: #Predicate { $0.badgeID == badgeID }
        )
        let existing = (try? context.fetch(descriptor)) ?? []
        guard existing.isEmpty else { return }

        guard let definition = BadgeDefinition.badge(id: badgeID) else { return }
        unlockBadge(definition, profile: profile, context: context)
    }

    private func unlockBadge(_ definition: BadgeDefinition, profile: UserProfile, context: ModelContext) {
        let badge = Badge(badgeID: definition.id)
        context.insert(badge)

        // Award XP without recursion — direct update, no badge checks
        let record = XPRecord(amount: definition.xpReward, source: "badge_\(definition.id)")
        profile.xp += definition.xpReward
        profile.totalXPEarned += definition.xpReward
        context.insert(record)

        newBadge = definition
        showBadgeUnlock = true
        hapticBadgeUnlock()

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.showBadgeUnlock = false
        }

        try? context.save()
    }

    // MARK: - Haptics

    func hapticLevelUp() {
        let heavy = UIImpactFeedbackGenerator(style: .heavy)
        heavy.impactOccurred()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            heavy.impactOccurred()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
    }

    func hapticQuestComplete() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
    }

    func hapticBadgeUnlock() {
        let rigid = UIImpactFeedbackGenerator(style: .rigid)
        rigid.impactOccurred()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            rigid.impactOccurred()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
    }

    func hapticStreakMilestone() {
        let heavy = UIImpactFeedbackGenerator(style: .heavy)
        heavy.impactOccurred()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { heavy.impactOccurred() }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { heavy.impactOccurred() }
    }

    func hapticXPGain() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
}
