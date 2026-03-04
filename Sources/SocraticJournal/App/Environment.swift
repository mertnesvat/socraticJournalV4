// Environment.swift
// Breathe
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

    public static var isRelease: Bool { !isDebug }

    // MARK: - Firebase

    public enum Firebase {
        public static var useEmulator: Bool {
            guard let value = Bundle.main.infoDictionary?["FirebaseUseEmulator"] as? String else {
                return AppEnvironment.isDebug
            }
            return value.uppercased() == "YES"
        }
    }

    // MARK: - Logging

    public static func logConfiguration() {
        #if DEBUG
        print("=== Breathe Environment ===")
        print("Build: \(isDebug ? "DEBUG" : "RELEASE")")
        print("===========================")
        #endif
    }
}
