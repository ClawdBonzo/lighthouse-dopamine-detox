import SwiftUI

// MARK: - Lighthouse Design System
// Dark-first, calming, focused aesthetic with deep navy + teal/gold accents

enum LHColor {
    // Core backgrounds
    static let background = Color(hex: "0A1628")
    static let surface = Color(hex: "111D32")
    static let surfaceElevated = Color(hex: "182742")
    static let card = Color(hex: "1A2A45")

    // Primary accent — teal
    static let teal = Color(hex: "00D4AA")
    static let tealDim = Color(hex: "00A888")
    static let tealGlow = Color(hex: "00D4AA").opacity(0.3)

    // Secondary accent — gold
    static let gold = Color(hex: "FFD166")
    static let goldDim = Color(hex: "E6B84D")

    // Semantic
    static let streak = Color(hex: "FF6B6B")
    static let success = Color(hex: "4ADE80")
    static let warning = Color(hex: "FBBF24")
    static let danger = Color(hex: "EF4444")

    // Text
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.7)
    static let textTertiary = Color.white.opacity(0.45)
    static let textMuted = Color.white.opacity(0.3)
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
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
}

enum LHRadius {
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 20
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
        case 6:
            (a, r, g, b) = (255, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = ((int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - View Modifiers

struct LHCardStyle: ViewModifier {
    var padding: CGFloat = LHSpacing.md

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(LHColor.card)
            .clipShape(RoundedRectangle(cornerRadius: LHRadius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: LHRadius.lg)
                    .stroke(Color.white.opacity(0.06), lineWidth: 1)
            )
    }
}

struct LHGlassStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial.opacity(0.5))
            .background(LHColor.surface.opacity(0.8))
            .clipShape(RoundedRectangle(cornerRadius: LHRadius.lg))
    }
}

extension View {
    func lhCard(padding: CGFloat = LHSpacing.md) -> some View {
        modifier(LHCardStyle(padding: padding))
    }

    func lhGlass() -> some View {
        modifier(LHGlassStyle())
    }
}
