// BreathSession.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

public struct BreathSession: Identifiable, Codable, Sendable {
    public let id: String
    public let techniqueId: String
    public let startedAt: Date
    public let completedAt: Date
    public let totalDuration: TimeInterval
    public let cyclesCompleted: Int

    public var date: Date { Calendar.current.startOfDay(for: startedAt) }
}
