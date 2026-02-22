// ShareCardView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// The rendered opinion card designed for sharing to social media (1080x1920 for Stories)
/// Works both as a displayable preview and as a renderable card via ImageRenderer
public struct ShareCardView: View {
    public let variant: ShareCardVariant
    public let questionText: String
    public let userName: String
    public let friendName: String?
    public let category: QuestionCategory

    /// Pre-generated waveform levels for the decorative static waveform
    private let waveformLevels: [Float] = {
        // Deterministic decorative waveform pattern
        (0..<40).map { index in
            let normalized = Float(index) / 40.0
            let wave1 = sin(normalized * .pi * 3) * 0.3
            let wave2 = sin(normalized * .pi * 5 + 1.2) * 0.2
            return max(0.1, min(0.9, 0.4 + wave1 + wave2))
        }
    }()

    public init(
        variant: ShareCardVariant,
        questionText: String,
        userName: String,
        friendName: String? = nil,
        category: QuestionCategory
    ) {
        self.variant = variant
        self.questionText = questionText
        self.userName = userName
        self.friendName = friendName
        self.category = category
    }

    public var body: some View {
        ZStack {
            // Dark gradient background
            LinearGradient(
                colors: variant.gradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 160)

                // Category badge
                categoryBadge
                    .padding(.bottom, 48)

                // Question text
                Text(questionText)
                    .font(.system(size: 72, weight: .bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .lineSpacing(8)
                    .padding(.horizontal, 80)

                Spacer()
                    .frame(height: 80)

                // Decorative waveform
                AudioWaveformView(
                    levels: waveformLevels,
                    mode: .staticWaveform,
                    barCount: 40,
                    barColor: .white.opacity(0.25),
                    activeColor: .white.opacity(0.6),
                    barSpacing: 6,
                    cornerRadius: 3,
                    progress: 0.65
                )
                .frame(width: 800, height: 120)

                Spacer()
                    .frame(height: 80)

                // User info area (variant-specific)
                variantUserInfo
                    .padding(.horizontal, 80)

                Spacer()

                // App branding at bottom
                brandingFooter
                    .padding(.bottom, 120)
            }
        }
        .clipped()
    }

    // MARK: - Category Badge

    private var categoryBadge: some View {
        Text(category.displayName)
            .font(.system(size: 32, weight: .semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 32)
            .padding(.vertical, 14)
            .background(
                Capsule()
                    .fill(categoryColor.opacity(0.7))
            )
    }

    // MARK: - Variant User Info

    @ViewBuilder
    private var variantUserInfo: some View {
        switch variant {
        case .myTake:
            myTakeInfo
        case .hotTake:
            hotTakeInfo
        case .weDisagree:
            weDisagreeInfo
        case .guessWho:
            guessWhoInfo
        }
    }

    private var myTakeInfo: some View {
        VStack(spacing: 20) {
            Text("My Take")
                .font(.system(size: 36, weight: .bold))
                .foregroundStyle(.white.opacity(0.9))

            HStack(spacing: 16) {
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(.white.opacity(0.7))

                Text(userName)
                    .font(.system(size: 40, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.8))
            }
        }
    }

    private var hotTakeInfo: some View {
        VStack(spacing: 20) {
            Text("Hot Take Alert")
                .font(.system(size: 36, weight: .bold))
                .foregroundStyle(.white.opacity(0.9))

            Text(userName)
                .font(.system(size: 40, weight: .semibold))
                .foregroundStyle(.white.opacity(0.8))
        }
    }

    private var weDisagreeInfo: some View {
        VStack(spacing: 20) {
            Text("We Disagree")
                .font(.system(size: 36, weight: .bold))
                .foregroundStyle(.white.opacity(0.9))

            HStack(spacing: 24) {
                VStack(spacing: 8) {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(.white.opacity(0.7))
                    Text(userName)
                        .font(.system(size: 28, weight: .medium))
                        .foregroundStyle(.white.opacity(0.8))
                }

                Text("vs")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(.white.opacity(0.5))

                VStack(spacing: 8) {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(.white.opacity(0.7))
                    Text(friendName ?? "Friend")
                        .font(.system(size: 28, weight: .medium))
                        .foregroundStyle(.white.opacity(0.8))
                }
            }
        }
    }

    private var guessWhoInfo: some View {
        VStack(spacing: 20) {
            Text("Guess Who Said This")
                .font(.system(size: 36, weight: .bold))
                .foregroundStyle(.white.opacity(0.9))

            HStack(spacing: 16) {
                Image(systemName: "questionmark.circle.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(.white.opacity(0.5))

                Text("Mystery")
                    .font(.system(size: 40, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.6))
            }
        }
    }

    // MARK: - Branding Footer

    private var brandingFooter: some View {
        VStack(spacing: 12) {
            Text("Socratic")
                .font(.system(size: 40, weight: .bold))
                .foregroundStyle(.white.opacity(0.6))

            Text("Hear the full answer in the app")
                .font(.system(size: 28))
                .foregroundStyle(.white.opacity(0.35))
        }
    }

    // MARK: - Helpers

    private var categoryColor: Color {
        switch category.colorHint {
        case "blue": return .blue
        case "teal": return .teal
        case "orange": return .orange
        case "purple": return .purple
        case "red": return .red
        default: return .accentColor
        }
    }
}

// MARK: - Preview

#Preview("My Take") {
    ShareCardView(
        variant: .myTake,
        questionText: "Is social media making us more or less connected?",
        userName: "Alex",
        category: .debateTrigger
    )
    .frame(width: 360, height: 640)
    .scaleEffect(0.33)
    .frame(width: 120, height: 212)
}
#endif
