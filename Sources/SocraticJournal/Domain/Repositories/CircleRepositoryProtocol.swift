// CircleRepositoryProtocol.swift
// Circle
// Copyright 2024 StudioNext

import Foundation

/// Protocol defining circle data operations
public protocol CircleRepositoryProtocol: Sendable {
    /// Fetch all circles the current user belongs to
    func getCircles(for userId: String) async throws -> [Circle]

    /// Fetch a single circle by ID
    func getCircle(id: String) async throws -> Circle?

    /// Create a new circle
    func createCircle(_ circle: Circle) async throws

    /// Update an existing circle
    func updateCircle(_ circle: Circle) async throws

    /// Delete a circle
    func deleteCircle(id: String) async throws

    /// Add a member to a circle
    func addMember(_ member: CircleMember, to circleId: String) async throws

    /// Remove a member from a circle
    func removeMember(userId: String, from circleId: String) async throws

    /// Get all members of a circle
    func getMembers(for circleId: String) async throws -> [CircleMember]

    /// Find a circle by its invite code
    func findCircle(byInviteCode code: String) async throws -> Circle?
}
