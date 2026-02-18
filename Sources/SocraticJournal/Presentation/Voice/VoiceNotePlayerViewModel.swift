// VoiceNotePlayerViewModel.swift
// Circle
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation
import SwiftUI

/// ViewModel for the inline voice note player.
/// Wraps VoicePlaybackServiceProtocol and provides computed progress, formatted time strings,
/// and actions for play/pause/seek.
@Observable
@MainActor
public final class VoiceNotePlayerViewModel {
    // MARK: - State

    private(set) var error: Error?

    // MARK: - Dependencies

    private let playbackService: VoicePlaybackServiceProtocol
    private let voiceNote: VoiceNote

    // MARK: - Init

    public init(
        playbackService: VoicePlaybackServiceProtocol,
        voiceNote: VoiceNote
    ) {
        self.playbackService = playbackService
        self.voiceNote = voiceNote
    }

    // MARK: - Computed Properties

    /// Whether this specific voice note is currently playing.
    var isPlaying: Bool {
        playbackService.currentlyPlayingId == voiceNote.id && playbackService.isPlaying
    }

    /// Whether this specific voice note is the one currently loaded (playing or paused).
    var isActiveNote: Bool {
        playbackService.currentlyPlayingId == voiceNote.id
    }

    /// Playback progress from 0.0 to 1.0.
    var progress: CGFloat {
        guard isActiveNote else { return 0.0 }
        let dur = playbackService.duration
        guard dur > 0 else { return 0.0 }
        return CGFloat(min(playbackService.currentTime / dur, 1.0))
    }

    /// Current elapsed time, or 0 if this note is not active.
    var currentTime: TimeInterval {
        guard isActiveNote else { return 0.0 }
        return playbackService.currentTime
    }

    /// Total duration from the voice note metadata.
    var totalDuration: TimeInterval {
        voiceNote.duration
    }

    /// Formatted elapsed time string (M:SS).
    var elapsedTimeString: String {
        guard isActiveNote else { return formatTime(0) }
        return formatTime(playbackService.currentTime)
    }

    /// Formatted total duration string (M:SS).
    var totalTimeString: String {
        formatTime(voiceNote.duration)
    }

    /// Waveform amplitude data from the voice note.
    var waveformData: [Float] {
        voiceNote.waveformData
    }

    // MARK: - Actions

    /// Toggle between play and pause for this voice note.
    func togglePlayback() {
        if isPlaying {
            playbackService.pause()
        } else {
            do {
                try playbackService.play(voiceNote: voiceNote)
                error = nil
            } catch {
                self.error = error
            }
        }
    }

    /// Seek to a normalized position (0.0 to 1.0) within the waveform.
    func seekToProgress(_ normalizedProgress: CGFloat) {
        let clamped = max(0.0, min(normalizedProgress, 1.0))
        let targetTime = TimeInterval(clamped) * voiceNote.duration

        // If the note is not yet loaded, load it first then seek
        if !isActiveNote {
            do {
                try playbackService.play(voiceNote: voiceNote)
                playbackService.seek(to: targetTime)
                playbackService.pause()
                error = nil
            } catch {
                self.error = error
            }
        } else {
            playbackService.seek(to: targetTime)
        }
    }

    /// Stop playback entirely.
    func stopPlayback() {
        if isActiveNote {
            playbackService.stop()
        }
    }

    /// Clear error state.
    func clearError() {
        error = nil
    }

    // MARK: - Private

    private func formatTime(_ time: TimeInterval) -> String {
        let total = Int(max(0, time))
        let minutes = total / 60
        let seconds = total % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
#endif
