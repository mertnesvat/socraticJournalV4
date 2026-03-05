// AppColors.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI
import UIKit

public enum AppColors {

    // MARK: - Adaptive Color Helper

    /// Creates a Color that automatically adapts between light and dark mode.
    /// Uses UIColor's dynamic provider so SwiftUI views update when the trait changes.
    private static func adaptive(light: String, dark: String) -> Color {
        Color(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(hex: dark)
                : UIColor(hex: light)
        })
    }

    // MARK: - Primary — Calm Teal (breath-focused)

    /// Teal accent — slightly brighter in dark mode for contrast on dark surfaces
    public static let accent = adaptive(light: "2D5F5D", dark: "3D8B87")

    /// Teal at low opacity — 10% on light, 15% on dark for subtle tint
    public static let accentLight = adaptive(light: "2D5F5D", dark: "3D8B87")
        .opacity(0.12)

    // MARK: - Secondary — Deep Coral (works on both)

    public static let accent2 = Color(hex: "C4502A")

    // MARK: - Backgrounds

    /// Main background — warm cream in light, near-black in dark
    public static let background = adaptive(light: "FAF7F2", dark: "1A1A1A")

    /// Card/surface background — slightly offset from main background for depth
    public static let surface = adaptive(light: "F2EDE4", dark: "2A2A2A")

    /// Elevated surface — modals, popovers
    public static let surfaceElevated = adaptive(light: "EDE7DB", dark: "333333")

    // MARK: - Text

    /// Primary text — near-black in light, near-white in dark
    public static let textPrimary = adaptive(light: "1C1710", dark: "F5F5F5")

    /// Secondary text — warm brown in light, mid gray in dark
    public static let textSecondary = adaptive(light: "7A6E60", dark: "A0A0A0")

    /// Tertiary text — muted, used for captions and hints
    public static let textTertiary = adaptive(light: "B0A898", dark: "707070")

    /// Text on dark backgrounds (always white)
    public static let textOnDark = Color.white

    /// Text on accent-colored backgrounds (always white)
    public static let textOnAccent = Color.white

    // MARK: - Semantic

    public static let success = Color(hex: "34C759")
    public static let warning = Color(hex: "FF9F0A")
    public static let error = Color(hex: "C4502A")

    // MARK: - Pattern tag colors (work on both themes)

    public static let tagSleep = Color(hex: "6B4C8A")
    public static let tagCO2 = Color(hex: "7A6030")
    public static let tagNature = Color(hex: "5A6E3D")
    public static let tagHold = Color(hex: "5A8A6A")

    // MARK: - Card colors

    public static let cardTeal = Color(hex: "8EDDD0")
    public static let cardYellow = Color(hex: "FADF63")
    public static let cardDark = Color(hex: "1C1C1E")

    // MARK: - Borders (hairline grid)

    /// Subtle border — warm in light, dark gray in dark
    public static let border = adaptive(light: "D8D0C4", dark: "3A3A3A")

    /// Stronger border for emphasis
    public static let borderStrong = adaptive(light: "C8C4BC", dark: "4A4A4A")

    // MARK: - Gradient

    /// Accent gradient — slightly brighter in dark mode
    public static let accentGradient = LinearGradient(
        colors: [
            adaptive(light: "2D5F5D", dark: "3D8B87"),
            adaptive(light: "1E4A48", dark: "2D6B68")
        ],
        startPoint: .leading, endPoint: .trailing
    )
}

// MARK: - UIColor Hex Extension

private extension UIColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            red: CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue: CGFloat(b) / 255,
            alpha: CGFloat(a) / 255
        )
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}
#endif
