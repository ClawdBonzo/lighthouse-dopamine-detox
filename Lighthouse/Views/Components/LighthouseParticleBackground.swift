import SwiftUI

// MARK: - LighthouseParticleBackground
//
// Production-hardened animated background:
// • Respects .accessibilityReduceMotion — static gradient fallback, no animation
// • Device-tier throttling: 8 / 14 / 24 particles based on physical RAM
// • Single Canvas draw-pass for all animated elements (beam + particles + scan line)
//   — eliminates per-particle GeometryReader layout passes
// • .drawingGroup() forces Metal compositing of the Canvas layer
// • TimelineView capped at 30 fps — sufficient for a bg effect, saves ~50% GPU vs 60fps
// • .accessibilityHidden(true) — purely decorative, not VoiceOver-readable

struct LighthouseParticleBackground: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    // Computed once at type level — free after first call
    private static let particleCount: Int = {
        let gb = Int(ProcessInfo.processInfo.physicalMemory / (1024 * 1024 * 1024))
        switch gb {
        case ..<3:  return 8   // iPhone 12 mini and older
        case 3..<5: return 14  // iPhone 13/14 base
        default:    return 24  // iPhone 14 Pro, 15, 16
        }
    }()

    // Particle pool is a constant value type — safe to capture in Canvas closure
    private let particles: [ClarityParticle]

    init() {
        particles = ClarityParticle.pool(count: Self.particleCount)
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Deep navy base — always visible
                LHColor.background

                // Static radial blooms — no per-frame re-render
                ambientGlows(geo: geo)

                if !reduceMotion {
                    // All animated elements: beam + particles + scan line
                    // Single Canvas pass → single Metal draw call per frame
                    TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { tl in
                        let t = tl.date.timeIntervalSinceReferenceDate
                        Canvas { ctx, size in
                            drawBeam(ctx: ctx, size: size, t: t)
                            drawParticles(ctx: ctx, size: size, t: t)
                            drawScanLine(ctx: ctx, size: size, t: t)
                        }
                        .drawingGroup() // Metal GPU compositing
                    }
                    .allowsHitTesting(false)
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .accessibilityHidden(true)
    }

    // MARK: - Static Layers

    @ViewBuilder
    private func ambientGlows(geo: GeometryProxy) -> some View {
        // Teal bloom from bottom — lighthouse origin point
        RadialGradient(
            colors: [LHColor.teal.opacity(0.07), LHColor.teal.opacity(0.02), Color.clear],
            center: UnitPoint(x: 0.5, y: 1.1),
            startRadius: 0,
            endRadius: geo.size.height * 0.85
        )

        // Gold accent — upper trailing corner
        RadialGradient(
            colors: [LHColor.gold.opacity(0.04), Color.clear],
            center: UnitPoint(x: 0.88, y: 0.06),
            startRadius: 0,
            endRadius: 160
        )
    }

    // MARK: - Canvas Draw Functions

    // Lighthouse beam cone: sweeps gently left-right
    private func drawBeam(ctx: GraphicsContext, size: CGSize, t: TimeInterval) {
        let sway = sin(t * 0.26) * 18.0
        let origin = CGPoint(x: size.width / 2 + sway, y: size.height + 15)
        let spread = size.width * 0.52

        var path = Path()
        path.move(to: origin)
        path.addLine(to: CGPoint(x: size.width / 2 - spread, y: -15))
        path.addLine(to: CGPoint(x: size.width / 2 + spread, y: -15))
        path.closeSubpath()

        let pulse = 0.055 + sin(t * 0.9) * 0.015
        var c = ctx
        c.addFilter(.blur(radius: 22))
        c.drawLayer { inner in
            inner.fill(path, with: .color(LHColor.teal.opacity(pulse)))
        }
    }

    // Floating clarity particles — pre-computed positions from `t`
    private func drawParticles(ctx: GraphicsContext, size: CGSize, t: TimeInterval) {
        for p in particles {
            let dx = sin(t * p.speed * 0.07 + p.phaseOffset) * 18.0
            let dy = -cos(t * p.speed * 0.05 + p.phaseOffset) * 28.0
            let px = p.x * size.width + dx
            let py = p.startY * size.height + dy
            let alpha = p.opacity * (0.55 + 0.45 * sin(t * 1.8 + p.phaseOffset))

            var inner = ctx
            inner.opacity = alpha
            inner.fill(
                Path(ellipseIn: CGRect(x: px - p.size / 2, y: py - p.size / 2,
                                       width: p.size, height: p.size)),
                with: .color(p.color)
            )
        }
    }

    // Subtle horizontal scan line that drifts vertically
    private func drawScanLine(ctx: GraphicsContext, size: CGSize, t: TimeInterval) {
        let scanY = size.height * 0.72 + sin(t * 0.48) * 10.0
        var line = Path()
        line.move(to: CGPoint(x: 0, y: scanY))
        line.addLine(to: CGPoint(x: size.width, y: scanY))

        var c = ctx
        c.opacity = 0.10
        c.stroke(line, with: .color(LHColor.teal), lineWidth: 0.8)
    }
}

