// AppColors.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI
import UIKit

public enum AppColors {
    // MARK: - Primary Accent (unchanged in both modes — teal reads well on dark)
    public static let accent = Color(hex: "2D5F5D")
    public static let accentLight = Color(hex: "2D5F5D").opacity(0.1)

    // MARK: - Secondary Accent (unchanged — coral works on dark)
    public static let accent2 = Color(hex: "C4502A")

    // MARK: - Backgrounds — Adaptive (warm cream → warm dark black)
    public static let background = Color(uiColor: UIColor(dynamicProvider: { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(hex: "0F0E0C")
            : UIColor(hex: "FAF7F2")
    }))

    public static let surface = Color(uiColor: UIColor(dynamicProvider: { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(hex: "1A1815")
            : UIColor(hex: "F2EDE4")
    }))

    public static let surfaceElevated = Color(uiColor: UIColor(dynamicProvider: { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(hex: "242018")
            : UIColor(hex: "EDE7DB")
    }))

    // MARK: - Text — Adaptive (warm brown → warm off-white)
    public static let textPrimary = Color(uiColor: UIColor(dynamicProvider: { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(hex: "F0EBE3")
            : UIColor(hex: "1C1710")
    }))

    public static let textSecondary = Color(uiColor: UIColor(dynamicProvider: { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(hex: "9E9488")
            : UIColor(hex: "7A6E60")
    }))

    public static let textTertiary = Color(uiColor: UIColor(dynamicProvider: { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(hex: "5C564E")
            : UIColor(hex: "B0A898")
    }))

    /// Warm body text used in long-form editorial content (body paragraphs, interpretations)
    public static let textWarmBody = Color(uiColor: UIColor(dynamicProvider: { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(hex: "9E9488")
            : UIColor(hex: "3D3328")
    }))

    public static let textOnDark = Color.white
    public static let textOnAccent = Color.white

    // MARK: - Primary Button — Adaptive (dark filled → light filled)
    /// Background for the primary filled button (dark in light mode, warm-white in dark mode)
    public static let buttonPrimaryBackground = Color(uiColor: UIColor(dynamicProvider: { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(hex: "F0EBE3")
            : UIColor(hex: "1C1710")
    }))

    /// Foreground text/icon for the primary filled button
    public static let buttonPrimaryForeground = Color(uiColor: UIColor(dynamicProvider: { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(hex: "0F0E0C")
            : UIColor(hex: "FAF7F2")
    }))

    // MARK: - Semantic (unchanged)
    public static let success = Color(hex: "34C759")
    public static let warning = Color(hex: "FF9F0A")
    public static let error = Color(hex: "C4502A")

    // MARK: - Pattern Tag Colors (design-intentional — unchanged)
    public static let tagSleep = Color(hex: "6B4C8A")
    public static let tagCO2 = Color(hex: "7A6030")
    public static let tagNature = Color(hex: "5A6E3D")
    public static let tagHold = Color(hex: "5A8A6A")

    // MARK: - Card Colors — Adaptive
    public static let cardTeal = Color(uiColor: UIColor(dynamicProvider: { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(hex: "5CBFB8")
            : UIColor(hex: "8EDDD0")
    }))

    public static let cardYellow = Color(uiColor: UIColor(dynamicProvider: { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(hex: "C8A84A")
            : UIColor(hex: "FADF63")
    }))

    public static let cardDark = Color(hex: "1C1C1E")

    // MARK: - Borders — Adaptive (warm grey → dark warm divider)
    public static let border = Color(uiColor: UIColor(dynamicProvider: { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(hex: "2E2A24")
            : UIColor(hex: "D8D0C4")
    }))

    public static let borderStrong = Color(uiColor: UIColor(dynamicProvider: { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(hex: "3A342C")
            : UIColor(hex: "C8C4BC")
    }))

    // MARK: - Gradient (teal works on both)
    public static let accentGradient = LinearGradient(
        colors: [Color(hex: "2D5F5D"), Color(hex: "1E4A48")],
        startPoint: .leading, endPoint: .trailing
    )

    // MARK: - Legacy dark variants (kept for backwards compat)
    public static let backgroundDark = Color(hex: "0A0A0A")
    public static let surfaceDark = Color(hex: "1A1A1A")
}

// MARK: - Color Hex Init

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

// MARK: - UIColor Hex Init

extension UIColor {
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
#endif
