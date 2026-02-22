// VoiceRecordingError.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Errors that can occur during voice recording operations
public enum VoiceRecordingError: Error, Sendable {
    case permissionDenied
    case recordingFailed
    case audioSessionFailed
    case tooShort
    case interrupted
}
