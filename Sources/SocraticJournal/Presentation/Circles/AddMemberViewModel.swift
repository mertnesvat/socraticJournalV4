// AddMemberViewModel.swift
// Circle
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation
import SwiftUI

/// ViewModel for the Add Member sheet.
/// Manages form state (name, selected emoji avatar), validates input,
/// calls the circle service, and enforces maximum member limits.
@Observable
@MainActor
public final class AddMemberViewModel {
    // MARK: - Form State

    var memberName: String = ""
    var selectedEmoji: String? = nil

    // MARK: - UI State

    private(set) var isLoading = false
    private(set) var error: Error?
    private(set) var didAddMember = false

    // MARK: - Circle Info

    private let circle: Circle
    private let circleService: CircleServiceProtocol

    /// Maximum members allowed per circle.
    let maxMembers: Int = LocalCircleService.maxMembersPerCircle

    /// Current number of members in the circle.
    var currentMemberCount: Int {
        circle.memberCount
    }

    /// How many spots remain in the circle.
    var remainingSlots: Int {
        max(0, maxMembers - currentMemberCount)
    }

    /// Whether the circle is at capacity.
    var isAtMaxMembers: Bool {
        currentMemberCount >= maxMembers
    }

    /// Whether the form is valid (name is non-empty and circle has room).
    var isFormValid: Bool {
        !trimmedName.isEmpty && !isAtMaxMembers
    }

    /// The trimmed member name.
    var trimmedName: String {
        memberName.trimmingCharacters(in: .whitespaces)
    }

    /// Curated set of emoji face avatars for member selection.
    static let avatarEmojis: [String] = [
        "\u{1F469}", // woman
        "\u{1F468}", // man
        "\u{1F467}", // girl
        "\u{1F466}", // boy
        "\u{1F471}\u{200D}\u{2640}\u{FE0F}", // blond woman
        "\u{1F471}", // blond person
        "\u{1F474}", // old man
        "\u{1F475}", // old woman
        "\u{1F469}\u{200D}\u{1F9B0}", // red hair woman
        "\u{1F468}\u{200D}\u{1F9B1}", // curly hair man
        "\u{1F9D1}", // person
        "\u{1F476}", // baby
        "\u{1F934}", // prince
        "\u{1F478}", // princess
        "\u{1F9D9}", // mage
        "\u{1F47C}", // angel
    ]

    // MARK: - Init

    public init(circle: Circle, circleService: CircleServiceProtocol) {
        self.circle = circle
        self.circleService = circleService
    }

    // MARK: - Actions

    /// Add the member to the circle using the service.
    func addMember() async {
        guard isFormValid else {
            error = CircleServiceError.invalidMemberName
            return
        }

        isLoading = true
        error = nil

        do {
            let _ = try await circleService.addMember(
                to: circle.id,
                name: trimmedName,
                avatarData: nil
            )
            didAddMember = true
        } catch {
            self.error = error
        }

        isLoading = false
    }

    /// Clear the current error state.
    func clearError() {
        error = nil
    }

    /// Reset form fields.
    func resetForm() {
        memberName = ""
        selectedEmoji = nil
        error = nil
        didAddMember = false
    }
}
#endif
