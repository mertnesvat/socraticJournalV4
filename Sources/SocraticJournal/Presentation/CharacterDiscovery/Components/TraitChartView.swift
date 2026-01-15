// TraitChartView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Displays a visual chart of all Big Five traits
struct TraitChartView: View {
    let profile: BigFiveProfile
    let onTraitTap: (PersonalityTrait) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Personality Profile")
                .font(.headline)

            // Bar chart representation
            VStack(spacing: 12) {
                ForEach(profile.allTraits, id: \.type) { trait in
                    TraitBarView(trait: trait)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            onTraitTap(trait)
                        }
                }
            }

            // Legend
            HStack(spacing: 16) {
                legendItem(color: .red.opacity(0.7), label: "Low")
                legendItem(color: .orange.opacity(0.7), label: "Moderate")
                legendItem(color: .green.opacity(0.7), label: "High")
            }
            .font(.caption2)
            .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(label)
        }
    }
}

/// Individual trait bar in the chart
struct TraitBarView: View {
    let trait: PersonalityTrait

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(trait.emoji)
                Text(trait.type.shortName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                Text("\(trait.score)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(barColor)
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))

                    // Fill
                    RoundedRectangle(cornerRadius: 4)
                        .fill(barColor)
                        .frame(width: geometry.size.width * CGFloat(trait.score) / 100.0)
                }
            }
            .frame(height: 8)
        }
        .padding(.vertical, 4)
    }

    private var barColor: Color {
        switch trait.score {
        case 0..<40: return .red.opacity(0.7)
        case 40..<60: return .orange.opacity(0.7)
        default: return .green.opacity(0.7)
        }
    }
}

#Preview {
    TraitChartView(
        profile: BigFiveProfile(
            openness: PersonalityTrait(type: .openness, score: 72, label: "High", description: "", evidence: []),
            conscientiousness: PersonalityTrait(type: .conscientiousness, score: 58, label: "Moderate", description: "", evidence: []),
            extraversion: PersonalityTrait(type: .extraversion, score: 45, label: "Moderate", description: "", evidence: []),
            agreeableness: PersonalityTrait(type: .agreeableness, score: 68, label: "Moderately High", description: "", evidence: []),
            neuroticism: PersonalityTrait(type: .neuroticism, score: 35, label: "Moderately Low", description: "", evidence: []),
            summary: "Sample summary",
            analyzedAt: Date()
        ),
        onTraitTap: { _ in }
    )
    .padding()
}
#endif
