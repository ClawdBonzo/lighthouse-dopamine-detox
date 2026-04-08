import Foundation
import SwiftData
import SwiftUI

// MARK: - Level Definitions

struct LevelDefinition {
    let level: Int
    let name: String
    let subtitle: String
    let icon: String
    let xpRequired: Int
    let color: Color
    let beamOpacity: Double

    static let all: [LevelDefinition] = [
        LevelDefinition(level: 1, name: "Foggy", subtitle: "The detox begins", icon: "cloud.fog.fill", xpRequired: 0, color: .gray, beamOpacity: 0.1),
        LevelDefinition(level: 2, name: "Hazy", subtitle: "Clarity emerging", icon: "cloud.fill", xpRequired: 150, color: Color(red: 0.5, green: 0.6, blue: 0.7), beamOpacity: 0.25),
        LevelDefinition(level: 3, name: "Clearing", subtitle: "The mist lifts", icon: "sun.haze.fill", xpRequired: 400, color: Color(red: 0.6, green: 0.8, blue: 0.7), beamOpacity: 0.45),
        LevelDefinition(level: 4, name: "Illuminated", subtitle: "Sharp and present", icon: "sun.max.fill", xpRequired: 800, color: Color(red: 0, green: 0.83, blue: 0.67), beamOpacity: 0.65),
        LevelDefinition(level: 5, name: "Keeper of Light", subtitle: "Guiding others", icon: "light.beacon.max.fill", xpRequired: 1500, color: Color(red: 1, green: 0.82, blue: 0.4), beamOpacity: 0.85),
        LevelDefinition(level: 6, name: "Crystal Clear", subtitle: "Complete mastery", icon: "sparkles", xpRequired: 2500, color: Color(red: 1, green: 0.92, blue: 0.6), beamOpacity: 1.0),
    ]

    static func current(for xp: Int) -> LevelDefinition {
        all.last(where: { xp >= $0.xpRequired }) ?? all[0]
    }

    static func next(for xp: Int) -> LevelDefinition? {
        all.first(where: { xp < $0.xpRequired })
    }

    static func progressToNext(for xp: Int) -> Double {
        let current = current(for: xp)
        guard let next = next(for: xp) else { return 1.0 }
        let range = next.xpRequired - current.xpRequired
        let progress = xp - current.xpRequired
        return Double(progress) / Double(range)
    }
}

// MARK: - Badge Rarity

enum BadgeRarity: String, Codable {
    case common, rare, epic, legendary

    var color: Color {
        switch self {
        case .common: .gray
        case .rare: Color(red: 0, green: 0.83, blue: 0.67) // teal
        case .epic: Color(red: 0.6, green: 0.4, blue: 1.0) // purple
        case .legendary: Color(red: 1, green: 0.82, blue: 0.4) // gold
        }
    }

    var label: String { rawValue.capitalized }
}

// MARK: - Badge Definitions

struct BadgeDefinition {
    let id: String
    let name: String
    let description: String
    let icon: String
    let iconColor: Color
    let xpReward: Int
    let category: String
    let rarity: BadgeRarity

