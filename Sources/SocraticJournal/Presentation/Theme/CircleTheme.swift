// CircleTheme.swift
// Circle
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Warm, intimate color palette for the Circle app.
/// Think voice memo warmth — amber, cream, soft greys.
public enum CircleTheme {
    // MARK: - Primary Palette

    /// Warm amber — primary accent, CTAs, active states
    public static let warmAmber = Color(red: 0.87, green: 0.65, blue: 0.33)

    /// Warm orange — gradient end, hover states
    public static let warmOrange = Color(red: 0.90, green: 0.52, blue: 0.25)

    /// Soft cream — light backgrounds, card surfaces
    public static let cream = Color(red: 0.98, green: 0.96, blue: 0.92)

    /// Deep warm brown — text on light backgrounds
    public static let warmBrown = Color(red: 0.30, green: 0.22, blue: 0.15)

    // MARK: - Waveform Colors

    /// Active waveform bars (during recording/playback)
    public static let waveformActive = warmAmber

    /// Inactive waveform bars (unplayed portion)
    public static let waveformInactive = Color.gray.opacity(0.3)

    // MARK: - Status Colors

    /// Someone has responded (unheard)
    public static let unheardGlow = warmAmber.opacity(0.6)

    /// Everyone responded
    public static let allResponded = Color(red: 0.40, green: 0.73, blue: 0.42)

    /// Waiting for responses
    public static let waiting = Color.gray.opacity(0.4)

    // MARK: - Gradients

    /// Primary CTA gradient
    public static let primaryGradient = LinearGradient(
        colors: [warmAmber, warmOrange],
        startPoint: .leading,
        endPoint: .trailing
    )

    /// Subtle background warmth
    public static let backgroundGradient = LinearGradient(
        colors: [cream, Color(uiColor: .systemBackground)],
        startPoint: .top,
        endPoint: .bottom
    )
}
#endif
