import Foundation
import SwiftData

@Model
final class ScreenTimeLog {
    var id: UUID
    var date: Date
    var totalMinutes: Int
    var productiveMinutes: Int
    var socialMediaMinutes: Int
    var entertainmentMinutes: Int
    var otherMinutes: Int
    var appBreakdown: [String: Int]  // app name → minutes
    var manualEntry: Bool
    var notes: String?

    init(
        date: Date = .now,
        totalMinutes: Int = 0,
        productiveMinutes: Int = 0,
        socialMediaMinutes: Int = 0,
        entertainmentMinutes: Int = 0,
        otherMinutes: Int = 0,
        appBreakdown: [String: Int] = [:],
        manualEntry: Bool = true,
        notes: String? = nil
    ) {
        self.id = UUID()
        self.date = date
        self.totalMinutes = totalMinutes
        self.productiveMinutes = productiveMinutes
        self.socialMediaMinutes = socialMediaMinutes
        self.entertainmentMinutes = entertainmentMinutes
        self.otherMinutes = otherMinutes
        self.appBreakdown = appBreakdown
        self.manualEntry = manualEntry
        self.notes = notes
    }

    var wastedMinutes: Int {
        socialMediaMinutes + entertainmentMinutes
    }

    var reclaimedMinutes: Int {
        max(0, totalMinutes - wastedMinutes)
    }

    var wastedPercentage: Double {
        guard totalMinutes > 0 else { return 0 }
        return Double(wastedMinutes) / Double(totalMinutes) * 100
    }

    var formattedTotal: String {
        let hours = totalMinutes / 60
        let mins = totalMinutes % 60
        if hours > 0 {
            return "\(hours)h \(mins)m"
        }
        return "\(mins)m"
    }
}
