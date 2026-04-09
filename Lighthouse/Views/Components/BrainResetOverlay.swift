import SwiftUI

// MARK: - Brain Reset Overlay
// Full-screen euphoric celebration when all daily challenges complete.
//
// Performance notes:
// • 32 NeuralSpark particles drawn via a single Canvas (was 32 individual NeuralSparkView
//   each with their own GeometryReader — eliminated O(32) layout passes per frame)
// • TimelineView capped at 30 fps for particle animation — sufficient for overlay effect
// • @Environment(\.accessibilityReduceMotion) guard — static display when motion is reduced
// • .accessibilityHidden(true) on all decorative particle/glow layers

struct BrainResetOverlay: View {
    let streakDay: Int
    var onDismiss: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var beamScale: CGFloat = 0.01
    @State private var beamOpacity: Double = 0
    @State private var contentOpacity: Double = 0
    @State private var titleScale: CGFloat = 0.6
    @State private var ringProgress: Double = 0

    // Pre-generated spark pool — constant value type, safe across actor boundaries
    private let sparks: [NeuralSpark] = NeuralSpark.generate(count: 32)

    var body: some View {
        ZStack {
            // Scrim
            Color.black.opacity(0.92).ignoresSafeArea()

            // Beam explosion from center (decorative — hidden from VoiceOver)
            RadialGradient(
                colors: [
                    LHColor.teal.opacity(0.35),
                    LHColor.gold.opacity(0.15),
                    LHColor.neural.opacity(0.08),
                    Color.clear,
                ],
                center: .center,
                startRadius: 0,
                endRadius: 350
            )
            .scaleEffect(beamScale)
            .opacity(beamOpacity)
            .ignoresSafeArea()
            .animation(.easeOut(duration: 0.8), value: beamScale)
            .accessibilityHidden(true)

            // Single Canvas pass for all 32 neural sparks — 30 fps cap
            if !reduceMotion {
                TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { tl in
                    let t = tl.date.timeIntervalSinceReferenceDate
                    Canvas { ctx, size in
                        for spark in sparks {
                            let dx = sin(t * spark.speed * 0.08 + spark.phaseOffset) * 25.0
                            let dy = -abs(cos(t * spark.speed * 0.05 + spark.phaseOffset)) * 40.0
                            let px = spark.x * size.width + dx
                            let py = spark.baseY * size.height + dy
                            let alpha = (0.3 + 0.5 * abs(sin(t * spark.speed * 0.1 + spark.phaseOffset))) * 0.7

                            var inner = ctx
                            inner.opacity = alpha
                            inner.fill(
                                Path(ellipseIn: CGRect(
                                    x: px - spark.size / 2, y: py - spark.size / 2,
                                    width: spark.size, height: spark.size
                                )),
                                with: .color(spark.color)
                            )
                        }
                    }
                    .drawingGroup()
                    .allowsHitTesting(false)
                }
                .accessibilityHidden(true)
            }

            // Main accessible content
            VStack(spacing: LHSpacing.lg) {
                Spacer()

                // Pulsing clarity ring
                ZStack {
                    // Outer halo rings (decorative)
                    if !reduceMotion {
                        ForEach(0..<3, id: \.self) { i in
                            Circle()
                                .stroke(LHColor.teal.opacity(0.15 - Double(i) * 0.04), lineWidth: 1)
                                .frame(width: 130 + CGFloat(i) * 28, height: 130 + CGFloat(i) * 28)
                        }
                        .accessibilityHidden(true)
                    }

                    // Completion ring
                    Circle()
                        .trim(from: 0, to: ringProgress)
                        .stroke(
                            AngularGradient(
                                colors: [LHColor.teal, LHColor.gold, LHColor.teal],
                                center: .center,
                                startAngle: .degrees(-90),
                                endAngle: .degrees(270)
                            ),
                            style: StrokeStyle(lineWidth: 4, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .frame(width: 130, height: 130)
                        .shadow(color: LHColor.gold.opacity(0.6), radius: 12)
                        .accessibilityHidden(true)

                    // Brain icon
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 42, weight: .thin))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [LHColor.teal, LHColor.gold],
                                startPoint: .top, endPoint: .bottom
                            )
                        )
                        .shadow(color: LHColor.teal.opacity(0.8), radius: 16)
                        .accessibilityLabel("Brain reset complete")
                }

                // Title block
                VStack(spacing: LHSpacing.sm) {
                    Text("BRAIN RESET")
                        .font(LHFont.caption(12))
                        .tracking(5)
                        .foregroundStyle(LHColor.teal)

                    Text("Mental Fog\nCleared")
                        .font(LHFont.display(36))
                        .foregroundStyle(LHColor.textPrimary)
                        .multilineTextAlignment(.center)
                        .shadow(color: LHColor.gold.opacity(0.3), radius: 12)

                    Text("Day \(streakDay) of your detox journey")
                        .font(LHFont.headline(16))
                        .foregroundStyle(LHColor.textSecondary)
                }
                .scaleEffect(titleScale)
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Brain Reset! Mental fog cleared. Day \(streakDay) of your detox journey.")

                // Stat pills
                HStack(spacing: LHSpacing.md) {
                    celebrationPill("flame.fill", "\(streakDay)", "Day streak", LHColor.streak)
                    celebrationPill("bolt.fill", "+50",          "XP earned",  LHColor.gold)
                    celebrationPill("brain.head.profile", "100%", "Clarity",   LHColor.teal)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("\(streakDay) day streak. 50 XP earned. 100% clarity.")

                Spacer()

                // CTAs
                VStack(spacing: LHSpacing.sm) {
                    GlowButton(title: "I Feel It 🔥", style: .gold) { onDismiss() }
                        .accessibilityLabel("I feel it! Dismiss celebration")

                    Button("Continue") { onDismiss() }
                        .font(LHFont.caption(13))
                        .foregroundStyle(LHColor.textTertiary)
                        .accessibilityLabel("Continue")
                }
                .padding(.horizontal, LHSpacing.xl)
                .padding(.bottom, LHSpacing.xxl)
            }
            .opacity(contentOpacity)
        }
        .onAppear { startAnimation() }
        // Full overlay is announced as a modal for VoiceOver
        .accessibilityAddTraits(.isModal)
    }

    private func startAnimation() {
        guard !reduceMotion else {
            // Instant reveal for reduce-motion users
            beamScale = 1.5; beamOpacity = 1.0
            contentOpacity = 1.0; titleScale = 1.0; ringProgress = 1.0
            return
        }
        withAnimation(.easeOut(duration: 0.6))         { beamScale = 1.5; beamOpacity = 1.0 }
        withAnimation(.easeOut(duration: 0.5).delay(0.3))     { contentOpacity = 1 }
        withAnimation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.3)) { titleScale = 1.0 }
        withAnimation(.easeInOut(duration: 1.2).delay(0.5))   { ringProgress = 1.0 }
    }

    private func celebrationPill(_ icon: String, _ value: String, _ label: String, _ color: Color) -> some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 11))
                    .foregroundStyle(color)
                Text(value)
                    .font(LHFont.headline(14))
                    .foregroundStyle(LHColor.textPrimary)
            }
            Text(label)
                .font(LHFont.caption(10))
                .foregroundStyle(LHColor.textTertiary)
        }
        .padding(.horizontal, LHSpacing.md)
        .padding(.vertical, 10)
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: LHRadius.md))
        .overlay(RoundedRectangle(cornerRadius: LHRadius.md).stroke(color.opacity(0.25), lineWidth: 1))
    }
}

// MARK: - Neural Spark (value type, Sendable)

struct NeuralSpark: Identifiable, Sendable {
    let id: UUID
    let x: CGFloat
    let baseY: CGFloat
    let size: CGFloat
    let speed: Double
    let color: Color
    let phaseOffset: Double

    static func generate(count: Int) -> [NeuralSpark] {
        let colors: [Color] = [LHColor.teal, LHColor.gold, LHColor.neural, .white]
        return (0..<count).map { _ in
            NeuralSpark(
                id: UUID(),
                x: CGFloat.random(in: 0.05...0.95),
                baseY: CGFloat.random(in: 0.1...0.95),
                size: CGFloat.random(in: 2...6),
                speed: Double.random(in: 6...14),
                color: colors.randomElement()!,
                phaseOffset: Double.random(in: 0...(.pi * 2))
            )
        }
    }
}
