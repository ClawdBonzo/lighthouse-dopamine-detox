import SwiftUI

struct LoadingPlanView: View {
    @Bindable var viewModel: OnboardingViewModel
    @State private var currentPhase = 0
    @State private var showSocialProof = false

    private let phases = [
        ("Analyzing your habits", "brain.head.profile"),
        ("Identifying trigger patterns", "exclamationmark.triangle"),
        ("Building challenge library", "sparkles"),
        ("Personalizing your detox plan", "wand.and.stars"),
    ]

    var body: some View {
        VStack(spacing: LHSpacing.xxl) {
            Spacer()

            // Analyzing illustration + pulsing rings
            ZStack {
                ForEach(0..<3, id: \.self) { ring in
                    Circle()
                        .stroke(LHColor.teal.opacity(0.1 + Double(ring) * 0.05), lineWidth: 2)
                        .frame(width: CGFloat(140 + ring * 40), height: CGFloat(140 + ring * 40))
                        .scaleEffect(viewModel.loadingProgress > Double(ring) / 3.0 ? 1.0 : 0.5)
                        .opacity(viewModel.loadingProgress > Double(ring) / 3.0 ? 1.0 : 0.3)
                        .animation(.easeOut(duration: 0.6), value: viewModel.loadingProgress)
                }

                Image("Onboarding-4")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .shadow(color: LHColor.teal.opacity(0.5), radius: 15)
            }

            VStack(spacing: LHSpacing.md) {
                Text("Creating your personalized\nDetox Plan")
                    .font(LHFont.display(24))
                    .foregroundStyle(LHColor.textPrimary)
                    .multilineTextAlignment(.center)

                Text("for \(viewModel.displayName)")
                    .font(LHFont.headline(18))
                    .foregroundStyle(LHColor.teal)
            }

            // Progress phases
            VStack(alignment: .leading, spacing: LHSpacing.md) {
                ForEach(Array(phases.enumerated()), id: \.offset) { index, phase in
                    HStack(spacing: LHSpacing.md) {
                        ZStack {
                            if index < currentPhase {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(LHColor.success)
                            } else if index == currentPhase {
                                ProgressView()
                                    .tint(LHColor.teal)
                            } else {
                                Circle()
                                    .stroke(LHColor.textMuted, lineWidth: 1.5)
                                    .frame(width: 20, height: 20)
                            }
                        }
                        .frame(width: 24, height: 24)

                        Text(phase.0)
                            .font(LHFont.body(15))
                            .foregroundStyle(index <= currentPhase ? LHColor.textPrimary : LHColor.textTertiary)
                    }
                }
            }
            .padding(.horizontal, LHSpacing.xxl)

            // Progress bar
            VStack(spacing: LHSpacing.sm) {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(LHColor.surface)
                            .frame(height: 8)

                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [LHColor.teal, LHColor.tealDim],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * viewModel.loadingProgress, height: 8)
                            .animation(.spring(response: 0.4), value: viewModel.loadingProgress)
                    }
                }
                .frame(height: 8)

                Text("\(Int(viewModel.loadingProgress * 100))%")
                    .font(LHFont.mono(14))
                    .foregroundStyle(LHColor.teal)
            }
            .padding(.horizontal, LHSpacing.xl)

            Spacer()

            // Social proof
            if showSocialProof {
                VStack(spacing: LHSpacing.sm) {
                    HStack(spacing: -8) {
                        ForEach(0..<5, id: \.self) { i in
                            Circle()
                                .fill(
                                    [LHColor.teal, LHColor.gold, LHColor.streak, Color.purple, Color.blue][i]
                                )
                                .frame(width: 28, height: 28)
                                .overlay(
                                    Circle().stroke(LHColor.background, lineWidth: 2)
                                )
                        }
                    }

                    Text("Join 1.8M+ people reclaiming their focus")
                        .font(LHFont.caption(14))
                        .foregroundStyle(LHColor.textSecondary)
                }
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }

            Spacer().frame(height: LHSpacing.xl)
        }
        .task {
            withAnimation(.easeIn(duration: 0.5).delay(1.0)) {
                showSocialProof = true
            }

            // Animate phases
            for i in 0..<phases.count {
                try? await Task.sleep(for: .milliseconds(800))
                withAnimation { currentPhase = i + 1 }
            }

            await viewModel.simulateLoading()
        }
    }
}
