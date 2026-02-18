// HomeViewModel.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation
import SwiftUI

/// ViewModel for the Home Feed — the daily circle experience.
/// Manages circles, today's prompt, voice notes, and the "respond first to unlock" mechanic.
@Observable
@MainActor
public final class HomeViewModel {

    // MARK: - State

    /// All circles the current user belongs to
    private(set) var circles: [CircleGroup] = []

    /// The currently selected circle (shown in the feed)
    private(set) var selectedCircle: CircleGroup?

    /// Today's prompt for the selected circle
    private(set) var todayPrompt: DailyPrompt?

    /// Voice notes for today's prompt
    private(set) var voiceNotes: [VoiceNote] = []

    /// Members of the selected circle
    private(set) var members: [CircleMember] = []

    /// Whether the current user has responded to today's prompt
    var hasUserResponded: Bool {
        guard let prompt = todayPrompt else { return false }
        return prompt.respondedUserIds.contains(currentUserId)
    }

    /// Voice notes visible based on the unlock mechanic
    var visibleVoiceNotes: [VoiceNote] {
        if hasUserResponded {
            return voiceNotes
        }
        return voiceNotes.filter { $0.userId == currentUserId }
    }

    /// Loading state
    private(set) var isLoading = false

    /// Error message for display
    private(set) var error: String?

    /// Whether voice recording is currently in progress
    private(set) var isRecording = false

    /// Whether playing all voice notes sequentially
    private(set) var isPlayingAll = false

    /// Index of the currently playing voice note during playAll
    private(set) var currentlyPlayingIndex: Int?

    // MARK: - Dependencies

    private let circleRepository: CircleRepositoryProtocol
    private let promptRepository: PromptRepositoryProtocol
    private let promptGenerationService: PromptGenerationServiceProtocol
    private let voiceNoteRepository: VoiceNoteRepositoryProtocol
    private let voiceRecordingService: VoiceRecordingServiceProtocol
    private let playbackService: AudioPlaybackServiceProtocol
    let currentUserId: UUID

    // MARK: - Init

    public init(
        circleRepository: CircleRepositoryProtocol,
        promptRepository: PromptRepositoryProtocol,
        promptGenerationService: PromptGenerationServiceProtocol,
        voiceNoteRepository: VoiceNoteRepositoryProtocol,
        voiceRecordingService: VoiceRecordingServiceProtocol,
        playbackService: AudioPlaybackServiceProtocol,
        currentUserId: UUID
    ) {
        self.circleRepository = circleRepository
        self.promptRepository = promptRepository
        self.promptGenerationService = promptGenerationService
        self.voiceNoteRepository = voiceNoteRepository
        self.voiceRecordingService = voiceRecordingService
        self.playbackService = playbackService
        self.currentUserId = currentUserId
    }

    // MARK: - Actions

    /// Load circles, select the first one, and load its prompt + voice notes
    func loadData() async {
        isLoading = true
        error = nil

        do {
            circles = try await circleRepository.fetchAll(userId: currentUserId)

            // Select first circle if none selected, or validate current selection still exists
            if selectedCircle == nil || !circles.contains(where: { $0.id == selectedCircle?.id }) {
                selectedCircle = circles.first
            }

            if selectedCircle != nil {
                await loadTodayPrompt()
                await loadMembers()
            }
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    /// Switch to a different circle and reload prompt + voice notes
    func selectCircle(_ circle: CircleGroup) async {
        selectedCircle = circle
        todayPrompt = nil
        voiceNotes = []
        members = []
        await loadTodayPrompt()
        await loadMembers()
    }

    /// Fetch or generate today's prompt for the selected circle
    func loadTodayPrompt() async {
        guard let circle = selectedCircle else { return }

        do {
            // Try to fetch an existing prompt for today
            if let existing = try await promptRepository.fetchToday(circleId: circle.id) {
                todayPrompt = existing
            } else {
                // Generate a new prompt
                let weekNumber = circle.weekNumber
                let recentPrompts = try await promptRepository.fetchRecent(circleId: circle.id, count: 7)
                let recentTexts = recentPrompts.map { $0.promptText }

                let promptText = try await promptGenerationService.generatePrompt(
                    circleId: circle.id,
                    weekNumber: weekNumber,
                    recentPrompts: recentTexts
                )

                let dailyPrompt = DailyPrompt(
                    circleId: circle.id,
                    promptText: promptText,
                    weekNumber: weekNumber
                )

                try await promptRepository.save(dailyPrompt)
                todayPrompt = dailyPrompt
            }

            // Load voice notes for this prompt
            if let prompt = todayPrompt {
                voiceNotes = try await voiceNoteRepository.fetchForPrompt(promptId: prompt.id)
            }
        } catch {
            self.error = error.localizedDescription
        }
    }

    /// Load members for the selected circle
    private func loadMembers() async {
        guard let circle = selectedCircle else { return }

        do {
            members = try await circleRepository.fetchMembers(circleId: circle.id)
        } catch {
            // Non-critical, don't override primary error
        }
    }

    /// Mark the current user as having responded to today's prompt
    func markUserResponded() async {
        guard var prompt = todayPrompt else { return }
        guard !prompt.respondedUserIds.contains(currentUserId) else { return }

        prompt.respondedUserIds.append(currentUserId)

        do {
            try await promptRepository.update(prompt)
            todayPrompt = prompt
        } catch {
            self.error = error.localizedDescription
        }
    }

    /// Reload voice notes for the current prompt
    func reloadVoiceNotes() async {
        guard let prompt = todayPrompt else { return }

        do {
            voiceNotes = try await voiceNoteRepository.fetchForPrompt(promptId: prompt.id)
        } catch {
            self.error = error.localizedDescription
        }
    }

    /// Pull-to-refresh: reload all data
    func refresh() async {
        await loadData()
    }

    /// Play all voice notes sequentially (one after another)
    func playAll() async {
        let notes = visibleVoiceNotes
        guard !notes.isEmpty else { return }

        isPlayingAll = true

        let documentsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]

        for (index, note) in notes.enumerated() {
            guard isPlayingAll else { break }

            currentlyPlayingIndex = index
            let audioURL = documentsDir.appendingPathComponent(note.localAudioPath)

            do {
                try playbackService.play(url: audioURL)

                // Wait for playback to finish
                while playbackService.isPlaying && isPlayingAll {
                    try await Task.sleep(for: .milliseconds(200))
                }
            } catch {
                // Skip notes that fail to play
                continue
            }
        }

        currentlyPlayingIndex = nil
        isPlayingAll = false
    }

    /// Stop the play-all sequence
    func stopPlayAll() {
        isPlayingAll = false
        playbackService.stop()
        currentlyPlayingIndex = nil
    }

    /// Clear the current error
    func clearError() {
        error = nil
    }

    /// Get the display name for a member by userId
    func memberName(for userId: UUID) -> String {
        if userId == currentUserId { return "You" }
        return members.first(where: { $0.userId == userId })?.displayName ?? "Member"
    }

    /// Get the initials for a member by userId
    func memberInitials(for userId: UUID) -> String {
        let name = memberName(for: userId)
        let components = name.split(separator: " ")
        if components.count >= 2 {
            return String(components[0].prefix(1) + components[1].prefix(1)).uppercased()
        }
        return String(name.prefix(2)).uppercased()
    }

    /// Check if a member has responded to today's prompt
    func hasResponded(userId: UUID) -> Bool {
        guard let prompt = todayPrompt else { return false }
        return prompt.respondedUserIds.contains(userId)
    }
}
#endif
