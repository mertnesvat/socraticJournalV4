// AppTypography.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

public enum AppTypography {
    // Headlines
    public static let headline = Font.system(size: 28, weight: .bold, design: .default)
    public static let headlineLarge = Font.system(size: 34, weight: .bold, design: .default)

    // Titles
    public static let title = Font.system(size: 24, weight: .semibold, design: .default)
    public static let titleSmall = Font.system(size: 20, weight: .semibold, design: .default)

    // Body
    public static let body = Font.system(size: 17, weight: .regular, design: .default)
    public static let bodyBold = Font.system(size: 17, weight: .semibold, design: .default)

    // Caption
    public static let caption = Font.system(size: 13, weight: .regular, design: .default)
    public static let captionBold = Font.system(size: 13, weight: .semibold, design: .default)

    // Special
    public static let timer = Font.system(size: 28, weight: .medium, design: .monospaced)
    public static let stat = Font.system(size: 22, weight: .bold, design: .rounded)
    public static let badge = Font.system(size: 11, weight: .bold, design: .default)
}
#endif
