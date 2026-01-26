// CharacterQuizHistoryView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// View displaying character quiz history with favorites support
public struct CharacterQuizHistoryView: View {
    // MARK: - Properties

    let entries: [CharacterQuizHistoryEntry]
    let onSelectEntry: (CharacterQuizHistoryEntry) -> Void
    let onToggleFavorite: (CharacterQuizHistoryEntry) -> Void
    let onDelete: (CharacterQuizHistoryEntry) -> Void
    let onReanalyze: (String) -> Void  // universeId

    @State private var selectedFilter: HistoryFilter = .all
    @State private var showDeleteConfirmation = false
    @State private var entryToDelete: CharacterQuizHistoryEntry?

    // MARK: - Filter

    enum HistoryFilter: String, CaseIterable {
        case all = "All"
        case favorites = "Favorites"

        var icon: String {
            switch self {
            case .all: return "clock"
            case .favorites: return "star.fill"
            }
        }
    }

    // MARK: - Computed Properties

    private var filteredEntries: [CharacterQuizHistoryEntry] {
        switch selectedFilter {
        case .all:
            return entries
        case .favorites:
            return entries.filter { $0.isFavorite }
        }
    }

    private var groupedByUniverse: [String: [CharacterQuizHistoryEntry]] {
        Dictionary(grouping: filteredEntries) { $0.universeId }
    }

    private var sortedUniverseIds: [String] {
        groupedByUniverse.keys.sorted { lhs, rhs in
            // Sort by most recent entry in each universe
            guard let lhsDate = groupedByUniverse[lhs]?.first?.createdAt,
                  let rhsDate = groupedByUniverse[rhs]?.first?.createdAt else {
                return lhs < rhs
            }
            return lhsDate > rhsDate
        }
    }

    // MARK: - Body

    public var body: some View {
        VStack(spacing: 0) {
            // Filter picker
            filterPicker
                .padding()

            if filteredEntries.isEmpty {
                emptyState
            } else {
                historyList
            }
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .confirmationDialog(
            "Delete Result",
            isPresented: $showDeleteConfirmation,
            presenting: entryToDelete
        ) { entry in
            Button("Delete", role: .destructive) {
                onDelete(entry)
            }
            Button("Cancel", role: .cancel) {}
        } message: { entry in
            Text("Delete your \(entry.universeName) result as \(entry.topCharacterName)?")
        }
    }

    // MARK: - Filter Picker

    private var filterPicker: some View {
        HStack(spacing: 12) {
            ForEach(HistoryFilter.allCases, id: \.self) { filter in
                FilterButton(
                    title: filter.rawValue,
                    icon: filter.icon,
                    isSelected: selectedFilter == filter,
                    count: filter == .favorites ? entries.filter { $0.isFavorite }.count : entries.count
                ) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedFilter = filter
                    }
                }
            }
            Spacer()
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: selectedFilter == .favorites ? "star.slash" : "clock.badge.questionmark")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            Text(selectedFilter == .favorites ? "No Favorites Yet" : "No Results Yet")
                .font(.title3)
                .fontWeight(.semibold)

