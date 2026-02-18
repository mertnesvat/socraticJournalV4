// CircleFeedViewModel.swift
// Circle
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation
import SwiftUI

/// Represents a member's response status in the feed.
struct MemberResponseItem: Identifiable {
    let id: UUID
    let member: CircleMember
    let response: VoiceResponse?
    let voiceNote: VoiceNote?

    /// Whether this member has responded today.
    var hasResponded: Bool { response != nil }

    /// Whether the response has been heard by the current user.
    var isHeard: Bool { response?.isHeard ?? false }
}

/// ViewModel for the Circle Response Feed -- the main daily interaction screen.
/// Manages selected circle, selected date, responses, prompt, and recording state.
@Observable
@MainActor
public final class CircleFeedViewModel {
    // MARK: - State

    private(set) var circles: [Circle] = []
    private(set) var memberItems: [MemberResponseItem] = []
    private(set) var prompt: Prompt?
    private(set) var isLoading = false
    private(set) var error: Error?
    var selectedCircle: Circle?
    var selectedDate: Date = Date()
    var showRecorder = false

    /// Date pills for the horizontal date scroller (today and past 6 days).
    var datePills: [Date] {
        let calendar = Calendar.current
        return (0..<7).compactMap { offset in
            calendar.date(byAdding: .day, value: -offset, to: calendar.startOfDay(for: Date()))
        }
    }

    /// Whether the current user has already responded today.
    var currentUserHasResponded: Bool {
        memberItems.contains { $0.member.isCurrentUser && $0.hasResponded }
    }

    /// Number of members who have responded.
    var respondedCount: Int {
        memberItems.filter { $0.hasResponded }.count
    }

    /// Total member count in the selected circle.
    var totalMemberCount: Int {
        selectedCircle?.memberCount ?? 0
    }

    /// Whether there are any unheard responses.
    var hasUnheardResponses: Bool {
        memberItems.contains { $0.hasResponded && !$0.isHeard && !$0.member.isCurrentUser }
    }

    /// Whether the selected date is today.
    var isToday: Bool {
        Calendar.current.isDateInToday(selectedDate)
    }

    // MARK: - Dependencies

    private let responseService: ResponseServiceProtocol
    private let promptService: PromptServiceProtocol
    private let circleService: CircleServiceProtocol
    private let voicePlaybackService: VoicePlaybackServiceProtocol
    private let voiceRecordingService: VoiceRecordingServiceProtocol
    private let authService: AuthServiceProtocol

    // MARK: - Init

    public init(
        responseService: ResponseServiceProtocol,
        promptService: PromptServiceProtocol,
        circleService: CircleServiceProtocol,
        voicePlaybackService: VoicePlaybackServiceProtocol,
        voiceRecordingService: VoiceRecordingServiceProtocol,
        authService: AuthServiceProtocol,
        circle: Circle? = nil
    ) {
        self.responseService = responseService
        self.promptService = promptService
        self.circleService = circleService
        self.voicePlaybackService = voicePlaybackService
        self.voiceRecordingService = voiceRecordingService
        self.authService = authService
        self.selectedCircle = circle
    }

    // MARK: - Actions

    /// Load circles and select the first one if none selected.
    func loadCircles() async {
        do {
            circles = try await circleService.getCircles()
            if selectedCircle == nil {
                selectedCircle = circles.first
            }
        } catch {
            self.error = error
        }
    }

    /// Load the feed for the selected circle and date.
    func loadFeed() async {
        guard let circle = selectedCircle else { return }

        isLoading = true
        error = nil

        do {
            // Load prompt for the circle
            prompt = try await promptService.getTodaysPrompt(for: circle.id)

            // Load responses for the selected date
            let responses = try await responseService.getResponses(circleId: circle.id, date: selectedDate)

            // Build member response items
            var items: [MemberResponseItem] = []
            for member in circle.members {
                let response = responses.first { $0.memberId == member.id }
                var voiceNote: VoiceNote?

                // In a real app we would fetch the VoiceNote by ID.
                // For now the voice note will be loaded by the player view
                // when it is needed for playback.
                _ = voiceNote

                items.append(MemberResponseItem(
                    id: member.id,
                    member: member,
                    response: response,
                    voiceNote: voiceNote
                ))
            }

            // Sort: responded members first (unheard before heard), then pending
            memberItems = items.sorted { a, b in
                if a.hasResponded && !b.hasResponded { return true }
                if !a.hasResponded && b.hasResponded { return false }
                if a.hasResponded && b.hasResponded {
                    if !a.isHeard && b.isHeard { return true }
                    if a.isHeard && !b.isHeard { return false }
                }
                return a.member.displayName < b.member.displayName
            }
        } catch {
            self.error = error
        }

        isLoading = false
    }

    /// Select a date and reload the feed.
    func selectDate(_ date: Date) {
        selectedDate = date
        Task { await loadFeed() }
    }

    /// Select a circle and reload the feed.
    func selectCircle(_ circle: Circle) {
        selectedCircle = circle
        selectedDate = Date()
        Task { await loadFeed() }
    }

    /// Mark a response as heard.
    func markAsHeard(_ item: MemberResponseItem) async {
        guard let response = item.response, !response.isHeard else { return }
        do {
            try await responseService.markAsHeard(responseId: response.id)
            // Reload feed to reflect change
            await loadFeed()
        } catch {
            self.error = error
        }
    }

    /// Handle a confirmed recording: save the voice note as a response.
    func handleRecordingConfirmed(voiceNote: VoiceNote) async {
        guard let circle = selectedCircle,
              let prompt = prompt else { return }

        // Find the current user's member ID
        guard let currentMember = circle.members.first(where: { $0.isCurrentUser }) else { return }

        do {
            _ = try await responseService.saveResponse(
                voiceNoteId: voiceNote.id,
                promptId: prompt.id,
                memberId: currentMember.id,
                circleId: circle.id
            )
            showRecorder = false
            await loadFeed()
        } catch {
            self.error = error
        }
    }

    /// Open the recorder sheet.
    func startRecording() {
        showRecorder = true
    }

    /// Clear error state.
    func clearError() {
        error = nil
    }
}
#endif
