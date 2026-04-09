import SwiftUI

// MARK: - Lighthouse Design System
// Deep navy → electric teal → glowing gold — euphoric clarity aesthetic

enum LHColor {
    // Core backgrounds — deep navy base
    static let background    = Color(hex: "080F1E")
    static let surface       = Color(hex: "0E1A30")
    static let surfaceElevated = Color(hex: "162540")
    static let card          = Color(hex: "182A45")

    // Electric teal — primary clarity accent
    static let teal          = Color(hex: "00E5BE")
    static let tealDim       = Color(hex: "00B89A")
    static let tealGlow      = Color(hex: "00E5BE")
    static let tealSoft      = Color(hex: "00E5BE")

    // Glowing gold — achievement accent
    static let gold          = Color(hex: "FFD84D")
    static let goldDim       = Color(hex: "E6BC38")
    static let goldGlow      = Color(hex: "FFD84D")

    // Semantic
    static let streak        = Color(hex: "FF6B6B")
    static let success       = Color(hex: "4ADE80")
    static let warning       = Color(hex: "FBBF24")
    static let danger        = Color(hex: "EF4444")

    // Neural purple — for brain-reset moments
    static let neural        = Color(hex: "9B6DFF")
    static let neuralDim     = Color(hex: "7B4FE0")

    // Text
    static let textPrimary   = Color.white
    static let textSecondary = Color.white.opacity(0.75)
    static let textTertiary  = Color.white.opacity(0.45)
    static let textMuted     = Color.white.opacity(0.28)

    // MARK: - Gradient Tokens

    static var clarityGradient: LinearGradient {
        LinearGradient(
            colors: [teal, gold],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    static var beamGradient: LinearGradient {
        LinearGradient(
            colors: [background, teal.opacity(0.12), gold.opacity(0.06), background],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    static var cardGlassGradient: LinearGradient {
        LinearGradient(
            colors: [Color.white.opacity(0.06), Color.white.opacity(0.02)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var glowButtonGradient: LinearGradient {
        LinearGradient(
            colors: [teal, tealDim],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var goldButtonGradient: LinearGradient {
        LinearGradient(
            colors: [gold, goldDim],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

enum LHFont {
    static func display(_ size: CGFloat) -> Font {
        .system(size: size, weight: .bold, design: .rounded)
    }
    static func headline(_ size: CGFloat = 20) -> Font {
        .system(size: size, weight: .semibold, design: .rounded)
    }
    static func body(_ size: CGFloat = 16) -> Font {
        .system(size: size, weight: .regular, design: .rounded)
    }
    static func caption(_ size: CGFloat = 13) -> Font {
        .system(size: size, weight: .medium, design: .rounded)
    }
    static func mono(_ size: CGFloat = 14) -> Font {
        .system(size: size, weight: .medium, design: .monospaced)
    }
}

enum LHSpacing {
    static let xs: CGFloat  = 4
    static let sm: CGFloat  = 8
    static let md: CGFloat  = 16
    static let lg: CGFloat  = 24
    static let xl: CGFloat  = 32
    static let xxl: CGFloat = 48
}

enum LHRadius {
    static let sm: CGFloat   = 8
    static let md: CGFloat   = 12
    static let lg: CGFloat   = 16
    static let xl: CGFloat   = 20
    static let full: CGFloat = 100
}

// MARK: - Hex Color Initializer

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: .alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:  (a, r, g, b) = (255, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        case 8:  (a, r, g, b) = ((int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255, opacity: Double(a)/255)
    }
}

// MARK: - View Modifiers

struct LHCardStyle: ViewModifier {
    var padding: CGFloat = LHSpacing.md
    var glowColor: Color = .clear

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: LHRadius.lg)
                        .fill(LHColor.card)
                    RoundedRectangle(cornerRadius: LHRadius.lg)
                        .fill(LHColor.cardGlassGradient)
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: LHRadius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: LHRadius.lg)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
    }
}

struct LHGlowCardStyle: ViewModifier {
    var padding: CGFloat = LHSpacing.md
    var glowColor: Color
    var glowRadius: CGFloat = 12

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: LHRadius.lg).fill(LHColor.card)
                    RoundedRectangle(cornerRadius: LHRadius.lg).fill(LHColor.cardGlassGradient)
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: LHRadius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: LHRadius.lg)
                    .stroke(
                        LinearGradient(colors: [glowColor.opacity(0.5), glowColor.opacity(0.15)],
                                       startPoint: .topLeading, endPoint: .bottomTrailing),
                        lineWidth: 1.5
                    )
            )
            .shadow(color: glowColor.opacity(0.18), radius: glowRadius, x: 0, y: 4)
    }
}

extension View {
    func lhCard(padding: CGFloat = LHSpacing.md) -> some View {
        modifier(LHCardStyle(padding: padding))
    }

    func lhGlowCard(padding: CGFloat = LHSpacing.md, color: Color = LHColor.teal, radius: CGFloat = 12) -> some View {
        modifier(LHGlowCardStyle(padding: padding, glowColor: color, glowRadius: radius))
    }

    func lhGlass() -> some View {
        self
            .background(.ultraThinMaterial.opacity(0.4))
            .background(LHColor.surface.opacity(0.7))
            .clipShape(RoundedRectangle(cornerRadius: LHRadius.lg))
    }
}
