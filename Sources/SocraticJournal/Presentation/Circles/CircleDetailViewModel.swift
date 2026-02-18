// CircleDetailViewModel.swift
// Circle
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation
import SwiftUI

/// ViewModel for the circle detail screen.
/// Manages circle editing, member management, and deletion.
@Observable
@MainActor
public final class CircleDetailViewModel {
    // MARK: - State

    private(set) var circle: Circle
    private(set) var isLoading = false
    private(set) var error: Error?

    var isEditing = false
    var editName: String = ""
    var editIcon: String = ""

    var showAddMember = false
    var showDeleteConfirmation = false

    /// Whether the circle has reached the maximum number of members.
    var isAtMaxMembers: Bool {
        circle.memberCount >= LocalCircleService.maxMembersPerCircle
    }

    /// Sorted members: current user first, then alphabetically.
    var sortedMembers: [CircleMember] {
        circle.members.sorted { a, b in
            if a.isCurrentUser != b.isCurrentUser {
                return a.isCurrentUser
            }
            return a.displayName.localizedCompare(b.displayName) == .orderedAscending
        }
    }

    // MARK: - Dependencies

    private let circleService: CircleServiceProtocol

    /// Callback fired when the circle is deleted so the parent can pop navigation.
    var onDeleted: (() -> Void)?

    // MARK: - Init

    public init(circle: Circle, circleService: CircleServiceProtocol) {
        self.circle = circle
        self.circleService = circleService
        self.editName = circle.name
        self.editIcon = circle.emojiIcon
    }

    // MARK: - Actions

    /// Refresh circle data from the data source.
    func refresh() async {
        do {
            if let updated = try await circleService.getCircle(id: circle.id) {
                circle = updated
                editName = updated.name
                editIcon = updated.emojiIcon
            }
        } catch {
            self.error = error
        }
    }

    /// Start editing mode, populating fields with current values.
    func startEditing() {
        editName = circle.name
        editIcon = circle.emojiIcon
        isEditing = true
    }

    /// Save the current edits to the circle.
    func saveEdits() async {
        let trimmed = editName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            error = CircleServiceError.invalidName
            return
        }

        isLoading = true
        do {
            try await circleService.updateCircle(id: circle.id, name: trimmed, icon: editIcon)
            circle.name = trimmed
            circle.emojiIcon = editIcon
            isEditing = false
        } catch {
            self.error = error
        }
        isLoading = false
    }

    /// Cancel editing and revert fields.
    func cancelEditing() {
        editName = circle.name
        editIcon = circle.emojiIcon
        isEditing = false
    }

    /// Remove a member from the circle.
    func removeMember(_ member: CircleMember) async {
        do {
            try await circleService.removeMember(id: member.id, from: circle.id)
            await refresh()
        } catch {
            self.error = error
        }
    }

    /// Delete the entire circle.
    func deleteCircle() async {
        isLoading = true
        do {
            try await circleService.deleteCircle(id: circle.id)
            onDeleted?()
        } catch {
            self.error = error
        }
        isLoading = false
    }

    /// Clear the current error state.
    func clearError() {
        error = nil
    }
}
#endif
