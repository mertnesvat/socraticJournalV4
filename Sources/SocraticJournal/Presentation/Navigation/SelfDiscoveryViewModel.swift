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
    public let badgeCount: Int?

    public init(
        id: String,
        title: String,
        subtitle: String,
        icon: String,
        color: Color,
        isAvailable: Bool = false,
        badgeCount: Int? = nil
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.color = color
        self.isAvailable = isAvailable
        self.badgeCount = badgeCount
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

    // MARK: - Personality Feature State
    private(set) var personalityUnlockState: CharacterDiscoveryUnlockState = .locked(progress: 0, entriesNeeded: 3)
    private(set) var totalEntries: Int = 0

    // MARK: - Letters Feature State
    private(set) var readyLettersCount: Int = 0

    // MARK: - Navigation State
    var showingLetters = false

    // MARK: - Computed Properties
    var hasFeatures: Bool {
        !features.isEmpty
    }

    /// Whether the personality feature is locked
    var isPersonalityLocked: Bool {
        if case .locked = personalityUnlockState {
            return true
        }
        return false
    }

    /// Progress toward unlocking personality (0.0 to 1.0)
    var personalityProgress: Double {
        personalityUnlockState.progressPercent / 100.0
    }

    /// Entries required to unlock personality feature
    var personalityEntriesRequired: Int {
        // Based on the unlock formula, need 3 entries minimum to reach sample mode
        if case .locked(_, let entriesNeeded) = personalityUnlockState {
            return totalEntries + entriesNeeded
        }
        return 3
    }

    // MARK: - Dependencies
    private let repository: JournalRepositoryProtocol

    // MARK: - Initialization
    public init(repository: JournalRepositoryProtocol? = nil) {
        // Use injected repository or fall back to shared instance
        self.repository = repository ?? FirestoreJournalRepository.shared
        loadFeatures()
    }

    // MARK: - Actions
    func loadFeatures() {
        isLoading = true
        buildFeaturesList()
        isLoading = false
    }

    private func buildFeaturesList() {
        // Define the self-discovery features (non-personality features are coming soon)
        features = [
            SelfDiscoveryFeature(
                id: "personality",
                title: "My Personality",
                subtitle: "Discover your Big Five traits through reflection",
                icon: "brain.head.profile",
                color: .purple,
                isAvailable: true  // Always available to tap, unlock state shown in card
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
                subtitle: "Write meaningful letters to your future self",
                icon: "envelope.badge.fill",
                color: .blue,
                isAvailable: true,
                badgeCount: readyLettersCount > 0 ? readyLettersCount : nil
            )
        ]
    }

    /// Loads personality unlock state from repository
    func loadPersonalityState() async {
        do {
            let stats = try await repository.getStats()
            totalEntries = stats.totalEntries
            personalityUnlockState = CharacterDiscoveryUnlockState.calculate(totalEntries: stats.totalEntries)
        } catch {
            self.error = error
        }
    }

    /// Loads ready letters count from repository
    func loadLettersCount() async {
        do {
            readyLettersCount = try await repository.getReadyLettersCount()
            buildFeaturesList()
        } catch {
            self.error = error
        }
    }

    /// Loads all data for the self-discovery tab
    func loadAllData() async {
        isLoading = true
        await loadPersonalityState()
        await loadLettersCount()
        isLoading = false
    }

    func selectFeature(_ feature: SelfDiscoveryFeature) {
        guard feature.isAvailable else { return }

        switch feature.id {
        case "letters":
            showingLetters = true
        default:
            // Handled in the view via sheet presentation for other features
            break
        }
    }
}
#endif
