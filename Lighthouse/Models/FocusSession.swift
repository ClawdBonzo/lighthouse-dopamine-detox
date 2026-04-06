import Foundation
import SwiftData

@Model
final class FocusSession {
    var id: UUID
    var startTime: Date
    var endTime: Date?
    var targetMinutes: Int
    var actualMinutes: Int
    var presetName: String?
    var wasCompleted: Bool
    var interruptions: Int
    var notes: String?
    var date: Date

    init(
        targetMinutes: Int = 25,
        presetName: String? = nil
    ) {
        self.id = UUID()
        self.startTime = Date()
        self.endTime = nil
        self.targetMinutes = targetMinutes
        self.actualMinutes = 0
        self.presetName = presetName
        self.wasCompleted = false
        self.interruptions = 0
        self.notes = nil
        self.date = Calendar.current.startOfDay(for: .now)
    }

    func complete() {
        endTime = Date()
        actualMinutes = Int(Date().timeIntervalSince(startTime) / 60)
        wasCompleted = actualMinutes >= targetMinutes
    }

    func cancel() {
        endTime = Date()
        actualMinutes = Int(Date().timeIntervalSince(startTime) / 60)
        wasCompleted = false
    }

    var isActive: Bool {
        endTime == nil
    }

    var progress: Double {
        guard targetMinutes > 0 else { return 0 }
        let elapsed = Date().timeIntervalSince(startTime) / 60
        return min(1.0, elapsed / Double(targetMinutes))
    }

    var formattedDuration: String {
        let mins = actualMinutes > 0 ? actualMinutes : Int(Date().timeIntervalSince(startTime) / 60)
        if mins >= 60 {
            return "\(mins / 60)h \(mins % 60)m"
        }
        return "\(mins)m"
    }
}
