// CharacterDiscoveryViewModel.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation
import SwiftUI

/// ViewModel for the Character Discovery (Personality Analysis) screen
@Observable
@MainActor
public final class CharacterDiscoveryViewModel {
    // MARK: - State

    private(set) var profile: BigFiveProfile?
    private(set) var unlockState: CharacterDiscoveryUnlockState = .locked(progress: 0, entriesNeeded: 3)
    private(set) var isLoading: Bool = false
    private(set) var isRefreshing: Bool = false
    private(set) var error: Error?
    private(set) var totalEntries: Int = 0

    var selectedTrait: PersonalityTrait?
    var showingTraitDetail: Bool = false

    /// Whether the profile can be refreshed (has been unlocked and enough time has passed)
    var canRefresh: Bool {
        unlockState.isUnlocked && profile != nil && !isRefreshing
    }

    /// Whether to show the sample disclaimer
    var showSampleDisclaimer: Bool {
        unlockState.showsSample
    }

    // MARK: - Dependencies

    private let repository: JournalRepositoryProtocol
    private let analysisService: PersonalityAnalysisServiceProtocol

    // MARK: - Init

    public init(
        repository: JournalRepositoryProtocol,
        analysisService: PersonalityAnalysisServiceProtocol
    ) {
        self.repository = repository
        self.analysisService = analysisService
    }

    // MARK: - Actions

    /// Loads the initial state and profile
    public func loadData() async {
        isLoading = true
        error = nil

        do {
            // Get stats to determine unlock state
            let stats = try await repository.getStats()
            totalEntries = stats.totalEntries
            unlockState = CharacterDiscoveryUnlockState.calculate(totalEntries: stats.totalEntries)

            // Load appropriate profile based on unlock state
            switch unlockState {
            case .locked:
                profile = nil

            case .sample:
                profile = try await analysisService.generateSampleProfile()

            case .available:
                let sessions = try await repository.getAllSessions()
                let completedSessions = sessions.filter { $0.isComplete }
                profile = try await analysisService.analyzePersonality(from: completedSessions)
            }
        } catch {
            self.error = error
        }

        isLoading = false
    }

    /// Refreshes the personality analysis with latest data
    public func refreshAnalysis() async {
        guard canRefresh else { return }

        isRefreshing = true
        error = nil

        do {
            let sessions = try await repository.getAllSessions()
            let completedSessions = sessions.filter { $0.isComplete }
            profile = try await analysisService.analyzePersonality(from: completedSessions)
        } catch {
            self.error = error
        }

        isRefreshing = false
    }

    /// Selects a trait to show detail
    public func selectTrait(_ trait: PersonalityTrait) {
        selectedTrait = trait
        showingTraitDetail = true
    }

    /// Dismisses trait detail
    public func dismissTraitDetail() {
        showingTraitDetail = false
        selectedTrait = nil
    }
}
#endif
