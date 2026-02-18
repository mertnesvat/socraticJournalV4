// CircleListViewModel.swift
// Circle
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// ViewModel for the circle list and management
@Observable
@MainActor
public final class CircleListViewModel {
    // MARK: - State

    public var circles: [Circle] = []
    public var isLoading = false
    public var showCreateCircle = false
    public var error: String?

    // Create circle form
    public var newCircleName = ""
    public var newCircleEmoji = "💬"

    // MARK: - Dependencies

    private let circleRepository: CircleRepositoryProtocol
    private let authService: AuthServiceProtocol
    private let currentUserId: String

    // MARK: - Init

    public init(
        circleRepository: CircleRepositoryProtocol,
        authService: AuthServiceProtocol,
        currentUserId: String
    ) {
        self.circleRepository = circleRepository
        self.authService = authService
        self.currentUserId = currentUserId
    }

    // MARK: - Actions

    public func loadCircles() async {
        isLoading = true
        error = nil
        do {
            circles = try await circleRepository.getCircles(for: currentUserId)
        } catch {
            self.error = "Failed to load circles"
        }
        isLoading = false
    }

    public func createCircle() async {
        guard !newCircleName.trimmingCharacters(in: .whitespaces).isEmpty else { return }

        let circle = Circle(
            name: newCircleName.trimmingCharacters(in: .whitespaces),
            emoji: newCircleEmoji,
            createdBy: currentUserId,
            memberIds: [currentUserId]
        )

        do {
            try await circleRepository.createCircle(circle)

            let ownerMember = CircleMember(
                userId: currentUserId,
                displayName: "You",
                role: .owner
            )
            try await circleRepository.addMember(ownerMember, to: circle.id)

            newCircleName = ""
            newCircleEmoji = "💬"
            showCreateCircle = false
            await loadCircles()
        } catch {
            self.error = "Failed to create circle"
        }
    }

    public func deleteCircle(_ circle: Circle) async {
        guard circle.createdBy == currentUserId else { return }
        do {
            try await circleRepository.deleteCircle(id: circle.id)
            await loadCircles()
        } catch {
            self.error = "Failed to delete circle"
        }
    }

    public func leaveCircle(_ circle: Circle) async {
        do {
            try await circleRepository.removeMember(userId: currentUserId, from: circle.id)
            await loadCircles()
        } catch {
            self.error = "Failed to leave circle"
        }
    }
}
#endif
