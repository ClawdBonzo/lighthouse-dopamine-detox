import WidgetKit
import SwiftUI

// MARK: - Daily Tip Widget

struct TipEntry: TimelineEntry {
    let date: Date
    let tip: String
}

struct TipProvider: TimelineProvider {
    private let tips: [String] = [
        "Your brain needs 20 minutes to fully refocus after checking social media.",
        "Morning sunlight exposure reduces the urge to scroll before bed.",
        "Replace one scroll session with a 5-minute walk today.",
        "Grayscale mode makes your phone 60% less addictive.",
        "The average person checks their phone 96 times per day. You're changing that.",
        "Boredom is your brain's way of asking for creative input, not content.",
        "Every minute you don't scroll is a minute invested in your real life.",
        "Phone-free meals improve both digestion and relationships.",
        "Your dopamine system resets after just 48 hours of reduced stimulation.",
        "Reading a physical book for 30 minutes reduces stress by 68%.",
        "Notifications interrupt your deep focus for an average of 23 minutes each.",
        "The urge to check your phone peaks at 10 minutes, then fades.",
        "Screen time before bed reduces sleep quality by up to 50%.",
        "Three deep breaths can reset your craving to pick up your phone.",
        "Your longest streak shows what you're truly capable of.",
    ]

    func placeholder(in context: Context) -> TipEntry {
        TipEntry(date: .now, tip: "Every minute offline is a minute invested in real life.")
    }

    func getSnapshot(in context: Context, completion: @escaping (TipEntry) -> Void) {
        let entry = TipEntry(date: .now, tip: todaysTip)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TipEntry>) -> Void) {
        let entry = TipEntry(date: .now, tip: todaysTip)
        let nextMidnight = Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: 1, to: .now)!)
        let timeline = Timeline(entries: [entry], policy: .after(nextMidnight))
        completion(timeline)
    }

    private var todaysTip: String {
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: .now) ?? 0
        return tips[dayOfYear % tips.count]
    }
}

struct TipWidgetEntryView: View {
    var entry: TipEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image("BrandIcon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 18, height: 18)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                Text("Daily Detox Tip")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color(red: 0, green: 0.83, blue: 0.67))
            }

            Text(entry.tip)
                .font(.system(size: family == .systemSmall ? 13 : 14, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.85))
                .lineLimit(family == .systemSmall ? 4 : 3)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .containerBackground(for: .widget) {
            Color(red: 0.04, green: 0.09, blue: 0.16)
        }
    }
}

struct TipWidget: Widget {
    let kind: String = "TipWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TipProvider()) { entry in
            TipWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Daily Detox Tip")
        .description("Get a fresh focus tip every day.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
