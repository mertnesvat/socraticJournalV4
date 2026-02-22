// ShareViewModel.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// ViewModel managing the share card generation and sharing flow.
/// Handles style selection, anonymous toggle, image generation, and share sheet presentation.
@Observable
@MainActor
public final class ShareViewModel {

    // MARK: - State

    /// The currently selected card style
    public var selectedStyle: ShareCardStyle = .electricBlue

    /// Whether to hide the friend's name and show as anonymous
    public var isAnonymous: Bool = false

    /// Whether to use the "guess who" mystery card variant
    public var useGuessWhoVariant: Bool = false

    /// The generated card image ready for sharing
    public private(set) var generatedImage: UIImage?

    /// Whether the share sheet is currently presented
    public var showShareSheet: Bool = false

    /// Whether image generation is in progress
    public private(set) var isGenerating: Bool = false

    /// Error message if generation fails
    public private(set) var errorMessage: String?

    // MARK: - Input Data

    /// The question text to display on the card
    public let question: String

    /// The friend's display name
    public let friendName: String

    /// Audio waveform amplitude data
    public let amplitudes: [Float]

    // MARK: - Computed Properties

    /// The display name to use on the card based on anonymous setting
    private var displayName: String? {
        isAnonymous ? nil : friendName
    }

    /// Whether a card has been generated and is ready to share
    public var canShare: Bool {
        generatedImage != nil
    }

    // MARK: - Init

    public init(
        question: String,
        friendName: String,
        amplitudes: [Float]
    ) {
        self.question = question
        self.friendName = friendName
        self.amplitudes = amplitudes
    }

    // MARK: - Actions

    /// Generates the square (1:1) share card image based on current settings.
    /// Automatically selects between standard and guess-who card variants.
    public func generateCard() {
        isGenerating = true
        errorMessage = nil

        if useGuessWhoVariant {
            generatedImage = ShareCardGenerator.generateGuessWhoImage(
                question: question,
                waveformAmplitudes: amplitudes,
                style: selectedStyle
            )
        } else {
            generatedImage = ShareCardGenerator.generateImage(
                question: question,
                friendName: displayName,
                waveformAmplitudes: amplitudes,
                style: selectedStyle,
                isAnonymous: isAnonymous
            )
        }

        if generatedImage == nil {
            errorMessage = "Failed to generate share card. Please try again."
        }

        isGenerating = false
    }

    /// Generates the story (9:16) share card image based on current settings.
    public func generateStoryCard() {
        isGenerating = true
        errorMessage = nil

        if useGuessWhoVariant {
            generatedImage = ShareCardGenerator.generateGuessWhoStoryImage(
                question: question,
                waveformAmplitudes: amplitudes,
                style: selectedStyle
            )
        } else {
            generatedImage = ShareCardGenerator.generateStoryImage(
                question: question,
                friendName: displayName,
                waveformAmplitudes: amplitudes,
                style: selectedStyle,
                isAnonymous: isAnonymous
            )
        }

        if generatedImage == nil {
            errorMessage = "Failed to generate story card. Please try again."
        }

        isGenerating = false
    }

    /// Presents the system share sheet with the generated card image.
    public func shareCard() {
        guard generatedImage != nil else {
            generateCard()
            return
        }
        showShareSheet = true
    }

    /// Regenerates the card when style or anonymous settings change.
    public func refreshCard() {
        generateCard()
    }
}
#endif