    static let all: [BadgeDefinition] = [
        // Streak badges
        BadgeDefinition(id: "streak_3", name: "First Flame", description: "3-day streak", icon: "flame.fill", iconColor: .orange, xpReward: 25, category: "streak", rarity: .common),
        BadgeDefinition(id: "streak_7", name: "Week Warrior", description: "7-day streak", icon: "flame.fill", iconColor: Color(red: 1, green: 0.5, blue: 0), xpReward: 75, category: "streak", rarity: .rare),
        BadgeDefinition(id: "streak_14", name: "Fortnight Focus", description: "14-day streak", icon: "flame.fill", iconColor: Color(red: 0, green: 0.83, blue: 0.67), xpReward: 150, category: "streak", rarity: .epic),
        BadgeDefinition(id: "streak_30", name: "Month Master", description: "30-day streak", icon: "flame.fill", iconColor: Color(red: 1, green: 0.82, blue: 0.4), xpReward: 400, category: "streak", rarity: .legendary),
        // Focus badges
        BadgeDefinition(id: "focus_first", name: "First Focus", description: "Complete a focus session", icon: "brain.head.profile", iconColor: Color(red: 0, green: 0.83, blue: 0.67), xpReward: 20, category: "focus", rarity: .common),
        BadgeDefinition(id: "focus_deep", name: "Deep Dive", description: "Complete a 45+ min focus session", icon: "waveform.path.ecg", iconColor: Color(red: 0.4, green: 0.7, blue: 1.0), xpReward: 50, category: "focus", rarity: .rare),
        BadgeDefinition(id: "focus_early_bird", name: "Early Bird", description: "Focus session before 8am", icon: "sunrise.fill", iconColor: Color(red: 1, green: 0.7, blue: 0.3), xpReward: 40, category: "focus", rarity: .rare),
        BadgeDefinition(id: "focus_10hrs", name: "Time Alchemist", description: "10 total hours of focus", icon: "hourglass.bottomhalf.filled", iconColor: Color(red: 0.6, green: 0.4, blue: 1.0), xpReward: 200, category: "focus", rarity: .epic),
        // Challenge badges
        BadgeDefinition(id: "challenge_first", name: "Challenger", description: "Complete first challenge", icon: "checkmark.seal.fill", iconColor: Color(red: 0, green: 0.83, blue: 0.67), xpReward: 15, category: "challenge", rarity: .common),
        BadgeDefinition(id: "challenge_10", name: "Challenge Streak", description: "Complete 10 challenges", icon: "checkmark.seal.fill", iconColor: Color(red: 1, green: 0.82, blue: 0.4), xpReward: 80, category: "challenge", rarity: .rare),
        BadgeDefinition(id: "challenge_50", name: "Detox Champion", description: "Complete 50 challenges", icon: "trophy.fill", iconColor: Color(red: 1, green: 0.82, blue: 0.4), xpReward: 300, category: "challenge", rarity: .epic),
        // Quest badges
        BadgeDefinition(id: "quest_first", name: "Quest Starter", description: "Complete your first quest", icon: "map.fill", iconColor: Color(red: 0.4, green: 0.8, blue: 0.6), xpReward: 20, category: "quest", rarity: .common),
        BadgeDefinition(id: "quest_10", name: "Quest Hunter", description: "Complete 10 quests", icon: "map.fill", iconColor: Color(red: 0.6, green: 0.4, blue: 1.0), xpReward: 120, category: "quest", rarity: .rare),
        // Level badges
        BadgeDefinition(id: "level_2", name: "Breaking Free", description: "Reach level 2: Hazy", icon: "cloud.fill", iconColor: Color(red: 0.5, green: 0.6, blue: 0.7), xpReward: 30, category: "level", rarity: .common),
        BadgeDefinition(id: "level_3", name: "The Clearing", description: "Reach level 3: Clearing", icon: "sun.haze.fill", iconColor: Color(red: 0.6, green: 0.8, blue: 0.7), xpReward: 60, category: "level", rarity: .rare),
        BadgeDefinition(id: "level_4", name: "Illuminated Mind", description: "Reach level 4: Illuminated", icon: "sun.max.fill", iconColor: Color(red: 0, green: 0.83, blue: 0.67), xpReward: 100, category: "level", rarity: .epic),
        BadgeDefinition(id: "level_6", name: "Crystal Clear", description: "Reach level 6: Crystal Clear", icon: "sparkles", iconColor: Color(red: 1, green: 0.92, blue: 0.6), xpReward: 500, category: "level", rarity: .legendary),
        // Special
        BadgeDefinition(id: "xp_500", name: "XP Machine", description: "Earn 500 total XP", icon: "bolt.fill", iconColor: Color(red: 1, green: 0.82, blue: 0.4), xpReward: 50, category: "special", rarity: .rare),
    ]

    static func badge(id: String) -> BadgeDefinition? {
        all.first { $0.id == id }
    }
}

// MARK: - Quest Types

enum QuestType: String, Codable {
    case daily, weekly
}

enum QuestMetric: String, Codable {
    case focusMinutes
    case challengesCompleted
    case moodLogged
    case streakMaintained
    case xpEarned
}

// MARK: - Quest Definitions

struct QuestDefinition {
    let id: String
    let title: String
    let description: String
    let icon: String
    let iconColor: Color
    let metric: QuestMetric
    let targetCount: Int
    let xpReward: Int
    let questType: QuestType

    // Daily quest pool
    static let dailyPool: [QuestDefinition] = [
        QuestDefinition(id: "daily_deep_focus", title: "Deep Focus", description: "Complete 25 min of focused work", icon: "brain.head.profile", iconColor: Color(red: 0, green: 0.83, blue: 0.67), metric: .focusMinutes, targetCount: 25, xpReward: 30, questType: .daily),
        QuestDefinition(id: "daily_double_trouble", title: "Double Trouble", description: "Complete 2 challenges today", icon: "checkmark.circle.fill", iconColor: Color(red: 1, green: 0.82, blue: 0.4), metric: .challengesCompleted, targetCount: 2, xpReward: 25, questType: .daily),
        QuestDefinition(id: "daily_mindful_logger", title: "Mindful Logger", description: "Log your mood today", icon: "heart.fill", iconColor: Color(red: 1, green: 0.45, blue: 0.45), metric: .moodLogged, targetCount: 1, xpReward: 15, questType: .daily),
        QuestDefinition(id: "daily_streak_keeper", title: "Streak Keeper", description: "Keep your streak alive", icon: "flame.fill", iconColor: .orange, metric: .streakMaintained, targetCount: 1, xpReward: 20, questType: .daily),
        QuestDefinition(id: "daily_challenger", title: "Challenge Accepted", description: "Complete all 3 challenges", icon: "trophy.fill", iconColor: Color(red: 1, green: 0.82, blue: 0.4), metric: .challengesCompleted, targetCount: 3, xpReward: 50, questType: .daily),
    ]

