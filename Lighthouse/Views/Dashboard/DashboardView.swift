import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = DashboardViewModel()
    @State private var showFocusPresets = false
    @Query(filter: #Predicate<Quest> { !$0.isCompleted }) private var activeQuests: [Quest]

    var body: some View {
        NavigationStack {
            ZStack {
                // Global animated background
                LighthouseParticleBackground().ignoresSafeArea()

                ScrollView {
                    VStack(spacing: LHSpacing.lg) {
                        // Greeting header
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(viewModel.greetingText)
                                    .font(LHFont.headline(20))
                                    .foregroundStyle(LHColor.textPrimary)

                                Text(ChallengeEngine.todaysTip)
                                    .font(LHFont.caption(13))
                                    .foregroundStyle(LHColor.textTertiary)
                                    .lineLimit(2)
                            }
                            Spacer()

                            // Streak badge
                            VStack(spacing: 2) {
                                Text("\(viewModel.currentStreak)")
                                    .font(LHFont.display(28))
                                    .foregroundStyle(LHColor.streak)
                                Text("streak")
                                    .font(LHFont.caption(11))
                                    .foregroundStyle(LHColor.textTertiary)
                            }
                            .frame(width: 64, height: 64)
                            .background(LHColor.streak.opacity(0.1))
                            .clipShape(Circle())
                            .overlay(Circle().stroke(LHColor.streak.opacity(0.3), lineWidth: 2))
                        }
                        .padding(.horizontal, LHSpacing.lg)

                        // Level progress bar
                        if let profile = viewModel.profile {
                            LevelProgressView(profile: profile)
                                .padding(.horizontal, LHSpacing.lg)
                        }

                        // Stats row
                        HStack(spacing: LHSpacing.md) {
                            StatCard(
                                title: "Focus Today",
                                value: "\(viewModel.reclaimedTimeToday)m",
                                icon: "brain.head.profile",
                                color: LHColor.teal
                            )
                            StatCard(
                                title: "Challenges",
                                value: "\(viewModel.completedChallengesCount)/\(viewModel.todayChallenges.count)",
                                icon: "checkmark.circle",
                                color: LHColor.gold
                            )
                            StatCard(
                                title: "Total Days",
                                value: "\(viewModel.profile?.totalDetoxDays ?? 0)",
                                icon: "calendar",
                                color: LHColor.success
                            )
                        }
                        .padding(.horizontal, LHSpacing.lg)

                        // Active focus session
                        if viewModel.showingFocusTimer {
                            focusTimerCard
                                .padding(.horizontal, LHSpacing.lg)
                        }

                        // Quick focus start
                        if !viewModel.showingFocusTimer {
                            Button {
                                showFocusPresets = true
                            } label: {
                                HStack {
                                    Image(systemName: "play.fill")
                                        .font(.system(size: 16))
                                    Text("Start Focus Session")
                                        .font(LHFont.headline(15))
                                }
                                .foregroundStyle(LHColor.teal)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(LHColor.teal.opacity(0.08))
                                .clipShape(RoundedRectangle(cornerRadius: LHRadius.md))
                                .overlay(
                                    RoundedRectangle(cornerRadius: LHRadius.md)
                                        .stroke(LHColor.teal.opacity(0.3), lineWidth: 1)
                                )
                            }
                            .padding(.horizontal, LHSpacing.lg)
                        }

                        // Active quests preview (up to 2)
                        if !activeQuests.isEmpty {
                            VStack(alignment: .leading, spacing: LHSpacing.md) {
                                HStack {
                                    Text("Active Quests")
                                        .font(LHFont.headline(18))
                                        .foregroundStyle(LHColor.textPrimary)
                                    Spacer()
                                    Text("\(activeQuests.count) active")
                                        .font(LHFont.caption(13))
                                        .foregroundStyle(LHColor.textTertiary)
                                }
                                ForEach(activeQuests.prefix(2)) { quest in
                                    QuestCardView(quest: quest)
                                }
                            }
                            .padding(.horizontal, LHSpacing.lg)
                        }

                        // Today's challenges
                        VStack(alignment: .leading, spacing: LHSpacing.md) {
                            HStack {
                                Text("Today's Challenges")
                                    .font(LHFont.headline(18))
                                    .foregroundStyle(LHColor.textPrimary)
                                Spacer()

                                // Progress ring
                                AnimatedRing(progress: viewModel.challengeCompletionRate, size: 32, lineWidth: 3, color: LHColor.teal)
                            }

                            ForEach(viewModel.todayChallenges, id: \.id) { challenge in
                                ChallengeCard(challenge: challenge) {
                                    withAnimation(.spring(response: 0.4)) {
                                        viewModel.completeChallenge(challenge, modelContext: modelContext)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, LHSpacing.lg)

                        // Share card button (only when streak > 0)
                        if viewModel.currentStreak > 0 {
                            Button {
                                viewModel.showShareCard = true
                            } label: {
                                HStack(spacing: LHSpacing.sm) {
                                    Image(systemName: "square.and.arrow.up")
                                        .font(.system(size: 14))
                                    Text("Share Day \(viewModel.currentStreak)")
                                        .font(LHFont.caption(13))
                                }
                                .foregroundStyle(LHColor.gold)
                                .padding(.horizontal, LHSpacing.md)
                                .padding(.vertical, 8)
                                .background(LHColor.gold.opacity(0.08))
                                .clipShape(Capsule())
                                .overlay(Capsule().stroke(LHColor.gold.opacity(0.2), lineWidth: 1))
                            }
                        }

                        Spacer().frame(height: LHSpacing.xxl)
                    }
                    .padding(.top, LHSpacing.md)
                }
                .scrollIndicators(.hidden)

                // Brain Reset Overlay
                if viewModel.showBrainReset {
                    BrainResetOverlay(streakDay: viewModel.currentStreak) {
                        withAnimation(.easeOut(duration: 0.3)) {
                            viewModel.showBrainReset = false
                        }
                    }
                    .transition(.opacity)
                    .zIndex(20)
                }

                // Focus Celebration Overlay
                if viewModel.showFocusCelebration {
                    FocusCelebrationOverlay(
                        minutesFocused: viewModel.lastFocusMinutes,
                        xpEarned: viewModel.lastFocusXP
                    ) {
                        withAnimation(.easeOut(duration: 0.3)) {
                            viewModel.showFocusCelebration = false
                        }
                    }
                    .transition(.opacity)
                    .zIndex(19)
                }

                // Share Card
                if viewModel.showShareCard {
                    ClearMindShareCard(
                        streakDay: viewModel.currentStreak,
                        focusMinutes: viewModel.reclaimedTimeToday,
                        challengesCompleted: viewModel.completedChallengesCount
                    ) {
                        withAnimation(.easeOut(duration: 0.25)) {
                            viewModel.showShareCard = false
                        }
                    }
                    .transition(.opacity)
                    .zIndex(18)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showFocusPresets) {
                FocusPresetsView { preset in
                    viewModel.startFocusSession(preset: preset, modelContext: modelContext)
                    showFocusPresets = false
                }
                .presentationDetents([.medium])
            }
        }
        .onAppear {
            viewModel.loadTodayData(modelContext: modelContext)
        }
    }

    // MARK: - Focus Timer Card

    private var focusTimerCard: some View {
        VStack(spacing: LHSpacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.activeFocusSession?.presetName ?? "Focus Session")
                        .font(LHFont.headline(16))
                        .foregroundStyle(LHColor.textPrimary)
                    Text("Stay focused — you've got this")
                        .font(LHFont.caption(13))
                        .foregroundStyle(LHColor.textTertiary)
                }
                Spacer()
            }

            // Timer display
            ZStack {
                AnimatedRing(progress: viewModel.focusProgress, size: 120, lineWidth: 6, color: LHColor.teal)

                VStack(spacing: 2) {
                    Text(viewModel.focusTimerDisplay)
                        .font(LHFont.mono(32))
                        .foregroundStyle(LHColor.textPrimary)
                    Text("remaining")
                        .font(LHFont.caption(11))
                        .foregroundStyle(LHColor.textTertiary)
                }
            }

            Button {
                viewModel.endFocusSession(modelContext: modelContext)
            } label: {
                Text("End Session")
                    .font(LHFont.headline(14))
                    .foregroundStyle(LHColor.streak)
                    .padding(.horizontal, LHSpacing.lg)
                    .padding(.vertical, LHSpacing.sm)
                    .background(LHColor.streak.opacity(0.1))
                    .clipShape(Capsule())
            }
        }
        .lhGlowCard(color: LHColor.teal)
    }
}

