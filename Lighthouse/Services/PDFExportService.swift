import Foundation
import PDFKit
import UIKit

struct PDFExportService {

    static func generateReport(
        profile: UserProfile,
        dailyLogs: [DailyLog],
        screenTimeLogs: [ScreenTimeLog],
        focusSessions: [FocusSession]
    ) -> Data? {
        let pageWidth: CGFloat = 612
        let pageHeight: CGFloat = 792
        let margin: CGFloat = 50

        let pdfRenderer = UIGraphicsPDFRenderer(
            bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        )

        let data = pdfRenderer.pdfData { context in
            // Page 1: Summary
            context.beginPage()
            var yOffset: CGFloat = margin

            // Title
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 28, weight: .bold),
                .foregroundColor: UIColor(red: 0, green: 0.83, blue: 0.67, alpha: 1)
            ]
            let title = "Lighthouse — Focus Report"
            title.draw(at: CGPoint(x: margin, y: yOffset), withAttributes: titleAttributes)
            yOffset += 45

            // Subtitle
            let subtitleAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14, weight: .regular),
                .foregroundColor: UIColor.darkGray
            ]
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .long
            let subtitle = "Generated for \(profile.displayName) on \(dateFormatter.string(from: .now))"
            subtitle.draw(at: CGPoint(x: margin, y: yOffset), withAttributes: subtitleAttrs)
            yOffset += 40

            // Divider
            let dividerPath = UIBezierPath()
            dividerPath.move(to: CGPoint(x: margin, y: yOffset))
            dividerPath.addLine(to: CGPoint(x: pageWidth - margin, y: yOffset))
            UIColor.lightGray.setStroke()
            dividerPath.stroke()
            yOffset += 20

            // Stats section
            let headerAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 18, weight: .semibold),
                .foregroundColor: UIColor.black
            ]
            let bodyAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14, weight: .regular),
                .foregroundColor: UIColor.darkGray
            ]

            "Overview".draw(at: CGPoint(x: margin, y: yOffset), withAttributes: headerAttrs)
            yOffset += 30

            let stats: [(String, String)] = [
                ("Current Streak", "\(profile.currentStreak) days"),
                ("Longest Streak", "\(profile.longestStreak) days"),
                ("Total Detox Days", "\(profile.totalDetoxDays)"),
                ("Total Focus Time", "\(profile.totalFocusMinutes / 60)h \(profile.totalFocusMinutes % 60)m"),
                ("Daily Logs Recorded", "\(dailyLogs.count)"),
                ("Focus Sessions", "\(focusSessions.count)"),
                ("Sessions Completed", "\(focusSessions.filter(\.wasCompleted).count)"),
            ]

            for (label, value) in stats {
                let line = "\(label): \(value)"
                line.draw(at: CGPoint(x: margin + 10, y: yOffset), withAttributes: bodyAttrs)
                yOffset += 22
            }

            yOffset += 20

            // Recent daily logs
            if !dailyLogs.isEmpty {
                "Recent Daily Logs".draw(at: CGPoint(x: margin, y: yOffset), withAttributes: headerAttrs)
                yOffset += 30

                let recentLogs = dailyLogs.sorted { $0.date > $1.date }.prefix(14)
                let logDateFormatter = DateFormatter()
                logDateFormatter.dateFormat = "MMM d"

                for log in recentLogs {
                    guard yOffset < pageHeight - margin - 30 else {
                        context.beginPage()
                        yOffset = margin
                        break
                    }

                    let dateStr = logDateFormatter.string(from: log.date)
                    let line = "\(dateStr) — Mood: \(log.moodEmoji)  Focus: \(log.focusMinutes)m  Challenges: \(log.challengesCompleted)/\(log.challengesTotal)"
                    line.draw(at: CGPoint(x: margin + 10, y: yOffset), withAttributes: bodyAttrs)
                    yOffset += 22
                }
            }

            yOffset += 20

            // Screen time summary
            if !screenTimeLogs.isEmpty {
                if yOffset > pageHeight - margin - 100 {
                    context.beginPage()
                    yOffset = margin
                }

                "Screen Time Summary".draw(at: CGPoint(x: margin, y: yOffset), withAttributes: headerAttrs)
                yOffset += 30

                let totalScreenTime = screenTimeLogs.reduce(0) { $0 + $1.totalMinutes }
                let totalWasted = screenTimeLogs.reduce(0) { $0 + $1.wastedMinutes }
                let avgDaily = screenTimeLogs.isEmpty ? 0 : totalScreenTime / screenTimeLogs.count

                let screenStats: [(String, String)] = [
                    ("Average Daily Screen Time", "\(avgDaily / 60)h \(avgDaily % 60)m"),
                    ("Total Wasted Time Tracked", "\(totalWasted / 60)h \(totalWasted % 60)m"),
                    ("Days Logged", "\(screenTimeLogs.count)"),
                ]

                for (label, value) in screenStats {
                    let line = "\(label): \(value)"
                    line.draw(at: CGPoint(x: margin + 10, y: yOffset), withAttributes: bodyAttrs)
                    yOffset += 22
                }
            }

            // Footer
            yOffset = pageHeight - margin - 20
            let footerAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 10, weight: .regular),
                .foregroundColor: UIColor.lightGray
            ]
            "Generated by Lighthouse — Your Dopamine Detox Companion".draw(
                at: CGPoint(x: margin, y: yOffset),
                withAttributes: footerAttrs
            )
        }

        return data
    }
}
