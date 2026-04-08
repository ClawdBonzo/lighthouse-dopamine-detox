import SwiftUI

struct QuestCardView: View {
    let quest: Quest
    @State private var animatedProgress: Double = 0

    private var def: QuestDefinition? { quest.definition }

    var body: some View {
        VStack(alignment: .leading, spacing: LHSpacing.sm) {
            HStack(spacing: LHSpacing.md) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: LHRadius.sm)
                        .fill((def?.iconColor ?? LHColor.teal).opacity(0.15))
                        .frame(width: 40, height: 40)
                    Image(systemName: def?.icon ?? "star.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(def?.iconColor ?? LHColor.teal)
                }

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: LHSpacing.sm) {
                        Text(def?.title ?? quest.questID)
                            .font(LHFont.headline(14))
                            .foregroundStyle(quest.isCompleted ? LHColor.textTertiary : LHColor.textPrimary)

                        if quest.questType == .weekly {
                            Text("WEEKLY")
                                .font(LHFont.caption(9))
                                .foregroundStyle(LHColor.gold)
                                .padding(.horizontal, 5)
                                .padding(.vertical, 2)
                                .background(LHColor.gold.opacity(0.12))
                                .clipShape(Capsule())
                        }
                    }
                    Text(def?.description ?? "")
                        .font(LHFont.caption(12))
                        .foregroundStyle(LHColor.textTertiary)
                }

                Spacer()

                // XP reward
                VStack(spacing: 2) {
                    Text("+\(quest.xpReward)")
                        .font(LHFont.headline(13))
                        .foregroundStyle(quest.isCompleted ? LHColor.success : LHColor.gold)
                    Text("XP")
                        .font(LHFont.caption(10))
                        .foregroundStyle(LHColor.textMuted)
                }
            }

            // Progress bar
            if !quest.isCompleted {
                VStack(alignment: .leading, spacing: 4) {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(LHColor.background)
                                .frame(height: 6)

                            RoundedRectangle(cornerRadius: 3)
                                .fill(
                                    LinearGradient(
                                        colors: [(def?.iconColor ?? LHColor.teal).opacity(0.7), def?.iconColor ?? LHColor.teal],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geo.size.width * animatedProgress, height: 6)
                        }
                    }
                    .frame(height: 6)

                    Text("\(quest.currentCount) / \(quest.targetCount)")
                        .font(LHFont.caption(11))
                        .foregroundStyle(LHColor.textTertiary)
                }
            } else {
                HStack(spacing: LHSpacing.sm) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(LHColor.success)
                        .font(.system(size: 14))
                    Text("Completed!")
                        .font(LHFont.caption(12))
                        .foregroundStyle(LHColor.success)
                }
            }
        }
        .padding(LHSpacing.md)
        .background(quest.isCompleted ? LHColor.success.opacity(0.05) : LHColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: LHRadius.md))
        .overlay(
            RoundedRectangle(cornerRadius: LHRadius.md)
                .stroke(
                    quest.isCompleted
                        ? LHColor.success.opacity(0.3)
                        : (def?.iconColor ?? LHColor.teal).opacity(0.1),
                    lineWidth: 1
                )
        )
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                animatedProgress = quest.progress
            }
        }
        .onChange(of: quest.currentCount) {
            withAnimation(.spring(response: 0.4)) {
                animatedProgress = quest.progress
            }
        }
    }
}
