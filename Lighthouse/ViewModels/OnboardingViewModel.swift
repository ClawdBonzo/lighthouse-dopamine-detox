import Foundation
import SwiftData
import SwiftUI

enum OnboardingStep: Int, CaseIterable {
    case splash = 0
    case name
    case habits
    case apps
    case commitment
    case loading
    case paywall
}

@MainActor
@Observable
final class OnboardingViewModel {
    var currentStep: OnboardingStep = .splash
    var displayName: String = ""
    var dailyScreenTime: Double = 4.0
    var doomscrollFrequency: String = "sometimes"
    var selectedApps: Set<String> = []
    var commitmentMinutes: Int = 30
    var loadingProgress: Double = 0

    var isNameValid: Bool {
        displayName.trimmingCharacters(in: .whitespacesAndNewlines).count >= 2
    }

    // Available apps that hijack attention
    static let attentionApps: [(name: String, icon: String)] = [
        ("Instagram", "camera.fill"),
        ("TikTok", "play.rectangle.fill"),
        ("Twitter/X", "bubble.left.fill"),
        ("Facebook", "person.2.fill"),
        ("YouTube", "play.tv.fill"),
        ("Reddit", "text.bubble.fill"),
        ("Snapchat", "camera.viewfinder"),
        ("Netflix", "tv.fill"),
        ("News Apps", "newspaper.fill"),
        ("Dating Apps", "heart.fill"),
        ("Email", "envelope.fill"),
        ("Slack/Teams", "message.fill"),
        ("Games", "gamecontroller.fill"),
        ("Shopping", "cart.fill"),
        ("Threads", "number"),
        ("BeReal", "circle.dotted"),
    ]

    // Screen time options for quiz
    static let screenTimeOptions: [(label: String, hours: Double)] = [
        ("< 2 hours", 1.5),
        ("2-4 hours", 3.0),
        ("4-6 hours", 5.0),
        ("6-8 hours", 7.0),
        ("8+ hours", 9.0),
    ]

    static let doomscrollOptions: [(label: String, value: String, icon: String)] = [
        ("Rarely", "rarely", "hand.thumbsup.fill"),
        ("Sometimes", "sometimes", "hand.raised.fill"),
        ("Often", "often", "exclamationmark.triangle.fill"),
        ("Constantly", "constantly", "flame.fill"),
    ]

    static let commitmentOptions: [Int] = [10, 15, 20, 30, 45, 60]

    func advance() {
        withAnimation(.easeInOut(duration: 0.4)) {
            if let next = OnboardingStep(rawValue: currentStep.rawValue + 1) {
                currentStep = next
            }
        }
    }

    func goBack() {
        withAnimation(.easeInOut(duration: 0.4)) {
            if let prev = OnboardingStep(rawValue: currentStep.rawValue - 1) {
                currentStep = prev
            }
        }
    }

    func simulateLoading() async {
        for i in 1...20 {
            try? await Task.sleep(for: .milliseconds(150))
            loadingProgress = Double(i) / 20.0
        }
        try? await Task.sleep(for: .milliseconds(500))
        advance()
    }

    func createProfile(modelContext: ModelContext) -> UserProfile {
        let profile = UserProfile(
            displayName: displayName.trimmingCharacters(in: .whitespacesAndNewlines),
            dailyScreenTimeHours: dailyScreenTime,
            doomscrollFrequency: doomscrollFrequency,
            hijackingApps: Array(selectedApps),
            dailyCommitmentMinutes: commitmentMinutes
        )
        profile.hasCompletedOnboarding = true
        modelContext.insert(profile)
        try? modelContext.save()
        return profile
    }
}
