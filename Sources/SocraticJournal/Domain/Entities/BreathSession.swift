// BreathSession.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// A completed breathing session record
public struct BreathSession: Identifiable, Codable, Sendable {
    public let id: UUID
    public let techniqueId: String
    public let techniqueName: String
    public let startedAt: Date
    public let completedAt: Date?
    public let targetDuration: TimeInterval
    public let cyclesCompleted: Int

    public var actualDuration: TimeInterval {
        guard let completedAt else { return 0 }
        return completedAt.timeIntervalSince(startedAt)
    }

    public var isCompleted: Bool { completedAt != nil }

    public init(
        id: UUID = UUID(),
        techniqueId: String,
        techniqueName: String,
        startedAt: Date,
        completedAt: Date?,
        targetDuration: TimeInterval,
        cyclesCompleted: Int
    ) {
        self.id = id
        self.techniqueId = techniqueId
        self.techniqueName = techniqueName
        self.startedAt = startedAt
        self.completedAt = completedAt
        self.targetDuration = targetDuration
        self.cyclesCompleted = cyclesCompleted
    }
}
