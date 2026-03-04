// BreathSession.swift
// Breathe
// Copyright 2024 StudioNext

import Foundation

/// Represents a completed breath pacing session
public struct BreathSession: Identifiable, Codable, Sendable {
    public let id: String
    public let techniqueId: String
    public let startedAt: Date
    public let completedAt: Date
    public let totalDuration: TimeInterval
    public let cyclesCompleted: Int

    /// The calendar day this session belongs to
    public var date: Date {
        Calendar.current.startOfDay(for: startedAt)
    }

    /// Duration formatted as minutes (e.g. "5 min")
    public var formattedDuration: String {
        let minutes = Int(totalDuration / 60)
        return "\(minutes) min"
    }

    /// Time formatted for display (e.g. "9:30 AM")
    public var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: startedAt)
    }

    public init(
        id: String = UUID().uuidString,
        techniqueId: String,
        startedAt: Date,
        completedAt: Date,
        totalDuration: TimeInterval,
        cyclesCompleted: Int
    ) {
        self.id = id
        self.techniqueId = techniqueId
        self.startedAt = startedAt
        self.completedAt = completedAt
        self.totalDuration = totalDuration
        self.cyclesCompleted = cyclesCompleted
    }
}
