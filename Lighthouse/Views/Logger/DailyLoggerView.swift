import SwiftUI
import SwiftData

struct DailyLoggerView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \DailyLog.date, order: .reverse) private var logs: [DailyLog]
    @State private var showAddLog = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: LHSpacing.lg) {
                    // Today's log card
                    if let todayLog = todayLog {
                        TodayLogCard(log: todayLog) {
                            showAddLog = true
                        }
                    } else {
                        Button {
                            showAddLog = true
                        } label: {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundStyle(LHColor.teal)
                                Text("Log today's progress")
                                    .font(LHFont.headline(15))
                                    .foregroundStyle(LHColor.teal)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, LHSpacing.lg)
                            .background(LHColor.teal.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: LHRadius.lg))
                            .overlay(
                                RoundedRectangle(cornerRadius: LHRadius.lg)
                                    .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [8]))
                                    .foregroundStyle(LHColor.teal.opacity(0.3))
                            )
                        }
                    }

                    // Recent logs
                    if !logs.isEmpty {
                        VStack(alignment: .leading, spacing: LHSpacing.md) {
                            Text("Recent Logs")
                                .font(LHFont.headline(18))
                                .foregroundStyle(LHColor.textPrimary)

                            ForEach(logs.prefix(14), id: \.id) { log in
                                LogRow(log: log)
                            }
                        }
                    }
                }
                .padding(.horizontal, LHSpacing.lg)
                .padding(.top, LHSpacing.md)
            }
            .scrollIndicators(.hidden)
            .background(LHColor.background)
            .navigationTitle("Daily Log")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .sheet(isPresented: $showAddLog) {
                AddLogSheet(existingLog: todayLog)
            }
        }
    }

    private var todayLog: DailyLog? {
        let today = Calendar.current.startOfDay(for: .now)
        return logs.first { Calendar.current.isDate($0.date, inSameDayAs: today) }
    }
}

// MARK: - Today's Log Card

struct TodayLogCard: View {
    let log: DailyLog
    let onEdit: () -> Void

    var body: some View {
        VStack(spacing: LHSpacing.md) {
            HStack {
                Text("Today")
                    .font(LHFont.headline(18))
                    .foregroundStyle(LHColor.textPrimary)
                Spacer()
                Button("Edit", action: onEdit)
                    .font(LHFont.caption(14))
                    .foregroundStyle(LHColor.teal)
            }

            HStack(spacing: LHSpacing.lg) {
                VStack(spacing: 4) {
                    Text(log.moodEmoji)
                        .font(.system(size: 28))
                    Text("Mood")
                        .font(LHFont.caption(11))
                        .foregroundStyle(LHColor.textTertiary)
                }

                VStack(spacing: 4) {
                    Text(log.energyEmoji)
                        .font(.system(size: 28))
                    Text("Energy")
                        .font(LHFont.caption(11))
                        .foregroundStyle(LHColor.textTertiary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(log.focusMinutes)m")
                        .font(LHFont.headline(20))
                        .foregroundStyle(LHColor.teal)
                    Text("focused")
                        .font(LHFont.caption(11))
                        .foregroundStyle(LHColor.textTertiary)
                }
            }

            if let note = log.gratitudeNote, !note.isEmpty {
                HStack {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(LHColor.streak)
                    Text(note)
                        .font(LHFont.body(13))
                        .foregroundStyle(LHColor.textSecondary)
                        .lineLimit(2)
                    Spacer()
                }
                .padding(LHSpacing.sm)
                .background(LHColor.surface)
                .clipShape(RoundedRectangle(cornerRadius: LHRadius.sm))
            }
        }
        .lhCard()
    }
}

// MARK: - Log Row

struct LogRow: View {
    let log: DailyLog

    private var dateLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d"
        return formatter.string(from: log.date)
    }

    var body: some View {
        HStack(spacing: LHSpacing.md) {
            VStack(alignment: .leading, spacing: 4) {
                Text(dateLabel)
                    .font(LHFont.headline(14))
                    .foregroundStyle(LHColor.textPrimary)
                Text("\(log.challengesCompleted)/\(log.challengesTotal) challenges")
                    .font(LHFont.caption(12))
                    .foregroundStyle(LHColor.textTertiary)
            }

            Spacer()

            Text(log.moodEmoji)
                .font(.system(size: 20))

            VStack(alignment: .trailing, spacing: 2) {
                Text("\(log.focusMinutes)m")
                    .font(LHFont.mono(14))
                    .foregroundStyle(LHColor.teal)
            }

            if log.didDetox {
                Image(systemName: "flame.fill")
                    .foregroundStyle(LHColor.streak)
                    .font(.system(size: 14))
            }
        }
        .padding(LHSpacing.md)
        .background(LHColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: LHRadius.md))
    }
}

