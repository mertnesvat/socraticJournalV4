// VoicePlaybackServiceProtocol.swift
// Circle
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation

/// Protocol for voice note playback operations.
/// Implementations handle audio session configuration, playback, seeking, and state updates.
@MainActor
public protocol VoicePlaybackServiceProtocol: AnyObject {
    /// Whether audio is currently playing.
    var isPlaying: Bool { get }

    /// The current playback position in seconds, updated during playback.
    var currentTime: TimeInterval { get }

    /// The total duration of the currently loaded audio in seconds.
    var duration: TimeInterval { get }

    /// The ID of the voice note currently loaded for playback, if any.
    var currentlyPlayingId: UUID? { get }

    /// Begin or resume playback of the given voice note.
    /// - Parameter voiceNote: The voice note to play.
    func play(voiceNote: VoiceNote) throws

    /// Pause playback without resetting position.
    func pause()

    /// Stop playback and reset position to zero.
    func stop()

    /// Seek to a specific time position.
    /// - Parameter time: The target time in seconds.
    func seek(to time: TimeInterval)
}
#endif
