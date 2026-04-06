import Foundation
import SwiftData

@MainActor
struct ChallengeEngine {

    // MARK: - Challenge Templates

    static let templates: [(title: String, subtitle: String, category: String, difficulty: Int, duration: Int, icon: String)] = [
        // Mindfulness
        ("5-Minute Breathing", "Close your eyes and focus on deep breaths", "mindfulness", 1, 5, "wind"),
        ("Body Scan Meditation", "Progressively relax each muscle group", "mindfulness", 2, 15, "figure.mind.and.body"),
        ("Gratitude Journaling", "Write 3 things you're grateful for today", "mindfulness", 1, 10, "heart.text.clipboard"),
        ("Mindful Walk", "Take a 15-minute walk without your phone", "mindfulness", 2, 15, "figure.walk"),
        ("Digital Sunset", "No screens 1 hour before bed tonight", "mindfulness", 3, 60, "sunset.fill"),

        // Digital Detox
        ("App-Free Hour", "Put your phone in another room for 1 hour", "digital", 2, 60, "iphone.slash"),
        ("No Social Media Morning", "Don't open social media until noon", "digital", 3, 240, "hand.raised.fill"),
        ("Notification Audit", "Turn off non-essential notifications", "digital", 1, 15, "bell.slash.fill"),
        ("Single-Tab Challenge", "Browse with only one tab open", "digital", 2, 30, "rectangle.on.rectangle.slash"),
        ("Grayscale Mode", "Set your phone to grayscale for the day", "digital", 2, 480, "circle.lefthalf.filled"),

        // Social
        ("Phone-Free Meal", "Eat without looking at any screen", "social", 1, 30, "fork.knife"),
        ("Face-to-Face Talk", "Have a 15-minute in-person conversation", "social", 2, 15, "person.2.fill"),
        ("Handwrite a Note", "Write a physical letter or note to someone", "social", 2, 20, "envelope.fill"),
        ("Eye Contact Practice", "Maintain eye contact in conversations today", "social", 1, 5, "eye.fill"),
        ("Device-Free Hangout", "Spend 1 hour with friends, no devices", "social", 3, 60, "person.3.fill"),

        // Physical
        ("Stretch Break", "Do a 10-minute full body stretch", "physical", 1, 10, "figure.flexibility"),
        ("Cold Shower Challenge", "End your shower with 30 seconds of cold water", "physical", 3, 1, "drop.fill"),
        ("Outdoor Time", "Spend 30 minutes outside without your phone", "physical", 2, 30, "sun.max.fill"),
        ("Dance Break", "Put on music and dance for 5 minutes", "physical", 1, 5, "music.note"),
        ("7-Minute Workout", "Complete a quick bodyweight circuit", "physical", 2, 7, "figure.highintensity.intervaltraining"),

        // Creative
        ("Sketch Something", "Draw anything for 15 minutes", "creative", 1, 15, "paintbrush.fill"),
        ("Write a Poem", "Express yourself in verse", "creative", 2, 20, "text.book.closed.fill"),
        ("Learn a New Word", "Find and memorize an interesting new word", "creative", 1, 5, "character.book.closed.fill"),
        ("Cook Without a Recipe", "Make a meal from intuition", "creative", 3, 45, "frying.pan.fill"),
        ("Analog Hour", "Create something with your hands — no screens", "creative", 2, 60, "hand.draw.fill"),
    ]

    // MARK: - Generate Daily Challenges

    static func generateDailyChallenges(for profile: UserProfile, existingToday: [DetoxChallenge]) -> [DetoxChallenge] {
        guard existingToday.isEmpty else { return existingToday }

        let commitmentMinutes = profile.dailyCommitmentMinutes
        var selected: [(String, String, String, Int, Int, String)] = []
        var totalDuration = 0
        var usedCategories = Set<String>()
        var shuffled = templates.shuffled()

        // Pick challenges that fit within commitment time, spread across categories
        while totalDuration < commitmentMinutes && !shuffled.isEmpty {
            if let index = shuffled.firstIndex(where: { template in
                !usedCategories.contains(template.category) &&
                totalDuration + template.duration <= commitmentMinutes + 10
            }) {
                let pick = shuffled.remove(at: index)
                selected.append(pick)
                totalDuration += pick.duration
                usedCategories.insert(pick.category)
            } else if let index = shuffled.firstIndex(where: { template in
                totalDuration + template.duration <= commitmentMinutes + 10
            }) {
                let pick = shuffled.remove(at: index)
                selected.append(pick)
                totalDuration += pick.duration
            } else {
                break
            }
        }

        // Ensure at least 1 challenge
        if selected.isEmpty, let first = templates.randomElement() {
            selected.append(first)
        }

        return selected.map { template in
            DetoxChallenge(
                title: template.0,
                subtitle: template.1,
                category: template.2,
                difficulty: template.3,
                durationMinutes: template.4,
                iconName: template.5,
                assignedDate: Calendar.current.startOfDay(for: .now),
                focusPointsReward: template.3 * 5
            )
        }
    }

    // MARK: - Daily Tips

    static let dailyTips: [String] = [
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
        "Your longest streak shows what you're truly capable of.",
        "The urge to check your phone peaks at 10 minutes, then fades.",
        "Screen time before bed reduces sleep quality by up to 50%.",
        "Three deep breaths can reset your craving to pick up your phone.",
    ]

    static var todaysTip: String {
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: .now) ?? 0
        return dailyTips[dayOfYear % dailyTips.count]
    }
}
