// DailyLog.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Aggregation of breath sessions for a single day
public struct DailyLog: Identifiable, Codable, Sendable {
    public let date: Date
    public let sessions: [BreathSession]

    public var id: Date { date }
    public var totalMinutes: Double { sessions.reduce(0) { $0 + $1.totalDuration } / 60.0 }
    public var sessionsCount: Int { sessions.count }

    public init(date: Date, sessions: [BreathSession]) {
        self.date = date
        self.sessions = sessions
    }
}
