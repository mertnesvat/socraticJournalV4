// TodayPlaceholderView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Placeholder view for the Today tab
/// Will be replaced with the Daily Question Feed in a future feature
public struct TodayPlaceholderView: View {
    public init() {}

    public var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Image(systemName: "mic.circle.fill")
                    .font(.system(size: 64))
                    .foregroundColor(.accentColor)

                Text("Daily Question Feed Coming Soon")
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("Today")
        }
    }
}

#Preview {
    TodayPlaceholderView()
}
#endif
