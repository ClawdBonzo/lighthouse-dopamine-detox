import WidgetKit
import SwiftUI
import AppIntents

// MARK: - Streak Widget

struct StreakEntry: TimelineEntry {
    let date: Date
    let streakCount: Int
    let focusMinutesToday: Int
    let challengesCompleted: Int
    let challengesTotal: Int
}

struct StreakProvider: TimelineProvider {
    func placeholder(in context: Context) -> StreakEntry {
        StreakEntry(date: .now, streakCount: 7, focusMinutesToday: 45, challengesCompleted: 2, challengesTotal: 3)
    }

    func getSnapshot(in context: Context, completion: @escaping (StreakEntry) -> Void) {
        let entry = StreakEntry(date: .now, streakCount: 7, focusMinutesToday: 45, challengesCompleted: 2, challengesTotal: 3)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<StreakEntry>) -> Void) {
        // In production, read from shared UserDefaults (App Group) or SwiftData
        let entry = StreakEntry(
            date: .now,
            streakCount: UserDefaults(suiteName: "group.com.lighthouse.app")?.integer(forKey: "currentStreak") ?? 0,
            focusMinutesToday: UserDefaults(suiteName: "group.com.lighthouse.app")?.integer(forKey: "focusToday") ?? 0,
            challengesCompleted: UserDefaults(suiteName: "group.com.lighthouse.app")?.integer(forKey: "challengesCompleted") ?? 0,
            challengesTotal: UserDefaults(suiteName: "group.com.lighthouse.app")?.integer(forKey: "challengesTotal") ?? 3
        )

        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: .now)!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

struct StreakWidgetEntryView: View {
    var entry: StreakEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            smallView
        case .systemMedium:
            mediumView
        default:
            smallView
        }
    }

    private var smallView: some View {
        VStack(spacing: 6) {
            Image("BrandIcon")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 32, height: 32)
                .clipShape(RoundedRectangle(cornerRadius: 8))

            Text("\(entry.streakCount)")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Text("day streak")
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(for: .widget) {
            Color(red: 0.04, green: 0.09, blue: 0.16)
        }
    }

    private var mediumView: some View {
        HStack(spacing: 16) {
            // Streak
            VStack(spacing: 6) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(.orange)

                Text("\(entry.streakCount)")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text("day streak")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.6))
            }
            .frame(maxWidth: .infinity)

            // Divider
            Rectangle()
                .fill(.white.opacity(0.1))
                .frame(width: 1)
                .padding(.vertical, 8)

            // Stats
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 14))
                        .foregroundStyle(Color(red: 0, green: 0.83, blue: 0.67))
                    Text("\(entry.focusMinutesToday)m focused")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.8))
                }

                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(Color(red: 1, green: 0.82, blue: 0.4))
                    Text("\(entry.challengesCompleted)/\(entry.challengesTotal) done")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.8))
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 4)
        .containerBackground(for: .widget) {
            Color(red: 0.04, green: 0.09, blue: 0.16)
        }
    }
}

struct StreakWidget: Widget {
    let kind: String = "StreakWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StreakProvider()) { entry in
            StreakWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Detox Streak")
        .description("Track your current detox streak at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
