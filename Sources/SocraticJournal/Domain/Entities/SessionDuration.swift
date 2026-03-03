// SessionDuration.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Available session durations for MVP
public enum SessionDuration: Int, CaseIterable, Sendable, Identifiable {
    case fiveMinutes = 300
    case tenMinutes = 600

    public var id: Int { rawValue }

    /// Duration in seconds
    public var seconds: TimeInterval {
        TimeInterval(rawValue)
    }

    /// Display label
    public var label: String {
        switch self {
        case .fiveMinutes: return "5 min"
        case .tenMinutes: return "10 min"
        }
    }

    /// Default duration
    public static let `default`: SessionDuration = .fiveMinutes
}
