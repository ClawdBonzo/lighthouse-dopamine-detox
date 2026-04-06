import SwiftUI

struct CommitmentView: View {
    @Bindable var viewModel: OnboardingViewModel

    var body: some View {
        VStack(spacing: LHSpacing.xl) {
            Spacer()

            OnboardingProgress(current: 4, total: 5)

            VStack(spacing: LHSpacing.sm) {
                Text("How many minutes\ncan you commit daily?")
                    .font(LHFont.display(28))
                    .foregroundStyle(LHColor.textPrimary)
                    .multilineTextAlignment(.center)

                Text("We'll build challenges that fit your schedule")
                    .font(LHFont.body(15))
                    .foregroundStyle(LHColor.textTertiary)
            }

            // Big number display
            VStack(spacing: LHSpacing.xs) {
                Text("\(viewModel.commitmentMinutes)")
                    .font(LHFont.display(72))
                    .foregroundStyle(LHColor.teal)
                    .contentTransition(.numericText(value: Double(viewModel.commitmentMinutes)))

                Text("minutes per day")
                    .font(LHFont.headline(16))
                    .foregroundStyle(LHColor.textSecondary)
            }

            // Option pills
            VStack(spacing: LHSpacing.md) {
                ForEach(OnboardingViewModel.commitmentOptions, id: \.self) { minutes in
                    let isSelected = viewModel.commitmentMinutes == minutes

                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            viewModel.commitmentMinutes = minutes
                        }
                    } label: {
                        HStack {
                            Text("\(minutes) min")
                                .font(LHFont.headline(16))
                                .foregroundStyle(isSelected ? LHColor.textPrimary : LHColor.textSecondary)

                            Spacer()

                            Text(commitmentLabel(for: minutes))
                                .font(LHFont.caption(13))
                                .foregroundStyle(isSelected ? LHColor.teal : LHColor.textTertiary)

                            if isSelected {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(LHColor.teal)
                            }
                        }
                        .padding(.horizontal, LHSpacing.md)
                        .padding(.vertical, 14)
                        .background(isSelected ? LHColor.teal.opacity(0.1) : LHColor.surface)
                        .clipShape(RoundedRectangle(cornerRadius: LHRadius.md))
                        .overlay(
                            RoundedRectangle(cornerRadius: LHRadius.md)
                                .stroke(isSelected ? LHColor.teal.opacity(0.5) : Color.clear, lineWidth: 1.5)
                        )
                    }
                }
            }
            .padding(.horizontal, LHSpacing.lg)

            Spacer()

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

                GlowButton(title: "Create My Plan", icon: "sparkles") {
                    viewModel.advance()
                }
            }
            .padding(.horizontal, LHSpacing.lg)

            Spacer().frame(height: LHSpacing.xl)
        }
    }

    private func commitmentLabel(for minutes: Int) -> String {
        switch minutes {
        case 10: return "Quick start"
        case 15: return "Easy habit"
        case 20: return "Solid routine"
        case 30: return "Recommended"
        case 45: return "Power user"
        case 60: return "Full reset"
        default: return ""
        }
    }
}
