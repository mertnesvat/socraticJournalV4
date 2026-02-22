// AudioPlaybackError.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Errors that can occur during audio playback operations
public enum AudioPlaybackError: Error, Sendable {
    case fileNotFound
    case playbackFailed
    case audioSessionFailed
    case invalidFormat
}
