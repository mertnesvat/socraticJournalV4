// CircleFeedViewModel.swift
// Circle
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// ViewModel for the circle feed — today's prompt and voice note responses
@Observable
@MainActor
public final class CircleFeedViewModel {
    // MARK: - State

    public var todaysPrompt: DailyPrompt?
    public var responses: [VoiceNote] = []
    public var members: [CircleMember] = []
    public var circle: Circle?
    public var hasResponded = false
    public var isLoading = false
    public var playingNoteId: String?
    public var error: String?

    // MARK: - Dependencies (internal for view access)

    let circleId: String
    let currentUserId: String
    let circleRepository: CircleRepositoryProtocol
    let promptRepository: PromptRepositoryProtocol
    let promptService: PromptGenerationServiceProtocol
    let voiceNoteRepository: VoiceNoteRepositoryProtocol
    let audioService: AudioServiceProtocol
    let audioStorageService: AudioStorageServiceProtocol
    let userProfileRepository: UserProfileRepositoryProtocol
    let transcriptionService: TranscriptionServiceProtocol?

    // MARK: - Init

    public init(
        circleId: String,
        currentUserId: String,
        circleRepository: CircleRepositoryProtocol,
        promptRepository: PromptRepositoryProtocol,
        promptService: PromptGenerationServiceProtocol,
        voiceNoteRepository: VoiceNoteRepositoryProtocol,
        audioService: AudioServiceProtocol,
        audioStorageService: AudioStorageServiceProtocol,
        userProfileRepository: UserProfileRepositoryProtocol,
        transcriptionService: TranscriptionServiceProtocol? = nil
    ) {
        self.circleId = circleId
        self.currentUserId = currentUserId
        self.circleRepository = circleRepository
        self.promptRepository = promptRepository
        self.promptService = promptService
        self.voiceNoteRepository = voiceNoteRepository
        self.audioService = audioService
        self.audioStorageService = audioStorageService
        self.userProfileRepository = userProfileRepository
        self.transcriptionService = transcriptionService
    }

    // MARK: - Actions

    public func loadFeed() async {
        isLoading = true
        error = nil

        do {
            circle = try await circleRepository.getCircle(id: circleId)
            members = try await circleRepository.getMembers(for: circleId)

            if let existing = try await promptRepository.getTodaysPrompt(for: circleId) {
                todaysPrompt = existing
            } else {
                let usedIds = try await promptRepository.getUsedPromptIds(for: circleId)
                let isNew = (circle?.createdAt ?? Date()).timeIntervalSinceNow > -86400 * 7
                let prompt = try await promptService.generatePrompt(
                    for: circleId, excludingIds: usedIds, isNewCircle: isNew
                )
                try await promptRepository.savePrompt(prompt)
                todaysPrompt = prompt
            }

            if let prompt = todaysPrompt {
                responses = try await voiceNoteRepository.getVoiceNotes(
                    circleId: circleId, promptId: prompt.id
                )
                hasResponded = try await voiceNoteRepository.hasUserResponded(
                    userId: currentUserId, promptId: prompt.id
                )
            }
            // Update widget data
            if let circle, let prompt = todaysPrompt {
                WidgetDataService.write(WidgetDataService.WidgetData(
                    circleName: circle.name,
                    circleEmoji: circle.emoji,
                    promptQuestion: prompt.question,
                    promptCategory: prompt.category.displayName,
                    responseCount: responses.count,
                    memberCount: members.count,
                    hasResponded: hasResponded
                ))
            }
        } catch {
            self.error = "Failed to load feed"
        }

        isLoading = false
    }

    public func playVoiceNote(_ note: VoiceNote) async {
        do {
            if playingNoteId != nil {
                await audioService.stopPlayback()
                playingNoteId = nil
            }

            let localURL = try await audioStorageService.downloadAudio(remotePath: note.audioURL)
            try await audioService.startPlayback(url: localURL)
            playingNoteId = note.id

            if !note.isListened {
                try await voiceNoteRepository.markAsListened(id: note.id)
                if let idx = responses.firstIndex(where: { $0.id == note.id }) {
                    responses[idx].isListened = true
                }
            }
        } catch {
            playingNoteId = nil
        }
    }

    public func stopPlayback() async {
        await audioService.stopPlayback()
        playingNoteId = nil
    }

    public func displayName(for userId: String) -> String {
        if userId == currentUserId { return "You" }
        return members.first { $0.userId == userId }?.displayName ?? "Unknown"
    }

    public func initial(for userId: String) -> String {
        String(displayName(for: userId).prefix(1)).uppercased()
    }
}
#endif
