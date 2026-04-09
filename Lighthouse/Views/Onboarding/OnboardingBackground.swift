import SwiftUI

struct OnboardingBackground: View {
    @State private var phase: CGFloat = 0
    @State private var beamPulse: CGFloat = 0
    @State private var particleOffsets: [ParticleState] = (0..<20).map { _ in ParticleState.random() }

    var body: some View {
        ZStack {
            // Deep navy base
            LHColor.background.ignoresSafeArea()

            // Slow-moving radial beam from bottom center (lighthouse origin)
            RadialGradient(
                colors: [
                    LHColor.teal.opacity(0.08 + beamPulse * 0.04),
                    LHColor.teal.opacity(0.03),
                    Color.clear,
                ],
                center: .bottom,
                startRadius: 0,
                endRadius: 500
            )
            .ignoresSafeArea()

            // Sweeping beam cone — slow rotation
            AngularGradient(
                colors: [
                    Color.clear,
                    LHColor.teal.opacity(0.06 + beamPulse * 0.03),
                    LHColor.gold.opacity(0.03),
                    Color.clear,
                    Color.clear,
                    Color.clear,
                ],
                center: .bottom,
                angle: .degrees(phase * 30 - 15)
            )
            .ignoresSafeArea()
            .blur(radius: 40)

            // Floating particles
            ForEach(particleOffsets.indices, id: \.self) { i in
                Circle()
                    .fill(particleOffsets[i].color)
                    .frame(width: particleOffsets[i].size, height: particleOffsets[i].size)
                    .blur(radius: particleOffsets[i].size * 0.3)
                    .offset(
                        x: particleOffsets[i].x + sin(phase * particleOffsets[i].speedX) * 20,
                        y: particleOffsets[i].y + cos(phase * particleOffsets[i].speedY) * 30
                    )
                    .opacity(particleOffsets[i].opacity)
            }

            // Subtle wave lines at bottom
            WaveLine(phase: phase, amplitude: 8, frequency: 1.5)
                .stroke(LHColor.teal.opacity(0.06), lineWidth: 1)
                .frame(height: 200)
                .offset(y: 300)

            WaveLine(phase: phase + 0.5, amplitude: 12, frequency: 1.0)
                .stroke(LHColor.gold.opacity(0.04), lineWidth: 1)
                .frame(height: 200)
                .offset(y: 320)
        }
        .onAppear {
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                phase = .pi * 2
            }
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                beamPulse = 1
            }
        }
    }
}

// MARK: - Particle State

private struct ParticleState {
    let x: CGFloat
    let y: CGFloat
    let size: CGFloat
    let opacity: Double
    let speedX: CGFloat
    let speedY: CGFloat
    let color: Color

    static func random() -> ParticleState {
        let colors: [Color] = [
            LHColor.teal.opacity(0.3),
            LHColor.gold.opacity(0.2),
            Color.white.opacity(0.15),
        ]
        return ParticleState(
            x: CGFloat.random(in: -200...200),
            y: CGFloat.random(in: -400...400),
            size: CGFloat.random(in: 2...6),
            opacity: Double.random(in: 0.15...0.4),
            speedX: CGFloat.random(in: 0.3...1.2),
            speedY: CGFloat.random(in: 0.2...0.8),
            color: colors.randomElement()!
        )
    }
}

// MARK: - Wave Line Shape

struct WaveLine: Shape {
    var phase: CGFloat
    var amplitude: CGFloat
    var frequency: CGFloat

    var animatableData: CGFloat {
        get { phase }
        set { phase = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let midY = rect.midY
        let step: CGFloat = 2

        path.move(to: CGPoint(x: 0, y: midY + sin(phase) * amplitude))
        var x: CGFloat = step
        while x <= rect.width {
            let relX = x / rect.width * .pi * 2 * frequency
            let y = midY + sin(relX + phase) * amplitude
            path.addLine(to: CGPoint(x: x, y: y))
            x += step
        }
        return path
    }
}
