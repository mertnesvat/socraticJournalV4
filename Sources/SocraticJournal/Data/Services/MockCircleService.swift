// MockCircleService.swift
// Circle
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation

/// Mock circle service for SwiftUI previews and testing.
/// Returns sample data without requiring SwiftData persistence.
@Observable
@MainActor
public final class MockCircleService: CircleServiceProtocol {
    // MARK: - State

    public var circles: [Circle] = []

    // MARK: - Init

    /// Creates a mock circle service.
    /// - Parameter withSampleData: If true, populates with sample circles.
    public init(withSampleData: Bool = true) {
        if withSampleData {
            circles = Self.makeSampleCircles()
        }
    }

    // MARK: - CircleServiceProtocol

    public func createCircle(name: String, icon: String) async throws -> Circle {
        let circle = Circle(name: name, emojiIcon: icon)
        let member = CircleMember(
            displayName: "You",
            isCurrentUser: true,
            circle: circle
        )
        circle.members.append(member)
        circles.append(circle)
        return circle
    }

    public func getCircles() async throws -> [Circle] {
        circles.sorted { $0.createdAt > $1.createdAt }
    }

    public func getCircle(id: UUID) async throws -> Circle? {
        circles.first { $0.id == id }
    }

    public func updateCircle(id: UUID, name: String, icon: String) async throws {
        guard let circle = circles.first(where: { $0.id == id }) else {
            throw CircleServiceError.circleNotFound
        }
        circle.name = name
        circle.emojiIcon = icon
    }

    public func deleteCircle(id: UUID) async throws {
        circles.removeAll { $0.id == id }
    }

    public func addMember(to circleId: UUID, name: String, avatarData: Data?) async throws -> CircleMember {
        guard let circle = circles.first(where: { $0.id == circleId }) else {
            throw CircleServiceError.circleNotFound
        }
        guard circle.memberCount < 5 else {
            throw CircleServiceError.maxMembersReached
        }
        let member = CircleMember(
            displayName: name,
            avatarImageData: avatarData,
            isCurrentUser: false,
            circle: circle
        )
        circle.members.append(member)
        return member
    }

    public func removeMember(id: UUID, from circleId: UUID) async throws {
        guard let circle = circles.first(where: { $0.id == circleId }) else {
            throw CircleServiceError.circleNotFound
        }
        circle.members.removeAll { $0.id == id }
    }

    // MARK: - Sample Data

    private static func makeSampleCircles() -> [Circle] {
        let family = Circle(name: "Family", emojiIcon: "house")
        let familyMembers = [
            CircleMember(displayName: "You", isCurrentUser: true, circle: family),
            CircleMember(displayName: "Mom", circle: family),
            CircleMember(displayName: "Dad", circle: family),
            CircleMember(displayName: "Sister", circle: family)
        ]
        family.members = familyMembers

        let friends = Circle(name: "Close Friends", emojiIcon: "star")
        let friendMembers = [
            CircleMember(displayName: "You", isCurrentUser: true, circle: friends),
            CircleMember(displayName: "Alex", circle: friends),
            CircleMember(displayName: "Jordan", circle: friends)
        ]
        friends.members = friendMembers

        return [family, friends]
    }
}
#endif
