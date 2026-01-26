// WisdomLibrarySettingsRow.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Settings row for accessing the Wisdom Library
struct WisdomLibrarySettingsRow: View {
    let onTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Content")
                .font(.headline)

            Button(action: onTap) {
                HStack {
                    Image(systemName: "book.fill")
                        .font(.body)
                        .foregroundStyle(.blue)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Wisdom Library")
                            .font(.body)
                            .foregroundStyle(.primary)
                        Text("Browse quotes and philosophical insights")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
            .buttonStyle(.plain)
        }
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    WisdomLibrarySettingsRow(onTap: {})
        .padding()
        .background(Color(uiColor: .systemGroupedBackground))
}
#endif
