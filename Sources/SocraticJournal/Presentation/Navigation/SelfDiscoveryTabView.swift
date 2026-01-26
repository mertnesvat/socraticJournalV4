// SelfDiscoveryTabView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Self-discovery view for personality insights and character quizzes
/// Provides a dedicated space for users to explore their inner selves
public struct SelfDiscoveryTabView: View {

    public init() {}

    public var body: some View {
        NavigationStack {
            content
                .navigationTitle("Discover")
                .navigationBarTitleDisplayMode(.large)
        }
    }

    @ViewBuilder
    private var content: some View {
        ScrollView {
            VStack(spacing: 24) {
                emptyStateView

                // Extra bottom padding to account for tab bar
                Spacer(minLength: 100)
            }
            .padding()
        }
        .background(Color(uiColor: .systemGroupedBackground))
    }

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "sparkles")
                .font(.system(size: 56))
                .foregroundStyle(Color.accentColor)
                .padding(.bottom, 8)

            Text("Welcome to Self-Discovery")
                .font(.title2)
                .fontWeight(.bold)

            Text("Explore your personality, take character quizzes, and gain deeper insights into who you are.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            VStack(alignment: .leading, spacing: 16) {
                DiscoveryFeatureRow(
                    icon: "person.crop.circle.badge.questionmark",
                    title: "Personality Insights",
                    description: "Discover your unique traits"
                )

                DiscoveryFeatureRow(
                    icon: "brain.head.profile",
                    title: "Character Quizzes",
                    description: "Fun assessments to learn about yourself"
                )

                DiscoveryFeatureRow(
                    icon: "chart.pie.fill",
                    title: "Growth Tracking",
                    description: "See how you evolve over time"
                )
            }
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .padding(.horizontal, 24)
        .background(Color(uiColor: .secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

/// Row component for displaying upcoming discovery features
private struct DiscoveryFeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(Color.accentColor)
                .frame(width: 40, height: 40)
                .background(Color.accentColor.opacity(0.15))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    SelfDiscoveryTabView()
}
#endif
