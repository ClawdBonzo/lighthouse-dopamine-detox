import SwiftUI
import SwiftData

// MARK: - Badge Toast

struct BadgeToast: View {
    let badge: BadgeDefinition

    var body: some View {
        HStack(spacing: LHSpacing.md) {
            ZStack {
                Circle()
                    .fill(badge.iconColor.opacity(0.15))
                    .frame(width: 36, height: 36)
                Image(systemName: badge.icon)
                    .font(.system(size: 18))
                    .foregroundStyle(badge.iconColor)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("Badge Unlocked!")
                    .font(LHFont.caption(11))
                    .foregroundStyle(badge.rarity.color)
                    .tracking(1)
                Text(badge.name)
                    .font(LHFont.headline(14))
                    .foregroundStyle(LHColor.textPrimary)
            }

            Spacer()

            Text("+\(badge.xpReward) XP")
                .font(LHFont.caption(12))
                .foregroundStyle(LHColor.gold)
        }
        .padding(LHSpacing.md)
        .background(LHColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: LHRadius.md))
        .overlay(
            RoundedRectangle(cornerRadius: LHRadius.md)
                .stroke(badge.rarity.color.opacity(0.4), lineWidth: 1)
        )
        .shadow(color: badge.rarity.color.opacity(0.2), radius: 12)
        .padding(.horizontal, LHSpacing.lg)
        .padding(.top, LHSpacing.md)
    }
}

struct BadgeGridView: View {
    let earnedBadges: [Badge]

    private let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        VStack(alignment: .leading, spacing: LHSpacing.md) {
            HStack {
                Text("Badges")
                    .font(LHFont.headline(18))
                    .foregroundStyle(LHColor.textPrimary)
                Spacer()
                Text("\(earnedBadges.count)/\(BadgeDefinition.all.count)")
                    .font(LHFont.caption(13))
                    .foregroundStyle(LHColor.textTertiary)
            }

            LazyVGrid(columns: columns, spacing: LHSpacing.md) {
                ForEach(BadgeDefinition.all, id: \.id) { def in
                    let earned = earnedBadges.first { $0.badgeID == def.id }
                    BadgeTile(definition: def, earnedAt: earned?.earnedAt)
                }
            }
        }
    }
}

struct BadgeTile: View {
    let definition: BadgeDefinition
    let earnedAt: Date?

    private var isEarned: Bool { earnedAt != nil }

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                RoundedRectangle(cornerRadius: LHRadius.sm)
                    .fill(isEarned ? definition.iconColor.opacity(0.15) : LHColor.surface)
                    .frame(width: 56, height: 56)
                    .overlay(
                        RoundedRectangle(cornerRadius: LHRadius.sm)
                            .stroke(
                                isEarned ? definition.rarity.color.opacity(0.5) : Color.white.opacity(0.06),
                                lineWidth: isEarned ? 2 : 1
                            )
                    )

                if isEarned {
                    Image(systemName: definition.icon)
                        .font(.system(size: 24))
                        .foregroundStyle(definition.iconColor)

                    // Rarity shimmer dot
                    if definition.rarity != .common {
                        VStack {
                            HStack {
                                Spacer()
                                Circle()
                                    .fill(definition.rarity.color)
                                    .frame(width: 8, height: 8)
                                    .offset(x: 4, y: -4)
                            }
                            Spacer()
                        }
                        .frame(width: 56, height: 56)
                    }
                } else {
                    Image(systemName: definition.icon)
                        .font(.system(size: 24))
                        .foregroundStyle(LHColor.textMuted)
                        .opacity(0.3)
                }
            }

            Text(isEarned ? definition.name : "?????")
                .font(LHFont.caption(11))
                .foregroundStyle(isEarned ? LHColor.textSecondary : LHColor.textMuted)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
    }
}
