import SwiftUI

struct GlowButton: View {
    let title: String
    var icon: String? = nil
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: LHSpacing.sm) {
                Text(title)
                    .font(LHFont.headline(17))

                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 15, weight: .semibold))
                }
            }
            .foregroundStyle(LHColor.background)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [LHColor.teal, LHColor.tealDim],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: LHRadius.lg))
            .shadow(color: LHColor.teal.opacity(isPressed ? 0.2 : 0.4), radius: isPressed ? 8 : 16, y: 4)
            .scaleEffect(isPressed ? 0.97 : 1.0)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation(.easeInOut(duration: 0.15)) { isPressed = true }
                }
                .onEnded { _ in
                    withAnimation(.easeInOut(duration: 0.15)) { isPressed = false }
                }
        )
    }
}

// MARK: - Secondary Button Style

struct LHSecondaryButton: View {
    let title: String
    var icon: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: LHSpacing.sm) {
                if let icon {
                    Image(systemName: icon)
                }
                Text(title)
            }
            .font(LHFont.headline(15))
            .foregroundStyle(LHColor.teal)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(LHColor.teal.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: LHRadius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: LHRadius.lg)
                    .stroke(LHColor.teal.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
