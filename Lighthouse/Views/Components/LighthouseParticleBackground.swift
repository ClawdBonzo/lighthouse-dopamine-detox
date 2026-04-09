import SwiftUI

// MARK: - Global lighthouse beam + clarity particle background
// Drop this behind any screen: LighthouseParticleBackground().ignoresSafeArea()

struct LighthouseParticleBackground: View {
    @State private var beamPhase: CGFloat = 0
    @State private var beamPulse: Double = 0
    @State private var particles: [ClarityParticle] = ClarityParticle.pool()

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Deep navy base
                LHColor.background

                // Ambient radial bloom from bottom (lighthouse origin)
                RadialGradient(
                    colors: [
                        LHColor.teal.opacity(0.07 + beamPulse * 0.04),
                        LHColor.teal.opacity(0.02),
                        Color.clear,
                    ],
                    center: UnitPoint(x: 0.5, y: 1.1),
                    startRadius: 0,
                    endRadius: geo.size.height * 0.85
                )

                // Gold bloom — top corner accent
                RadialGradient(
                    colors: [LHColor.gold.opacity(0.05), Color.clear],
                    center: UnitPoint(x: 0.85, y: 0.08),
                    startRadius: 0,
                    endRadius: 180
                )

                // Sweeping beam cone
                BeamCone(phase: beamPhase)
                    .fill(
                        AngularGradient(
                            colors: [
                                Color.clear,
                                LHColor.teal.opacity(0.05 + beamPulse * 0.03),
                                LHColor.gold.opacity(0.03),
                                Color.clear,
                            ],
                            center: UnitPoint(x: 0.5, y: 1.05),
                            startAngle: .degrees(-8),
                            endAngle: .degrees(8)
                        )
                    )
                    .blur(radius: 20)
                    .frame(width: geo.size.width, height: geo.size.height)

                // Floating clarity particles
                ForEach(particles) { p in
                    ClarityParticleView(particle: p, phase: beamPhase)
                }

                // Subtle horizontal scan line at bottom
                LinearGradient(
                    colors: [Color.clear, LHColor.teal.opacity(0.06), Color.clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(height: 1)
                .blur(radius: 1)
                .offset(y: geo.size.height * 0.72 + sin(beamPhase * 0.5) * 12)
                .opacity(0.6)
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 24).repeatForever(autoreverses: false)) {
                beamPhase = .pi * 2
            }
            withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                beamPulse = 1
            }
        }
    }
}

// MARK: - Beam Cone Shape

private struct BeamCone: Shape {
    var phase: CGFloat
    var animatableData: CGFloat {
        get { phase }
        set { phase = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var p = Path()
        let origin = CGPoint(x: rect.midX + sin(phase * 0.3) * 20, y: rect.maxY + 20)
        let spread: CGFloat = rect.width * 0.55
        let topY: CGFloat = rect.minY - 20
        p.move(to: origin)
        p.addLine(to: CGPoint(x: rect.midX - spread, y: topY))
        p.addLine(to: CGPoint(x: rect.midX + spread, y: topY))
        p.closeSubpath()
        return p
    }
}

// MARK: - Clarity Particle

struct ClarityParticle: Identifiable {
    let id = UUID()
    let x: CGFloat        // 0–1 normalized
    let startY: CGFloat   // 0–1 normalized
    let size: CGFloat
    let speed: Double     // animation duration
    let opacity: Double
    let color: Color
    let phaseOffset: Double

    static func pool() -> [ClarityParticle] {
        let colors: [Color] = [
            LHColor.teal.opacity(0.7),
            LHColor.gold.opacity(0.6),
            Color.white.opacity(0.5),
            LHColor.teal.opacity(0.4),
        ]
        return (0..<24).map { _ in
            ClarityParticle(
                x: CGFloat.random(in: 0.05...0.95),
                startY: CGFloat.random(in: 0.4...1.0),
                size: CGFloat.random(in: 1.5...4.5),
                speed: Double.random(in: 8...18),
                opacity: Double.random(in: 0.2...0.55),
                color: colors.randomElement()!,
                phaseOffset: Double.random(in: 0...(.pi * 2))
            )
        }
    }
}

private struct ClarityParticleView: View {
    let particle: ClarityParticle
    let phase: CGFloat

    var body: some View {
        GeometryReader { geo in
            let driftX = sin(phase * particle.speed * 0.07 + particle.phaseOffset) * 18
            let driftY = -cos(phase * particle.speed * 0.05 + particle.phaseOffset) * 30
            let x = particle.x * geo.size.width + driftX
            let y = particle.startY * geo.size.height + driftY

            Circle()
                .fill(particle.color)
                .frame(width: particle.size, height: particle.size)
                .blur(radius: particle.size * 0.4)
                .opacity(particle.opacity * (0.6 + 0.4 * sin(phase * 2 + particle.phaseOffset)))
                .position(x: x, y: y)
        }
    }
}

// MARK: - Burst Particles (used on celebrations)

struct BurstParticle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    let angle: Double
    let distance: CGFloat
    let size: CGFloat
    let color: Color
}

struct ParticleBurstView: View {
    let center: CGPoint
    let isActive: Bool
    let colors: [Color]

    @State private var particles: [BurstParticle] = []
    @State private var animationProgress: CGFloat = 0

    var body: some View {
        Canvas { ctx, size in
            for p in particles {
                let dx = p.distance * animationProgress * CGFloat(cos(p.angle))
                let dy = p.distance * animationProgress * CGFloat(sin(p.angle))
                let opacity = Double(1.0 - animationProgress) * 0.9
                let pSize = p.size * (1.0 - animationProgress * 0.5)

                ctx.opacity = opacity
                ctx.fill(
                    Path(ellipseIn: CGRect(
                        x: p.x + dx - pSize/2,
                        y: p.y + dy - pSize/2,
                        width: pSize, height: pSize
                    )),
                    with: .color(p.color)
                )
            }
        }
        .onChange(of: isActive) { _, active in
            guard active else { return }
            particles = (0..<40).map { _ in
                BurstParticle(
                    x: center.x, y: center.y,
                    angle: Double.random(in: 0...(.pi * 2)),
                    distance: CGFloat.random(in: 60...200),
                    size: CGFloat.random(in: 4...10),
                    color: colors.randomElement() ?? LHColor.teal
                )
            }
            animationProgress = 0
            withAnimation(.easeOut(duration: 1.2)) {
                animationProgress = 1.0
            }
        }
    }
}
