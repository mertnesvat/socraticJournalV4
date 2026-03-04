// AppTypography.swift
// Breathe
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

public enum AppTypography {
    // Serif font family
    public static let serifFamily = "Georgia"

    // Display — Georgia serif heroes
    public static let displayLarge = Font.custom(serifFamily, size: 48).weight(.bold)
    public static let displayMedium = Font.custom(serifFamily, size: 40).weight(.bold)
    public static let display = Font.custom(serifFamily, size: 34).weight(.bold)

    // Headlines — Georgia serif
    public static let headline = Font.custom(serifFamily, size: 28).weight(.bold)
    public static let headlineMedium = Font.custom(serifFamily, size: 24).weight(.semibold)
    public static let headlineSmall = Font.custom(serifFamily, size: 22).weight(.bold)

    // Section headers — ALL CAPS editorial (system sans-serif)
    public static let sectionHeader = Font.system(size: 13, weight: .heavy, design: .default)

    // Body — System sans-serif
    public static let bodyLarge = Font.system(size: 20, weight: .regular, design: .default)
    public static let body = Font.system(size: 17, weight: .regular, design: .default)
    public static let bodyBold = Font.system(size: 17, weight: .semibold, design: .default)

    // Caption
    public static let caption = Font.system(size: 13, weight: .regular, design: .default)
    public static let captionBold = Font.system(size: 13, weight: .semibold, design: .default)

    // Special
    public static let stat = Font.custom(serifFamily, size: 42).weight(.bold)
    public static let statSmall = Font.custom(serifFamily, size: 32).weight(.bold)
    public static let timer = Font.system(size: 28, weight: .medium, design: .monospaced)
    public static let badge = Font.system(size: 11, weight: .bold, design: .default)

    // Phase label — italic Georgia
    public static let phaseLabel = Font.custom(serifFamily, size: 28)

    // Article title — Georgia
    public static let articleTitle = Font.custom(serifFamily, size: 15).weight(.bold)

    // Fact value — Georgia
    public static let factValue = Font.custom(serifFamily, size: 18).weight(.bold)

    // Tab label — Georgia
    public static let tabLabel = Font.custom(serifFamily, size: 11)

    // Reminder time — Georgia
    public static let reminderTime = Font.custom(serifFamily, size: 20).weight(.bold)

    // Greeting — Georgia
    public static let greeting = Font.custom(serifFamily, size: 26).weight(.bold)

    // Pattern selector — Georgia
    public static let patternPill = Font.custom(serifFamily, size: 12)

    // Tracking for section headers
    public static let sectionHeaderTracking: CGFloat = 2.0
}
#endif
