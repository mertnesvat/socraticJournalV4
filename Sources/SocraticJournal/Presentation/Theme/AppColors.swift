// AppColors.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

public enum AppColors {
    // Primary — Calm Teal (breath-focused)
    public static let accent = Color(hex: "2D5F5D")
    public static let accentLight = Color(hex: "2D5F5D").opacity(0.1)

    // Secondary — Deep Coral (energy, alerts, stress patterns)
    public static let accent2 = Color(hex: "C4502A")

    // Backgrounds — Warm cream editorial
    public static let background = Color(hex: "FAF7F2")
    public static let surface = Color(hex: "F2EDE4")
    public static let surfaceElevated = Color(hex: "EDE7DB")

    // Dark variants
    public static let backgroundDark = Color(hex: "0A0A0A")
    public static let surfaceDark = Color(hex: "1A1A1A")

    // Text — Warm brown tones
    public static let textPrimary = Color(hex: "1C1710")
    public static let textSecondary = Color(hex: "7A6E60")
    public static let textTertiary = Color(hex: "B0A898")
    public static let textOnDark = Color.white
    public static let textOnAccent = Color.white

    // Semantic
    public static let success = Color(hex: "34C759")
    public static let warning = Color(hex: "FF9F0A")
    public static let error = Color(hex: "C4502A")

    // Pattern tag colors
    public static let tagSleep = Color(hex: "6B4C8A")
    public static let tagCO2 = Color(hex: "7A6030")
    public static let tagNature = Color(hex: "5A6E3D")
    public static let tagHold = Color(hex: "5A8A6A")

    // Card colors
    public static let cardTeal = Color(hex: "8EDDD0")
    public static let cardYellow = Color(hex: "FADF63")
    public static let cardDark = Color(hex: "1C1C1E")

    // Borders (hairline grid)
    public static let border = Color(hex: "D8D0C4")
    public static let borderStrong = Color(hex: "C8C4BC")

    // Gradient
    public static let accentGradient = LinearGradient(
        colors: [Color(hex: "2D5F5D"), Color(hex: "1E4A48")],
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
