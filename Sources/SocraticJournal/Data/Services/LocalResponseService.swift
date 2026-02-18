// LocalResponseService.swift
// Circle
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation
import SwiftData
import SwiftUI

/// Local response service backed by SwiftData.
/// All operations are performed on-device with no network calls.
@Observable
@MainActor
public final class LocalResponseService: ResponseServiceProtocol {
    // MARK: - Dependencies

    private let modelContainer: ModelContainer

    private var modelContext: ModelContext {
        modelContainer.mainContext
    }

    // MARK: - Init

    public init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
    }

    // MARK: - ResponseServiceProtocol

    public func getResponses(circleId: UUID, date: Date) async throws -> [VoiceResponse] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            return []
        }

        let descriptor = FetchDescriptor<VoiceResponse>(
            predicate: #Predicate<VoiceResponse> { response in
                response.circleId == circleId
                    && response.createdAt >= startOfDay
                    && response.createdAt < endOfDay
            },
            sortBy: [SortDescriptor(\.createdAt, order: .forward)]
        )
        return try modelContext.fetch(descriptor)
    }

    public func saveResponse(voiceNoteId: UUID, promptId: UUID, memberId: UUID, circleId: UUID) async throws -> VoiceResponse {
        let response = VoiceResponse(
            voiceNoteId: voiceNoteId,
            promptId: promptId,
            memberId: memberId,
            circleId: circleId
        )

        modelContext.insert(response)
        try modelContext.save()
        return response
    }

    public func markAsHeard(responseId: UUID) async throws {
        let descriptor = FetchDescriptor<VoiceResponse>(
            predicate: #Predicate<VoiceResponse> { $0.id == responseId }
        )
        guard let response = try modelContext.fetch(descriptor).first else {
            return
        }
        response.isHeard = true
        try modelContext.save()
    }

    public func getResponseCount(circleId: UUID, date: Date) async throws -> Int {
        let responses = try await getResponses(circleId: circleId, date: date)
        return responses.count
    }
}
#endif
