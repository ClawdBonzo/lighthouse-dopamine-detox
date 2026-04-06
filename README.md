# Lighthouse

**Daily dopamine detox tracker · Break phone addiction · Reclaim your focus**

A beautiful, private SwiftUI habit tracker built with 100% on-device SwiftData.

## Features

- 7-step Woofz-style onboarding with personalized detox plan generation
- Daily dopamine detox challenges across 5 categories (mindfulness, digital, social, physical, creative)
- Streak tracking with calendar view and recovery tools (streak freeze, compassion reminders)
- Focus session timer with customizable presets (Deep Work, Pomodoro, Reading, Meditation, Exercise)
- Daily logger with mood, energy, screen time, gratitude, and reflection journaling
- Progress charts for focus hours gained, mood trends, and app usage over 7D/30D/90D
- Reclaimed time calculator showing hours won back from doomscrolling
- PDF report export of your entire detox journey
- Home screen widgets (streak glance + daily detox tip)
- RevenueCat subscriptions with 3-day free trial (Weekly, Monthly, Yearly, Lifetime)
- Premium dark-first UI with deep navy, teal, and gold accents
- All data stays on-device — zero tracking, zero servers, total privacy

## Tech Stack

- Swift 6 + SwiftUI
- SwiftData (100% local & private)
- RevenueCat
- WidgetKit + Swift Charts
- MVVM + @Observable

## Screenshots

| Onboarding | Dashboard | Streak Calendar | Progress |
|:---:|:---:|:---:|:---:|
| *placeholder* | *placeholder* | *placeholder* | *placeholder* |

(placeholder images — we will replace after asset integration)

## Quick Start

1. Open in Xcode 16+
2. Add RevenueCat SPM package (`https://github.com/RevenueCat/purchases-ios.git`, version `5.0.0`+)
3. Replace `YOUR_REVENUECAT_API_KEY` in `Lighthouse/Services/SubscriptionService.swift`
4. Add App Group `group.com.lighthouse.app` to both targets
5. Build & run on iOS 18+ simulator or device

Built as part of a 10-app portfolio targeting $10k+/mo each.

Made with ❤️ by ClawdBonzo
