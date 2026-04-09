import SwiftUI
import SwiftData
import Charts

struct ProgressChartsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \DailyLog.date) private var logs: [DailyLog]
    @Query(sort: \ScreenTimeLog.date) private var screenTimeLogs: [ScreenTimeLog]
    @Query(sort: \FocusSession.date) private var focusSessions: [FocusSession]
    @Query private var profiles: [UserProfile]

    @State private var selectedTimeRange: TimeRange = .week
    @State private var showExportSheet = false

    enum TimeRange: String, CaseIterable {
        case week = "7D"
        case month = "30D"
        case quarter = "90D"
    }

    private var profile: UserProfile? { profiles.first }

    var body: some View {
        NavigationStack {
            ZStack {
                LighthouseParticleBackground().ignoresSafeArea()
                ScrollView {
                VStack(spacing: LHSpacing.lg) {
                    // Time range picker
                    Picker("Range", selection: $selectedTimeRange) {
                        ForEach(TimeRange.allCases, id: \.self) { range in
                            Text(range.rawValue).tag(range)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, LHSpacing.lg)

                    // Focus Hours Chart
                    focusChart

                    // Mood Trend
                    moodChart

                    // Screen Time Chart
                    screenTimeChart

                    // Summary stats
                    summaryStats

                    Spacer().frame(height: LHSpacing.xxl)
                }
                .padding(.top, LHSpacing.md)
            }
            .scrollIndicators(.hidden)
            } // ZStack
            .background(LHColor.background)
            .navigationTitle("Progress")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showExportSheet = true
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundStyle(LHColor.teal)
                    }
                }
            }
            .sheet(isPresented: $showExportSheet) {
                exportView
            }
        }
    }

    // MARK: - Focus Chart

    private var focusChart: some View {
        VStack(alignment: .leading, spacing: LHSpacing.md) {
            Text("Focus Minutes")
                .font(LHFont.headline(16))
                .foregroundStyle(LHColor.textPrimary)

            let data = filteredLogs
            if data.isEmpty {
                emptyChartPlaceholder
            } else {
                Chart(data, id: \.id) { log in
                    BarMark(
                        x: .value("Date", log.date, unit: .day),
                        y: .value("Minutes", log.focusMinutes)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [LHColor.teal, LHColor.tealDim],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .cornerRadius(4)
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day, count: axisStride)) { _ in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                            .foregroundStyle(LHColor.textMuted)
                        AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                            .foregroundStyle(LHColor.textTertiary)
                    }
                }
                .chartYAxis {
                    AxisMarks { _ in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                            .foregroundStyle(LHColor.textMuted)
                        AxisValueLabel()
                            .foregroundStyle(LHColor.textTertiary)
                    }
                }
                .frame(height: 200)
            }
        }
        .lhCard()
        .padding(.horizontal, LHSpacing.lg)
    }

    // MARK: - Mood Chart

    private var moodChart: some View {
        VStack(alignment: .leading, spacing: LHSpacing.md) {
            Text("Mood Trend")
                .font(LHFont.headline(16))
                .foregroundStyle(LHColor.textPrimary)

            let data = filteredLogs
            if data.isEmpty {
                emptyChartPlaceholder
            } else {
                Chart(data, id: \.id) { log in
                    LineMark(
                        x: .value("Date", log.date, unit: .day),
                        y: .value("Mood", log.mood)
                    )
                    .foregroundStyle(LHColor.gold)
                    .interpolationMethod(.catmullRom)

                    PointMark(
                        x: .value("Date", log.date, unit: .day),
                        y: .value("Mood", log.mood)
                    )
                    .foregroundStyle(LHColor.gold)
                    .symbolSize(30)
                }
                .chartYScale(domain: 1...5)
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day, count: axisStride)) { _ in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                            .foregroundStyle(LHColor.textMuted)
                        AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                            .foregroundStyle(LHColor.textTertiary)
                    }
                }
                .chartYAxis {
                    AxisMarks(values: [1, 2, 3, 4, 5]) { value in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                            .foregroundStyle(LHColor.textMuted)
                        AxisValueLabel {
                            let emojis = ["", "😞", "😐", "🙂", "😊", "🤩"]
                            if let v = value.as(Int.self), v < emojis.count {
                                Text(emojis[v]).font(.system(size: 10))
                            }
                        }
                    }
                }
                .frame(height: 180)
            }
        }
        .lhCard()
        .padding(.horizontal, LHSpacing.lg)
    }

    // MARK: - Screen Time Chart

    private var screenTimeChart: some View {
        VStack(alignment: .leading, spacing: LHSpacing.md) {
            Text("Screen Time")
                .font(LHFont.headline(16))
                .foregroundStyle(LHColor.textPrimary)

            let data = filteredScreenTimeLogs
            if data.isEmpty {
                emptyChartPlaceholder
            } else {
                Chart(data, id: \.id) { log in
                    BarMark(
                        x: .value("Date", log.date, unit: .day),
                        y: .value("Hours", Double(log.totalMinutes) / 60.0)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [LHColor.streak, LHColor.streak.opacity(0.5)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .cornerRadius(4)
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day, count: axisStride)) { _ in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                            .foregroundStyle(LHColor.textMuted)
                        AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                            .foregroundStyle(LHColor.textTertiary)
                    }
                }
                .chartYAxis {
                    AxisMarks { _ in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                            .foregroundStyle(LHColor.textMuted)
                        AxisValueLabel()
                            .foregroundStyle(LHColor.textTertiary)
                    }
                }
                .frame(height: 180)
            }
        }
        .lhCard()
        .padding(.horizontal, LHSpacing.lg)
    }

    // MARK: - Summary

    private var summaryStats: some View {
        let data = filteredLogs
        let totalFocus = data.reduce(0) { $0 + $1.focusMinutes }
        let avgMood = data.isEmpty ? 0.0 : Double(data.reduce(0) { $0 + $1.mood }) / Double(data.count)
        let completionRate = data.isEmpty ? 0.0 : Double(data.reduce(0) { $0 + $1.challengesCompleted }) / max(1, Double(data.reduce(0) { $0 + $1.challengesTotal }))

        return VStack(alignment: .leading, spacing: LHSpacing.md) {
            Text("Summary")
                .font(LHFont.headline(16))
                .foregroundStyle(LHColor.textPrimary)

            HStack(spacing: LHSpacing.md) {
                summaryCard("Focus Time", "\(totalFocus / 60)h \(totalFocus % 60)m", LHColor.teal)
                summaryCard("Avg Mood", String(format: "%.1f", avgMood), LHColor.gold)
                summaryCard("Completion", "\(Int(completionRate * 100))%", LHColor.success)
            }
        }
        .padding(.horizontal, LHSpacing.lg)
    }

    private func summaryCard(_ title: String, _ value: String, _ color: Color) -> some View {
        VStack(spacing: 6) {
            Text(value)
                .font(LHFont.headline(18))
                .foregroundStyle(color)
            Text(title)
                .font(LHFont.caption(11))
                .foregroundStyle(LHColor.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .lhCard()
    }

    // MARK: - Export

    private var exportView: some View {
        NavigationStack {
            VStack(spacing: LHSpacing.lg) {
                Image(systemName: "doc.richtext")
                    .font(.system(size: 48))
                    .foregroundStyle(LHColor.teal)

                Text("Export Focus Report")
                    .font(LHFont.headline(20))
                    .foregroundStyle(LHColor.textPrimary)

                Text("Generate a PDF summary of your detox journey")
                    .font(LHFont.body(15))
                    .foregroundStyle(LHColor.textSecondary)
                    .multilineTextAlignment(.center)

                GlowButton(title: "Generate PDF", icon: "doc.fill") {
                    generateAndSharePDF()
                }
                .padding(.horizontal, LHSpacing.lg)
            }
            .padding(LHSpacing.xl)
            .background(LHColor.background)
            .navigationTitle("Export")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .presentationDetents([.medium])
    }

    // MARK: - Helpers

    private var emptyChartPlaceholder: some View {
        VStack(spacing: LHSpacing.sm) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 32))
                .foregroundStyle(LHColor.textMuted)
            Text("Not enough data yet")
                .font(LHFont.body(14))
                .foregroundStyle(LHColor.textTertiary)
        }
        .frame(height: 150)
        .frame(maxWidth: .infinity)
    }

    private var axisStride: Int {
        switch selectedTimeRange {
        case .week: 1
        case .month: 5
        case .quarter: 15
        }
    }

    private var startDate: Date {
        let days: Int = switch selectedTimeRange {
        case .week: 7
        case .month: 30
        case .quarter: 90
        }
        return Calendar.current.date(byAdding: .day, value: -days, to: .now) ?? .now
    }

    private var filteredLogs: [DailyLog] {
        logs.filter { $0.date >= startDate }
    }

    private var filteredScreenTimeLogs: [ScreenTimeLog] {
        screenTimeLogs.filter { $0.date >= startDate }
    }

    private func generateAndSharePDF() {
        guard let profile else { return }
        guard let data = PDFExportService.generateReport(
            profile: profile,
            dailyLogs: logs,
            screenTimeLogs: screenTimeLogs,
            focusSessions: focusSessions
        ) else { return }

        let url = FileManager.default.temporaryDirectory.appendingPathComponent("Lighthouse_Report.pdf")
        try? data.write(to: url)

        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
}
