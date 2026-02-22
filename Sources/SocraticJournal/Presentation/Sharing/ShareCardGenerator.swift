// ShareCardGenerator.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Renders share card views to UIImage for social media sharing.
/// Uses SwiftUI's ImageRenderer to produce high-quality rasterized output.
///
/// Supports two output formats:
/// - Square (1080x1080) for Instagram feed, iMessage, etc.
/// - Story (1080x1920) for Instagram Stories, TikTok, Snapchat
@MainActor
public final class ShareCardGenerator {

    // MARK: - Square Card (1:1)

    /// Generates a 1080x1080 square image from a share card view.
    ///
    /// - Parameters:
    ///   - question: The question text to display
    ///   - friendName: The friend's name, or nil for no name display
    ///   - waveformAmplitudes: Audio amplitude data for the waveform visualization
    ///   - style: The visual style (gradient theme) for the card
    ///   - isAnonymous: Whether to show the anonymous indicator
    /// - Returns: A rendered UIImage, or nil if rendering fails
    public static func generateImage(
        question: String,
        friendName: String?,
        waveformAmplitudes: [Float],
        style: ShareCardStyle,
        isAnonymous: Bool = false
    ) -> UIImage? {
        let view = ShareCardView(
            question: question,
            friendName: friendName,
            amplitudes: waveformAmplitudes,
            style: style,
            isAnonymous: isAnonymous
        )

        let renderer = ImageRenderer(content: view.frame(width: 1080, height: 1080))
        renderer.scale = 1.0
        return renderer.uiImage
    }

    // MARK: - Story Card (9:16)

    /// Generates a 1080x1920 story-sized image from a share card view.
    ///
    /// - Parameters:
    ///   - question: The question text to display
    ///   - friendName: The friend's name, or nil for no name display
    ///   - waveformAmplitudes: Audio amplitude data for the waveform visualization
    ///   - style: The visual style (gradient theme) for the card
    ///   - isAnonymous: Whether to show the anonymous indicator
    /// - Returns: A rendered UIImage, or nil if rendering fails
    public static func generateStoryImage(
        question: String,
        friendName: String?,
        waveformAmplitudes: [Float],
        style: ShareCardStyle,
        isAnonymous: Bool = false
    ) -> UIImage? {
        let view = ShareCardView(
            question: question,
            friendName: friendName,
            amplitudes: waveformAmplitudes,
            style: style,
            isAnonymous: isAnonymous
        )

        let renderer = ImageRenderer(content: view.frame(width: 1080, height: 1920))
        renderer.scale = 1.0
        return renderer.uiImage
    }

    // MARK: - Guess Who Card

    /// Generates a 1080x1080 square "guess who" mystery card image.
    ///
    /// - Parameters:
    ///   - question: The question text to display
    ///   - waveformAmplitudes: Audio amplitude data (rendered with blur effect)
    ///   - style: The visual style (gradient theme) for the card
    /// - Returns: A rendered UIImage, or nil if rendering fails
    public static func generateGuessWhoImage(
        question: String,
        waveformAmplitudes: [Float],
        style: ShareCardStyle
    ) -> UIImage? {
        let view = GuessWhoCard(
            question: question,
            amplitudes: waveformAmplitudes,
            style: style
        )

        let renderer = ImageRenderer(content: view.frame(width: 1080, height: 1080))
        renderer.scale = 1.0
        return renderer.uiImage
    }

    /// Generates a 1080x1920 story-sized "guess who" mystery card image.
    ///
    /// - Parameters:
    ///   - question: The question text to display
    ///   - waveformAmplitudes: Audio amplitude data (rendered with blur effect)
    ///   - style: The visual style (gradient theme) for the card
    /// - Returns: A rendered UIImage, or nil if rendering fails
    public static func generateGuessWhoStoryImage(
        question: String,
        waveformAmplitudes: [Float],
        style: ShareCardStyle
    ) -> UIImage? {
        let view = GuessWhoCard(
            question: question,
            amplitudes: waveformAmplitudes,
            style: style
        )

        let renderer = ImageRenderer(content: view.frame(width: 1080, height: 1920))
        renderer.scale = 1.0
        return renderer.uiImage
    }
}
#endif
