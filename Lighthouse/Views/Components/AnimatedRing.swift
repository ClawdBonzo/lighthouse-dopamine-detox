import SwiftUI

struct AnimatedRing: View {
    let progress: Double
    var size: CGFloat = 60
    var lineWidth: CGFloat = 4
    var color: Color = LHColor.teal
    var enableGlow: Bool = true

    @State private var animatedProgress: Double = 0
    @State private var glowPulse: Bool = false

    var body: some View {
        ZStack {
            // Outer glow halo
            if enableGlow && animatedProgress > 0.05 {
                Circle()
                    .stroke(color.opacity(glowPulse ? 0.18 : 0.10), lineWidth: lineWidth * 3)
                    .blur(radius: 6)
                    .frame(width: size + lineWidth * 2, height: size + lineWidth * 2)
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: glowPulse)
            }

            // Background track
            Circle()
                .stroke(color.opacity(0.10), lineWidth: lineWidth)

            // Progress arc with clarity gradient
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    AngularGradient(
                        colors: [
                            color.opacity(0.5),
                            color,
                            LHColor.gold.opacity(animatedProgress > 0.8 ? 0.8 : 0),
                            color,
                        ],
                        center: .center,
                        startAngle: .degrees(-90),
                        endAngle: .degrees(270)
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .shadow(color: color.opacity(0.5), radius: enableGlow ? 6 : 0)

            // Leading-edge glow dot
            if animatedProgress > 0.02 && enableGlow {
                let angle = (animatedProgress * 360 - 90) * .pi / 180
                let r = size / 2
                Circle()
                    .fill(color)
                    .frame(width: lineWidth * 1.8, height: lineWidth * 1.8)
                    .offset(x: r * CGFloat(cos(angle)), y: r * CGFloat(sin(angle)))
                    .shadow(color: color.opacity(0.9), radius: 4)
            }
        }
        .frame(width: size, height: size)
        .onChange(of: progress) { _, newValue in
            withAnimation(.spring(response: 0.6, dampingFraction: 0.78)) {
                animatedProgress = newValue
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.78).delay(0.2)) {
                animatedProgress = progress
            }
            glowPulse = true
        }
    }
}
