// AppTypography.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

public enum AppTypography {
    // Display -- Editorial heroes
    public static let displayLarge = Font.system(size: 48, weight: .bold, design: .default)
    public static let displayMedium = Font.system(size: 40, weight: .bold, design: .default)
    public static let display = Font.system(size: 34, weight: .bold, design: .default)

    // Headlines
    public static let headline = Font.system(size: 28, weight: .bold, design: .default)
    public static let headlineMedium = Font.system(size: 24, weight: .semibold, design: .default)

    // Section headers -- ALL CAPS editorial
    public static let sectionHeader = Font.system(size: 13, weight: .heavy, design: .default)

    // Body
    public static let bodyLarge = Font.system(size: 20, weight: .regular, design: .default)
    public static let body = Font.system(size: 17, weight: .regular, design: .default)
    public static let bodyBold = Font.system(size: 17, weight: .semibold, design: .default)

    // Caption
    public static let caption = Font.system(size: 13, weight: .regular, design: .default)
    public static let captionBold = Font.system(size: 13, weight: .semibold, design: .default)

    // Special
    public static let stat = Font.system(size: 56, weight: .bold, design: .default)
    public static let statSmall = Font.system(size: 32, weight: .bold, design: .default)
    public static let timer = Font.system(size: 28, weight: .medium, design: .monospaced)
    public static let badge = Font.system(size: 11, weight: .bold, design: .default)

    // Breath phase labels -- lowercase serif for session display
    public static let phaseLabel = Font.system(size: 34, weight: .regular, design: .serif)
    public static let phaseLabelSmall = Font.system(size: 20, weight: .regular, design: .serif)

    // Tracking for section headers
    public static let sectionHeaderTracking: CGFloat = 2.0
}
#endif
