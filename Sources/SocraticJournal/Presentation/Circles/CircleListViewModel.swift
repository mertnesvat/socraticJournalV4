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

    /// Whether there are no circles to display.
    var isEmpty: Bool {
        circles.isEmpty && !isLoading
    }

    // MARK: - Dependencies

    private let circleService: CircleServiceProtocol

    // MARK: - Init

    public init(circleService: CircleServiceProtocol) {
        self.circleService = circleService
    }

    // MARK: - Actions

    /// Load all circles from the data source.
    func loadCircles() async {
        isLoading = true
        error = nil
        do {
            circles = try await circleService.getCircles()
        } catch {
            self.error = error
        }
        isLoading = false
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
