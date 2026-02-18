// ResponseServiceProtocol.swift
// Circle
// Copyright 2024 StudioNext

import Foundation

/// Protocol defining voice response operations.
/// All implementations are local-only -- no network calls.
@MainActor
public protocol ResponseServiceProtocol: AnyObject {
    /// Get all responses for a given circle on a specific date.
    /// - Parameters:
    ///   - circleId: The circle to query.
    ///   - date: The date to filter by (matches calendar day).
    /// - Returns: Array of VoiceResponse entities sorted by creation date.
    func getResponses(circleId: UUID, date: Date) async throws -> [VoiceResponse]

    /// Save a new voice response linking a voice note to a prompt and member.
    /// - Parameters:
    ///   - voiceNoteId: The recorded VoiceNote's identifier.
    ///   - promptId: The Prompt being responded to.
    ///   - memberId: The CircleMember who recorded the response.
    ///   - circleId: The Circle this response belongs to.
    /// - Returns: The saved VoiceResponse entity.
    func saveResponse(voiceNoteId: UUID, promptId: UUID, memberId: UUID, circleId: UUID) async throws -> VoiceResponse

    /// Mark a response as heard by the current user.
    /// - Parameter responseId: The response identifier.
    func markAsHeard(responseId: UUID) async throws

    /// Get the count of responses for a given circle on a specific date.
    /// - Parameters:
    ///   - circleId: The circle to query.
    ///   - date: The date to filter by (matches calendar day).
    /// - Returns: The number of responses.
    func getResponseCount(circleId: UUID, date: Date) async throws -> Int
}
