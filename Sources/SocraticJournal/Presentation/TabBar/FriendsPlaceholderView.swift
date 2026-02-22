// FriendsPlaceholderView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Placeholder view for the Friends tab
/// Will be replaced with the Friend Management Screen in a future feature
public struct FriendsPlaceholderView: View {
    public init() {}

    public var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Image(systemName: "person.2.fill")
                    .font(.system(size: 64))
                    .foregroundColor(.accentColor)

                Text("Friends Coming Soon")
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("Friends")
        }
    }
}

#Preview {
    FriendsPlaceholderView()
}
#endif