// MARK: - Add Log Sheet

struct AddLogSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var profiles: [UserProfile]
    var existingLog: DailyLog?

    @State private var mood: Int = 3
    @State private var energy: Int = 3
    @State private var screenTimeMinutes: Int = 120
    @State private var gratitude: String = ""
    @State private var reflection: String = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: LHSpacing.lg) {
                    // Mood picker
                    VStack(spacing: LHSpacing.sm) {
                        Text("How are you feeling?")
                            .font(LHFont.headline(16))
                            .foregroundStyle(LHColor.textSecondary)

                        HStack(spacing: LHSpacing.lg) {
                            ForEach(1...5, id: \.self) { value in
                                let emojis = ["😞", "😐", "🙂", "😊", "🤩"]
                                Button {
                                    mood = value
                                } label: {
                                    Text(emojis[value - 1])
                                        .font(.system(size: mood == value ? 36 : 28))
                                        .opacity(mood == value ? 1 : 0.5)
                                }
                            }
                        }
                    }

                    // Energy picker
                    VStack(spacing: LHSpacing.sm) {
                        Text("Energy level?")
                            .font(LHFont.headline(16))
                            .foregroundStyle(LHColor.textSecondary)

                        HStack(spacing: LHSpacing.lg) {
                            ForEach(1...5, id: \.self) { value in
                                let emojis = ["🔋", "🪫", "⚡", "🔥", "💥"]
                                Button {
                                    energy = value
                                } label: {
                                    Text(emojis[value - 1])
                                        .font(.system(size: energy == value ? 36 : 28))
                                        .opacity(energy == value ? 1 : 0.5)
                                }
                            }
                        }
                    }

                    // Screen time
                    VStack(spacing: LHSpacing.sm) {
                        Text("Screen time today")
                            .font(LHFont.headline(16))
                            .foregroundStyle(LHColor.textSecondary)

                        HStack {
                            Text("\(screenTimeMinutes / 60)h \(screenTimeMinutes % 60)m")
                                .font(LHFont.mono(20))
                                .foregroundStyle(LHColor.textPrimary)
                        }

                        Slider(value: Binding(
                            get: { Double(screenTimeMinutes) },
                            set: { screenTimeMinutes = Int($0) }
                        ), in: 0...720, step: 15)
                        .tint(LHColor.teal)
                    }

                    // Gratitude
                    VStack(alignment: .leading, spacing: LHSpacing.sm) {
                        Text("Gratitude note")
                            .font(LHFont.headline(16))
                            .foregroundStyle(LHColor.textSecondary)

                        TextField("What are you grateful for?", text: $gratitude, axis: .vertical)
                            .font(LHFont.body(15))
                            .foregroundStyle(LHColor.textPrimary)
                            .padding(LHSpacing.md)
                            .background(LHColor.surface)
                            .clipShape(RoundedRectangle(cornerRadius: LHRadius.md))
                            .lineLimit(3...5)
                    }

                    // Reflection
                    VStack(alignment: .leading, spacing: LHSpacing.sm) {
                        Text("Reflection")
                            .font(LHFont.headline(16))
                            .foregroundStyle(LHColor.textSecondary)

                        TextField("How did your detox go today?", text: $reflection, axis: .vertical)
                            .font(LHFont.body(15))
                            .foregroundStyle(LHColor.textPrimary)
                            .padding(LHSpacing.md)
                            .background(LHColor.surface)
                            .clipShape(RoundedRectangle(cornerRadius: LHRadius.md))
                            .lineLimit(3...5)
                    }
                }
                .padding(LHSpacing.lg)
            }
            .scrollIndicators(.hidden)
            .background(LHColor.background)
            .navigationTitle("Daily Log")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(LHColor.textSecondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveLog()
                        dismiss()
                    }
                    .foregroundStyle(LHColor.teal)
                }
            }
        }
        .presentationDetents([.large])
        .onAppear {
            if let log = existingLog {
                mood = log.mood
                energy = log.energyLevel
                screenTimeMinutes = log.screenTimeMinutes
                gratitude = log.gratitudeNote ?? ""
                reflection = log.reflectionNote ?? ""
            }
        }
    }

    private func saveLog() {
        let log = existingLog ?? DailyLog()
        let isNew = existingLog == nil
        log.mood = mood
        log.energyLevel = energy
        log.screenTimeMinutes = screenTimeMinutes
        log.gratitudeNote = gratitude.isEmpty ? nil : gratitude
        log.reflectionNote = reflection.isEmpty ? nil : reflection

        if isNew {
            modelContext.insert(log)
        }
        try? modelContext.save()

        // Award XP for mood logging (new logs only)
        if isNew, let profile = profiles.first {
            GamificationEngine.shared.awardMoodLogXP(profile: profile, context: modelContext)
        }
    }
}
