import SwiftUI

struct LevelUpOverlay: View {
    let data: LevelUpData
    var onDismiss: () -> Void

    @State private var beamScale: CGFloat = 0.1
    @State private var beamOpacity: Double = 0
    @State private var contentOpacity: Double = 0
    @State private var sparkleOffset: CGFloat = 0
    @State private var particlesVisible = false

    var body: some View {
        ZStack {
            // Dark overlay
            Color.black.opacity(0.85)
                .ignoresSafeArea()

            // Beam light burst
            RadialGradient(
                colors: [data.newLevel.color.opacity(0.4), data.newLevel.color.opacity(0.1), Color.clear],
                center: .center,
                startRadius: 0,
                endRadius: 300
            )
            .scaleEffect(beamScale)
            .opacity(beamOpacity)
            .ignoresSafeArea()

            VStack(spacing: LHSpacing.xl) {
                Spacer()

                // Level icon with glow ring
                ZStack {
                    Circle()
                        .fill(data.newLevel.color.opacity(0.1))
                        .frame(width: 160, height: 160)
                        .scaleEffect(beamScale > 0.5 ? 1.05 : 0.95)
                        .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: beamScale)

                    Circle()
                        .stroke(data.newLevel.color.opacity(0.4), lineWidth: 2)
                        .frame(width: 140, height: 140)

                    Image(systemName: data.newLevel.icon)
                        .font(.system(size: 64))
                        .foregroundStyle(data.newLevel.color)
                        .shadow(color: data.newLevel.color.opacity(0.8), radius: 20)
                }

                VStack(spacing: LHSpacing.md) {
                    Text("LEVEL UP!")
                        .font(LHFont.caption(14))
                        .tracking(4)
                        .foregroundStyle(data.newLevel.color)

                    Text(data.newLevel.name)
                        .font(LHFont.display(36))
                        .foregroundStyle(LHColor.textPrimary)

                    Text(data.newLevel.subtitle)
                        .font(LHFont.headline(16))
                        .foregroundStyle(LHColor.textSecondary)

                    // Level badge
                    HStack(spacing: LHSpacing.sm) {
                        Text("Lv.\(data.previousLevel.level)")
                            .foregroundStyle(LHColor.textMuted)
                        Image(systemName: "arrow.right")
                            .foregroundStyle(data.newLevel.color)
                        Text("Lv.\(data.newLevel.level)")
                            .foregroundStyle(data.newLevel.color)
                    }
                    .font(LHFont.headline(18))
                    .padding(.horizontal, LHSpacing.lg)
                    .padding(.vertical, LHSpacing.sm)
                    .background(data.newLevel.color.opacity(0.1))
                    .clipShape(Capsule())
                }

                Spacer()

                Button {
                    withAnimation(.easeIn(duration: 0.3)) {
                        contentOpacity = 0
                        beamOpacity = 0
                    }
                    // Swift 6 compliant delay — stays on @MainActor
                    Task { @MainActor in
                        try? await Task.sleep(for: .milliseconds(300))
                        onDismiss()
                    }
                } label: {
                    Text("Let's Go!")
                        .font(LHFont.headline(17))
                        .foregroundStyle(LHColor.background)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(data.newLevel.color)
                        .clipShape(RoundedRectangle(cornerRadius: LHRadius.lg))
                        .shadow(color: data.newLevel.color.opacity(0.4), radius: 12, y: 4)
                }
                .padding(.horizontal, LHSpacing.xxl)
                .padding(.bottom, LHSpacing.xxl)
            }
            .opacity(contentOpacity)
        }
        .onAppear {
            // Beam burst
            withAnimation(.easeOut(duration: 0.5)) {
                beamScale = 1.5
                beamOpacity = 1.0
            }
            // Content reveal
            withAnimation(.easeOut(duration: 0.4).delay(0.2)) {
                contentOpacity = 1.0
            }
        }
    }
}
