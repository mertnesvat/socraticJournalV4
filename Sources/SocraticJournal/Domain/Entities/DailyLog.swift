// DailyLog.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

struct DailyLog: Identifiable, Codable, Sendable {
    let date: Date
    let sessions: [BreathSession]

    var id: Date { date }
    var totalMinutes: Double { sessions.reduce(0) { $0 + $1.totalDuration } / 60.0 }
    var sessionsCount: Int { sessions.count }
}
