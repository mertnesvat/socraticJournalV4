// CharacterResultsView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// View displaying character match results with confidence scores and reasoning
public struct CharacterResultsView: View {
    // MARK: - Properties

    let result: CharacterMatchResult
    let universe: FictionalUniverse
    let onTryAgain: () -> Void

    @State private var expandedMatchId: String?
    @State private var showShareSheet = false

    // MARK: - Body

    public var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header with universe badge
                headerSection

                // Top match highlight
                if let topMatch = result.topMatch {
                    topMatchCard(topMatch)
                        .padding(.horizontal)
                }

                // Other matches
                if result.matches.count > 1 {
                    otherMatchesSection
                        .padding(.horizontal)
                }

                // Analysis summary
                analysisSummarySection
                    .padding(.horizontal)

                // Actions
                actionsSection
                    .padding(.horizontal)

                Spacer(minLength: 60)
            }
            .padding(.top)
        }
        .background(Color(uiColor: .systemGroupedBackground))
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: 12) {
            UniverseBadge(universe: universe)

            Text("Your Character Match")
                .font(.title2)
                .fontWeight(.bold)

            Text("Based on your journal reflections")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
    }

    // MARK: - Top Match Card

    private func topMatchCard(_ match: CharacterMatch) -> some View {
        let character = findCharacter(for: match)

        return VStack(spacing: 16) {
            // Character avatar
            if let character = character {
                CharacterAvatar(character: character, size: .hero, style: .gradient)
            } else {
                PlaceholderAvatar(size: .hero)
            }

            // Character name
            Text(match.characterName)
                .font(.title)
                .fontWeight(.bold)

            // Confidence indicator
            confidenceIndicator(match.confidence, isTopMatch: true)

            // Confidence label
            Text(match.confidenceLabel)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(confidenceColor(match.confidence))

            // Character description
            if let character = character {
                Text(character.description)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
                    .padding(.horizontal)
            }

            // Reasoning
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "quote.opening")
                        .foregroundStyle(.secondary)
                    Text("Why this match?")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Spacer()
                }

                Text(match.reasoning)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .lineSpacing(4)
            }
            .padding()
            .background(Color(uiColor: .tertiarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(20)
        .background(Color(uiColor: .systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
    }

    // MARK: - Other Matches Section

    private var otherMatchesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Other Matches")
                .font(.headline)

            ForEach(Array(result.matches.dropFirst().prefix(2))) { match in
                otherMatchCard(match)
            }
        }
    }

    private func otherMatchCard(_ match: CharacterMatch) -> some View {
        let character = findCharacter(for: match)
        let isExpanded = expandedMatchId == match.id

        return VStack(spacing: 0) {
            // Main row
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    expandedMatchId = isExpanded ? nil : match.id
                }
            } label: {
                HStack(spacing: 12) {
                    // Avatar
                    if let character = character {
                        CharacterAvatar(character: character, size: .medium, style: .gradient)
                    } else {
                        PlaceholderAvatar(size: .medium)
                    }

                    // Name and confidence
                    VStack(alignment: .leading, spacing: 4) {
                        Text(match.characterName)
                            .font(.headline)
                            .foregroundStyle(.primary)

                        Text(match.confidenceLabel)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    // Confidence percentage
                    Text(match.confidencePercentage)
                        .font(.headline)
                        .foregroundStyle(confidenceColor(match.confidence))

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding()
            }
            .buttonStyle(.plain)

            // Expanded reasoning
            if isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    // Confidence bar
                    confidenceIndicator(match.confidence, isTopMatch: false)
                        .padding(.bottom, 4)

                    // Character description
                    if let character = character {
                        Text(character.description)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineSpacing(2)
                            .padding(.bottom, 8)
                    }

                    // Reasoning
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "lightbulb.fill")
                            .foregroundStyle(.yellow)
                            .font(.caption)

                        Text(match.reasoning)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineSpacing(2)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(Color(uiColor: .systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
    }

    // MARK: - Analysis Summary

    private var analysisSummarySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "brain.head.profile")
                    .foregroundStyle(.purple)
                Text("Analysis Summary")
                    .font(.headline)
            }

            Text(result.analysisSummary)
                .font(.body)
                .foregroundStyle(.secondary)
                .lineSpacing(4)

            HStack {
                Image(systemName: "clock")
                    .foregroundStyle(.secondary)
                Text("Generated \(result.generatedAt, style: .relative) ago")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding(.top, 4)
        }
        .padding()
        .background(Color(uiColor: .systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Actions Section

    private var actionsSection: some View {
        VStack(spacing: 12) {
            // Try another universe button
            Button(action: onTryAgain) {
                HStack {
                    Image(systemName: "arrow.triangle.2.circlepath")
                    Text("Try Another Universe")
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.accentColor)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            // Share button (optional)
            Button {
                showShareSheet = true
            } label: {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("Share Result")
                }
                .font(.subheadline)
                .fontWeight(.medium)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .foregroundStyle(.primary)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .sheet(isPresented: $showShareSheet) {
            if let topMatch = result.topMatch {
                ShareSheet(items: [shareText(for: topMatch)])
            }
        }
    }

    // MARK: - Helper Views

    private func confidenceIndicator(_ confidence: Double, isTopMatch: Bool) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background track
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(uiColor: .tertiarySystemFill))

                // Progress fill
                RoundedRectangle(cornerRadius: 4)
                    .fill(
                        LinearGradient(
                            colors: [confidenceColor(confidence), confidenceColor(confidence).opacity(0.7)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * confidence)
            }
        }
        .frame(height: isTopMatch ? 8 : 6)
    }

    private func confidenceColor(_ confidence: Double) -> Color {
        switch confidence {
        case 0.8...: return .green
        case 0.6..<0.8: return .blue
        case 0.4..<0.6: return .orange
        default: return .gray
        }
    }

    // MARK: - Helpers

    private func findCharacter(for match: CharacterMatch) -> FictionalCharacter? {
        universe.characters.first { $0.id == match.characterId }
    }

    private func shareText(for match: CharacterMatch) -> String {
        """
        I took the Socratic Journal Character Quiz and matched with \(match.characterName) from \(universe.name) with \(match.confidencePercentage) confidence!

        \(match.reasoning)

        Discover your character match with Socratic Journal.
        """
    }
}

// MARK: - Share Sheet

private struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Previews

#Preview("Character Results") {
    let mockResult = CharacterMatchResult(
        matches: [
            CharacterMatch(
                characterId: "lotr-gandalf",
                characterName: "Gandalf",
                confidence: 0.87,
                reasoning: "Your journal entries reveal a deep wisdom and thoughtful approach to life's challenges. Like Gandalf, you guide others with patience and see the potential in those around you."
            ),
            CharacterMatch(
                characterId: "lotr-aragorn",
                characterName: "Aragorn",
                confidence: 0.72,
                reasoning: "You show strong leadership qualities and a sense of duty that resonates with Aragorn's noble character."
            ),
            CharacterMatch(
                characterId: "lotr-sam",
                characterName: "Samwise Gamgee",
                confidence: 0.58,
                reasoning: "Your loyalty and steadfast nature align with Sam's unwavering dedication to those he cares about."
            )
        ],
        universe: "Lord of the Rings",
        analysisSummary: "Your personality was analyzed across 12 journal entries, examining themes of growth, relationships, and personal values.",
        generatedAt: Date()
    )

    NavigationStack {
        CharacterResultsView(
            result: mockResult,
            universe: .lordOfTheRings,
            onTryAgain: {}
        )
        .navigationTitle("Results")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("Dark Mode") {
    let mockResult = CharacterMatchResult(
        matches: [
            CharacterMatch(
                characterId: "hp-hermione",
                characterName: "Hermione Granger",
                confidence: 0.91,
                reasoning: "Your intellectual curiosity and dedication to learning shine through your reflections, much like Hermione's love of knowledge."
            ),
            CharacterMatch(
                characterId: "hp-luna",
                characterName: "Luna Lovegood",
                confidence: 0.68,
                reasoning: "Your unique perspective and authenticity mirror Luna's unwavering individuality."
            )
        ],
        universe: "Harry Potter",
        analysisSummary: "Analysis of 8 journal entries revealed your unique personality fingerprint.",
        generatedAt: Date().addingTimeInterval(-3600)
    )

    NavigationStack {
        CharacterResultsView(
            result: mockResult,
            universe: .harryPotter,
            onTryAgain: {}
        )
        .navigationTitle("Results")
        .navigationBarTitleDisplayMode(.inline)
    }
    .preferredColorScheme(.dark)
}
#endif
