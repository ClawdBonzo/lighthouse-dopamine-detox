import SwiftUI

// MARK: - Primary Glow Button (teal → gold gradient on high-value actions)

struct GlowButton: View {
    let title: String
    var icon: String? = nil
    var style: GlowButtonStyle = .teal
    let action: () -> Void

    enum GlowButtonStyle {
        case teal, gold, neural
        var gradient: LinearGradient {
            switch self {
            case .teal:   return LHColor.glowButtonGradient
            case .gold:   return LHColor.goldButtonGradient
            case .neural: return LinearGradient(colors: [LHColor.neural, LHColor.neuralDim], startPoint: .topLeading, endPoint: .bottomTrailing)
            }
        }
        var glowColor: Color {
            switch self {
            case .teal:   return LHColor.teal
            case .gold:   return LHColor.gold
            case .neural: return LHColor.neural
            }
        }
    }

    @State private var isPressed = false
    @State private var glowPulse = false

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
            .foregroundStyle(style == .gold ? LHColor.background : .white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(style.gradient)
            .clipShape(RoundedRectangle(cornerRadius: LHRadius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: LHRadius.lg)
                    .stroke(style.glowColor.opacity(0.4), lineWidth: 1)
            )
            .shadow(color: style.glowColor.opacity(isPressed ? 0.2 : glowPulse ? 0.55 : 0.4),
                    radius: isPressed ? 8 : glowPulse ? 20 : 14, y: 4)
            .scaleEffect(isPressed ? 0.97 : 1.0)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in withAnimation(.easeInOut(duration: 0.12)) { isPressed = true } }
                .onEnded   { _ in withAnimation(.easeInOut(duration: 0.12)) { isPressed = false } }
        )
        .onAppear {
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                glowPulse = true
            }
        }
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
                if let icon { Image(systemName: icon) }
                Text(title)
            }
            .font(LHFont.headline(15))
            .foregroundStyle(LHColor.teal)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(LHColor.teal.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: LHRadius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: LHRadius.lg)
                    .stroke(LHColor.teal.opacity(0.25), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
