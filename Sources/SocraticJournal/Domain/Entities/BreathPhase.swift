// BreathPhase.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// The type of a breath phase
public enum BreathPhaseType: String, Codable, Sendable {
    case inhale
    case holdAfterInhale
    case exhale
    case holdAfterExhale
}

/// A single phase within a breathing pattern
public struct BreathPhase: Codable, Sendable, Identifiable {
    public let id: String
    public let phaseType: BreathPhaseType
    public let duration: TimeInterval

    /// Lowercase label shown during this phase
    public var displayLabel: String {
        switch phaseType {
        case .inhale: return "inhale"
        case .holdAfterInhale, .holdAfterExhale: return "hold"
        case .exhale: return "exhale"
        }
    }

    public init(id: String = UUID().uuidString, phaseType: BreathPhaseType, duration: TimeInterval) {
        self.id = id
        self.phaseType = phaseType
        self.duration = duration
    }
}
