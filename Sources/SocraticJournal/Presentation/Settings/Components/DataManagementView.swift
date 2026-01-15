// DataManagementView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Data management section with export and clear options
struct DataManagementView: View {
    let onExport: () -> Void
    let onClearData: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Data")
                .font(.headline)

            // Export button
            Button(action: onExport) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                        .font(.body)
                        .foregroundStyle(.blue)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Export Journal")
                            .font(.body)
                            .foregroundStyle(.primary)
                        Text("Save your journal as a JSON file")
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

            Divider()

            // Clear data button
            Button(action: onClearData) {
                HStack {
                    Image(systemName: "trash")
                        .font(.body)
                        .foregroundStyle(.red)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Clear All Data")
                            .font(.body)
                            .foregroundStyle(.red)
                        Text("Permanently delete all sessions and letters")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()
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
    DataManagementView(
        onExport: {},
        onClearData: {}
    )
    .padding()
    .background(Color(uiColor: .systemGroupedBackground))
}
#endif
