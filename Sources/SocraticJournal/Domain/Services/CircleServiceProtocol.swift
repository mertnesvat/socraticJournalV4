// CircleServiceProtocol.swift
// Circle
// Copyright 2024 StudioNext

import Foundation

/// Protocol defining circle management operations.
/// All implementations are local-only -- no network calls.
@MainActor
public protocol CircleServiceProtocol: AnyObject {
    /// Create a new circle with the given name and emoji icon.
    /// The current user is automatically added as the first member.
    /// - Parameters:
    ///   - name: The circle name (required, non-empty).
    ///   - icon: The emoji icon string for the circle.
    /// - Returns: The newly created Circle entity.
    func createCircle(name: String, icon: String) async throws -> Circle

    /// Fetch all circles for the current user, sorted by creation date.
    func getCircles() async throws -> [Circle]

    /// Fetch a single circle by its identifier.
    func getCircle(id: UUID) async throws -> Circle?

    /// Update a circle's name and/or emoji icon.
    func updateCircle(id: UUID, name: String, icon: String) async throws

    /// Delete a circle and all its members.
    func deleteCircle(id: UUID) async throws

    /// Add a new member to a circle.
    /// Enforces a maximum of 5 members per circle.
    /// - Parameters:
    ///   - circleId: The circle to add the member to.
    ///   - name: The member's display name.
    ///   - avatarData: Optional avatar image data.
    /// - Returns: The newly created CircleMember entity.
    func addMember(to circleId: UUID, name: String, avatarData: Data?) async throws -> CircleMember

    /// Remove a member from a circle.
    /// - Parameters:
    ///   - id: The member's identifier.
    ///   - circleId: The circle to remove them from.
    func removeMember(id: UUID, from circleId: UUID) async throws
}
