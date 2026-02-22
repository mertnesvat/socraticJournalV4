// AppColors.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

public enum AppColors {
    // Primary
    public static let primary = Color(hex: "007AFF")        // Electric Blue
    public static let secondary = Color(hex: "FF6B6B")      // Hot Coral

    // Backgrounds
    public static let background = Color(hex: "0A0A0A")     // Near Black
    public static let surface = Color(hex: "1A1A1A")        // Dark Gray
    public static let surfaceElevated = Color(hex: "2A2A2A") // Slightly lighter

    // Text
    public static let textPrimary = Color.white
    public static let textSecondary = Color(hex: "8E8E93")  // System Gray
    public static let textTertiary = Color(hex: "636366")

    // Semantic
    public static let success = Color(hex: "34C759")        // Emerald
    public static let warning = Color(hex: "FF9F0A")        // Amber
    public static let error = Color(hex: "FF3B30")          // Red

    // Question Categories
    public static let iceBreaker = Color(hex: "007AFF")     // Blue
    public static let gettingSpicy = Color(hex: "FF9F0A")   // Orange
    public static let deepDive = Color(hex: "AF52DE")       // Purple
    public static let debateTrigger = Color(hex: "FF3B30")  // Red

    // Gradients
    public static let primaryGradient = LinearGradient(
        colors: [Color(hex: "007AFF"), Color(hex: "5856D6")],
        startPoint: .leading, endPoint: .trailing
    )
    public static let coralGradient = LinearGradient(
        colors: [Color(hex: "FF6B6B"), Color(hex: "FF9F0A")],
        startPoint: .leading, endPoint: .trailing
    )
    public static let backgroundGradient = LinearGradient(
        colors: [Color(hex: "1A0033"), Color(hex: "000D1A"), Color(hex: "001A1A")],
        startPoint: .topLeading, endPoint: .bottomTrailing
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
