import SwiftUI

// MARK: - Focus Celebration Overlay
// Beam sweep + particle burst when a focus session ends

struct FocusCelebrationOverlay: View {
    let minutesFocused: Int
    let xpEarned: Int
    var onDismiss: () -> Void

    @State private var beamAngle: Double = -40
    @State private var beamOpacity: Double = 0
    @State private var contentScale: CGFloat = 0.7
    @State private var contentOpacity: Double = 0
    @State private var sparkPhase: Double = 0
    @State private var sparks: [FocusSpark] = FocusSpark.generate(count: 24)
    @State private var ringProgress: Double = 0
    @State private var glowPulse: Bool = false

    var body: some View {
        ZStack {
            // Scrim
            Color.black.opacity(0.88).ignoresSafeArea()

            // Sweeping beam — rotates across the screen
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.clear,
                            LHColor.teal.opacity(0.12),
                            LHColor.gold.opacity(0.06),
                            Color.clear,
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 200)
                .blur(radius: 30)
                .rotationEffect(.degrees(beamAngle))
                .opacity(beamOpacity)
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 1.4), value: beamAngle)

            // Floating sparks
            ForEach(sparks) { spark in
                FocusSparkView(spark: spark, phase: sparkPhase)
            }

            // Main panel
            VStack(spacing: LHSpacing.lg) {
                Spacer()

                // Central ring + icon
                ZStack {
                    // Pulse rings
                    ForEach(0..<2, id: \.self) { i in
                        Circle()
                            .stroke(
                                LHColor.teal.opacity(glowPulse ? 0.18 : 0.08),
                                lineWidth: 1
                            )
                            .frame(width: 110 + CGFloat(i) * 26, height: 110 + CGFloat(i) * 26)
                            .animation(
                                .easeInOut(duration: 2.2 + Double(i) * 0.4).repeatForever(autoreverses: true),
                                value: glowPulse
                            )
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
                        .frame(width: 110, height: 110)
                        .shadow(color: LHColor.teal.opacity(0.6), radius: 10)

                    // Focus icon
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 36, weight: .thin))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [LHColor.teal, LHColor.gold],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(color: LHColor.teal.opacity(0.9), radius: 14)
                }

                // Title block
                VStack(spacing: LHSpacing.sm) {
                    Text("FOCUS COMPLETE")
                        .font(LHFont.caption(11))
                        .tracking(5)
                        .foregroundStyle(LHColor.teal)

                    Text("Deep Work\nUnlocked")
                        .font(LHFont.display(34))
                        .foregroundStyle(LHColor.textPrimary)
                        .multilineTextAlignment(.center)
                        .shadow(color: LHColor.teal.opacity(0.25), radius: 10)

                    Text("\(minutesFocused) min of undistracted clarity")
                        .font(LHFont.headline(15))
                        .foregroundStyle(LHColor.textSecondary)
                }

                // Stat pills
                HStack(spacing: LHSpacing.md) {
                    focusPill("timer", "\(minutesFocused)m", "Focused", LHColor.teal)
                    focusPill("bolt.fill", "+\(xpEarned)", "XP earned", LHColor.gold)
                    focusPill("brain.head.profile", "Flow", "State", LHColor.neural)
                }

                Spacer()

                // CTA
                VStack(spacing: LHSpacing.sm) {
                    GlowButton(title: "Keep the Streak ⚡", style: .teal) { onDismiss() }

                    Button("Dismiss") { onDismiss() }
                        .font(LHFont.caption(13))
                        .foregroundStyle(LHColor.textTertiary)
                }
                .padding(.horizontal, LHSpacing.xl)
                .padding(.bottom, LHSpacing.xxl)
            }
            .scaleEffect(contentScale)
            .opacity(contentOpacity)
        }
        .onAppear { startAnimation() }
    }

    private func startAnimation() {
        // Beam sweep
        withAnimation(.easeInOut(duration: 1.4)) {
            beamAngle = 40
            beamOpacity = 1.0
        }
        // Sparks loop
        withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
            sparkPhase = .pi * 2
        }
        // Content in
        withAnimation(.spring(response: 0.55, dampingFraction: 0.65).delay(0.25)) {
            contentScale = 1.0
            contentOpacity = 1.0
        }
        // Ring draw
        withAnimation(.easeInOut(duration: 1.0).delay(0.4)) {
            ringProgress = 1.0
        }
        // Pulse rings
        glowPulse = true
    }

    private func focusPill(_ icon: String, _ value: String, _ label: String, _ color: Color) -> some View {
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

// MARK: - Focus Spark

private struct FocusSpark: Identifiable {
    let id = UUID()
    let x: CGFloat
    let baseY: CGFloat
    let size: CGFloat
    let speed: Double
    let color: Color
    let phaseOffset: Double

    static func generate(count: Int) -> [FocusSpark] {
        let colors: [Color] = [LHColor.teal, LHColor.gold, .white, LHColor.teal]
        return (0..<count).map { _ in
            FocusSpark(
                x: CGFloat.random(in: 0.05...0.95),
                baseY: CGFloat.random(in: 0.1...0.9),
                size: CGFloat.random(in: 1.5...5),
                speed: Double.random(in: 5...12),
                color: colors.randomElement()!,
                phaseOffset: Double.random(in: 0...(.pi * 2))
            )
        }
    }
}

private struct FocusSparkView: View {
    let spark: FocusSpark
    let phase: Double

    var body: some View {
        GeometryReader { geo in
            let dx = cos(phase * spark.speed * 0.09 + spark.phaseOffset) * 20
            let dy = -abs(sin(phase * spark.speed * 0.06 + spark.phaseOffset)) * 35
            let x = spark.x * geo.size.width + dx
            let y = spark.baseY * geo.size.height + dy
            let opacity = (0.25 + 0.55 * abs(cos(phase * spark.speed * 0.11 + spark.phaseOffset))) * 0.75

            Circle()
                .fill(spark.color)
                .frame(width: spark.size, height: spark.size)
                .blur(radius: spark.size * 0.3)
                .opacity(opacity)
                .position(x: x, y: y)
        }
    }
}
