import Foundation
import SwiftData

@Model
final class DailyLog {
    var id: UUID
    var date: Date
    var challengesCompleted: Int
    var challengesTotal: Int
    var focusMinutes: Int
    var screenTimeMinutes: Int
    var mood: Int                  // 1-5 scale
    var energyLevel: Int           // 1-5 scale
    var gratitudeNote: String?
    var reflectionNote: String?
    var didDetox: Bool
    var streakDay: Int

    init(
        date: Date = Calendar.current.startOfDay(for: .now),
        streakDay: Int = 0
    ) {
        self.id = UUID()
        self.date = date
        self.challengesCompleted = 0
        self.challengesTotal = 0
        self.focusMinutes = 0
        self.screenTimeMinutes = 0
        self.mood = 3
        self.energyLevel = 3
        self.gratitudeNote = nil
        self.reflectionNote = nil
        self.didDetox = false
        self.streakDay = streakDay
    }

    var completionRate: Double {
        guard challengesTotal > 0 else { return 0 }
        return Double(challengesCompleted) / Double(challengesTotal)
    }

    var moodEmoji: String {
        switch mood {
        case 1: return "😞"
        case 2: return "😐"
        case 3: return "🙂"
        case 4: return "😊"
        case 5: return "🤩"
        default: return "🙂"
        }
    }

    var energyEmoji: String {
        switch energyLevel {
        case 1: return "🔋"
        case 2: return "🪫"
        case 3: return "⚡"
        case 4: return "🔥"
        case 5: return "💥"
        default: return "⚡"
        }
    }
}
