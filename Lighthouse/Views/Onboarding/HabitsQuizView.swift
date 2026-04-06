import SwiftUI

struct HabitsQuizView: View {
    @Bindable var viewModel: OnboardingViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: LHSpacing.xl) {
                Spacer().frame(height: LHSpacing.sm)

                // Header illustration
                Image("Onboarding-2")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 160)
                    .clipShape(RoundedRectangle(cornerRadius: LHRadius.lg))
                    .padding(.horizontal, LHSpacing.xl)

                OnboardingProgress(current: 2, total: 5)

                VStack(spacing: LHSpacing.sm) {
                    Text("Let's understand\nyour habits")
                        .font(LHFont.display(28))
                        .foregroundStyle(LHColor.textPrimary)
                        .multilineTextAlignment(.center)

                    Text("Be honest — this helps personalize your plan")
                        .font(LHFont.body(15))
                        .foregroundStyle(LHColor.textTertiary)
                }

                // Daily screen time
                VStack(alignment: .leading, spacing: LHSpacing.md) {
                    Text("Daily Screen Time")
                        .font(LHFont.headline(16))
                        .foregroundStyle(LHColor.textSecondary)

                    ForEach(OnboardingViewModel.screenTimeOptions, id: \.hours) { option in
                        Button {
                            withAnimation(.spring(response: 0.3)) {
                                viewModel.dailyScreenTime = option.hours
                            }
                        } label: {
                            HStack {
                                Text(option.label)
                                    .font(LHFont.body(16))
                                    .foregroundStyle(LHColor.textPrimary)
                                Spacer()
                                if viewModel.dailyScreenTime == option.hours {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(LHColor.teal)
                                        .font(.system(size: 22))
                                }
                            }
                            .padding(LHSpacing.md)
                            .background(viewModel.dailyScreenTime == option.hours ? LHColor.teal.opacity(0.1) : LHColor.surface)
                            .clipShape(RoundedRectangle(cornerRadius: LHRadius.md))
                            .overlay(
                                RoundedRectangle(cornerRadius: LHRadius.md)
                                    .stroke(viewModel.dailyScreenTime == option.hours ? LHColor.teal.opacity(0.5) : Color.clear, lineWidth: 1.5)
                            )
                        }
                    }
                }
                .padding(.horizontal, LHSpacing.lg)

                // Doomscroll frequency
                VStack(alignment: .leading, spacing: LHSpacing.md) {
                    Text("How often do you doomscroll?")
                        .font(LHFont.headline(16))
                        .foregroundStyle(LHColor.textSecondary)

                    ForEach(OnboardingViewModel.doomscrollOptions, id: \.value) { option in
                        Button {
                            withAnimation(.spring(response: 0.3)) {
                                viewModel.doomscrollFrequency = option.value
                            }
                        } label: {
                            HStack(spacing: LHSpacing.md) {
                                Image(systemName: option.icon)
                                    .font(.system(size: 18))
                                    .foregroundStyle(viewModel.doomscrollFrequency == option.value ? LHColor.teal : LHColor.textTertiary)
                                    .frame(width: 28)

                                Text(option.label)
                                    .font(LHFont.body(16))
                                    .foregroundStyle(LHColor.textPrimary)

                                Spacer()

                                if viewModel.doomscrollFrequency == option.value {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(LHColor.teal)
                                        .font(.system(size: 22))
                                }
                            }
                            .padding(LHSpacing.md)
                            .background(viewModel.doomscrollFrequency == option.value ? LHColor.teal.opacity(0.1) : LHColor.surface)
                            .clipShape(RoundedRectangle(cornerRadius: LHRadius.md))
                            .overlay(
                                RoundedRectangle(cornerRadius: LHRadius.md)
                                    .stroke(viewModel.doomscrollFrequency == option.value ? LHColor.teal.opacity(0.5) : Color.clear, lineWidth: 1.5)
                            )
                        }
                    }
                }
                .padding(.horizontal, LHSpacing.lg)

                // Navigation
                HStack(spacing: LHSpacing.md) {
                    Button {
                        viewModel.goBack()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(LHColor.textSecondary)
                            .frame(width: 52, height: 52)
                            .background(LHColor.surface)
                            .clipShape(Circle())
                    }

                    GlowButton(title: "Continue", icon: "arrow.right") {
                        viewModel.advance()
                    }
                }
                .padding(.horizontal, LHSpacing.lg)

                Spacer().frame(height: LHSpacing.xl)
            }
        }
        .scrollIndicators(.hidden)
    }
}
