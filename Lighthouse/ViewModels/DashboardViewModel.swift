import Foundation
import SwiftData
import SwiftUI

@MainActor
@Observable
final class DashboardViewModel {
    var profile: UserProfile?
    var todayChallenges: [DetoxChallenge] = []
    var todayLog: DailyLog?
    var activeFocusSession: FocusSession?
    var showingFocusTimer = false
    var focusTimeRemaining: TimeInterval = 0

    private var focusTimer: Timer?

    var currentStreak: Int {
        profile?.currentStreak ?? 0
    }

    var reclaimedTimeToday: Int {
        todayLog?.focusMinutes ?? 0
    }

    var challengeCompletionRate: Double {
        guard !todayChallenges.isEmpty else { return 0 }
        let completed = todayChallenges.filter(\.isCompleted).count
        return Double(completed) / Double(todayChallenges.count)
    }

    var completedChallengesCount: Int {
        todayChallenges.filter(\.isCompleted).count
    }

    var greetingText: String {
        let hour = Calendar.current.component(.hour, from: .now)
        let name = profile?.displayName ?? "Friend"
        switch hour {
        case 5..<12: return "Good morning, \(name)"
        case 12..<17: return "Good afternoon, \(name)"
        case 17..<22: return "Good evening, \(name)"
        default: return "Night owl, \(name)"
        }
    }

    func loadTodayData(modelContext: ModelContext) {
        let today = Calendar.current.startOfDay(for: .now)

        // Load profile
        let profileDescriptor = FetchDescriptor<UserProfile>()
        profile = try? modelContext.fetch(profileDescriptor).first

        // Load or generate today's challenges
        let challengeDescriptor = FetchDescriptor<DetoxChallenge>(
            predicate: #Predicate { $0.assignedDate >= today }
        )
        let existing = (try? modelContext.fetch(challengeDescriptor)) ?? []

        if existing.isEmpty, let profile {
            let newChallenges = ChallengeEngine.generateDailyChallenges(for: profile, existingToday: [])
            for challenge in newChallenges {
                modelContext.insert(challenge)
            }
            todayChallenges = newChallenges
        } else {
            todayChallenges = existing
        }

        // Load or create today's log
        let logDescriptor = FetchDescriptor<DailyLog>(
            predicate: #Predicate { $0.date >= today }
        )
        if let existingLog = try? modelContext.fetch(logDescriptor).first {
            todayLog = existingLog
        } else {
            let newLog = DailyLog(date: today, streakDay: profile?.currentStreak ?? 0)
            newLog.challengesTotal = todayChallenges.count
            modelContext.insert(newLog)
            todayLog = newLog
        }

        // Check for active focus session
        let sessionDescriptor = FetchDescriptor<FocusSession>(
            predicate: #Predicate { $0.endTime == nil }
        )
        activeFocusSession = try? modelContext.fetch(sessionDescriptor).first

        try? modelContext.save()
    }

    func completeChallenge(_ challenge: DetoxChallenge, modelContext: ModelContext) {
        challenge.markCompleted()
        todayLog?.challengesCompleted = completedChallengesCount
        todayLog?.focusMinutes += challenge.durationMinutes
        profile?.totalFocusMinutes += challenge.durationMinutes

        // Award XP
        if let profile {
            GamificationEngine.shared.awardChallengeXP(
                difficulty: challenge.difficultyLabel,
                profile: profile,
                context: modelContext
            )
        }

        // Check if all challenges are completed → update streak
        if todayChallenges.allSatisfy(\.isCompleted) {
            todayLog?.didDetox = true
            profile?.updateStreak()
            if let profile {
                GamificationEngine.shared.awardStreakBonus(profile: profile, context: modelContext)
            }
        }

        try? modelContext.save()
    }

    func startFocusSession(preset: FocusPreset?, modelContext: ModelContext) {
        let session = FocusSession(
            targetMinutes: preset?.durationMinutes ?? 25,
            presetName: preset?.name
        )
        modelContext.insert(session)
        activeFocusSession = session
        showingFocusTimer = true

        focusTimeRemaining = TimeInterval(session.targetMinutes * 60)
        startTimer()

        try? modelContext.save()
    }

    func endFocusSession(modelContext: ModelContext) {
        guard let session = activeFocusSession else { return }
        session.complete()
        todayLog?.focusMinutes += session.actualMinutes
        profile?.totalFocusMinutes += session.actualMinutes

        // Award XP
        if let profile {
            GamificationEngine.shared.awardFocusXP(
                minutes: session.actualMinutes,
                profile: profile,
                context: modelContext
            )
        }

        activeFocusSession = nil
        showingFocusTimer = false
        stopTimer()
        try? modelContext.save()
    }

    private func startTimer() {
        focusTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self else { return }
                if self.focusTimeRemaining > 0 {
                    self.focusTimeRemaining -= 1
                } else {
                    self.stopTimer()
                }
            }
        }
    }

    private func stopTimer() {
        focusTimer?.invalidate()
        focusTimer = nil
    }

    var focusTimerDisplay: String {
        let minutes = Int(focusTimeRemaining) / 60
        let seconds = Int(focusTimeRemaining) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var focusProgress: Double {
        guard let session = activeFocusSession else { return 0 }
        let total = TimeInterval(session.targetMinutes * 60)
        guard total > 0 else { return 0 }
        return 1.0 - (focusTimeRemaining / total)
    }
}
