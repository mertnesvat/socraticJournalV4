// ProfileHeader.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Profile header showing avatar, display name, and username
struct ProfileHeader: View {
    let user: User

    var body: some View {
        VStack(spacing: 12) {
            // Avatar with edit overlay
            ZStack(alignment: .bottomTrailing) {
                avatarCircle
                editButton
            }

            // Display name
            Text(user.displayName)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.primary)

            // Username
            Text("@\(user.username)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }

    // MARK: - Subviews

    private var avatarCircle: some View {
        ZStack {
            Circle()
                .fill(avatarBackgroundColor)
                .frame(width: 100, height: 100)

            Text(initialLetter)
                .font(.system(size: 40, weight: .bold))
                .foregroundStyle(.white)
        }
    }

    private var editButton: some View {
        Image(systemName: "pencil.circle.fill")
            .font(.system(size: 28))
            .foregroundStyle(.white, Color.accentColor)
            .offset(x: 4, y: 4)
    }

    // MARK: - Helpers

    private var initialLetter: String {
        String(user.displayName.prefix(1)).uppercased()
    }

    private var avatarBackgroundColor: Color {
        // Deterministic color based on user id
        let colors: [Color] = [
            .blue, .purple, .orange, .pink, .teal, .indigo, .mint
        ]
        let hash = abs(user.id.hashValue)
        return colors[hash % colors.count]
    }
}

#Preview {
    ProfileHeader(user: MockDataProvider.currentUser)
        .padding()
        .background(Color(.systemBackground))
}
#endif
