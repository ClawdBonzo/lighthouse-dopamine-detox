import SwiftUI

struct AppSelectionView: View {
    @Bindable var viewModel: OnboardingViewModel

    let columns = [
        GridItem(.flexible(), spacing: LHSpacing.md),
        GridItem(.flexible(), spacing: LHSpacing.md),
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: LHSpacing.xl) {
                Spacer().frame(height: LHSpacing.sm)

                // Header illustration
                Image("Onboarding-3")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 160)
                    .clipShape(RoundedRectangle(cornerRadius: LHRadius.lg))
                    .padding(.horizontal, LHSpacing.xl)

                OnboardingProgress(current: 3, total: 5)

                VStack(spacing: LHSpacing.sm) {
                    Text("Which apps hijack\nyour attention?")
                        .font(LHFont.display(28))
                        .foregroundStyle(LHColor.textPrimary)
                        .multilineTextAlignment(.center)

                    Text("Select all that apply — we'll help you fight back")
                        .font(LHFont.body(15))
                        .foregroundStyle(LHColor.textTertiary)
                }

                // App grid
                LazyVGrid(columns: columns, spacing: LHSpacing.md) {
                    ForEach(OnboardingViewModel.attentionApps, id: \.name) { app in
                        let isSelected = viewModel.selectedApps.contains(app.name)

                        Button {
                            withAnimation(.spring(response: 0.3)) {
                                if isSelected {
                                    viewModel.selectedApps.remove(app.name)
                                } else {
                                    viewModel.selectedApps.insert(app.name)
                                }
                            }
                        } label: {
                            VStack(spacing: LHSpacing.sm) {
                                Image(systemName: app.icon)
                                    .font(.system(size: 24))
                                    .foregroundStyle(isSelected ? LHColor.teal : LHColor.textTertiary)

                                Text(app.name)
                                    .font(LHFont.caption(13))
                                    .foregroundStyle(isSelected ? LHColor.textPrimary : LHColor.textSecondary)
                                    .lineLimit(1)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, LHSpacing.md)
                            .background(isSelected ? LHColor.teal.opacity(0.12) : LHColor.surface)
                            .clipShape(RoundedRectangle(cornerRadius: LHRadius.md))
                            .overlay(
                                RoundedRectangle(cornerRadius: LHRadius.md)
                                    .stroke(isSelected ? LHColor.teal.opacity(0.5) : Color.clear, lineWidth: 1.5)
                            )
                        }
                    }
                }
                .padding(.horizontal, LHSpacing.lg)

                // Selected count
                if !viewModel.selectedApps.isEmpty {
                    Text("\(viewModel.selectedApps.count) app\(viewModel.selectedApps.count == 1 ? "" : "s") selected")
                        .font(LHFont.caption(14))
                        .foregroundStyle(LHColor.teal)
                }

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
                    .opacity(viewModel.selectedApps.isEmpty ? 0.5 : 1)
                    .disabled(viewModel.selectedApps.isEmpty)
                }
                .padding(.horizontal, LHSpacing.lg)

                Spacer().frame(height: LHSpacing.xl)
            }
        }
        .scrollIndicators(.hidden)
    }
}
