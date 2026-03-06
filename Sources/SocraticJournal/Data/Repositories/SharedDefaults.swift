// SharedDefaults.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

public extension UserDefaults {
    /// App Group identifier shared between the main app and RumiWidget extension
    static let appGroupIdentifier = "group.com.StudioNext.socraticJournal"

    /// Shared UserDefaults suite accessible by both the main app and the widget extension.
    /// Falls back to `.standard` in environments where the App Group is not configured
    /// (e.g. macOS builds, Swift Package Manager unit tests).
    static let appGroup: UserDefaults = {
        UserDefaults(suiteName: appGroupIdentifier) ?? .standard
    }()
}