    // Weekly quest pool
    static let weeklyPool: [QuestDefinition] = [
        QuestDefinition(id: "weekly_focus_week", title: "Focus Week", description: "Accumulate 3 hours of focus", icon: "clock.fill", iconColor: Color(red: 0, green: 0.83, blue: 0.67), metric: .focusMinutes, targetCount: 180, xpReward: 100, questType: .weekly),
        QuestDefinition(id: "weekly_challenge_champion", title: "Challenge Champion", description: "Complete 15 challenges this week", icon: "medal.fill", iconColor: Color(red: 1, green: 0.82, blue: 0.4), metric: .challengesCompleted, targetCount: 15, xpReward: 120, questType: .weekly),
        QuestDefinition(id: "weekly_streak_warrior", title: "Streak Warrior", description: "Log mood every day this week", icon: "heart.fill", iconColor: Color(red: 1, green: 0.45, blue: 0.45), metric: .moodLogged, targetCount: 7, xpReward: 80, questType: .weekly),
        QuestDefinition(id: "weekly_xp_hunter", title: "XP Hunter", description: "Earn 200 XP this week", icon: "bolt.fill", iconColor: Color(red: 0.6, green: 0.4, blue: 1.0), metric: .xpEarned, targetCount: 200, xpReward: 100, questType: .weekly),
    ]

    static func dailyQuests(for date: Date) -> [QuestDefinition] {
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: date) ?? 0
        let count = min(3, dailyPool.count)
        let offset = dayOfYear % dailyPool.count
        return (0..<count).map { i in dailyPool[(offset + i) % dailyPool.count] }
    }

    static func weeklyQuests(for date: Date) -> [QuestDefinition] {
        let weekOfYear = Calendar.current.component(.weekOfYear, from: date)
        let count = min(2, weeklyPool.count)
        let offset = weekOfYear % weeklyPool.count
        return (0..<count).map { i in weeklyPool[(offset + i) % weeklyPool.count] }
    }
}

// MARK: - SwiftData Models

@Model
final class Badge {
    var id: UUID
    var badgeID: String
    var earnedAt: Date

    init(badgeID: String) {
        self.id = UUID()
        self.badgeID = badgeID
        self.earnedAt = Date()
    }

    var definition: BadgeDefinition? {
        BadgeDefinition.badge(id: badgeID)
    }
}

@Model
final class Quest {
    var id: UUID
    var questID: String
    var questTypeRaw: String
    var metricRaw: String
    var currentCount: Int
    var targetCount: Int
    var xpReward: Int
    var isCompleted: Bool
    var completedAt: Date?
    var assignedDate: Date
    var expiresAt: Date

    init(definition: QuestDefinition, assignedDate: Date) {
        self.id = UUID()
        self.questID = definition.id
        self.questTypeRaw = definition.questType.rawValue
        self.metricRaw = definition.metric.rawValue
        self.currentCount = 0
        self.targetCount = definition.targetCount
        self.xpReward = definition.xpReward
        self.isCompleted = false
        self.completedAt = nil
        self.assignedDate = assignedDate

        // Daily expires at midnight; weekly expires in 7 days
        let cal = Calendar.current
        if definition.questType == .daily {
            self.expiresAt = cal.startOfDay(for: cal.date(byAdding: .day, value: 1, to: assignedDate)!)
        } else {
            self.expiresAt = cal.startOfDay(for: cal.date(byAdding: .day, value: 7, to: assignedDate)!)
        }
    }

    var questType: QuestType { QuestType(rawValue: questTypeRaw) ?? .daily }
    var metric: QuestMetric { QuestMetric(rawValue: metricRaw) ?? .focusMinutes }
    var progress: Double { guard targetCount > 0 else { return 0 }; return min(1.0, Double(currentCount) / Double(targetCount)) }
    var isExpired: Bool { Date() >= expiresAt }

    var definition: QuestDefinition? {
        let pool = questType == .daily ? QuestDefinition.dailyPool : QuestDefinition.weeklyPool
        return pool.first { $0.id == questID }
    }
}

@Model
final class XPRecord {
    var id: UUID
    var amount: Int
    var source: String
    var earnedAt: Date

    init(amount: Int, source: String) {
        self.id = UUID()
        self.amount = amount
        self.source = source
        self.earnedAt = Date()
    }
}
