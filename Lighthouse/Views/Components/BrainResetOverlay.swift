import SwiftUI

// MARK: - Brain Reset Overlay
// Full-screen euphoric celebration when all daily challenges complete

struct BrainResetOverlay: View {
    let streakDay: Int
    var onDismiss: () -> Void

    @State private var beamScale: CGFloat = 0.01
    @State private var beamOpacity: Double = 0
    @State private var contentOpacity: Double = 0
    @State private var sparkPhase: Double = 0
    @State private var neuralSparks: [NeuralSpark] = NeuralSpark.generate(count: 32)
    @State private var titleScale: CGFloat = 0.6
    @State private var ringProgress: Double = 0

    var body: some View {
        ZStack {
            // Dark scrim
            Color.black.opacity(0.92).ignoresSafeArea()

            // Beam explosion from center
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

            // Neural sparks — floating upward
            ForEach(neuralSparks) { spark in
                NeuralSparkView(spark: spark, phase: sparkPhase)
            }

            // Main content
            VStack(spacing: LHSpacing.lg) {
                Spacer()

                // Pulsing clarity ring
                ZStack {
                    // Outer halo rings
                    ForEach(0..<3, id: \.self) { i in
                        Circle()
                            .stroke(
                                LHColor.teal.opacity(0.15 - Double(i) * 0.04),
                                lineWidth: 1
                            )
                            .frame(width: 130 + CGFloat(i) * 28, height: 130 + CGFloat(i) * 28)
                            .scaleEffect(1 + CGFloat(sparkPhase * 0.02 * Double(i + 1)))
                    }

                    // Gold completion ring
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

                    // Brain icon
                    VStack(spacing: 6) {
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 42, weight: .thin))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [LHColor.teal, LHColor.gold],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .shadow(color: LHColor.teal.opacity(0.8), radius: 16)
                    }
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

                // XP / stat pills
                HStack(spacing: LHSpacing.md) {
                    celebrationPill("flame.fill", "\(streakDay)", "Day streak", LHColor.streak)
                    celebrationPill("bolt.fill", "+50", "XP earned", LHColor.gold)
                    celebrationPill("brain.head.profile", "100%", "Clarity", LHColor.teal)
                }

                Spacer()

                // CTA
                VStack(spacing: LHSpacing.sm) {
                    GlowButton(title: "I Feel It 🔥", style: .gold) { onDismiss() }

                    Button("Continue") { onDismiss() }
                        .font(LHFont.caption(13))
                        .foregroundStyle(LHColor.textTertiary)
                }
                .padding(.horizontal, LHSpacing.xl)
                .padding(.bottom, LHSpacing.xxl)
            }
            .opacity(contentOpacity)
        }
        .onAppear { startAnimation() }
    }

    private func startAnimation() {
        // Beam burst
        withAnimation(.easeOut(duration: 0.6)) {
            beamScale = 1.5
            beamOpacity = 1.0
        }
        // Sparks
        withAnimation(.linear(duration: 12).repeatForever(autoreverses: false)) {
            sparkPhase = .pi * 2
        }
        // Content fade-in
        withAnimation(.easeOut(duration: 0.5).delay(0.3)) {
            contentOpacity = 1
        }
        withAnimation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.3)) {
            titleScale = 1.0
        }
        // Ring draw
        withAnimation(.easeInOut(duration: 1.2).delay(0.5)) {
            ringProgress = 1.0
        }
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

// MARK: - Neural Spark

struct NeuralSpark: Identifiable {
    let id = UUID()
    let x: CGFloat        // 0–1
    let baseY: CGFloat    // 0–1
    let size: CGFloat
    let speed: Double
    let color: Color
    let phaseOffset: Double

    static func generate(count: Int) -> [NeuralSpark] {
        let colors: [Color] = [LHColor.teal, LHColor.gold, LHColor.neural, .white]
        return (0..<count).map { _ in
            NeuralSpark(
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

private struct NeuralSparkView: View {
    let spark: NeuralSpark
    let phase: Double

    var body: some View {
        GeometryReader { geo in
            let dx = sin(phase * spark.speed * 0.08 + spark.phaseOffset) * 25
            let dy = -abs(cos(phase * spark.speed * 0.05 + spark.phaseOffset)) * 40
            let x = spark.x * geo.size.width + dx
            let y = spark.baseY * geo.size.height + dy
            let opacity = (0.3 + 0.5 * abs(sin(phase * spark.speed * 0.1 + spark.phaseOffset))) * 0.7

            Circle()
                .fill(spark.color)
                .frame(width: spark.size, height: spark.size)
                .blur(radius: spark.size * 0.35)
                .opacity(opacity)
                .position(x: x, y: y)
        }
    }
}
