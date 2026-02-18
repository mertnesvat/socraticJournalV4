// DailyPromptViewModel.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation
import SwiftUI

/// ViewModel for the daily prompt feature.
/// Manages today's prompt, voice note responses, and the "respond first to unlock" mechanic.
@Observable
@MainActor
final class DailyPromptViewModel {

    // MARK: - State

    private(set) var todayPrompt: DailyPrompt?
    private(set) var voiceNotes: [VoiceNote] = []
    private(set) var isLoading = false
    private(set) var error: Error?
    private(set) var promptHistory: [DailyPrompt] = []

    /// Whether the current user has responded to today's prompt.
    /// Controls whether other members' voice notes are visible ("respond first to unlock").
    var hasUserResponded: Bool {
        guard let prompt = todayPrompt else { return false }
        return prompt.respondedUserIds.contains(currentUserId)
    }

    /// Voice notes that should be visible based on the unlock mechanic.
    /// If the user has responded, all notes are visible. Otherwise, only their own.
    var visibleVoiceNotes: [VoiceNote] {
        if hasUserResponded {
            return voiceNotes
        }
        return voiceNotes.filter { $0.userId == currentUserId }
    }

    // MARK: - Dependencies

    private let promptRepository: PromptRepositoryProtocol
    private let promptGenerationService: PromptGenerationServiceProtocol
    private let circleRepository: CircleRepositoryProtocol
    private let voiceNoteRepository: VoiceNoteRepositoryProtocol
    let currentUserId: UUID

    // MARK: - Init

    init(
        promptRepository: PromptRepositoryProtocol,
        promptGenerationService: PromptGenerationServiceProtocol,
        circleRepository: CircleRepositoryProtocol,
        voiceNoteRepository: VoiceNoteRepositoryProtocol,
        currentUserId: UUID
    ) {
        self.promptRepository = promptRepository
        self.promptGenerationService = promptGenerationService
        self.circleRepository = circleRepository
        self.voiceNoteRepository = voiceNoteRepository
        self.currentUserId = currentUserId
    }

    // MARK: - Actions

    /// Load today's prompt for a circle. If none exists, generate one.
    func loadTodayPrompt(circleId: UUID) async {
        isLoading = true
        error = nil

        do {
            // Check if a prompt already exists for today
            if let existing = try await promptRepository.fetchToday(circleId: circleId) {
                todayPrompt = existing
            } else {
                // Generate a new prompt
                let prompt = try await generateNewPrompt(circleId: circleId)
                todayPrompt = prompt
            }

            // Load voice notes for this prompt
            if let prompt = todayPrompt {
                voiceNotes = try await voiceNoteRepository.fetchForPrompt(promptId: prompt.id)
            }
        } catch {
            self.error = error
        }

        isLoading = false
    }

    /// Mark the current user as having responded to today's prompt.
    func markUserResponded() async {
        guard var prompt = todayPrompt else { return }

        // Avoid duplicate entries
        guard !prompt.respondedUserIds.contains(currentUserId) else { return }

        prompt.respondedUserIds.append(currentUserId)

        do {
            try await promptRepository.update(prompt)
            todayPrompt = prompt
        } catch {
            self.error = error
        }
    }

    /// Reload voice notes for the current prompt (e.g., after recording a new one).
    func reloadVoiceNotes() async {
        guard let prompt = todayPrompt else { return }

        do {
            voiceNotes = try await voiceNoteRepository.fetchForPrompt(promptId: prompt.id)
        } catch {
            self.error = error
        }
    }

    /// Load prompt history for a circle.
    func loadHistory(circleId: UUID) async {
        do {
            promptHistory = try await promptRepository.fetchHistory(circleId: circleId, limit: nil)
        } catch {
            self.error = error
        }
    }

    // MARK: - Private

    private func generateNewPrompt(circleId: UUID) async throws -> DailyPrompt {
        // Get circle info for week number
        let circle = try await circleRepository.fetch(id: circleId)
        let weekNumber = circle?.weekNumber ?? 1

        // Get recent prompts for deduplication
        let recentPrompts = try await promptRepository.fetchRecent(circleId: circleId, count: 7)
        let recentTexts = recentPrompts.map { $0.promptText }

        // Generate prompt text
        let promptText = try await promptGenerationService.generatePrompt(
            circleId: circleId,
            weekNumber: weekNumber,
            recentPrompts: recentTexts
        )

        // Create and save the prompt entity
        let dailyPrompt = DailyPrompt(
            circleId: circleId,
            promptText: promptText,
            weekNumber: weekNumber
        )

        try await promptRepository.save(dailyPrompt)
        return dailyPrompt
    }
}
#endif
