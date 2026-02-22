// GuessWhoCard.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Anonymous "guess who" share card variant.
/// Hides the friend's identity behind a mystery persona with blurred waveform
/// to create intrigue and drive engagement.
public struct GuessWhoCard: View {
    /// The question text displayed on the card
    let question: String

    /// Waveform amplitude data (rendered with blur for mystery effect)
    let amplitudes: [Float]

    /// Visual style for the card background
    let style: ShareCardStyle

    /// Card dimensions
    private let cardWidth: CGFloat = 1080
    private let cardHeight: CGFloat = 1080

    public init(
        question: String,
        amplitudes: [Float],
        style: ShareCardStyle
    ) {
        self.question = question
        self.amplitudes = amplitudes
        self.style = style
    }

    public var body: some View {
        ZStack {
            // Gradient background
            style.gradient
                .ignoresSafeArea()

            // Subtle pattern overlay for depth
            patternOverlay

            // Card content
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 80)

                // Mystery badge
                mysteryBadge

                Spacer()
                    .frame(height: 48)

                // Question text
                Text(question)
                    .font(.system(size: 24, weight: .bold, design: .default))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .padding(.horizontal, 32)

                Spacer()
                    .frame(height: 48)

                // Blurred waveform for mystery effect
                ShareCardWaveform(
                    amplitudes: amplitudes,
                    barCount: 25,
                    barColor: .white
                )
                .blur(radius: 6)
                .padding(.horizontal, 32)

                Spacer()
                    .frame(height: 32)

                // "Guess who said this?" text
                Text("Guess who said this?")
                    .font(.system(size: 20, weight: .semibold, design: .default))
                    .foregroundStyle(.white.opacity(0.9))

                Spacer()

                // CTA and branding
                ctaSection
            }
            .padding(32)
        }
        .frame(width: cardWidth, height: cardHeight)
        .clipped()
    }

    // MARK: - Subviews

    private var mysteryBadge: some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(0.15))
                .frame(width: 80, height: 80)

            Circle()
                .strokeBorder(Color.white.opacity(0.3), lineWidth: 2)
                .frame(width: 80, height: 80)

            Text("?")
                .font(.system(size: 40, weight: .black, design: .rounded))
                .foregroundStyle(.white)
        }
    }

    private var patternOverlay: some View {
        // Radial gradient overlay for depth
        RadialGradient(
            gradient: Gradient(colors: [
                Color.white.opacity(0.06),
                Color.clear
            ]),
            center: .center,
            startRadius: 100,
            endRadius: 500
        )
    }

    private var ctaSection: some View {
        VStack(spacing: 12) {
            Text("Hear the answer on Socratic")
                .font(.system(size: 14, weight: .medium, design: .default))
                .foregroundStyle(.white.opacity(0.6))

            Text("Socratic")
                .font(.system(size: 16, weight: .bold, design: .default))
                .foregroundStyle(.white.opacity(0.5))
        }
    }
}

// MARK: - Story Variant

extension GuessWhoCard {
    /// Creates a story-sized (9:16) version of the guess who card
    public static func storyVariant(
        question: String,
        amplitudes: [Float],
        style: ShareCardStyle
    ) -> some View {
        GuessWhoCard(
            question: question,
            amplitudes: amplitudes,
            style: style
        )
        .frame(width: 1080, height: 1920)
    }
}

// MARK: - Preview

#Preview("Electric Blue") {
    GuessWhoCard(
        question: "Could you forgive cheating if everything else was perfect?",
        amplitudes: [0.3, 0.6, 0.9, 0.4, 0.7, 0.5, 0.8, 0.3, 0.6, 0.4],
        style: .electricBlue
    )
    .scaleEffect(0.35)
}

#Preview("Hot Coral") {
    GuessWhoCard(
        question: "What's the biggest lie you tell yourself?",
        amplitudes: [0.5, 0.8, 0.3, 0.7, 0.6, 0.9, 0.4, 0.5, 0.7, 0.3],
        style: .hotCoral
    )
    .scaleEffect(0.35)
}
#endif
