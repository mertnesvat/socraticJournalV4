// ShareCardViewModel.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI
import Observation

/// Visual variant for shareable opinion cards
public enum ShareCardVariant: String, CaseIterable, Sendable, Identifiable {
    case myTake
    case hotTake
    case weDisagree
    case guessWho

    public var id: String { rawValue }

    /// Human-readable label shown on the card
    public var displayLabel: String {
        switch self {
        case .myTake: return "My Take"
        case .hotTake: return "Hot Take Alert"
        case .weDisagree: return "We Disagree"
        case .guessWho: return "Guess Who Said This"
        }
    }

    /// Accent color name for the variant
    public var accentColorName: String {
        switch self {
        case .myTake: return "purple"
        case .hotTake: return "red"
        case .weDisagree: return "teal"
        case .guessWho: return "gray"
        }
    }

    /// Gradient colors for card background
    public var gradientColors: [Color] {
        switch self {
        case .myTake:
            return [Color(red: 0.25, green: 0.05, blue: 0.5), Color(red: 0.05, green: 0.05, blue: 0.3)]
        case .hotTake:
            return [Color(red: 0.5, green: 0.05, blue: 0.05), Color(red: 0.6, green: 0.25, blue: 0.0)]
        case .weDisagree:
            return [Color(red: 0.0, green: 0.3, blue: 0.3), Color(red: 0.02, green: 0.02, blue: 0.02)]
        case .guessWho:
            return [Color(red: 0.2, green: 0.2, blue: 0.2), Color(red: 0.05, green: 0.05, blue: 0.05)]
        }
    }
}

/// ViewModel managing share card generation and sharing
@Observable
@MainActor
public final class ShareCardViewModel {
    // MARK: - State

    /// Currently selected card variant
    public var selectedVariant: ShareCardVariant = .myTake

    /// The question text displayed on the card
    public let questionText: String

    /// The user's display name
    public let userName: String

    /// Friend's name (used for weDisagree variant)
    public let friendName: String?

    /// The question category for badge display
    public let category: QuestionCategory

    /// Whether the card image is being rendered
    public private(set) var isGenerating: Bool = false

    /// The rendered card image ready for sharing
    public private(set) var generatedImage: UIImage?

    /// Whether the share sheet should be presented
    public var showShareSheet: Bool = false

    // MARK: - Initialization

    public init(
        questionText: String,
        userName: String,
        friendName: String? = nil,
        category: QuestionCategory
    ) {
        self.questionText = questionText
        self.userName = userName
        self.friendName = friendName
        self.category = category
    }

    // MARK: - Actions

    /// Renders the current ShareCardView to a UIImage using ImageRenderer
    public func generateCard() {
        isGenerating = true

        let cardView = ShareCardView(
            variant: selectedVariant,
            questionText: questionText,
            userName: userName,
            friendName: friendName,
            category: category
        )
        .frame(width: 1080, height: 1920)

        let renderer = ImageRenderer(content: cardView)
        renderer.scale = 3
        generatedImage = renderer.uiImage
        isGenerating = false
    }

    /// Generates the card and triggers the share sheet
    public func shareCard() {
        generateCard()
        showShareSheet = true
    }
}
#endif
