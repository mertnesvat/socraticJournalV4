// CharacterQuizSection.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Section card for Character Quiz in the Self-Discovery tab
/// Shows quiz prompt and previous result if available
public struct CharacterQuizSection: View {
    let lastResult: CharacterQuizResult?
    let onTakeQuiz: () -> Void

    public init(lastResult: CharacterQuizResult?, onTakeQuiz: @escaping () -> Void) {
        self.lastResult = lastResult
        self.onTakeQuiz = onTakeQuiz
    }

    public var body: some View {
        Button(action: onTakeQuiz) {
            VStack(alignment: .leading, spacing: 16) {
                // Header with icon
                HStack {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color.indigo.opacity(0.15))
                                .frame(width: 44, height: 44)

                            Image(systemName: "theatermasks.fill")
                                .font(.title3)
                                .foregroundStyle(Color.indigo)
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Which Character Are You?")
                                .font(.headline)
                                .foregroundStyle(.primary)

                            Text("Personality quiz")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.tertiary)
                }

                // Description text
                Text("Discover which fictional character matches your personality based on your journal entries.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)

                // Last result or call to action
                if let result = lastResult, let topMatch = result.topMatch {
                    lastResultView(result: result, topMatch: topMatch)
                } else {
                    callToActionView
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(uiColor: .secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }

    private func lastResultView(result: CharacterQuizResult, topMatch: CharacterMatchEntry) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Divider()

            HStack(spacing: 12) {
                // Character result indicator
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.indigo.opacity(0.1))
                        .frame(width: 36, height: 36)

                    Image(systemName: result.franchise.iconName)
                        .font(.subheadline)
                        .foregroundStyle(Color.indigo)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Last result:")
                        .font(.caption)
                        .foregroundStyle(.tertiary)

                    HStack(spacing: 4) {
                        Text(topMatch.character.name)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(.primary)

                        Text("from \(result.franchise.displayName)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                // Confidence badge
                Text("\(topMatch.confidencePercentage)%")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.indigo)
                    )
            }

            // Time since analysis
            Text(result.timeSinceAnalysis)
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
    }

    private var callToActionView: some View {
        HStack {
            Image(systemName: "sparkles")
                .font(.subheadline)
            Text("Take Quiz")
                .font(.subheadline.weight(.medium))
        }
        .foregroundStyle(Color.indigo)
        .padding(.top, 4)
    }
}

#Preview {
    VStack(spacing: 16) {
        // Without previous result
        CharacterQuizSection(lastResult: nil) {
            print("Tapped - no previous result")
        }

        // With previous result
        CharacterQuizSection(
            lastResult: CharacterQuizResult(
                franchise: .lordOfTheRings,
                matches: [
                    CharacterMatchEntry(
                        character: FictionalCharacter.aragorn,
                        confidencePercentage: 78,
                        explanation: "Your leadership qualities shine through"
                    )
                ],
                journalEntriesUsed: 10
            )
        ) {
            print("Tapped - has previous result")
        }
    }
    .padding()
    .background(Color(uiColor: .systemGroupedBackground))
}
#endif
