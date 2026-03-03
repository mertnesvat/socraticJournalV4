// HapticRhythmEngine.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import UIKit

/// Provides taptic feedback at breath phase transitions
@MainActor
public final class HapticRhythmEngine {
    private let lightGenerator = UIImpactFeedbackGenerator(style: .light)
    private let mediumGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let softGenerator = UIImpactFeedbackGenerator(style: .soft)

    private(set) var isEnabled: Bool = true

    func setEnabled(_ enabled: Bool) {
        isEnabled = enabled
    }

    /// Fire haptic for a phase transition
    func firePhaseTransition(phaseType: BreathPhaseType) {
        guard isEnabled else { return }
        switch phaseType {
        case .inhale:
            mediumGenerator.impactOccurred(intensity: 0.6)
        case .inhaleTopUp:
            softGenerator.impactOccurred(intensity: 0.4)
        case .hold:
            lightGenerator.impactOccurred(intensity: 0.3)
        case .exhale:
            mediumGenerator.impactOccurred(intensity: 0.5)
        }
    }

    /// Prepare generators for low-latency feedback
    func prepare() {
        lightGenerator.prepare()
        mediumGenerator.prepare()
        softGenerator.prepare()
    }
}
#endif
