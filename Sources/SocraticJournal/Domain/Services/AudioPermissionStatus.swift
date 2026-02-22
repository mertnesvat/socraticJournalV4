// AudioPermissionStatus.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Represents the current status of microphone permission
public enum AudioPermissionStatus: Sendable {
    case notDetermined
    case granted
    case denied
}
