// AppColors.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

public enum AppColors {
    // Accent — Bold Coral Red (hero color)
    public static let accent = Color(hex: "E8503A")

    // Backgrounds — Cream editorial
    public static let background = Color(hex: "FAF7F2")      // Warm cream
    public static let surface = Color(hex: "FFFFFF")           // White cards
    public static let surfaceElevated = Color(hex: "F0EBE3")  // Darker cream

    // Dark variants (recording studio, dark cards)
    public static let backgroundDark = Color(hex: "0A0A0A")
    public static let surfaceDark = Color(hex: "1A1A1A")

    // Text
    public static let textPrimary = Color(hex: "1A1A1A")
    public static let textSecondary = Color(hex: "6B6B6B")
    public static let textTertiary = Color(hex: "9E9E9E")
    public static let textOnDark = Color.white
    public static let textOnAccent = Color.white

    // Semantic
    public static let success = Color(hex: "34C759")
    public static let warning = Color(hex: "FF9F0A")
    public static let error = Color(hex: "E8503A")

    // Card colors for conversational stacking
    public static let cardYellow = Color(hex: "FADF63")
    public static let cardTeal = Color(hex: "8EDDD0")
    public static let cardDark = Color(hex: "1C1C1E")

    // Question Categories
    public static let iceBreaker = Color(hex: "3A7BD5")
    public static let gettingSpicy = Color(hex: "F5A623")
    public static let deepDive = Color(hex: "9B59B6")
    public static let debateTrigger = Color(hex: "E8503A")

    // Borders (hairline grid from structured minimalism)
    public static let border = Color(hex: "E0DDD7")
    public static let borderStrong = Color(hex: "C8C4BC")

    // Single gradient for special elements
    public static let accentGradient = LinearGradient(
        colors: [Color(hex: "E8503A"), Color(hex: "D04030")],
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
