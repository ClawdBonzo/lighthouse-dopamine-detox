import Foundation
import SwiftData

@Model
final class DetoxChallenge {
    var id: UUID
    var title: String
    var subtitle: String
    var category: String          // "mindfulness", "digital", "social", "physical", "creative"
    var difficulty: Int            // 1-5
    var durationMinutes: Int
    var iconName: String
    var isCompleted: Bool
    var completedAt: Date?
    var assignedDate: Date
    var focusPointsReward: Int

    init(
        title: String,
        subtitle: String,
        category: String,
        difficulty: Int = 2,
        durationMinutes: Int = 15,
        iconName: String = "sparkles",
        assignedDate: Date = .now,
        focusPointsReward: Int = 10
    ) {
        self.id = UUID()
        self.title = title
        self.subtitle = subtitle
        self.category = category
        self.difficulty = difficulty
        self.durationMinutes = durationMinutes
        self.iconName = iconName
        self.isCompleted = false
        self.completedAt = nil
        self.assignedDate = assignedDate
        self.focusPointsReward = focusPointsReward
    }

    func markCompleted() {
        isCompleted = true
        completedAt = Date()
    }

    var difficultyLabel: String {
        switch difficulty {
        case 1: "Easy"
        case 2: "Medium"
        case 3: "Hard"
        case 4: "Expert"
        case 5: "Master"
        default: "Medium"
        }
    }

    var categoryColor: String {
        switch category {
        case "mindfulness": "00D4AA"
        case "digital": "6C63FF"
        case "social": "FF6B6B"
        case "physical": "FFD166"
        case "creative": "F472B6"
        default: "00D4AA"
        }
    }
}