// MARK: - Challenge Card

struct ChallengeCard: View {
    let challenge: DetoxChallenge
    let onComplete: () -> Void

    var body: some View {
        HStack(spacing: LHSpacing.md) {
            // Icon
            Image(systemName: challenge.iconName)
                .font(.system(size: 20))
                .foregroundStyle(Color(hex: challenge.categoryColor))
                .frame(width: 44, height: 44)
                .background(Color(hex: challenge.categoryColor).opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: LHRadius.sm))

            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(challenge.title)
                    .font(LHFont.headline(15))
                    .foregroundStyle(challenge.isCompleted ? LHColor.textTertiary : LHColor.textPrimary)
                    .strikethrough(challenge.isCompleted)

                HStack(spacing: LHSpacing.sm) {
                    Text("\(challenge.durationMinutes)m")
                        .font(LHFont.caption(12))
                        .foregroundStyle(LHColor.textTertiary)

                    Text("·")
                        .foregroundStyle(LHColor.textMuted)

                    Text(challenge.difficultyLabel)
                        .font(LHFont.caption(12))
                        .foregroundStyle(LHColor.textTertiary)
                }
            }

            Spacer()

            // Complete button
            if !challenge.isCompleted {
                Button(action: onComplete) {
                    Image(systemName: "checkmark.circle")
                        .font(.system(size: 28))
                        .foregroundStyle(LHColor.teal)
                }
                .accessibilityLabel("Mark \(challenge.title) as complete")
            } else {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(LHColor.success)
                    .accessibilityLabel("\(challenge.title) completed")
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(challenge.isCompleted
            ? "\(challenge.title), completed. \(challenge.durationMinutes) minutes, \(challenge.difficultyLabel)."
            : "\(challenge.title), \(challenge.durationMinutes) minutes, \(challenge.difficultyLabel). Double-tap to mark complete.")
        .lhGlowCard(color: challenge.isCompleted ? LHColor.success : Color(hex: challenge.categoryColor))
    }
}
