// CircleRepositoryProtocol.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Protocol for circle data persistence
/// Local implementation uses JSON files; Firestore implementation uses cloud database
public protocol CircleRepositoryProtocol: Sendable {
    /// Create a new circle
    func create(name: String, emoji: String, creatorId: UUID) async throws -> CircleGroup

    /// Fetch all circles the user belongs to
    func fetchAll(userId: UUID) async throws -> [CircleGroup]

    /// Fetch a specific circle by ID
    func fetch(id: UUID) async throws -> CircleGroup?

    /// Update a circle
    func update(_ circle: CircleGroup) async throws

    /// Delete a circle
    func delete(id: UUID) async throws

    /// Add a member to a circle
    func addMember(_ member: CircleMember, to circleId: UUID) async throws

    /// Remove a member from a circle
    func removeMember(userId: UUID, from circleId: UUID) async throws

    /// Fetch all members of a circle
    func fetchMembers(circleId: UUID) async throws -> [CircleMember]

    /// Generate an invite code for a circle
    func generateInviteCode(circleId: UUID) async throws -> String

    /// Join a circle using an invite code
    func join(inviteCode: String, userId: UUID) async throws -> CircleGroup
}
