// SelfDiscoveryViewModel.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Represents a self-discovery feature card
public struct SelfDiscoveryFeature: Identifiable, Equatable {
    public let id: String
    public let title: String
    public let subtitle: String
    public let icon: String
    public let color: Color
    public let isAvailable: Bool

    public init(
        id: String,
        title: String,
        subtitle: String,
        icon: String,
        color: Color,
        isAvailable: Bool = false
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.color = color
        self.isAvailable = isAvailable
    }
}

/// ViewModel for the Self-Discovery tab
@Observable
@MainActor
public final class SelfDiscoveryViewModel {
    // MARK: - State
    private(set) var features: [SelfDiscoveryFeature] = []
    private(set) var isLoading = false
    private(set) var error: Error?

    // MARK: - Computed Properties
    var hasFeatures: Bool {
        !features.isEmpty
    }

    // MARK: - Initialization
    public init() {
        loadFeatures()
    }

    // MARK: - Actions
    func loadFeatures() {
        isLoading = true

        // Define the self-discovery features
        features = [
            SelfDiscoveryFeature(
                id: "personality",
                title: "My Personality",
                subtitle: "Discover your traits through reflection",
                icon: "brain.head.profile",
                color: .purple,
                isAvailable: false
            ),
            SelfDiscoveryFeature(
                id: "character",
                title: "Which Character Am I?",
                subtitle: "Find your philosophical archetype",
                icon: "person.crop.circle.badge.questionmark",
                color: .orange,
                isAvailable: false
            ),
            SelfDiscoveryFeature(
                id: "letters",
                title: "Letters to Future Me",
                subtitle: "Write to your future self",
                icon: "envelope.badge.fill",
                color: .blue,
                isAvailable: false
            )
        ]

        isLoading = false
    }

    func selectFeature(_ feature: SelfDiscoveryFeature) {
        // Placeholder for future navigation handling
        // This will be connected when features are implemented
    }
}
#endif
