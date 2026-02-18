// LocalCircleRepository.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation

/// Helper struct that wraps CircleGroup and its members for JSON persistence
private struct CircleData: Codable {
    var circle: CircleGroup
    var members: [CircleMember]
}

/// JSON file-based implementation of CircleRepositoryProtocol
/// Stores each circle as a separate JSON file in: {documentsDir}/circles/{circleId}.json
public final class LocalCircleRepository: CircleRepositoryProtocol, @unchecked Sendable {
    private let lock = NSLock()
    private let circlesDirectory: URL
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    public init() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.circlesDirectory = documentsPath.appendingPathComponent("circles", isDirectory: true)

        self.encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601

        self.decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        // Ensure directory exists
        try? FileManager.default.createDirectory(
            at: circlesDirectory,
            withIntermediateDirectories: true
        )
    }

    // MARK: - Private Helpers

    private func fileURL(for circleId: UUID) -> URL {
        circlesDirectory.appendingPathComponent("\(circleId.uuidString).json")
    }

    private func readCircleData(id: UUID) throws -> CircleData? {
        let url = fileURL(for: id)
        guard FileManager.default.fileExists(atPath: url.path) else { return nil }
        let data = try Data(contentsOf: url)
        return try decoder.decode(CircleData.self, from: data)
    }

    private func writeCircleData(_ circleData: CircleData) throws {
        let url = fileURL(for: circleData.circle.id)
        let data = try encoder.encode(circleData)
        try data.write(to: url, options: .atomic)
    }

    private func allCircleData() throws -> [CircleData] {
        let contents = try FileManager.default.contentsOfDirectory(
            at: circlesDirectory,
            includingPropertiesForKeys: nil
        )
        return contents
            .filter { $0.pathExtension == "json" }
            .compactMap { url -> CircleData? in
                guard let data = try? Data(contentsOf: url) else { return nil }
                return try? decoder.decode(CircleData.self, from: data)
            }
    }

    // MARK: - CircleRepositoryProtocol

    public func create(name: String, emoji: String, creatorId: UUID) async throws -> CircleGroup {
        lock.lock()
        defer { lock.unlock() }

        let newCircle = CircleGroup(
            id: UUID(),
            name: name,
            emoji: emoji,
            creatorId: creatorId,
            memberIds: [creatorId],
            createdAt: Date()
        )

        let creatorMember = CircleMember(
            userId: creatorId,
            displayName: "You",
            joinedAt: Date(),
            role: .creator,
            isSimulated: false
        )

        let circleData = CircleData(circle: newCircle, members: [creatorMember])
        try writeCircleData(circleData)
        return newCircle
    }

    public func fetchAll(userId: UUID) async throws -> [CircleGroup] {
        lock.lock()
        defer { lock.unlock() }

        let allData = try allCircleData()
        return allData
            .filter { $0.circle.memberIds.contains(userId) }
            .map { $0.circle }
            .sorted { $0.createdAt > $1.createdAt }
    }

    public func fetch(id: UUID) async throws -> CircleGroup? {
        lock.lock()
        defer { lock.unlock() }

        return try readCircleData(id: id)?.circle
    }

    public func update(_ circle: CircleGroup) async throws {
        lock.lock()
        defer { lock.unlock() }

        guard var existing = try readCircleData(id: circle.id) else {
            throw CircleRepositoryError.circleNotFound
        }
        existing.circle = circle
        try writeCircleData(existing)
    }

    public func delete(id: UUID) async throws {
        lock.lock()
        defer { lock.unlock() }

        let url = fileURL(for: id)
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw CircleRepositoryError.circleNotFound
        }
        try FileManager.default.removeItem(at: url)
    }

    public func addMember(_ member: CircleMember, to circleId: UUID) async throws {
        lock.lock()
        defer { lock.unlock() }

        guard var circleData = try readCircleData(id: circleId) else {
            throw CircleRepositoryError.circleNotFound
        }

        // Check max members
        guard circleData.circle.memberIds.count < CircleGroup.maxMembers else {
            throw CircleRepositoryError.maximumMembersReached
        }

        // Avoid duplicates
        guard !circleData.circle.memberIds.contains(member.userId) else { return }

        circleData.circle.memberIds.append(member.userId)
        circleData.members.append(member)
        try writeCircleData(circleData)
    }

    public func removeMember(userId: UUID, from circleId: UUID) async throws {
        lock.lock()
        defer { lock.unlock() }

        guard var circleData = try readCircleData(id: circleId) else {
            throw CircleRepositoryError.circleNotFound
        }

        circleData.circle.memberIds.removeAll { $0 == userId }
        circleData.members.removeAll { $0.userId == userId }
        try writeCircleData(circleData)
    }

    public func fetchMembers(circleId: UUID) async throws -> [CircleMember] {
        lock.lock()
        defer { lock.unlock() }

        guard let circleData = try readCircleData(id: circleId) else {
            throw CircleRepositoryError.circleNotFound
        }
        return circleData.members
    }

    public func generateInviteCode(circleId: UUID) async throws -> String {
        lock.lock()
        defer { lock.unlock() }

        guard var circleData = try readCircleData(id: circleId) else {
            throw CircleRepositoryError.circleNotFound
        }

        let characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let code = String((0..<6).map { _ in characters.randomElement()! })

        circleData.circle.inviteCode = code
        try writeCircleData(circleData)
        return code
    }

    public func join(inviteCode: String, userId: UUID) async throws -> CircleGroup {
        lock.lock()
        defer { lock.unlock() }

        let allData = try allCircleData()
        guard var circleData = allData.first(where: {
            $0.circle.inviteCode?.uppercased() == inviteCode.uppercased()
        }) else {
            throw CircleRepositoryError.invalidInviteCode
        }

        guard circleData.circle.memberIds.count < CircleGroup.maxMembers else {
            throw CircleRepositoryError.maximumMembersReached
        }

        // Only add if not already a member
        if !circleData.circle.memberIds.contains(userId) {
            let newMember = CircleMember(
                userId: userId,
                displayName: "New Member",
                joinedAt: Date(),
                role: .member,
                isSimulated: false
            )
            circleData.circle.memberIds.append(userId)
            circleData.members.append(newMember)
            try writeCircleData(circleData)
        }

        return circleData.circle
    }
}

// MARK: - Errors

public enum CircleRepositoryError: LocalizedError {
    case circleNotFound
    case invalidInviteCode
    case maximumMembersReached

    public var errorDescription: String? {
        switch self {
        case .circleNotFound:
            return "Circle not found."
        case .invalidInviteCode:
            return "Invalid invite code. Please check and try again."
        case .maximumMembersReached:
            return "This circle is full. Circles can have up to \(CircleGroup.maxMembers) members."
        }
    }
}
#endif
