import SwiftUI

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    @State private var appeared = false

    var body: some View {
        VStack(spacing: LHSpacing.sm) {
            // Icon with glow
            ZStack {
                Circle()
                    .fill(color.opacity(0.12))
                    .frame(width: 36, height: 36)
                    .shadow(color: color.opacity(0.25), radius: 8)

                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(color)
            }

            Text(value)
                .font(LHFont.headline(18))
                .foregroundStyle(LHColor.textPrimary)
                .shadow(color: color.opacity(0.3), radius: 4)

            Text(title)
                .font(LHFont.caption(11))
                .foregroundStyle(LHColor.textTertiary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, LHSpacing.md)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: LHRadius.md).fill(LHColor.card)
                RoundedRectangle(cornerRadius: LHRadius.md).fill(LHColor.cardGlassGradient)
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: LHRadius.md))
        .overlay(
            RoundedRectangle(cornerRadius: LHRadius.md)
                .stroke(
                    LinearGradient(
                        colors: [color.opacity(0.35), color.opacity(0.08)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: color.opacity(0.1), radius: 8, y: 4)
        .scaleEffect(appeared ? 1 : 0.9)
        .opacity(appeared ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                appeared = true
            }
        }
    }
}
