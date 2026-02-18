// LocalCircleService.swift
// Circle
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation
import SwiftData
import SwiftUI

/// Local circle management service backed by SwiftData.
/// All operations are performed on-device with no network calls.
@Observable
@MainActor
public final class LocalCircleService: CircleServiceProtocol {
    // MARK: - Constants

    /// Maximum number of members allowed per circle.
    static let maxMembersPerCircle = 5

    // MARK: - Dependencies

    private let modelContainer: ModelContainer
    private let authService: AuthServiceProtocol

    private var modelContext: ModelContext {
        modelContainer.mainContext
    }

    // MARK: - Init

    public init(modelContainer: ModelContainer, authService: AuthServiceProtocol) {
        self.modelContainer = modelContainer
        self.authService = authService
    }

    // MARK: - CircleServiceProtocol

    public func createCircle(name: String, icon: String) async throws -> Circle {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else {
            throw CircleServiceError.invalidName
        }

        let circle = Circle(
            name: trimmedName,
            emojiIcon: icon
        )

        modelContext.insert(circle)

        // Automatically add current user as first member
        if let user = authService.currentUser {
            let member = CircleMember(
                displayName: user.displayName,
                avatarImageData: user.avatarImageData,
                isCurrentUser: true,
                circle: circle
            )
            modelContext.insert(member)
            circle.members.append(member)
        }

        try modelContext.save()
        return circle
    }

    public func getCircles() async throws -> [Circle] {
        let descriptor = FetchDescriptor<Circle>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }

    public func getCircle(id: UUID) async throws -> Circle? {
        let descriptor = FetchDescriptor<Circle>(
            predicate: #Predicate { $0.id == id }
        )
        return try modelContext.fetch(descriptor).first
    }

    public func updateCircle(id: UUID, name: String, icon: String) async throws {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else {
            throw CircleServiceError.invalidName
        }

        guard let circle = try await getCircle(id: id) else {
            throw CircleServiceError.circleNotFound
        }

        circle.name = trimmedName
        circle.emojiIcon = icon
        try modelContext.save()
    }

    public func deleteCircle(id: UUID) async throws {
        guard let circle = try await getCircle(id: id) else {
            throw CircleServiceError.circleNotFound
        }

        modelContext.delete(circle)
        try modelContext.save()
    }

    public func addMember(to circleId: UUID, name: String, avatarData: Data?) async throws -> CircleMember {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else {
            throw CircleServiceError.invalidMemberName
        }

        guard let circle = try await getCircle(id: circleId) else {
            throw CircleServiceError.circleNotFound
        }

        guard circle.memberCount < Self.maxMembersPerCircle else {
            throw CircleServiceError.maxMembersReached
        }

        let member = CircleMember(
            displayName: trimmedName,
            avatarImageData: avatarData,
            isCurrentUser: false,
            circle: circle
        )

        modelContext.insert(member)
        circle.members.append(member)
        try modelContext.save()

        return member
    }

    public func removeMember(id: UUID, from circleId: UUID) async throws {
        guard let circle = try await getCircle(id: circleId) else {
            throw CircleServiceError.circleNotFound
        }

        guard let member = circle.members.first(where: { $0.id == id }) else {
            throw CircleServiceError.memberNotFound
        }

        if member.isCurrentUser {
            throw CircleServiceError.cannotRemoveCurrentUser
        }

        circle.members.removeAll { $0.id == id }
        modelContext.delete(member)
        try modelContext.save()
    }
}

// MARK: - Circle Service Errors

public enum CircleServiceError: LocalizedError {
    case invalidName
    case invalidMemberName
    case circleNotFound
    case memberNotFound
    case maxMembersReached
    case cannotRemoveCurrentUser
    case persistenceFailed(Error)

    public var errorDescription: String? {
        switch self {
        case .invalidName:
            return "Please enter a valid circle name."
        case .invalidMemberName:
            return "Please enter a valid member name."
        case .circleNotFound:
            return "Circle not found."
        case .memberNotFound:
            return "Member not found."
        case .maxMembersReached:
            return "A circle can have at most \(LocalCircleService.maxMembersPerCircle) members."
        case .cannotRemoveCurrentUser:
            return "You cannot remove yourself from the circle."
        case .persistenceFailed(let error):
            return "Failed to save: \(error.localizedDescription)"
        }
    }
}
#endif
