import SwiftUI

struct NameInputView: View {
    @Bindable var viewModel: OnboardingViewModel
    @FocusState private var isNameFocused: Bool

    var body: some View {
        VStack(spacing: LHSpacing.xl) {
            Spacer()

            // Step indicator
            OnboardingProgress(current: 1, total: 5)

            VStack(spacing: LHSpacing.sm) {
                Text("What should we call\nyour focused self?")
                    .font(LHFont.display(28))
                    .foregroundStyle(LHColor.textPrimary)
                    .multilineTextAlignment(.center)

                Text("This is how Lighthouse will greet you")
                    .font(LHFont.body(15))
                    .foregroundStyle(LHColor.textTertiary)
            }

            // Name input
            VStack(spacing: LHSpacing.sm) {
                TextField("Your name", text: $viewModel.displayName)
                    .font(LHFont.headline(22))
                    .foregroundStyle(LHColor.textPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.vertical, LHSpacing.md)
                    .padding(.horizontal, LHSpacing.lg)
                    .background(LHColor.surface)
                    .clipShape(RoundedRectangle(cornerRadius: LHRadius.lg))
                    .overlay(
                        RoundedRectangle(cornerRadius: LHRadius.lg)
                            .stroke(isNameFocused ? LHColor.teal : Color.white.opacity(0.1), lineWidth: 2)
                    )
                    .focused($isNameFocused)
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled()

                if !viewModel.displayName.isEmpty && !viewModel.isNameValid {
                    Text("Name should be at least 2 characters")
                        .font(LHFont.caption(12))
                        .foregroundStyle(LHColor.warning)
                }
            }
            .padding(.horizontal, LHSpacing.xl)

            Spacer()
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

                GlowButton(title: "Continue", icon: "arrow.right") {
                    viewModel.advance()
                }
                .opacity(viewModel.isNameValid ? 1 : 0.5)
                .disabled(!viewModel.isNameValid)
            }
            .padding(.horizontal, LHSpacing.lg)

            Spacer().frame(height: LHSpacing.xl)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isNameFocused = true
            }
        }
    }
}

// MARK: - Onboarding Progress Indicator

struct OnboardingProgress: View {
    let current: Int
    let total: Int

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<total, id: \.self) { index in
                Capsule()
                    .fill(index < current ? LHColor.teal : LHColor.surface)
                    .frame(height: 4)
            }
        }
        .padding(.horizontal, LHSpacing.xxl)
    }
}
