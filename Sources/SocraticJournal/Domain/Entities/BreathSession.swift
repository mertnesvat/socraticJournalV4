// BreathSession.swift
// Breathe
// Copyright 2024 StudioNext

import Foundation

struct BreathSession: Identifiable, Codable, Sendable {
    let id: String
    let patternId: String
    let startedAt: Date
    let completedAt: Date
    let totalDuration: TimeInterval
    let cyclesCompleted: Int

    var date: Date { Calendar.current.startOfDay(for: startedAt) }

    init(
        id: String = UUID().uuidString,
        patternId: String,
        startedAt: Date,
        completedAt: Date,
        totalDuration: TimeInterval,
        cyclesCompleted: Int
    ) {
        self.id = id
        self.patternId = patternId
        self.startedAt = startedAt
        self.completedAt = completedAt
        self.totalDuration = totalDuration
        self.cyclesCompleted = cyclesCompleted
    }
}
