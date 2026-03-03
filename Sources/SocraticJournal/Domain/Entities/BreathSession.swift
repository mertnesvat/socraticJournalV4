// BreathSession.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// A completed breathing session record
public struct BreathSession: Codable, Sendable, Identifiable, Equatable {
    public let id: String
    public let patternId: String
    public let patternName: String
    public let startTime: Date
    public let endTime: Date
    public let totalDurationSeconds: TimeInterval
    public let breathsCompleted: Int
    public let date: Date  // Calendar date of the session (midnight-normalized)

    public init(
        id: String = UUID().uuidString,
        patternId: String,
        patternName: String,
        startTime: Date,
        endTime: Date,
        totalDurationSeconds: TimeInterval,
        breathsCompleted: Int,
        date: Date? = nil
    ) {
        self.id = id
        self.patternId = patternId
        self.patternName = patternName
        self.startTime = startTime
        self.endTime = endTime
        self.totalDurationSeconds = totalDurationSeconds
        self.breathsCompleted = breathsCompleted
        self.date = date ?? Calendar.current.startOfDay(for: startTime)
    }

    /// Formatted duration string (e.g. "5:00")
    public var formattedDuration: String {
        let minutes = Int(totalDurationSeconds) / 60
        let seconds = Int(totalDurationSeconds) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    /// Formatted duration for display (e.g. "5 min")
    public var shortDurationLabel: String {
        let minutes = Int(totalDurationSeconds) / 60
        if minutes > 0 {
            return "\(minutes) min"
        } else {
            return "\(Int(totalDurationSeconds)) sec"
        }
    }

    /// Formatted time of day (e.g. "9:30 AM")
    public var formattedTimeOfDay: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter.string(from: startTime)
    }

    /// Formatted date (e.g. "Mar 3")
    public var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }

    /// Whether this session counts toward streak (at least 60 seconds)
    public var countsForStreak: Bool {
        totalDurationSeconds >= 60
    }
}
