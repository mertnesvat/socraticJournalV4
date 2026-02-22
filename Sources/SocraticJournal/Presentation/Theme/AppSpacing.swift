// AppSpacing.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

public enum AppSpacing {
    public static let xxs: CGFloat = 4
    public static let xs: CGFloat = 8
    public static let sm: CGFloat = 12
    public static let md: CGFloat = 16
    public static let lg: CGFloat = 24
    public static let xl: CGFloat = 32
    public static let xxl: CGFloat = 48

    // Specific
    public static let cardPadding: CGFloat = 16
    public static let screenPadding: CGFloat = 20
    public static let sectionSpacing: CGFloat = 24
    public static let tabBarHeight: CGFloat = 60
    public static let avatarSmall: CGFloat = 44
    public static let avatarLarge: CGFloat = 100
    public static let recordButtonSize: CGFloat = 80
}
#endif
