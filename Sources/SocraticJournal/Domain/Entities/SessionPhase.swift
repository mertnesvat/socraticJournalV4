// SessionPhase.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Represents the current phase of a breathing cycle
public enum SessionPhase: String, Codable, Sendable, CaseIterable {
    case inhale
    case holdIn
    case exhale
    case holdOut

    /// Display string for the phase label (lowercase)
    public var displayName: String {
        switch self {
        case .inhale: return "inhale"
        case .holdIn: return "hold"
        case .exhale: return "exhale"
        case .holdOut: return "hold"
        }
    }

    /// The associated colour for this breath phase
    public var color: Color {
        switch self {
        case .inhale: return AppColors.breathInhale
        case .holdIn: return AppColors.breathHold
        case .holdOut: return AppColors.breathHold
        case .exhale: return AppColors.breathExhale
        }
    }
}
#endif
