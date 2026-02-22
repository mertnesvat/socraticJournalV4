// ShareCardView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// The shareable card view that renders as a premium social media image.
/// Designed to look "share-worthy" with bold gradients, large question text,
/// a decorative waveform, and app branding.
///
/// Supports two aspect ratios:
/// - Square (1:1) at 1080x1080 for Instagram feed posts
/// - Story (9:16) at 1080x1920 for Instagram/TikTok stories
public struct ShareCardView: View {
    /// The question text displayed prominently on the card
    let question: String

    /// The friend's display name, or nil for anonymous mode
    let friendName: String?

    /// Waveform amplitude data for the decorative visualization
    let amplitudes: [Float]

    /// Visual style controlling gradient and accent colors
    let style: ShareCardStyle

    /// Whether this card uses the anonymous "guess who" display
    let isAnonymous: Bool

    /// Card dimensions (default: square 1080x1080)
    private let cardWidth: CGFloat = 1080
    private let cardHeight: CGFloat = 1080

    public init(
        question: String,
        friendName: String?,
        amplitudes: [Float],
        style: ShareCardStyle,
        isAnonymous: Bool = false
    ) {
        self.question = question
        self.friendName = friendName
        self.amplitudes = amplitudes
        self.style = style
        self.isAnonymous = isAnonymous
    }

    public var body: some View {
        ZStack {
            // Gradient background
            style.gradient
                .ignoresSafeArea()

            // Subtle radial overlay for depth
            depthOverlay

            // Card content
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 80)

                // App branding in top corner
                brandingHeader

                Spacer()
                    .frame(height: 64)

                // Question text -- the hero element
                questionText

                Spacer()
                    .frame(height: 56)

                // Static waveform visualization
                ShareCardWaveform(
                    amplitudes: amplitudes,
                    barCount: 25,
                    barColor: .white
                )
                .padding(.horizontal, 32)

                Spacer()
                    .frame(height: 40)

                // Friend name or anonymous indicator
                nameDisplay

                Spacer()

                // CTA at bottom
                ctaFooter
            }
            .padding(32)
        }
        .frame(width: cardWidth, height: cardHeight)
        .clipped()
    }

    // MARK: - Subviews

    private var depthOverlay: some View {
        RadialGradient(
            gradient: Gradient(colors: [
                Color.white.opacity(0.05),
                Color.clear
            ]),
            center: .top,
            startRadius: 50,
            endRadius: 600
        )
    }

    private var brandingHeader: some View {
        HStack {
            Spacer()
            Text("Socratic")
                .font(.system(size: 18, weight: .bold, design: .default))
                .foregroundStyle(.white.opacity(0.5))
        }
    }

    private var questionText: some View {
        Text(question)
            .font(.system(size: 24, weight: .bold, design: .default))
            .foregroundStyle(.white)
            .multilineTextAlignment(.center)
            .lineSpacing(6)
            .padding(.horizontal, 32)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var nameDisplay: some View {
        Group {
            if isAnonymous {
                HStack(spacing: 8) {
                    Image(systemName: "person.fill.questionmark")
                        .font(.system(size: 16))
                    Text("Anonymous")
                        .font(.system(size: 16, weight: .semibold, design: .default))
                }
                .foregroundStyle(.white.opacity(0.7))
            } else if let name = friendName, !name.isEmpty {
                HStack(spacing: 8) {
                    Circle()
                        .fill(style.accentColor.opacity(0.5))
                        .frame(width: 28, height: 28)
                        .overlay(
                            Text(String(name.prefix(1)).uppercased())
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(.white)
                        )
                    Text(name)
                        .font(.system(size: 16, weight: .semibold, design: .default))
                        .foregroundStyle(.white.opacity(0.8))
                }
            }
        }
    }

    private var ctaFooter: some View {
        VStack(spacing: 8) {
            Text("Hear the answer on Socratic")
                .font(.system(size: 14, weight: .medium, design: .default))
                .foregroundStyle(.white.opacity(0.6))

            // Subtle divider
            Rectangle()
                .fill(Color.white.opacity(0.15))
                .frame(width: 40, height: 2)
        }
        .padding(.bottom, 16)
    }
}

// MARK: - Story Variant

extension ShareCardView {
    /// Creates a story-sized (9:16) variant of the share card at 1080x1920
    public static func storyVariant(
        question: String,
        friendName: String?,
        amplitudes: [Float],
        style: ShareCardStyle,
        isAnonymous: Bool = false
    ) -> some View {
        ShareCardView(
            question: question,
            friendName: friendName,
            amplitudes: amplitudes,
            style: style,
            isAnonymous: isAnonymous
        )
        .frame(width: 1080, height: 1920)
    }
}

// MARK: - Preview

#Preview("Electric Blue - Named") {
    ShareCardView(
        question: "Could you forgive cheating if everything else was perfect?",
        friendName: "Sarah",
        amplitudes: [0.3, 0.6, 0.9, 0.4, 0.7, 0.5, 0.8, 0.3, 0.6, 0.4],
        style: .electricBlue
    )
    .scaleEffect(0.35)
}

#Preview("Hot Coral - Anonymous") {
    ShareCardView(
        question: "What's the biggest lie you tell yourself?",
        friendName: nil,
        amplitudes: [0.5, 0.8, 0.3, 0.7, 0.6, 0.9, 0.4, 0.5, 0.7, 0.3],
        style: .hotCoral,
        isAnonymous: true
    )
    .scaleEffect(0.35)
}

#Preview("Midnight Purple - Named") {
    ShareCardView(
        question: "Is it ever okay to go through your partner's phone?",
        friendName: "Marcus",
        amplitudes: [0.4, 0.7, 0.5, 0.8, 0.3, 0.6, 0.9, 0.4, 0.5, 0.7],
        style: .midnightPurple
    )
    .scaleEffect(0.35)
}
#endif
