import SwiftUI
import SwiftData

struct GamificationView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @Query private var quests: [Quest]
    @Query private var badges: [Badge]

    private var profile: UserProfile? { profiles.first }
    private var engine: GamificationEngine { GamificationEngine.shared }

    private var activeQuests: [Quest] {
        quests.filter { !$0.isExpired }.sorted { !$0.isCompleted && $1.isCompleted }
    }
    private var dailyQuests: [Quest] { activeQuests.filter { $0.questType == .daily } }
    private var weeklyQuests: [Quest] { activeQuests.filter { $0.questType == .weekly } }

    var body: some View {
        NavigationStack {
            ZStack {
                LighthouseParticleBackground().ignoresSafeArea()
                ScrollView {
                VStack(spacing: LHSpacing.lg) {

                    // Level + streak header
                    if let profile {
                        VStack(spacing: LHSpacing.md) {
                            StreakFlameView(streak: profile.currentStreak)

                            LevelProgressView(profile: profile)
                                .padding(.horizontal, LHSpacing.lg)
                        }
                        .padding(.top, LHSpacing.md)
                    }

                    // Daily quests
                    if !dailyQuests.isEmpty {
                        questSection(title: "Daily Quests", subtitle: "Resets at midnight", quests: dailyQuests)
                    }

                    // Weekly quests
                    if !weeklyQuests.isEmpty {
                        questSection(title: "Weekly Quests", subtitle: "Resets Sunday", quests: weeklyQuests)
                    }

                    // Badges
                    BadgeGridView(earnedBadges: badges)
                        .padding(.horizontal, LHSpacing.lg)

                    Spacer().frame(height: LHSpacing.xxl)
                }
            }
            .scrollIndicators(.hidden)
            } // ZStack
            .background(LHColor.background)
            .navigationTitle("Quests")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .onAppear {
            engine.ensureQuestsExist(context: modelContext)
        }
    }

    private func questSection(title: String, subtitle: String, quests: [Quest]) -> some View {
        VStack(alignment: .leading, spacing: LHSpacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(LHFont.headline(18))
                        .foregroundStyle(LHColor.textPrimary)
                    Text(subtitle)
                        .font(LHFont.caption(12))
                        .foregroundStyle(LHColor.textTertiary)
                }
                Spacer()
                let completed = quests.filter(\.isCompleted).count
                Text("\(completed)/\(quests.count)")
                    .font(LHFont.caption(13))
                    .foregroundStyle(LHColor.textMuted)
            }

            ForEach(quests) { quest in
                QuestCardView(quest: quest)
            }
        }
        .padding(.horizontal, LHSpacing.lg)
    }
}
