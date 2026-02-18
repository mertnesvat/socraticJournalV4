// InMemoryCircleRepository.swift
// Circle
// Copyright 2024 StudioNext

import Foundation

/// In-memory circle repository with pre-seeded sample data
/// Replace with FirestoreCircleRepository when Firebase is integrated
public final class InMemoryCircleRepository: CircleRepositoryProtocol, @unchecked Sendable {
    private var circles: [String: Circle]
    private var members: [String: [CircleMember]] // circleId -> members
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let defaults: UserDefaults
    private static let storageKey = "circle_data"
    private static let membersKey = "circle_members_data"

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.circles = [:]
        self.members = [:]
        loadFromDisk()
        seedIfEmpty()
    }

    // MARK: - CircleRepositoryProtocol

    public func getCircles(for userId: String) async throws -> [Circle] {
        circles.values.filter { $0.memberIds.contains(userId) }
            .sorted { $0.createdAt < $1.createdAt }
    }

    public func getCircle(id: String) async throws -> Circle? {
        circles[id]
    }

    public func createCircle(_ circle: Circle) async throws {
        circles[circle.id] = circle
        saveToDisk()
    }

    public func updateCircle(_ circle: Circle) async throws {
        circles[circle.id] = circle
        saveToDisk()
    }

    public func deleteCircle(id: String) async throws {
        circles.removeValue(forKey: id)
        members.removeValue(forKey: id)
        saveToDisk()
    }

    public func addMember(_ member: CircleMember, to circleId: String) async throws {
        guard var circle = circles[circleId] else { return }
        guard !circle.isFull else { return }
        guard !circle.memberIds.contains(member.userId) else { return }

        circle.memberIds.append(member.userId)
        circles[circleId] = circle

        var circleMembers = members[circleId] ?? []
        circleMembers.append(member)
        members[circleId] = circleMembers

        saveToDisk()
    }

    public func removeMember(userId: String, from circleId: String) async throws {
        guard var circle = circles[circleId] else { return }

        circle.memberIds.removeAll { $0 == userId }
        circles[circleId] = circle

        members[circleId]?.removeAll { $0.userId == userId }

        saveToDisk()
    }

    public func getMembers(for circleId: String) async throws -> [CircleMember] {
        members[circleId] ?? []
    }

    public func findCircle(byInviteCode code: String) async throws -> Circle? {
        circles.values.first { $0.inviteCode.uppercased() == code.uppercased() }
    }

    // MARK: - Persistence

    private func saveToDisk() {
        if let data = try? encoder.encode(Array(circles.values)) {
            defaults.set(data, forKey: Self.storageKey)
        }
        if let data = try? encoder.encode(members) {
            defaults.set(data, forKey: Self.membersKey)
        }
    }

    private func loadFromDisk() {
        if let data = defaults.data(forKey: Self.storageKey),
           let saved = try? decoder.decode([Circle].self, from: data) {
            for circle in saved {
                circles[circle.id] = circle
            }
        }
        if let data = defaults.data(forKey: Self.membersKey),
           let saved = try? decoder.decode([String: [CircleMember]].self, from: data) {
            members = saved
        }
    }

    private func seedIfEmpty() {
        guard circles.isEmpty else { return }

        let sampleCircle = Circle(
            id: "circle-001",
            name: "Family Circle",
            emoji: "👨‍👩‍👧",
            colorHex: "#FF6B6B",
            createdBy: "user-001",
            createdAt: Date().addingTimeInterval(-86400 * 7),
            inviteCode: "FAM123",
            memberIds: ["user-001", "user-002", "user-003"]
        )

        circles[sampleCircle.id] = sampleCircle

        members[sampleCircle.id] = [
            CircleMember(id: "mem-001", userId: "user-001", displayName: "You",
                        joinedAt: sampleCircle.createdAt, role: .owner),
            CircleMember(id: "mem-002", userId: "user-002", displayName: "Sarah",
                        joinedAt: sampleCircle.createdAt.addingTimeInterval(3600), role: .member),
            CircleMember(id: "mem-003", userId: "user-003", displayName: "Mike",
                        joinedAt: sampleCircle.createdAt.addingTimeInterval(7200), role: .member),
        ]

        saveToDisk()
    }
}
