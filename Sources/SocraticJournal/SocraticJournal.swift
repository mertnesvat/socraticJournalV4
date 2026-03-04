// Breathe — Breath pacing & learning app
// Copyright 2024 StudioNext

import Foundation

public enum Breathe {
    public static let bundleIdentifier = "com.StudioNext.socraticJournal"

    public static var version: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
}
