// JournalExport.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Wrapper struct containing all exported journal data
public struct JournalExport: Codable, Sendable, Equatable {
    /// Timestamp when the export was created
    public let exportedAt: Date

    /// App version at time of export
    public let version: String

    /// All journal sessions with their exchanges
    public let sessions: [JournalSession]

    /// All future letters
    public let letters: [FutureLetter]

    /// User settings configuration
    public let settings: UserSettings

    public init(
        exportedAt: Date = Date(),
        version: String = SocraticJournal.version,
        sessions: [JournalSession],
        letters: [FutureLetter],
        settings: UserSettings
    ) {
        self.exportedAt = exportedAt
        self.version = version
        self.sessions = sessions
        self.letters = letters
        self.settings = settings
    }

    /// Summary statistics for the export
    public var summary: ExportSummary {
        ExportSummary(
            sessionCount: sessions.count,
            letterCount: letters.count,
            totalExchanges: sessions.reduce(0) { $0 + $1.exchanges.count },
            completedSessions: sessions.filter { $0.isComplete }.count
        )
    }
}

/// Summary statistics for exported data
public struct ExportSummary: Sendable, Equatable {
    public let sessionCount: Int
    public let letterCount: Int
    public let totalExchanges: Int
    public let completedSessions: Int

    public init(
        sessionCount: Int,
        letterCount: Int,
        totalExchanges: Int,
        completedSessions: Int
    ) {
        self.sessionCount = sessionCount
        self.letterCount = letterCount
        self.totalExchanges = totalExchanges
        self.completedSessions = completedSessions
    }
}
