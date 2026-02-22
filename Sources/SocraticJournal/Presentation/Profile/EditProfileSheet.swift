// EditProfileSheet.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Sheet for editing user profile details including display name, username, and avatar
public struct EditProfileSheet: View {
    @Environment(\.dismiss) private var dismiss

    @State private var displayName: String
    @State private var username: String
    @State private var selectedAvatar: String
    @State private var validationError: String?

    private let profile: UserProfile
    private let onSave: (UserProfile) -> Void

    /// Available SF Symbol options for avatar selection
    private let avatarOptions: [String] = [
        "person.circle.fill",
        "person.circle",
        "face.smiling",
        "star.circle.fill",
        "heart.circle.fill",
        "bolt.circle.fill",
        "moon.circle.fill",
        "sun.max.circle.fill"
    ]

    public init(profile: UserProfile, onSave: @escaping (UserProfile) -> Void) {
        self.profile = profile
        self.onSave = onSave
        _displayName = State(initialValue: profile.displayName)
        _username = State(initialValue: profile.username)
        _selectedAvatar = State(initialValue: profile.avatarImageName ?? "person.circle.fill")
    }

    public var body: some View {
        NavigationStack {
            Form {
                // Display Name
                Section("Display Name") {
                    TextField("Display Name", text: $displayName)
                        .textContentType(.name)
                        .autocorrectionDisabled()
                }

                // Username
                Section("Username") {
                    HStack(spacing: 0) {
                        Text("@")
                            .foregroundStyle(.secondary)
                        TextField("username", text: $username)
                            .textContentType(.username)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                    }
                }

                // Avatar Picker
                Section("Avatar") {
                    LazyVGrid(columns: [
                        GridItem(.adaptive(minimum: 60), spacing: 16)
                    ], spacing: 16) {
                        ForEach(avatarOptions, id: \.self) { avatarName in
                            Button {
                                selectedAvatar = avatarName
                            } label: {
                                Image(systemName: avatarName)
                                    .font(.system(size: 40))
                                    .foregroundStyle(selectedAvatar == avatarName ? Color.accentColor : Color.secondary)
                                    .frame(width: 60, height: 60)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(selectedAvatar == avatarName
                                                  ? Color.accentColor.opacity(0.1)
                                                  : Color.clear)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(selectedAvatar == avatarName
                                                    ? Color.accentColor
                                                    : Color.clear,
                                                    lineWidth: 2)
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 8)
                }

                // Validation error
                if let validationError = validationError {
                    Section {
                        Text(validationError)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        saveProfile()
                    }
                    .font(.body.weight(.semibold))
                }
            }
        }
    }

    // MARK: - Validation & Save

    private func saveProfile() {
        // Validate display name
        let trimmedName = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            validationError = "Display name is required."
            return
        }

        // Validate username
        let trimmedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedUsername.count >= 3 else {
            validationError = "Username must be at least 3 characters."
            return
        }

        validationError = nil

        // Create updated profile
        var updatedProfile = profile
        updatedProfile.displayName = trimmedName
        updatedProfile.username = trimmedUsername
        updatedProfile.avatarImageName = selectedAvatar

        onSave(updatedProfile)
        dismiss()
    }
}
#endif
