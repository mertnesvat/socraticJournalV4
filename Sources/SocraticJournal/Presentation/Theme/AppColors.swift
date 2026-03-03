// AppColors.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

public enum AppColors {
    // Accent -- Calming teal-cyan
    public static let accent = Color(hex: "64FFDA")

    // Backgrounds -- Deep navy
    public static let background = Color(hex: "0A1628")
    public static let surface = Color(hex: "112240")
    public static let surfaceElevated = Color(hex: "1B3A5C")

    // Dark variants (kept for compatibility)
    public static let backgroundDark = Color(hex: "0A0A0A")
    public static let surfaceDark = Color(hex: "1A1A1A")

    // Text -- Light on dark
    public static let textPrimary = Color.white
    public static let textSecondary = Color(hex: "8892B0")
    public static let textTertiary = Color(hex: "495670")
    public static let textOnDark = Color.white
    public static let textOnAccent = Color(hex: "0A1628")

    // Semantic
    public static let success = Color(hex: "34C759")
    public static let warning = Color(hex: "FF9F0A")
    public static let error = Color(hex: "FF5252")

    // Breath phase colours
    public static let breathInhale = Color(hex: "64FFDA")   // Teal
    public static let breathHold = Color(hex: "FFD54F")      // Amber/gold
    public static let breathExhale = Color(hex: "82B1FF")    // Soft blue

    // Background arc gradient for sessions
    public static let arcStart = Color(hex: "0A1628")        // Deep navy
    public static let arcEnd = Color(hex: "1B4B5A")          // Warmer blue-teal

    // Card colors (adapted for dark theme)
    public static let cardYellow = Color(hex: "FADF63")
    public static let cardTeal = Color(hex: "64FFDA")
    public static let cardDark = Color(hex: "1C1C1E")

    // Borders (muted for dark theme)
    public static let border = Color(hex: "1E3A5F")
    public static let borderStrong = Color(hex: "2A4A6F")

    // Tab bar specific
    public static let tabBarBackground = Color(hex: "0A1628")
    public static let tabBarBorder = Color(hex: "1E3A5F")

    // Single gradient for special elements
    public static let accentGradient = LinearGradient(
        colors: [Color(hex: "64FFDA"), Color(hex: "4ECDC4")],
        startPoint: .leading, endPoint: .trailing
    )
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