            Text(selectedFilter == .favorites
                 ? "Tap the star on any result to save it as a favorite."
                 : "Complete a character quiz to see your results here.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - History List

    private var historyList: some View {
        List {
            ForEach(sortedUniverseIds, id: \.self) { universeId in
                if let universeEntries = groupedByUniverse[universeId] {
                    Section {
                        ForEach(universeEntries) { entry in
                            HistoryEntryRow(
                                entry: entry,
                                universe: findUniverse(id: universeId),
                                onSelect: { onSelectEntry(entry) },
                                onToggleFavorite: { onToggleFavorite(entry) }
                            )
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    entryToDelete = entry
                                    showDeleteConfirmation = true
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                Button {
                                    onToggleFavorite(entry)
                                } label: {
                                    Label(
                                        entry.isFavorite ? "Unfavorite" : "Favorite",
                                        systemImage: entry.isFavorite ? "star.slash" : "star.fill"
                                    )
                                }
                                .tint(.yellow)
                            }
                        }
                    } header: {
                        universeHeader(universeId: universeId, entries: universeEntries)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    // MARK: - Universe Header

    private func universeHeader(universeId: String, entries: [CharacterQuizHistoryEntry]) -> some View {
        HStack {
            if let universe = findUniverse(id: universeId) {
                UniverseIcon(universe: universe, size: .small, style: .filled)
                Text(universe.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
            } else {
                Text(entries.first?.universeName ?? "Unknown")
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }

            Spacer()

            Text("\(entries.count) \(entries.count == 1 ? "result" : "results")")
                .font(.caption)
                .foregroundStyle(.secondary)

            // Re-analyze button
            Button {
                onReanalyze(universeId)
            } label: {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.caption)
                    .foregroundStyle(Color.accentColor)
            }
            .buttonStyle(.plain)
        }
        .textCase(nil)
    }

    // MARK: - Helpers

    private func findUniverse(id: String) -> FictionalUniverse? {
        FictionalUniverse.allUniverses.first { $0.id == id }
    }
}

// MARK: - Filter Button

private struct FilterButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let count: Int
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)

                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)

                if count > 0 {
                    Text("\(count)")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(isSelected ? Color.white.opacity(0.3) : Color(uiColor: .systemGray5))
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(isSelected ? Color.accentColor : Color(uiColor: .secondarySystemGroupedBackground))
            .foregroundStyle(isSelected ? .white : .primary)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - History Entry Row

private struct HistoryEntryRow: View {
    let entry: CharacterQuizHistoryEntry
    let universe: FictionalUniverse?
    let onSelect: () -> Void
    let onToggleFavorite: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                // Character avatar
                if let character = findTopCharacter() {
                    CharacterAvatar(character: character, size: .medium, style: .gradient)
                } else {
                    PlaceholderAvatar(size: .medium)
                }

                // Info
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(entry.topCharacterName)
                            .font(.headline)
                            .foregroundStyle(.primary)

                        if entry.isFavorite {
                            Image(systemName: "star.fill")
                                .font(.caption)
                                .foregroundStyle(.yellow)
                        }
                    }

                    HStack(spacing: 8) {
                        // Confidence
                        Text(entry.topMatchConfidence)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(confidenceColor)

                        Text("*")
                            .foregroundStyle(.tertiary)

                        // Date
                        Text(entry.relativeTimeString)
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Text("*")
                            .foregroundStyle(.tertiary)

                        // Entries analyzed
                        Text("\(entry.entryCountAtAnalysis) entries")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }

                Spacer()

                // Chevron
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }

    private var confidenceColor: Color {
        guard let confidence = entry.topMatch?.confidence else { return .gray }
        switch confidence {
        case 0.8...: return .green
        case 0.6..<0.8: return .blue
        case 0.4..<0.6: return .orange
        default: return .gray
        }
    }

    private func findTopCharacter() -> FictionalCharacter? {
        guard let universe = universe,
              let characterId = entry.topMatch?.characterId else {
            return nil
        }
        return universe.characters.first { $0.id == characterId }
    }
}

// MARK: - Previews

#Preview("History View") {
    let sampleEntries: [CharacterQuizHistoryEntry] = [
        CharacterQuizHistoryEntry(
            universeId: "lotr",
            universeName: "Lord of the Rings",
            result: CharacterMatchResult(
                matches: [
                    CharacterMatch(
                        characterId: "lotr-gandalf",
                        characterName: "Gandalf",
                        confidence: 0.87,
                        reasoning: "Your wisdom shines through..."
                    )
                ],
                universe: "Lord of the Rings",
                analysisSummary: "Based on 12 journal entries",
                generatedAt: Date()
            ),
            isFavorite: true,
            entryCountAtAnalysis: 12
        ),
        CharacterQuizHistoryEntry(
            universeId: "hp",
            universeName: "Harry Potter",
            result: CharacterMatchResult(
                matches: [
                    CharacterMatch(
                        characterId: "hp-hermione",
                        characterName: "Hermione Granger",
                        confidence: 0.91,
                        reasoning: "Your intellectual curiosity..."
                    )
                ],
                universe: "Harry Potter",
                analysisSummary: "Based on 8 journal entries",
                generatedAt: Date().addingTimeInterval(-86400)
            ),
            isFavorite: false,
            entryCountAtAnalysis: 8
        ),
        CharacterQuizHistoryEntry(
            universeId: "lotr",
            universeName: "Lord of the Rings",
            result: CharacterMatchResult(
                matches: [
                    CharacterMatch(
                        characterId: "lotr-aragorn",
                        characterName: "Aragorn",
                        confidence: 0.72,
                        reasoning: "Leadership qualities..."
                    )
                ],
                universe: "Lord of the Rings",
                analysisSummary: "Based on 5 journal entries",
                generatedAt: Date().addingTimeInterval(-604800)
            ),
            isFavorite: false,
            entryCountAtAnalysis: 5
        )
    ]

    NavigationStack {
        CharacterQuizHistoryView(
            entries: sampleEntries,
            onSelectEntry: { _ in },
            onToggleFavorite: { _ in },
            onDelete: { _ in },
            onReanalyze: { _ in }
        )
        .navigationTitle("My Results")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("Empty State") {
    NavigationStack {
        CharacterQuizHistoryView(
            entries: [],
            onSelectEntry: { _ in },
            onToggleFavorite: { _ in },
            onDelete: { _ in },
            onReanalyze: { _ in }
        )
        .navigationTitle("My Results")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("Dark Mode") {
    let sampleEntry = CharacterQuizHistoryEntry(
        universeId: "sw",
        universeName: "Star Wars",
        result: CharacterMatchResult(
            matches: [
                CharacterMatch(
                    characterId: "sw-yoda",
                    characterName: "Yoda",
                    confidence: 0.85,
                    reasoning: "Wisdom, you have..."
                )
            ],
            universe: "Star Wars",
            analysisSummary: "Based on 10 entries",
            generatedAt: Date()
        ),
        isFavorite: true,
        entryCountAtAnalysis: 10
    )

    NavigationStack {
        CharacterQuizHistoryView(
            entries: [sampleEntry],
            onSelectEntry: { _ in },
            onToggleFavorite: { _ in },
            onDelete: { _ in },
            onReanalyze: { _ in }
        )
        .navigationTitle("My Results")
        .navigationBarTitleDisplayMode(.inline)
    }
    .preferredColorScheme(.dark)
}
#endif
