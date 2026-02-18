// VoiceQuality.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Audio recording quality preference for voice notes
public enum VoiceQuality: String, CaseIterable, Codable, Sendable {
    case standard
    case high

    public var displayName: String {
        switch self {
        case .standard: return "Standard"
        case .high: return "High Quality"
        }
    }

    public var description: String {
        switch self {
        case .standard: return "Smaller file size, good quality"
        case .high: return "Larger file size, best quality"
        }
    }
}
