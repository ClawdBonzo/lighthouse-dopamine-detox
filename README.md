# Lighthouse — Dopamine Detox & Digital Minimalism Enforcer

A premium iOS app that helps users break phone addiction, rebuild deep focus, and track their transformation with daily challenges, streaks, and progress analytics.

## Tech Stack

- **iOS 18+** / Swift 6 / SwiftUI
- **SwiftData** for 100% on-device persistence (zero backend, zero tracking)
- **RevenueCat** for subscription management
- **SwiftUI Charts** for progress visualization
- **WidgetKit** for home screen widgets

## Features

### Onboarding (Woofz-style)
- Animated splash screen with CTA
- Personalized name input
- Screen-time and doomscrolling habits quiz
- Multi-select attention-hijacking app picker
- Daily commitment selector
- Animated loading screen with social proof
- Paywall with 3-day free trial (Weekly / Monthly / Yearly / Lifetime)

### Core App
- **Dashboard** — streak display, daily challenges, focus timer, reclaimed time stats
- **Daily Logger** — mood/energy tracking, screen time logging, gratitude & reflection journal
- **Streak Calendar** — visual calendar with detox day markers, recovery tools
- **Progress Charts** — focus minutes, mood trend, screen time charts (7D/30D/90D)
- **Focus Presets** — customizable timers (Deep Work, Pomodoro, Reading, etc.)
- **Settings** — profile, subscription management, data export, privacy controls

### Extras
- PDF report export
- Home screen widgets (streak glance + daily tip)
- Dark-first premium UI (deep navy + teal/gold accents)
- All data stays on-device — privacy by design

## Setup

### 1. Open in Xcode
```bash
open Lighthouse.xcodeproj
```
> You'll need to create the Xcode project first (see below).

### 2. Add RevenueCat SDK
In Xcode: **File → Add Package Dependencies**
- URL: `https://github.com/RevenueCat/purchases-ios.git`
- Version: Up to Next Major from `5.0.0`
- Add `RevenueCat` to the Lighthouse target

### 3. Configure RevenueCat API Key
Open `Lighthouse/Services/SubscriptionService.swift` and replace:
```swift
Purchases.configure(withAPIKey: "YOUR_REVENUECAT_API_KEY")
```

### 4. Set Bundle Identifier
Update the bundle ID in Xcode to match your RevenueCat project (e.g., `com.yourname.lighthouse`).

### 5. Add App Group (for Widgets)
Add the `group.com.lighthouse.app` App Group capability to both the main app target and the widget extension target.

### 6. Build & Run
Select an iOS 18+ simulator or device and hit Run.

## Project Structure

```
Lighthouse/
├── App/                    # App entry point, ContentView, tab routing
├── Theme/                  # Design system (colors, fonts, spacing, modifiers)
├── Models/                 # SwiftData models (6 models)
├── Services/               # Subscriptions, challenge engine, PDF export
├── ViewModels/             # Onboarding + Dashboard state management
├── Views/
│   ├── Onboarding/         # 7-step onboarding flow + paywall
│   ├── Dashboard/          # Main dashboard with challenges + focus timer
│   ├── Logger/             # Daily mood/energy/screen-time logger
│   ├── Streak/             # Calendar + recovery tools
│   ├── Progress/           # Charts (focus, mood, screen time)
│   ├── Focus/              # Focus presets + custom timer creation
│   ├── Settings/           # Profile, subscription, data, privacy
│   └── Components/         # GlowButton, StatCard, AnimatedRing
├── Extensions/             # Date helpers
└── Assets.xcassets/        # App icon, accent color

LighthouseWidgets/          # WidgetKit extension (streak + daily tip)
```

## Privacy

All user data is stored exclusively on-device using SwiftData. No analytics, no tracking, no servers. Your focus journey is yours alone.

## License

Proprietary. All rights reserved.
