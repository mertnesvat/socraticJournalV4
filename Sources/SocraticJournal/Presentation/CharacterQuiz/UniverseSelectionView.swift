// UniverseSelectionView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Grid view for selecting a fictional universe for character matching
public struct UniverseSelectionView: View {
    // MARK: - Properties

    let onSelectUniverse: (FictionalUniverse) -> Void

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    // MARK: - Body

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                headerSection
                    .padding(.horizontal)

                // Universe Grid
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(FictionalUniverse.allUniverses) { universe in
                        UniverseCard(universe: universe) {
                            onSelectUniverse(universe)
                        }
                    }
                }
                .padding(.horizontal)

                // Footer hint
                footerHint
                    .padding(.horizontal)
                    .padding(.top, 8)

                Spacer(minLength: 40)
            }
            .padding(.top)
        }
        .background(Color(uiColor: .systemGroupedBackground))
    }

    // MARK: - Subviews

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Choose Your Universe")
                .font(.title2)
                .fontWeight(.bold)

            Text("Select a fictional world to discover which character you most resemble based on your journal reflections.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineSpacing(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var footerHint: some View {
        HStack(spacing: 8) {
            Image(systemName: "lightbulb.fill")
                .foregroundStyle(.yellow)

            Text("Your character match is based on patterns in your journal entries, not a personality test.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Universe Card

/// Individual universe selection card
private struct UniverseCard: View {
    let universe: FictionalUniverse
    let onTap: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                // Icon and character count
                HStack {
                    UniverseIcon(universe: universe, size: .large, style: .filled)

                    Spacer()

                    Text("\(universe.characterCount)")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(uiColor: .tertiarySystemFill))
                        .clipShape(Capsule())
                }

                // Universe name
                Text(universe.name)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                // Description
                Text(universe.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)

                Spacer(minLength: 0)
            }
            .padding(16)
            .frame(maxWidth: .infinity, minHeight: 180, alignment: .topLeading)
            .background(Color(uiColor: .systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(universe.themeColor.opacity(0.2), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
        .buttonStyle(UniverseCardButtonStyle())
        .accessibilityLabel("\(universe.name), \(universe.characterCount) characters")
        .accessibilityHint("Double tap to select this universe")
    }
}

// MARK: - Button Style

private struct UniverseCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Previews

#Preview("Universe Selection") {
    NavigationStack {
        UniverseSelectionView { universe in
            print("Selected: \(universe.name)")
        }
        .navigationTitle("Character Quiz")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("Dark Mode") {
    NavigationStack {
        UniverseSelectionView { universe in
            print("Selected: \(universe.name)")
        }
        .navigationTitle("Character Quiz")
        .navigationBarTitleDisplayMode(.inline)
    }
    .preferredColorScheme(.dark)
}
#endif
