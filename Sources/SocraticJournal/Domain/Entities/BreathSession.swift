// BreathSession.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

struct BreathSession: Identifiable, Codable, Sendable {
    let id: String
    let techniqueId: String
    let startedAt: Date
    let completedAt: Date
    let totalDuration: TimeInterval
    let cyclesCompleted: Int

    var date: Date { Calendar.current.startOfDay(for: startedAt) }
}
