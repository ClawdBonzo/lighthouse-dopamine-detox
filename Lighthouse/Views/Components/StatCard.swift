import SwiftUI

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: LHSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(color)

            Text(value)
                .font(LHFont.headline(18))
                .foregroundStyle(LHColor.textPrimary)

            Text(title)
                .font(LHFont.caption(11))
                .foregroundStyle(LHColor.textTertiary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, LHSpacing.md)
        .background(LHColor.card)
        .clipShape(RoundedRectangle(cornerRadius: LHRadius.md))
        .overlay(
            RoundedRectangle(cornerRadius: LHRadius.md)
                .stroke(color.opacity(0.15), lineWidth: 1)
        )
    }
}
