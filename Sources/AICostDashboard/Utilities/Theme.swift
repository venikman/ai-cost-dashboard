import SwiftUI

// MARK: - Raycast-inspired Design Tokens

public enum Theme {
    // MARK: Colors

    /// Near-black background
    public static let backgroundPrimary = Color(nsColor: NSColor(red: 0.098, green: 0.098, blue: 0.106, alpha: 1.0))   // #191919/1B
    /// Slightly elevated surface
    public static let backgroundSecondary = Color(nsColor: NSColor(red: 0.141, green: 0.141, blue: 0.153, alpha: 1.0)) // #242427
    /// Card/elevated element background
    public static let backgroundTertiary = Color(nsColor: NSColor(red: 0.176, green: 0.176, blue: 0.192, alpha: 1.0))  // #2D2D31
    /// Hover state background
    public static let backgroundHover = Color.white.opacity(0.06)
    /// Selected/active state
    public static let backgroundSelected = Color.white.opacity(0.10)

    /// Primary text - bright white
    public static let textPrimary = Color.white.opacity(0.92)
    /// Secondary text - muted
    public static let textSecondary = Color.white.opacity(0.45)
    /// Tertiary text - very muted
    public static let textTertiary = Color.white.opacity(0.25)

    /// Accent color (Raycast purple)
    public static let accent = Color(nsColor: NSColor(red: 0.506, green: 0.349, blue: 1.0, alpha: 1.0))  // #8159FF
    /// Success/savings green
    public static let green = Color(nsColor: NSColor(red: 0.298, green: 0.847, blue: 0.392, alpha: 1.0)) // #4CD864
    /// Warning/expensive red
    public static let red = Color(nsColor: NSColor(red: 1.0, green: 0.38, blue: 0.38, alpha: 1.0))       // #FF6161

    /// Subtle border
    public static let border = Color.white.opacity(0.08)
    /// Divider line
    public static let divider = Color.white.opacity(0.06)

    // MARK: Spacing

    public static let spacingXS: CGFloat = 4
    public static let spacingS: CGFloat = 8
    public static let spacingM: CGFloat = 12
    public static let spacingL: CGFloat = 16
    public static let spacingXL: CGFloat = 24

    // MARK: Radii

    public static let radiusS: CGFloat = 6
    public static let radiusM: CGFloat = 8
    public static let radiusL: CGFloat = 10
    public static let radiusXL: CGFloat = 12

    // MARK: Provider Colors (muted for dark theme)

    public static func providerColor(_ provider: Provider) -> Color {
        switch provider {
        case .anthropic: Color(red: 0.85, green: 0.60, blue: 0.35)
        case .openai: Color(red: 0.30, green: 0.78, blue: 0.65)
        case .google: Color(red: 0.45, green: 0.62, blue: 0.95)
        case .openRouter: Color(red: 0.65, green: 0.45, blue: 0.95)
        case .bedrock: Color(red: 1.0, green: 0.65, blue: 0.25)
        case .azure: Color(red: 0.30, green: 0.58, blue: 0.92)
        case .vertex: Color(red: 0.35, green: 0.75, blue: 0.45)
        }
    }
}

// MARK: - View Modifiers

public struct RaycastRow: ViewModifier {
    public var isSelected: Bool = false
    @State private var isHovered = false

    public init(isSelected: Bool = false) {
        self.isSelected = isSelected
    }

    public func body(content: Content) -> some View {
        content
            .padding(.horizontal, Theme.spacingL)
            .padding(.vertical, Theme.spacingM)
            .background(
                RoundedRectangle(cornerRadius: Theme.radiusM)
                    .fill(isSelected ? Theme.backgroundSelected : (isHovered ? Theme.backgroundHover : .clear))
            )
            .onHover { hovering in
                withAnimation(.easeInOut(duration: 0.15)) {
                    isHovered = hovering
                }
            }
    }
}

public struct RaycastCard: ViewModifier {
    public var isSelected: Bool = false
    @State private var isHovered = false

    public init(isSelected: Bool = false) {
        self.isSelected = isSelected
    }

    public func body(content: Content) -> some View {
        content
            .padding(Theme.spacingL)
            .background(
                RoundedRectangle(cornerRadius: Theme.radiusL)
                    .fill(Theme.backgroundSecondary)
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.radiusL)
                            .stroke(isSelected ? Theme.accent.opacity(0.5) : Theme.border, lineWidth: 1)
                    )
            )
            .shadow(color: .black.opacity(isHovered ? 0.3 : 0.15), radius: isHovered ? 8 : 4, y: 2)
            .scaleEffect(isHovered ? 1.01 : 1.0)
            .onHover { hovering in
                withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                    isHovered = hovering
                }
            }
    }
}

public struct RaycastSearchBar: ViewModifier {
    public init() {}

    public func body(content: Content) -> some View {
        content
            .padding(.horizontal, Theme.spacingM)
            .padding(.vertical, Theme.spacingS)
            .background(
                RoundedRectangle(cornerRadius: Theme.radiusM)
                    .fill(Theme.backgroundTertiary)
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.radiusM)
                            .stroke(Theme.border, lineWidth: 1)
                    )
            )
    }
}

extension View {
    public func raycastRow(isSelected: Bool = false) -> some View {
        modifier(RaycastRow(isSelected: isSelected))
    }

    public func raycastCard(isSelected: Bool = false) -> some View {
        modifier(RaycastCard(isSelected: isSelected))
    }

    public func raycastSearchBar() -> some View {
        modifier(RaycastSearchBar())
    }
}
