import Foundation
import SwiftData

@Model
final class FocusPreset {
    var id: UUID
    var name: String
    var durationMinutes: Int
    var iconName: String
    var colorHex: String
    var blockedApps: [String]
    var isDefault: Bool
    var createdAt: Date
    var usageCount: Int

    init(
        name: String,
        durationMinutes: Int = 25,
        iconName: String = "moon.fill",
        colorHex: String = "00D4AA",
        blockedApps: [String] = [],
        isDefault: Bool = false
    ) {
        self.id = UUID()
        self.name = name
        self.durationMinutes = durationMinutes
        self.iconName = iconName
        self.colorHex = colorHex
        self.blockedApps = blockedApps
        self.isDefault = isDefault
        self.createdAt = Date()
        self.usageCount = 0
    }

    var color: String { colorHex }

    var formattedDuration: String {
        if durationMinutes >= 60 {
            let hours = durationMinutes / 60
            let mins = durationMinutes % 60
            return mins > 0 ? "\(hours)h \(mins)m" : "\(hours)h"
        }
        return "\(durationMinutes)m"
    }

    static var defaultPresets: [FocusPreset] {
        [
            FocusPreset(name: "Deep Work", durationMinutes: 90, iconName: "brain.head.profile", colorHex: "6C63FF", isDefault: true),
            FocusPreset(name: "Pomodoro", durationMinutes: 25, iconName: "timer", colorHex: "FF6B6B", isDefault: true),
            FocusPreset(name: "Reading", durationMinutes: 30, iconName: "book.fill", colorHex: "00D4AA", isDefault: true),
            FocusPreset(name: "Meditation", durationMinutes: 15, iconName: "leaf.fill", colorHex: "4ADE80", isDefault: true),
            FocusPreset(name: "Exercise", durationMinutes: 45, iconName: "figure.run", colorHex: "FFD166", isDefault: true),
        ]
    }
}
