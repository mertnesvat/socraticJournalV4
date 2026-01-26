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

    @State private var showShareSheet = false
    @State private var cardsRevealed = false

    // MARK: - Body

    public var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header with universe badge
                headerSection

                // Character match cards using the new component
                matchCardsSection
                    .padding(.horizontal)

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
        .onAppear {
            // Trigger reveal animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                cardsRevealed = true
            }
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: 12) {
            Text("Your Character Match")
                .font(.title2)
                .fontWeight(.bold)

            Text("Based on your journal reflections")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
    }

    // MARK: - Match Cards Section

    private var matchCardsSection: some View {
        VStack(spacing: 20) {
            ForEach(Array(result.matches.prefix(3).enumerated()), id: \.element.id) { index, match in
                let character = findCharacter(for: match)

                CharacterResultCard(
                    match: match,
                    character: character,
                    universe: universe,
                    rank: index + 1,
                    journalExcerpts: [], // Could be populated from result if available
                    animated: cardsRevealed
                )
                .characterCardReveal(index: index, isRevealed: cardsRevealed)
            }
        }
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
                ShareSheet(activityItems: [shareText(for: topMatch)])
            }
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
