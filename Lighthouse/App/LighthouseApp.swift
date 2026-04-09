import SwiftUI
import SwiftData

@main
struct LighthouseApp: App {
    let modelContainer: ModelContainer
    @State private var showSplash = true

    init() {
        do {
            let schema = Schema([
                UserProfile.self,
                DetoxChallenge.self,
                ScreenTimeLog.self,
                FocusSession.self,
                FocusPreset.self,
                DailyLog.self,
                Badge.self,
                Quest.self,
                XPRecord.self,
            ])
            let modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false
            )
            modelContainer = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }

        // Configure RevenueCat
        SubscriptionService.shared.configure()
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()
                    .preferredColorScheme(.dark)

                if showSplash {
                    AnimatedSplashScreen(isActive: $showSplash)
                        .transition(.opacity)
                        .zIndex(1)
                }
            }
        }
        .modelContainer(modelContainer)
    }
}

// MARK: - Animated Splash Screen

struct AnimatedSplashScreen: View {
    @Binding var isActive: Bool
    @State private var logoScale: CGFloat = 0.6
    @State private var logoOpacity: Double = 0
    @State private var beamOpacity: Double = 0
    @State private var textOpacity: Double = 0

    var body: some View {
        ZStack {
            // Background — matches Splash-Dark asset
            LHColor.background
                .ignoresSafeArea()

            // Subtle radial glow behind logo
            RadialGradient(
                colors: [LHColor.teal.opacity(0.15), Color.clear],
                center: .center,
                startRadius: 20,
                endRadius: 200
            )
            .frame(width: 400, height: 400)
            .opacity(beamOpacity)

            VStack(spacing: LHSpacing.lg) {
                Spacer()

                // Brand icon with glow pulse
                ZStack {
                    Circle()
                        .fill(LHColor.teal.opacity(0.08))
                        .frame(width: 180, height: 180)
                        .scaleEffect(beamOpacity > 0.5 ? 1.1 : 0.9)

                    Image("BrandIcon")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 120, height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 28))
                        .shadow(color: LHColor.teal.opacity(0.4), radius: 24, y: 4)
                }
                .scaleEffect(logoScale)
                .opacity(logoOpacity)

                VStack(spacing: LHSpacing.sm) {
                    Text("Lighthouse")
                        .font(LHFont.display(34))
                        .foregroundStyle(LHColor.textPrimary)

                    Text("Dopamine Detox")
                        .font(LHFont.headline(16))
                        .foregroundStyle(LHColor.teal)
                }
                .opacity(textOpacity)

                Spacer()
                Spacer()
            }
        }
        .onAppear {
            // Logo fades in + scales up
            withAnimation(.easeOut(duration: 0.6)) {
                logoOpacity = 1
                logoScale = 1.0
            }
            // Beam glow pulses in
            withAnimation(.easeInOut(duration: 0.8).delay(0.3)) {
                beamOpacity = 1.0
            }
            // Text fades in
            withAnimation(.easeOut(duration: 0.5).delay(0.5)) {
                textOpacity = 1.0
            }
            // Dismiss after 2 seconds — Task keeps us on MainActor (Swift 6 safe)
            Task { @MainActor in
                try? await Task.sleep(for: .seconds(2.0))
                withAnimation(.easeInOut(duration: 0.4)) {
                    isActive = false
                }
            }
        }
    }
}
