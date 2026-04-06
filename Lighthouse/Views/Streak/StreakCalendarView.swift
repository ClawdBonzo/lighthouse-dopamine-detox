import SwiftUI
import SwiftData

struct StreakCalendarView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \DailyLog.date, order: .reverse) private var logs: [DailyLog]
    @Query private var profiles: [UserProfile]

    @State private var currentMonth = Date()

    private var profile: UserProfile? { profiles.first }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: LHSpacing.lg) {
                    // Streak hero card
                    streakHeroCard

                    // Calendar grid
                    calendarView

                    // Recovery tools
                    recoverySection
                }
                .padding(.horizontal, LHSpacing.lg)
                .padding(.top, LHSpacing.md)
            }
            .scrollIndicators(.hidden)
            .background(LHColor.background)
            .navigationTitle("Streak")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }

    // MARK: - Streak Hero

    private var streakHeroCard: some View {
        VStack(spacing: LHSpacing.md) {
            ZStack {
                Circle()
                    .fill(LHColor.streak.opacity(0.1))
                    .frame(width: 100, height: 100)

                VStack(spacing: 2) {
                    Text("\(profile?.currentStreak ?? 0)")
                        .font(LHFont.display(42))
                        .foregroundStyle(LHColor.streak)
                    Text("days")
                        .font(LHFont.caption(12))
                        .foregroundStyle(LHColor.textTertiary)
                }
            }

            Text("Current Streak")
                .font(LHFont.headline(16))
                .foregroundStyle(LHColor.textPrimary)

            HStack(spacing: LHSpacing.xl) {
                VStack(spacing: 4) {
                    Text("\(profile?.longestStreak ?? 0)")
                        .font(LHFont.headline(20))
                        .foregroundStyle(LHColor.gold)
                    Text("Best")
                        .font(LHFont.caption(11))
                        .foregroundStyle(LHColor.textTertiary)
                }

                Rectangle()
                    .fill(LHColor.textMuted)
                    .frame(width: 1, height: 30)

                VStack(spacing: 4) {
                    Text("\(profile?.totalDetoxDays ?? 0)")
                        .font(LHFont.headline(20))
                        .foregroundStyle(LHColor.teal)
                    Text("Total")
                        .font(LHFont.caption(11))
                        .foregroundStyle(LHColor.textTertiary)
                }
            }
        }
        .lhCard(padding: LHSpacing.lg)
    }

    // MARK: - Calendar

    private var calendarView: some View {
        VStack(spacing: LHSpacing.md) {
            // Month nav
            HStack {
                Button {
                    withAnimation {
                        currentMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth)!
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(LHColor.textSecondary)
                }

                Spacer()

                Text(monthYearString)
                    .font(LHFont.headline(16))
                    .foregroundStyle(LHColor.textPrimary)

                Spacer()

                Button {
                    withAnimation {
                        currentMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth)!
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .foregroundStyle(LHColor.textSecondary)
                }
            }

            // Weekday headers
            HStack(spacing: 0) {
                ForEach(["S", "M", "T", "W", "T", "F", "S"], id: \.self) { day in
                    Text(day)
                        .font(LHFont.caption(12))
                        .foregroundStyle(LHColor.textTertiary)
                        .frame(maxWidth: .infinity)
                }
            }

            // Days grid
            let days = daysInMonth()
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 2), count: 7), spacing: 6) {
                ForEach(days, id: \.self) { day in
                    if day == 0 {
                        Text("")
                            .frame(width: 36, height: 36)
                    } else {
                        let date = dateForDay(day)
                        let hasLog = logForDate(date) != nil
                        let didDetox = logForDate(date)?.didDetox ?? false

                        Text("\(day)")
                            .font(LHFont.caption(13))
                            .foregroundStyle(
                                didDetox ? LHColor.background :
                                hasLog ? LHColor.textPrimary :
                                LHColor.textMuted
                            )
                            .frame(width: 36, height: 36)
                            .background(
                                didDetox ? LHColor.teal :
                                hasLog ? LHColor.surface :
                                Color.clear
                            )
                            .clipShape(Circle())
                    }
                }
            }
        }
        .lhCard()
    }

    // MARK: - Recovery

    private var recoverySection: some View {
        VStack(alignment: .leading, spacing: LHSpacing.md) {
            Text("Recovery Tools")
                .font(LHFont.headline(18))
                .foregroundStyle(LHColor.textPrimary)

            VStack(spacing: LHSpacing.sm) {
                recoveryCard(
                    icon: "arrow.counterclockwise",
                    title: "Streak Freeze",
                    subtitle: "Protect your streak on tough days",
                    color: LHColor.gold
                )
                recoveryCard(
                    icon: "heart.circle",
                    title: "Compassion Reminder",
                    subtitle: "Progress isn't linear — every day is a fresh start",
                    color: LHColor.streak
                )
                recoveryCard(
                    icon: "trophy",
                    title: "Milestone Celebration",
                    subtitle: "Review your wins and keep going",
                    color: LHColor.teal
                )
            }
        }
    }

    private func recoveryCard(icon: String, title: String, subtitle: String, color: Color) -> some View {
        HStack(spacing: LHSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(color)
                .frame(width: 40, height: 40)
                .background(color.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: LHRadius.sm))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(LHFont.headline(14))
                    .foregroundStyle(LHColor.textPrimary)
                Text(subtitle)
                    .font(LHFont.caption(12))
                    .foregroundStyle(LHColor.textTertiary)
                    .lineLimit(2)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundStyle(LHColor.textMuted)
        }
        .padding(LHSpacing.md)
        .background(LHColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: LHRadius.md))
    }

    // MARK: - Helpers

    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentMonth)
    }

    private func daysInMonth() -> [Int] {
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: currentMonth)!
        let firstDay = calendar.component(.weekday, from: calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth))!) - 1

        var days: [Int] = Array(repeating: 0, count: firstDay)
        days.append(contentsOf: Array(1...range.count))
        return days
    }

    private func dateForDay(_ day: Int) -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month], from: currentMonth)
        components.day = day
        return calendar.date(from: components) ?? currentMonth
    }

    private func logForDate(_ date: Date) -> DailyLog? {
        logs.first { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }
}