// MARK: - Clarity Particle (value type, Sendable)

struct ClarityParticle: Identifiable, Sendable {
    let id: UUID
    let x: CGFloat        // 0–1 normalized
    let startY: CGFloat   // 0–1 normalized
    let size: CGFloat
    let speed: Double
    let opacity: Double
    let color: Color
    let phaseOffset: Double

    static func pool(count: Int) -> [ClarityParticle] {
        let colors: [Color] = [
            LHColor.teal.opacity(0.75),
            LHColor.gold.opacity(0.60),
            Color.white.opacity(0.45),
            LHColor.teal.opacity(0.40),
        ]
        return (0..<count).map { _ in
            ClarityParticle(
                id: UUID(),
                x: CGFloat.random(in: 0.05...0.95),
                startY: CGFloat.random(in: 0.35...1.0),
                size: CGFloat.random(in: 1.5...5.0),
                speed: Double.random(in: 7...18),
                opacity: Double.random(in: 0.18...0.55),
                color: colors.randomElement()!,
                phaseOffset: Double.random(in: 0...(.pi * 2))
            )
        }
    }
}

// MARK: - Burst Particles (celebration use — Canvas-based, no individual views)

struct ParticleBurstView: View {
    let center: CGPoint
    let isActive: Bool
    let colors: [Color]

    @State private var burstParticles: [BurstParticle] = []
    @State private var progress: CGFloat = 0

    var body: some View {
        Canvas { ctx, _ in
            for p in burstParticles {
                let dx = p.distance * progress * cos(p.angle)
                let dy = p.distance * progress * sin(p.angle)
                let alpha = Double(1.0 - progress) * 0.9
                let sz = p.size * (1.0 - progress * 0.5)

                var inner = ctx
                inner.opacity = alpha
                inner.fill(
                    Path(ellipseIn: CGRect(x: p.x + dx - sz/2, y: p.y + dy - sz/2,
                                           width: sz, height: sz)),
                    with: .color(p.color)
                )
            }
        }
        .drawingGroup()
        .onChange(of: isActive) { _, active in
            guard active else { return }
            burstParticles = (0..<40).map { _ in
                BurstParticle(
                    x: center.x, y: center.y,
                    angle: Double.random(in: 0...(.pi * 2)),
                    distance: CGFloat.random(in: 60...200),
                    size: CGFloat.random(in: 4...10),
                    color: colors.randomElement() ?? LHColor.teal
                )
            }
            progress = 0
            withAnimation(.easeOut(duration: 1.2)) { progress = 1.0 }
        }
        .accessibilityHidden(true)
    }
}

struct BurstParticle: Identifiable {
    let id = UUID()
    let x, y: CGFloat
    let angle: Double
    let distance: CGFloat
    let size: CGFloat
    let color: Color
}
