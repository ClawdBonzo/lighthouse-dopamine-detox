import SwiftUI

struct SplashView: View {
    @Bindable var viewModel: OnboardingViewModel
    @State private var showContent = false
    @State private var pulseGlow = false

    var body: some View {
        VStack(spacing: LHSpacing.xxl) {
            Spacer()

            // Lighthouse icon
            ZStack {
                // Outer glow
                Circle()
                    .fill(LHColor.teal.opacity(0.15))
                    .frame(width: 180, height: 180)
                    .scaleEffect(pulseGlow ? 1.1 : 0.9)

                // Inner glow
                Circle()
                    .fill(LHColor.teal.opacity(0.25))
                    .frame(width: 120, height: 120)

                Image(systemName: "lighthouse.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(LHColor.teal)
                    .shadow(color: LHColor.teal.opacity(0.6), radius: 20)
            }
            .opacity(showContent ? 1 : 0)
            .offset(y: showContent ? 0 : 30)

            VStack(spacing: LHSpacing.md) {
                Text("Lighthouse")
                    .font(LHFont.display(38))
                    .foregroundStyle(LHColor.textPrimary)

                Text("Your Dopamine Detox\nCompanion")
                    .font(LHFont.headline(18))
                    .foregroundStyle(LHColor.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .opacity(showContent ? 1 : 0)
            .offset(y: showContent ? 0 : 20)

            Spacer()

            // Features preview
            VStack(spacing: LHSpacing.md) {
                featureRow(icon: "flame.fill", color: LHColor.streak, text: "Build unbreakable detox streaks")
                featureRow(icon: "brain.head.profile", color: LHColor.teal, text: "Reclaim your focus and energy")
                featureRow(icon: "chart.line.uptrend.xyaxis", color: LHColor.gold, text: "Track your transformation")
            }
            .padding(.horizontal, LHSpacing.xl)
            .opacity(showContent ? 1 : 0)

            Spacer()

            // CTA Button
            GlowButton(title: "Start Your Focused Life", icon: "arrow.right") {
                viewModel.advance()
            }
            .padding(.horizontal, LHSpacing.lg)
            .opacity(showContent ? 1 : 0)
            .offset(y: showContent ? 0 : 20)

            Spacer().frame(height: LHSpacing.xl)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8).delay(0.2)) {
                showContent = true
            }
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                pulseGlow = true
            }
        }
    }

    private func featureRow(icon: String, color: Color, text: String) -> some View {
        HStack(spacing: LHSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(color)
                .frame(width: 36, height: 36)
                .background(color.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: LHRadius.sm))

            Text(text)
                .font(LHFont.body(15))
                .foregroundStyle(LHColor.textSecondary)

            Spacer()
        }
    }
}
