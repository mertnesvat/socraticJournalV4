// ClarityScoreServiceProtocol.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Protocol defining the clarity score calculation service
/// Generates scores and wisdom quotes for completed sessions
public protocol ClarityScoreServiceProtocol: Sendable {
    /// Calculates the clarity score from completed exchanges
    /// - Parameter exchanges: The completed exchanges from a session
    /// - Returns: A fully populated ClarityScore
    func calculateScore(from exchanges: [Exchange]) async throws -> ClarityScore

    /// Generates a wisdom quote matched to the session content
    /// - Parameters:
    ///   - exchanges: The completed exchanges from a session
    ///   - score: The calculated clarity score
    /// - Returns: A thematic wisdom quote
    func generateWisdomQuote(for exchanges: [Exchange], score: ClarityScore) async throws -> WisdomQuote
}

/// Errors that can occur in the clarity score service
public enum ClarityScoreServiceError: Error, LocalizedError {
    case insufficientExchanges
    case calculationFailed(String)

    public var errorDescription: String? {
        switch self {
        case .insufficientExchanges:
            return "Not enough exchanges to calculate a score."
        case .calculationFailed(let reason):
            return "Failed to calculate clarity score: \(reason)"
        }
    }
}
