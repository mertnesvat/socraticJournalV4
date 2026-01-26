// SelfDiscoveryViewModel.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation
import SwiftUI

/// ViewModel for the Self-Discovery tab
@Observable
@MainActor
public final class SelfDiscoveryViewModel {
    // MARK: - State

    private(set) var isLoading: Bool = false
    private(set) var error: Error?
    private(set) var totalEntries: Int = 0

    /// Whether features are unlocked (requires 5+ entries)
    var isUnlocked: Bool {
        totalEntries >= 5
    }

    /// Progress toward unlocking (0.0 to 1.0)
    var unlockProgress: Double {
        min(Double(totalEntries) / 5.0, 1.0)
    }

    // MARK: - Dependencies

    private let repository: JournalRepositoryProtocol

    // MARK: - Init

    public init(repository: JournalRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: - Actions

    /// Loads the initial data
    public func loadData() async {
        isLoading = true
        error = nil

        do {
            let stats = try await repository.getStats()
            totalEntries = stats.totalEntries
        } catch {
            self.error = error
        }

        isLoading = false
    }
}
#endif
