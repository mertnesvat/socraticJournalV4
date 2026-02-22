// ProfilePlaceholderView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Placeholder view for the Profile tab
/// Will be replaced with the User Profile & Streak Dashboard in a future feature
public struct ProfilePlaceholderView: View {
    public init() {}

    public var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Image(systemName: "person.crop.circle")
                    .font(.system(size: 64))
                    .foregroundColor(.accentColor)

                Text("Profile Coming Soon")
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("Profile")
        }
    }
}

#Preview {
    ProfilePlaceholderView()
}
#endif
