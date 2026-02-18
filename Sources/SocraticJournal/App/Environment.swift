// Environment.swift
// Circle
// Copyright 2024 StudioNext

import Foundation

/// Centralized environment configuration for the app
public enum AppEnvironment {

    // MARK: - Build Configuration

    public static var isDebug: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }

    public static var isRelease: Bool {
        !isDebug
    }

    // MARK: - App Info

    public static var version: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "2.0.0"
    }

    public static var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }

    public static var displayName: String {
        Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "Circle"
    }

    // MARK: - Logging

    public static func logConfiguration() {
        #if DEBUG
        print("=== Circle App Configuration ===")
        print("Build: \(isDebug ? "DEBUG" : "RELEASE")")
        print("Version: \(version) (\(buildNumber))")
        print("================================")
        #endif
    }
}
