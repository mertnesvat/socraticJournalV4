// SectionHeader.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Reusable section header component for consistent styling across Self-Discovery tab
/// Provides visual hierarchy with icon, title, and optional subtitle
public struct SectionHeader: View {
    let icon: String
    let title: String
    let subtitle: String?
    let iconColor: Color

    public init(
        icon: String,
        title: String,
        subtitle: String? = nil,
        iconColor: Color = .secondary
    ) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.iconColor = iconColor
    }

    public var body: some View {
        HStack(spacing: 10) {
            // Icon with background circle
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.12))
                    .frame(width: 32, height: 32)

                Image(systemName: icon)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(iconColor)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)

                if let subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()
        }
    }
}

#Preview {
    VStack(spacing: 24) {
        SectionHeader(
            icon: "brain.head.profile",
            title: "Personality Insights",
            subtitle: "Discover your character traits",
            iconColor: .blue
        )

        SectionHeader(
            icon: "theatermasks.fill",
            title: "Character Quiz",
            subtitle: "Which character are you?",
            iconColor: .indigo
        )

        SectionHeader(
            icon: "envelope.fill",
            title: "Future Letters",
            iconColor: .purple
        )
    }
    .padding()
    .background(Color(uiColor: .systemGroupedBackground))
}
#endif
