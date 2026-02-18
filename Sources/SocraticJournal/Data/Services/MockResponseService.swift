// MockResponseService.swift
// Circle
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation

/// Mock response service for SwiftUI previews and testing.
/// Returns sample data without requiring SwiftData persistence.
@Observable
@MainActor
public final class MockResponseService: ResponseServiceProtocol {
    // MARK: - State

    public var responses: [VoiceResponse] = []

    // MARK: - Init

    /// Creates a mock response service.
    /// - Parameter withSampleData: If true, populates with sample responses.
    public init(withSampleData: Bool = true) {
        if withSampleData {
            responses = Self.makeSampleResponses()
        }
    }

    // MARK: - ResponseServiceProtocol

    public func getResponses(circleId: UUID, date: Date) async throws -> [VoiceResponse] {
        let calendar = Calendar.current
        return responses.filter { response in
            response.circleId == circleId
                && calendar.isDate(response.createdAt, inSameDayAs: date)
        }
        .sorted { $0.createdAt < $1.createdAt }
    }

    public func saveResponse(voiceNoteId: UUID, promptId: UUID, memberId: UUID, circleId: UUID) async throws -> VoiceResponse {
        let response = VoiceResponse(
            voiceNoteId: voiceNoteId,
            promptId: promptId,
            memberId: memberId,
            circleId: circleId
        )
        responses.append(response)
        return response
    }

    public func markAsHeard(responseId: UUID) async throws {
        if let index = responses.firstIndex(where: { $0.id == responseId }) {
            responses[index].isHeard = true
        }
    }

    public func getResponseCount(circleId: UUID, date: Date) async throws -> Int {
        let filtered = try await getResponses(circleId: circleId, date: date)
        return filtered.count
    }

    // MARK: - Sample Data

    /// Sample circle ID used across mock services for consistency.
    static let sampleCircleId = UUID()
    /// Sample prompt ID used across mock services for consistency.
    static let samplePromptId = UUID()
    /// Sample member IDs for mock data.
    static let sampleMemberIds = [UUID(), UUID(), UUID()]

    private static func makeSampleResponses() -> [VoiceResponse] {
        let circleId = sampleCircleId
        let promptId = samplePromptId

        return [
            VoiceResponse(
                voiceNoteId: UUID(),
                promptId: promptId,
                memberId: sampleMemberIds[0],
                circleId: circleId,
                isHeard: true,
                createdAt: Date().addingTimeInterval(-3600)
            ),
            VoiceResponse(
                voiceNoteId: UUID(),
                promptId: promptId,
                memberId: sampleMemberIds[1],
                circleId: circleId,
                isHeard: false,
                createdAt: Date().addingTimeInterval(-1800)
            ),
        ]
    }
}
#endif
