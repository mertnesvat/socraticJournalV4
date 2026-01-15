// TraitCardView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Displays detailed information about a single personality trait
struct TraitCardView: View {
    let trait: PersonalityTrait
    let onDismiss: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header with score
                    headerSection

                    Divider()

                    // Description
                    descriptionSection

                    // Evidence quotes
                    if !trait.evidence.isEmpty {
                        evidenceSection
                    }

                    // About this trait
                    aboutSection
                }
                .padding()
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle(trait.type.shortName)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        onDismiss()
                    }
                }
            }
        }
    }

    private var headerSection: some View {
        HStack(spacing: 16) {
            // Score ring
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 8)

                Circle()
                    .trim(from: 0, to: CGFloat(trait.score) / 100.0)
                    .stroke(scoreColor, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 0) {
                    Text("\(trait.score)")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(scoreColor)
                }
            }
            .frame(width: 100, height: 100)

            VStack(alignment: .leading, spacing: 8) {
                Text(trait.emoji)
                    .font(.title)

                Text(trait.type.displayName)
                    .font(.headline)

                Text(trait.label)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(scoreColor)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(scoreColor.opacity(0.15))
                    .clipShape(Capsule())
            }

            Spacer()
        }
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your Profile")
                .font(.headline)

            Text(trait.description)
                .font(.body)
                .foregroundStyle(.secondary)
                .lineSpacing(4)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var evidenceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "quote.opening")
                    .foregroundStyle(.secondary)
                Text("From Your Journal")
                    .font(.headline)
            }

            ForEach(trait.evidence.indices, id: \.self) { index in
                EvidenceQuoteView(quote: trait.evidence[index])
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "info.circle")
                    .foregroundStyle(.secondary)
                Text("About This Trait")
                    .font(.headline)
            }

            Text(trait.type.briefDescription)
                .font(.body)
                .foregroundStyle(.secondary)
                .lineSpacing(4)

            // Score interpretation
            VStack(alignment: .leading, spacing: 8) {
                Text("Score Interpretation")
                    .font(.subheadline)
                    .fontWeight(.medium)

                VStack(spacing: 4) {
                    scoreRow(range: "70-100", label: "High", highlight: trait.score >= 70)
                    scoreRow(range: "55-69", label: "Moderately High", highlight: trait.score >= 55 && trait.score < 70)
                    scoreRow(range: "45-54", label: "Moderate", highlight: trait.score >= 45 && trait.score < 55)
                    scoreRow(range: "30-44", label: "Moderately Low", highlight: trait.score >= 30 && trait.score < 45)
                    scoreRow(range: "0-29", label: "Low", highlight: trait.score < 30)
                }
            }
            .padding(.top, 8)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func scoreRow(range: String, label: String, highlight: Bool) -> some View {
        HStack {
            Text(range)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 50, alignment: .leading)

            Text(label)
                .font(.caption)
                .foregroundStyle(highlight ? scoreColor : .secondary)
                .fontWeight(highlight ? .semibold : .regular)

            Spacer()

            if highlight {
                Image(systemName: "arrow.left")
                    .font(.caption2)
                    .foregroundStyle(scoreColor)
                Text("You")
                    .font(.caption2)
                    .foregroundStyle(scoreColor)
                    .fontWeight(.semibold)
            }
        }
    }

    private var scoreColor: Color {
        switch trait.score {
        case 0..<40: return .red.opacity(0.8)
        case 40..<60: return .orange
        default: return .green
        }
    }
}

#Preview {
    TraitCardView(
        trait: PersonalityTrait(
            type: .openness,
            score: 72,
            label: "High",
            description: "You show strong intellectual curiosity and openness to new experiences. Your journal entries reveal a mind that enjoys exploring ideas and questioning assumptions.",
            evidence: [
                "\"I've been thinking about trying something completely different...\"",
                "\"What if I looked at this from another perspective?\""
            ]
        ),
        onDismiss: {}
    )
}
#endif
