// Environment.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Centralized environment configuration for the app
/// Reads build-time configuration from Info.plist (set via xcconfig files)
/// This allows switching between emulator and production via build configuration
/// Note: Named AppEnvironment to avoid conflict with SwiftUI's @Environment property wrapper
public enum AppEnvironment {

    // MARK: - Build Configuration Detection

    /// Whether the app is running in DEBUG build configuration
    public static var isDebug: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }

    /// Whether the app is running in RELEASE build configuration
    public static var isRelease: Bool {
        !isDebug
    }

    // MARK: - Firebase Configuration

    /// Firebase emulator configuration read from Info.plist
    /// These values are set via xcconfig files at build time
    public enum Firebase {

        /// Whether to use Firebase emulators (set via FIREBASE_USE_EMULATOR in xcconfig)
        /// Returns true only if explicitly set to "YES" in the build configuration
        public static var useEmulator: Bool {
            guard let value = Bundle.main.infoDictionary?["FirebaseUseEmulator"] as? String else {
                // Default to DEBUG behavior if not configured
                return AppEnvironment.isDebug
            }
            return value.uppercased() == "YES"
        }

        /// Firebase emulator host (default: 127.0.0.1)
        public static var emulatorHost: String {
            guard let value = Bundle.main.infoDictionary?["FirebaseEmulatorHost"] as? String,
                  !value.isEmpty else {
                return "127.0.0.1"
            }
            return value
        }

        /// Firebase Functions emulator port (default: 5001)
        public static var functionsEmulatorPort: Int {
            guard let value = Bundle.main.infoDictionary?["FirebaseFunctionsEmulatorPort"] as? String,
                  let port = Int(value) else {
                return 5001
            }
            return port
        }

        /// Firebase Firestore emulator port (default: 8080)
        public static var firestoreEmulatorPort: Int {
            guard let value = Bundle.main.infoDictionary?["FirebaseFirestoreEmulatorPort"] as? String,
                  let port = Int(value) else {
                return 8080
            }
            return port
        }

        /// Firebase Auth emulator port (default: 9099)
        public static var authEmulatorPort: Int {
            guard let value = Bundle.main.infoDictionary?["FirebaseAuthEmulatorPort"] as? String,
                  let port = Int(value) else {
                return 9099
            }
            return port
        }

        /// Convenience: Full emulator URL for Functions
        public static var functionsEmulatorURL: String {
            "http://\(emulatorHost):\(functionsEmulatorPort)"
        }

        /// Convenience: Full emulator URL for Firestore
        public static var firestoreEmulatorURL: String {
            "http://\(emulatorHost):\(firestoreEmulatorPort)"
        }

        /// Convenience: Full emulator URL for Auth
        public static var authEmulatorURL: String {
            "http://\(emulatorHost):\(authEmulatorPort)"
        }
    }

    // MARK: - Logging

    /// Print environment configuration (useful for debugging)
    public static func logConfiguration() {
        #if DEBUG
        print("=== Environment Configuration ===")
        print("Build: \(isDebug ? "DEBUG" : "RELEASE")")
        print("Firebase Use Emulator: \(Firebase.useEmulator)")
        if Firebase.useEmulator {
            print("  Emulator Host: \(Firebase.emulatorHost)")
            print("  Functions Port: \(Firebase.functionsEmulatorPort)")
            print("  Firestore Port: \(Firebase.firestoreEmulatorPort)")
            print("  Auth Port: \(Firebase.authEmulatorPort)")
        } else {
            print("  Using PRODUCTION Firebase")
        }
        print("=================================")
        #endif
    }
}
