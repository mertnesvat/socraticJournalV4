// JournalRepositoryProtocol.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Protocol defining journal data operations
public protocol JournalRepositoryProtocol: Sendable {
    // MARK: - Sessions

    /// Fetches all journal sessions
    func getAllSessions() async throws -> [JournalSession]

    /// Fetches a specific session by ID
    func getSession(id: String) async throws -> JournalSession?

    /// Saves a journal session (create or update)
    func saveSession(_ session: JournalSession) async throws

    /// Deletes a journal session
    func deleteSession(id: String) async throws

    /// Fetches sessions for a specific date
    func getSessions(for date: Date) async throws -> [JournalSession]

    // MARK: - Stats

    /// Fetches current journal statistics
    func getStats() async throws -> JournalStats

    // MARK: - Future Letters

    /// Fetches all future letters
    func getAllLetters() async throws -> [FutureLetter]

    /// Fetches letters by status
    func getLetters(status: FutureLetterStatus) async throws -> [FutureLetter]

    /// Saves a future letter
    func saveLetter(_ letter: FutureLetter) async throws

    /// Updates a letter's status
    func updateLetterStatus(id: String, status: FutureLetterStatus) async throws

    /// Returns count of letters ready to be read
    func getReadyLettersCount() async throws -> Int
}
