// CircleListViewModel.swift
// Circle
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation
import SwiftUI

/// ViewModel for the circle list screen.
/// Manages loading, creating, and deleting circles.
@Observable
@MainActor
public final class CircleListViewModel {
    // MARK: - State

    private(set) var circles: [Circle] = []
    private(set) var isLoading = false
    private(set) var error: Error?
    var showCreateCircle = false

    /// Streak data per circle keyed by circle ID.
    private(set) var streaks: [UUID: Int] = [:]

    /// Whether there are no circles to display.
    var isEmpty: Bool {
        circles.isEmpty && !isLoading
    }

    /// Get the current streak for a circle.
    func currentStreak(for circleId: UUID) -> Int {
        streaks[circleId] ?? 0
    }

    // MARK: - Dependencies

    private let circleService: CircleServiceProtocol
    private let promptService: PromptServiceProtocol?

    // MARK: - Init

    public init(circleService: CircleServiceProtocol, promptService: PromptServiceProtocol? = nil) {
        self.circleService = circleService
        self.promptService = promptService
    }

    // MARK: - Actions

    /// Load all circles from the data source.
    func loadCircles() async {
        isLoading = true
        error = nil
        do {
            circles = try await circleService.getCircles()
            loadStreaks()
        } catch {
            self.error = error
        }
        isLoading = false
    }

    /// Load streak data for all loaded circles.
    private func loadStreaks() {
        guard let promptService else { return }
        for circle in circles {
            do {
                let streak = try promptService.computeStreak(for: circle.id)
                streaks[circle.id] = streak.current
            } catch {
                // Non-critical; skip
            }
        }
    }

    /// Delete a circle by its identifier.
    func deleteCircle(_ circle: Circle) async {
        do {
            try await circleService.deleteCircle(id: circle.id)
            circles.removeAll { $0.id == circle.id }
        } catch {
            self.error = error
        }
    }

    /// Called after a new circle is successfully created to refresh the list.
    func onCircleCreated() async {
        await loadCircles()
    }

    /// Clear the current error state.
    func clearError() {
        error = nil
    }
}
#endif
