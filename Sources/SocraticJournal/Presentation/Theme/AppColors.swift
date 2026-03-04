// AppColors.swift
// Breathe
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

public enum AppColors {
    // Accents
    public static let accent = Color(hex: "2D5F5D")           // Deep teal (primary)
    public static let accentLight = Color(hex: "2D5F5D").opacity(0.09)
    public static let accent2 = Color(hex: "C4502A")          // Terracotta (secondary)

    // Backgrounds — Cream editorial
    public static let background = Color(hex: "FAF7F2")       // Warm cream white
    public static let surface = Color(hex: "F2EDE4")          // Cream
    public static let surfaceElevated = Color(hex: "EDE7DB")  // Paper

    // Dark variants
    public static let backgroundDark = Color(hex: "0A0A0A")
    public static let surfaceDark = Color(hex: "1A1A1A")

    // Text
    public static let textPrimary = Color(hex: "1C1710")      // Near-black warm
    public static let textSecondary = Color(hex: "3D3328")    // Brown (body)
    public static let textTertiary = Color(hex: "7A6E60")     // Mid brown
    public static let textQuaternary = Color(hex: "B0A898")   // Dim (captions)
    public static let textOnDark = Color.white
    public static let textOnAccent = Color.white

    // Semantic
    public static let success = Color(hex: "34C759")
    public static let warning = Color(hex: "FF9F0A")
    public static let error = Color(hex: "C4502A")

    // Phase colors
    public static let phaseInhale = Color(hex: "2D5F5D")     // Teal
    public static let phaseHold = Color(hex: "5A8A6A")        // Moss green
    public static let phaseExhale = Color(hex: "C4502A")      // Terracotta

    // Tag colors
    public static let tagPurple = Color(hex: "6B4C8A")
    public static let tagGold = Color(hex: "7A6030")
    public static let tagGreen = Color(hex: "5A6E3D")

    // Borders
    public static let border = Color(hex: "D8D0C4")
    public static let borderStrong = Color(hex: "C8C4BC")

    // Legacy compatibility
    public static let cardTeal = Color(hex: "8EDDD0")
    public static let cardYellow = Color(hex: "FADF63")
    public static let cardDark = Color(hex: "1C1C1E")
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
