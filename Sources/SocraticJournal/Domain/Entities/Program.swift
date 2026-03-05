// Program.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// A multi-day guided breathing program
public struct Program: Identifiable, Sendable {
    public let id: String
    public let name: String
    public let description: String
    public let themeColorHex: String
    public let days: [ProgramDay]
    public var totalDays: Int { days.count }
}

/// A single day within a program
public struct ProgramDay: Identifiable, Sendable {
    public let id: Int // 1-indexed day number
    public let prescriptions: [ProgramPrescription]
    public let tip: String
}

/// A breathing prescription within a program day
public struct ProgramPrescription: Identifiable, Sendable {
    public let id: String
    public let patternId: String
    public let durationMinutes: Int

    public init(patternId: String, durationMinutes: Int) {
        self.id = UUID().uuidString
        self.patternId = patternId
        self.durationMinutes = durationMinutes
    }
}
