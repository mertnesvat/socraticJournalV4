// AwardsBadgeView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Horizontal scroll of achievement badge cards for spicy take awards
struct AwardsBadgeView: View {
    let awards: [SpicyTakeAward]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Awards")
                .font(.headline)

            if awards.isEmpty {
                emptyState
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(awards) { award in
                            awardBadge(award)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Subviews

    private func awardBadge(_ award: SpicyTakeAward) -> some View {
        VStack(spacing: 8) {
            Text(award.category.emoji)
                .font(.system(size: 32))

            Text(award.category.displayTitle)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)

            Text("Week \(award.weekNumber)")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(12)
        .frame(width: 120, height: 110)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(award.category.backgroundColor.opacity(0.15))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(award.category.backgroundColor.opacity(0.3), lineWidth: 1)
        )
    }

    private var emptyState: some View {
        HStack {
            Spacer()
            VStack(spacing: 6) {
                Image(systemName: "trophy")
                    .font(.title2)
                    .foregroundStyle(.secondary)
                Text("No awards yet")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("Keep sharing your takes!")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding(.vertical, 12)
            Spacer()
        }
    }
}

// MARK: - SpicyTakeCategory Display Extensions

extension SpicyTakeCategory {
    var emoji: String {
        switch self {
        case .mostControversial: return "💥"
        case .mostPassionate: return "🔥"
        case .mostSurprising: return "😱"
        }
    }

    var displayTitle: String {
        switch self {
        case .mostControversial: return "Most Controversial"
        case .mostPassionate: return "Most Passionate"
        case .mostSurprising: return "Most Surprising"
        }
    }

    var backgroundColor: Color {
        switch self {
        case .mostControversial: return .red
        case .mostPassionate: return .orange
        case .mostSurprising: return .purple
        }
    }
}

#Preview {
    AwardsBadgeView(awards: MockDataProvider.awards)
        .padding()
        .background(Color(uiColor: .systemGroupedBackground))
}
#endif
