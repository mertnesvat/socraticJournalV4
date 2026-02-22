// FriendSearchView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Search results overlay displayed when the user is actively searching for friends
public struct FriendSearchView: View {
    let searchResults: [User]
    let searchQuery: String
    let onSendRequest: (String) -> Void

    @State private var sentRequestIds: Set<String> = []

    public var body: some View {
        Group {
            if searchResults.isEmpty && !searchQuery.isEmpty {
                emptyResultsView
            } else {
                resultsList
            }
        }
    }

    private var emptyResultsView: some View {
        ContentUnavailableView(
            "No Results",
            systemImage: "person.slash",
            description: Text("No users found matching \"\(searchQuery)\". Try a different username.")
        )
    }

    private var resultsList: some View {
        List {
            Section {
                ForEach(searchResults) { user in
                    searchResultRow(user: user)
                }
            } header: {
                Text("Search Results")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .textCase(nil)
            }
        }
        .listStyle(.insetGrouped)
    }

    private func searchResultRow(user: User) -> some View {
        HStack(spacing: 12) {
            // Avatar
            let avatarColor = avatarColorFor(user)
            let initial = String(user.displayName.prefix(1)).uppercased()

            Circle()
                .fill(avatarColor.opacity(0.3))
                .frame(width: 44, height: 44)
                .overlay(
                    Text(initial)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(avatarColor)
                )

            // Name and username
            VStack(alignment: .leading, spacing: 2) {
                Text(user.displayName)
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                Text("@\(user.username)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            // Add / Sent button
            if sentRequestIds.contains(user.id) {
                Text("Sent")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(Color(.systemGray5))
                    .clipShape(Capsule())
            } else {
                Button {
                    sentRequestIds.insert(user.id)
                    onSendRequest(user.id)
                } label: {
                    Text("Add")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 6)
                        .background(.blue)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 4)
    }

    private func avatarColorFor(_ user: User) -> Color {
        let colors: [Color] = [
            .blue, .purple, .orange, .pink, .teal, .indigo, .mint, .cyan
        ]
        let index = abs(user.displayName.hashValue) % colors.count
        return colors[index]
    }
}

#Preview {
    FriendSearchView(
        searchResults: MockDataProvider.friends,
        searchQuery: "luna",
        onSendRequest: { _ in }
    )
}
#endif
