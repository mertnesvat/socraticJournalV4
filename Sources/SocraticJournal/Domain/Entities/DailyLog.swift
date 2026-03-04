// DailyLog.swift
// Breathe
// Copyright 2024 StudioNext

import Foundation

/// Aggregated breath sessions for a single day
public struct DailyLog: Identifiable, Codable, Sendable {
    public let date: Date
    public let sessions: [BreathSession]

    public var id: Date { date }

    /// Total minutes breathed on this day
    public var totalMinutes: Double {
        sessions.reduce(0) { $0 + $1.totalDuration } / 60.0
    }

    /// Number of sessions on this day
    public var sessionsCount: Int { sessions.count }

    public init(date: Date, sessions: [BreathSession]) {
        self.date = date
        self.sessions = sessions
    }
}
