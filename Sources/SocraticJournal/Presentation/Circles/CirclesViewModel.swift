// CirclesViewModel.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// ViewModel that manages circle list state and operations
@Observable
@MainActor
public final class CirclesViewModel {
    // MARK: - State

    private(set) var circles: [CircleGroup] = []
    private(set) var selectedCircle: CircleGroup?
    private(set) var isLoading = false
    private(set) var error: Error?

    // MARK: - Dependencies

    private let repository: CircleRepositoryProtocol
    let currentUserId: UUID

    // MARK: - Init

    public init(repository: CircleRepositoryProtocol, currentUserId: UUID) {
        self.repository = repository
        self.currentUserId = currentUserId
    }

    // MARK: - Actions

    func loadCircles() async {
        isLoading = true
        error = nil
        do {
            circles = try await repository.fetchAll(userId: currentUserId)
        } catch {
            self.error = error
        }
        isLoading = false
    }

    func createCircle(name: String, emoji: String) async throws -> CircleGroup {
        let newCircle = try await repository.create(name: name, emoji: emoji, creatorId: currentUserId)
        circles.insert(newCircle, at: 0)
        return newCircle
    }

    func deleteCircle(id: UUID) async {
        do {
            try await repository.delete(id: id)
            circles.removeAll { $0.id == id }
        } catch {
            self.error = error
        }
    }

    func addMember(name: String, to circle: CircleGroup) async {
        do {
            let member = CircleMember(
                userId: UUID(),
                displayName: name,
                joinedAt: Date(),
                role: .member,
                isSimulated: true
            )
            try await repository.addMember(member, to: circle.id)
            // Reload the affected circle
            if let updated = try await repository.fetch(id: circle.id) {
                if let index = circles.firstIndex(where: { $0.id == circle.id }) {
                    circles[index] = updated
                }
                if selectedCircle?.id == circle.id {
                    selectedCircle = updated
                }
            }
        } catch {
            self.error = error
        }
    }

    func removeMember(userId: UUID, from circle: CircleGroup) async {
        do {
            try await repository.removeMember(userId: userId, from: circle.id)
            if let updated = try await repository.fetch(id: circle.id) {
                if let index = circles.firstIndex(where: { $0.id == circle.id }) {
                    circles[index] = updated
                }
                if selectedCircle?.id == circle.id {
                    selectedCircle = updated
                }
            }
        } catch {
            self.error = error
        }
    }

    func generateInviteCode(for circle: CircleGroup) async -> String? {
        do {
            let code = try await repository.generateInviteCode(circleId: circle.id)
            // Update local circle with new invite code
            if let updated = try await repository.fetch(id: circle.id) {
                if let index = circles.firstIndex(where: { $0.id == circle.id }) {
                    circles[index] = updated
                }
                if selectedCircle?.id == circle.id {
                    selectedCircle = updated
                }
            }
            return code
        } catch {
            self.error = error
            return nil
        }
    }

    func fetchMembers(for circle: CircleGroup) async -> [CircleMember] {
        do {
            return try await repository.fetchMembers(circleId: circle.id)
        } catch {
            self.error = error
            return []
        }
    }

    func clearError() {
        error = nil
    }
}
#endif
