// AboutView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// About section with version and links
struct AboutView: View {
    let version: String
    let onPrivacyPolicy: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("About")
                .font(.headline)

            // Version info
            HStack {
                Image(systemName: "info.circle")
                    .font(.body)
                    .foregroundStyle(.secondary)

                Text("Version")
                    .font(.body)

                Spacer()

                Text(version)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }

            Divider()

            // Privacy policy link
            Button(action: onPrivacyPolicy) {
                HStack {
                    Image(systemName: "hand.raised")
                        .font(.body)
                        .foregroundStyle(.secondary)

                    Text("Privacy Policy")
                        .font(.body)
                        .foregroundStyle(.primary)

                    Spacer()

                    Image(systemName: "arrow.up.right")
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
    AboutView(
        version: "1.0.0",
        onPrivacyPolicy: {}
    )
    .padding()
    .background(Color(uiColor: .systemGroupedBackground))
}
#endif
