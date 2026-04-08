import SwiftUI
import SwiftData

struct LevelProgressView: View {
    let profile: UserProfile
    @State private var animatedProgress: Double = 0

    private var currentLevel: LevelDefinition { LevelDefinition.current(for: profile.xp) }
    private var nextLevel: LevelDefinition? { LevelDefinition.next(for: profile.xp) }
    private var progress: Double { LevelDefinition.progressToNext(for: profile.xp) }

    var body: some View {
        VStack(spacing: LHSpacing.sm) {
            HStack(spacing: LHSpacing.md) {
                // Level icon
                ZStack {
                    Circle()
                        .fill(currentLevel.color.opacity(0.15))
                        .frame(width: 44, height: 44)
                    Image(systemName: currentLevel.icon)
                        .font(.system(size: 20))
                        .foregroundStyle(currentLevel.color)
                }

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: LHSpacing.sm) {
                        Text(currentLevel.name)
                            .font(LHFont.headline(15))
                            .foregroundStyle(currentLevel.color)
                        Text("Lv.\(currentLevel.level)")
                            .font(LHFont.caption(11))
                            .foregroundStyle(LHColor.textMuted)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(currentLevel.color.opacity(0.12))
                            .clipShape(Capsule())
                    }
                    Text(currentLevel.subtitle)
                        .font(LHFont.caption(12))
                        .foregroundStyle(LHColor.textTertiary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(profile.xp) XP")
                        .font(LHFont.headline(14))
                        .foregroundStyle(LHColor.textPrimary)
                    if let next = nextLevel {
                        Text("\(next.xpRequired - profile.xp) to \(next.name)")
                            .font(LHFont.caption(11))
                            .foregroundStyle(LHColor.textTertiary)
                    } else {
                        Text("Max Level")
                            .font(LHFont.caption(11))
                            .foregroundStyle(currentLevel.color)
                    }
                }
            }

            // XP Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(LHColor.surface)
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [currentLevel.color.opacity(0.7), currentLevel.color],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * animatedProgress, height: 8)

                    // Beam glow
                    RoundedRectangle(cornerRadius: 4)
                        .fill(currentLevel.color.opacity(0.4))
                        .frame(width: max(0, geo.size.width * animatedProgress - 4), height: 4)
                        .offset(x: 2, y: 0)
                        .blur(radius: 3)
                }
            }
            .frame(height: 8)
        }
        .padding(LHSpacing.md)
        .background(LHColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: LHRadius.md))
        .overlay(
            RoundedRectangle(cornerRadius: LHRadius.md)
                .stroke(currentLevel.color.opacity(0.2), lineWidth: 1)
        )
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                animatedProgress = progress
            }
        }
        .onChange(of: profile.xp) {
            withAnimation(.spring(response: 0.5)) {
                animatedProgress = progress
            }
        }
    }
}
