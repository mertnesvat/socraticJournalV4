// ProfileSetupViewModel.swift
// Circle
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation
import PhotosUI
import SwiftUI

/// ViewModel for the profile setup / sign-in screen.
@Observable
@MainActor
public final class ProfileSetupViewModel {
    // MARK: - State

    var displayName: String = ""
    var selectedPhotoItem: PhotosPickerItem?
    private(set) var avatarImageData: Data?
    private(set) var isLoading: Bool = false
    private(set) var error: Error?

    /// Whether the form is valid for submission.
    var isValid: Bool {
        !displayName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    /// Computed initials from the current display name input.
    var initials: String {
        let components = displayName
            .trimmingCharacters(in: .whitespaces)
            .split(separator: " ")
            .filter { !$0.isEmpty }

        guard let first = components.first else { return "?" }

        if components.count >= 2, let last = components.last {
            return "\(first.prefix(1).uppercased())\(last.prefix(1).uppercased())"
        }

        return first.prefix(1).uppercased()
    }

    // MARK: - Dependencies

    private let authService: AuthServiceProtocol

    // MARK: - Init

    public init(authService: AuthServiceProtocol) {
        self.authService = authService
    }

    // MARK: - Actions

    /// Handle photo selection from PhotosPicker.
    func handlePhotoSelection() async {
        guard let item = selectedPhotoItem else {
            avatarImageData = nil
            return
        }

        do {
            if let data = try await item.loadTransferable(type: Data.self) {
                avatarImageData = data
            }
        } catch {
            self.error = error
            avatarImageData = nil
        }
    }

    /// Clear the current error state.
    func clearError() {
        error = nil
    }

    /// Remove the selected avatar photo.
    func removePhoto() {
        selectedPhotoItem = nil
        avatarImageData = nil
    }

    /// Sign in with the entered profile information.
    func signIn() async {
        guard isValid else { return }

        isLoading = true
        error = nil

        do {
            try await authService.signIn(
                name: displayName,
                avatarData: avatarImageData
            )
        } catch {
            self.error = error
        }

        isLoading = false
    }
}
#endif
