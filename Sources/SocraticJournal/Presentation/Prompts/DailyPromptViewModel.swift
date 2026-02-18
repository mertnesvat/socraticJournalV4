// DailyPromptViewModel.swift
// Circle
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation
import SwiftUI

/// ViewModel for the daily prompt experience.
/// Loads today's prompt for a given circle and manages loading/error states.
@Observable
@MainActor
public final class DailyPromptViewModel {
    // MARK: - State

    private(set) var prompt: Prompt?
    private(set) var isLoading = false
    private(set) var error: Error?

    /// Whether the prompt has been loaded successfully.
    var hasPrompt: Bool { prompt != nil }

    // MARK: - Dependencies

    private let promptService: PromptServiceProtocol
    private let circleId: UUID

    // MARK: - Init

    public init(promptService: PromptServiceProtocol, circleId: UUID) {
        self.promptService = promptService
        self.circleId = circleId
    }

    // MARK: - Actions

    /// Load today's prompt for the circle.
    func loadTodaysPrompt() async {
        isLoading = true
        error = nil
        do {
            prompt = try await promptService.getTodaysPrompt(for: circleId)
        } catch {
            self.error = error
        }
        isLoading = false
    }

    /// Mark the current prompt as seen.
    func markSeen() async {
        guard let prompt else { return }
        do {
            try await promptService.markPromptSeen(id: prompt.id)
            self.prompt?.isSeen = true
        } catch {
            self.error = error
        }
    }

    /// Clear the current error state.
    func clearError() {
        error = nil
    }
}
#endif
