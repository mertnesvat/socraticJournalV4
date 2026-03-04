// BreathSession.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// A completed breath exercise session
public struct BreathSession: Identifiable, Codable, Sendable {
    public let id: String
    public let patternId: String
    public let startedAt: Date
    public let completedAt: Date
    public let totalDuration: TimeInterval
    public let cyclesCompleted: Int

    /// The calendar day this session belongs to
    public var date: Date { Calendar.current.startOfDay(for: startedAt) }

    public init(
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
