// AppGroupSessionStore.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Shared App Group identifier for main app and widget extension
public enum AppGroupIdentifier {
    public static let group = "group.com.StudioNext.socraticJournal"
    public static let sessionsKey = "com.socraticjournal.sessions.shared"
    public static let streakKey = "com.socraticjournal.streak.shared"
}

/// Lightweight struct for widget-readable streak data
public struct SharedStreakData: Codable, Sendable {
    public let currentStreak: Int
    public let lastSessionDate: Date?
    public let isAtRisk: Bool
    public let totalMinutes: Int
    public let lastUpdated: Date

    public init(
        currentStreak: Int = 0,
        lastSessionDate: Date? = nil,
        isAtRisk: Bool = false,
        totalMinutes: Int = 0,
        lastUpdated: Date = Date()
    ) {
        self.currentStreak = currentStreak
        self.lastSessionDate = lastSessionDate
        self.isAtRisk = isAtRisk
        self.totalMinutes = totalMinutes
        self.lastUpdated = lastUpdated
    }
}

/// Writes session and streak data to App Group UserDefaults for widget access
public final class AppGroupSessionStore: Sendable {
    public static let shared = AppGroupSessionStore()

    private init() {}

    /// Write streak data to App Group for widget consumption
    public func writeStreakData(_ data: SharedStreakData) {
        guard let defaults = UserDefaults(suiteName: AppGroupIdentifier.group) else { return }
        if let encoded = try? JSONEncoder().encode(data) {
            defaults.set(encoded, forKey: AppGroupIdentifier.streakKey)
        }
    }

    /// Read streak data from App Group (used by widget)
    public func readStreakData() -> SharedStreakData {
        guard let defaults = UserDefaults(suiteName: AppGroupIdentifier.group),
              let data = defaults.data(forKey: AppGroupIdentifier.streakKey),
              let decoded = try? JSONDecoder().decode(SharedStreakData.self, from: data) else {
            return SharedStreakData()
        }
        return decoded
    }

    /// Update streak data after a session is saved
    public func updateAfterSession(sessions: [BreathSession]) {
        let calculator = StreakCalculator()
        let streakInfo = calculator.calculateStreak(from: sessions)
        let totalMinutes = calculator.totalMinutes(from: sessions)

        let data = SharedStreakData(
            currentStreak: streakInfo.currentStreak,
            lastSessionDate: streakInfo.lastSessionDate,
            isAtRisk: streakInfo.isAtRisk,
            totalMinutes: totalMinutes
        )
        writeStreakData(data)
    }
}
