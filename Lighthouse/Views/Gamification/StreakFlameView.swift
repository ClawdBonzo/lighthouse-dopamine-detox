import SwiftUI

struct StreakFlameView: View {
    let streak: Int
    @State private var flameScale: CGFloat = 1.0
    @State private var glowOpacity: Double = 0.6

    private var engine: GamificationEngine { GamificationEngine.shared }
    private var flameColor: Color { engine.streakFlameColor(for: streak) }
    private var multiplier: Double { engine.streakMultiplier(for: streak) }
    private var isHot: Bool { streak >= 7 }

    var body: some View {
        VStack(spacing: LHSpacing.sm) {
            ZStack {
                // Glow halo
                Circle()
                    .fill(flameColor.opacity(0.15))
                    .frame(width: 80, height: 80)
                    .opacity(glowOpacity)
                    .scaleEffect(flameScale * 1.1)

                // Flame icon
                Image(systemName: "flame.fill")
                    .font(.system(size: 44, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [flameColor, flameColor.opacity(0.6)],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .scaleEffect(flameScale)
                    .shadow(color: flameColor.opacity(0.6), radius: 12)
            }

            // Streak count
            Text("\(streak)")
                .font(LHFont.display(42))
                .foregroundStyle(flameColor)

            Text("day streak")
                .font(LHFont.caption(13))
                .foregroundStyle(LHColor.textTertiary)

            // Multiplier badge
            if multiplier > 1.0 {
                HStack(spacing: 4) {
                    Image(systemName: "multiply")
                        .font(.system(size: 10, weight: .bold))
                    Text(multiplier == multiplier.rounded() ? "\(Int(multiplier))x XP" : String(format: "%.1fx XP", multiplier))
                        .font(LHFont.caption(12))
                }
                .foregroundStyle(flameColor)
                .padding(.horizontal, LHSpacing.md)
                .padding(.vertical, 4)
                .background(flameColor.opacity(0.15))
                .clipShape(Capsule())
                .overlay(Capsule().stroke(flameColor.opacity(0.3), lineWidth: 1))
            }
        }
        .onAppear {
            guard isHot else { return }
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                flameScale = 1.08
                glowOpacity = 0.9
            }
        }
    }
}
