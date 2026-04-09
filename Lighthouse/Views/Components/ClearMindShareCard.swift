import SwiftUI

// MARK: - Clear Mind Share Card
// Viral "Clear Mind Day X" story template — one-tap share via UIActivityViewController

struct ClearMindShareCard: View {
    let streakDay: Int
    let focusMinutes: Int
    let challengesCompleted: Int
    var onDismiss: () -> Void

    @State private var beamPhase: Double = 0
    @State private var appeared: Bool = false

    var body: some View {
        ZStack {
            // Scrim
            Color.black.opacity(0.85).ignoresSafeArea()
                .onTapGesture { onDismiss() }

            VStack(spacing: LHSpacing.lg) {
                Spacer()

                // Card
                shareCardContent
                    .scaleEffect(appeared ? 1 : 0.85)
                    .opacity(appeared ? 1 : 0)

                // Actions
                VStack(spacing: LHSpacing.sm) {
                    GlowButton(title: "Share My Journey", icon: "square.and.arrow.up", style: .gold) {
                        shareCard()
                    }
                    Button("Close") { onDismiss() }
                        .font(LHFont.caption(13))
                        .foregroundStyle(LHColor.textTertiary)
                }
                .padding(.horizontal, LHSpacing.xl)
                .padding(.bottom, LHSpacing.xxl)
                .scaleEffect(appeared ? 1 : 0.9)
                .opacity(appeared ? 1 : 0)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                appeared = true
            }
            withAnimation(.linear(duration: 16).repeatForever(autoreverses: false)) {
                beamPhase = .pi * 2
            }
        }
    }

    // MARK: - Card Visual

    private var shareCardContent: some View {
        ZStack {
            // Card background
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(hex: "080F1E"))

            // Beam background
            RadialGradient(
                colors: [
                    LHColor.teal.opacity(0.18),
                    LHColor.gold.opacity(0.06),
                    Color.clear,
                ],
                center: UnitPoint(x: 0.5, y: 1.05),
                startRadius: 0,
                endRadius: 260
            )
            .clipShape(RoundedRectangle(cornerRadius: 24))

            // Animated beam cone
            BeamConeShare(phase: beamPhase)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.clear,
                            LHColor.teal.opacity(0.07 + sin(beamPhase * 0.5) * 0.03),
                            Color.clear,
                        ],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
                .blur(radius: 12)
                .clipShape(RoundedRectangle(cornerRadius: 24))

            // Border
            RoundedRectangle(cornerRadius: 24)
                .stroke(
                    LinearGradient(
                        colors: [LHColor.teal.opacity(0.4), LHColor.gold.opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )

            // Content
            VStack(spacing: LHSpacing.lg) {
                // App brand
                HStack(spacing: 8) {
                    Image("BrandIcon")
                        .resizable()
                        .frame(width: 28, height: 28)
                    Text("Lighthouse")
                        .font(LHFont.headline(16))
                        .foregroundStyle(LHColor.textPrimary)
                    Spacer()
                    Text("Focus & Detox")
                        .font(LHFont.caption(11))
                        .foregroundStyle(LHColor.textTertiary)
                }

                // Day badge
                ZStack {
                    Circle()
                        .fill(LHColor.teal.opacity(0.12))
                        .frame(width: 100, height: 100)
                        .overlay(Circle().stroke(LHColor.teal.opacity(0.3), lineWidth: 1.5))
                        .shadow(color: LHColor.teal.opacity(0.4), radius: 20)

                    VStack(spacing: 2) {
                        Text("DAY")
                            .font(LHFont.caption(11))
                            .tracking(3)
                            .foregroundStyle(LHColor.teal)
                        Text("\(streakDay)")
                            .font(LHFont.display(40))
                            .foregroundStyle(LHColor.textPrimary)
                    }
                }

                // Headline
                VStack(spacing: 6) {
                    Text("Clear Mind")
                        .font(LHFont.display(28))
                        .foregroundStyle(LHColor.textPrimary)

                    Text("Reclaiming my focus, one day at a time.")
                        .font(LHFont.caption(14))
                        .foregroundStyle(LHColor.textSecondary)
                        .multilineTextAlignment(.center)
                }

                // Stats row
                HStack(spacing: 0) {
                    shareStatPill("timer", "\(focusMinutes)m", "focused", LHColor.teal)
                    Divider()
                        .frame(width: 1, height: 32)
                        .background(LHColor.textMuted)
                    shareStatPill("checkmark.circle", "\(challengesCompleted)", "challenges", LHColor.gold)
                    Divider()
                        .frame(width: 1, height: 32)
                        .background(LHColor.textMuted)
                    shareStatPill("flame.fill", "\(streakDay)", "day streak", LHColor.streak)
                }
                .padding(.vertical, LHSpacing.sm)
                .background(LHColor.teal.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: LHRadius.md))
                .overlay(RoundedRectangle(cornerRadius: LHRadius.md).stroke(LHColor.teal.opacity(0.1), lineWidth: 1))

                // Watermark
                Text("lighthouse.app — take back your attention")
                    .font(LHFont.caption(10))
                    .tracking(1)
                    .foregroundStyle(LHColor.textMuted)
            }
            .padding(LHSpacing.xl)
        }
        .frame(maxWidth: 360)
        .padding(.horizontal, LHSpacing.lg)
    }

    private func shareStatPill(_ icon: String, _ value: String, _ label: String, _ color: Color) -> some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 11))
                    .foregroundStyle(color)
                Text(value)
                    .font(LHFont.headline(15))
                    .foregroundStyle(LHColor.textPrimary)
            }
            Text(label)
                .font(LHFont.caption(10))
                .foregroundStyle(LHColor.textTertiary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Share Action

    private func shareCard() {
        let renderer = ImageRenderer(content:
            shareCardContent
                .frame(width: 360)
                .environment(\.colorScheme, .dark)
        )
        renderer.scale = 3.0
        guard let uiImage = renderer.uiImage else { return }

        let text = "Day \(streakDay) of my Dopamine Detox 🧠⚡ Reclaiming my focus with Lighthouse. Join me!"
        let items: [Any] = [uiImage, text]

        let av = UIActivityViewController(activityItems: items, applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let root = windowScene.windows.first?.rootViewController {
            root.present(av, animated: true)
        }
    }
}

// MARK: - Beam Shape for Share Card

private struct BeamConeShare: Shape {
    var phase: Double
    var animatableData: Double {
        get { phase }
        set { phase = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var p = Path()
        let ox = rect.midX + CGFloat(sin(phase * 0.25)) * 15
        let origin = CGPoint(x: ox, y: rect.maxY + 10)
        let spread: CGFloat = rect.width * 0.4
        p.move(to: origin)
        p.addLine(to: CGPoint(x: rect.midX - spread, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.midX + spread, y: rect.minY))
        p.closeSubpath()
        return p
    }
}
