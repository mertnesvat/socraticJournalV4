// CharacterResultCard.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

// MARK: - Card Size Variant

/// Size variants for the character result card based on ranking
public enum CharacterResultCardSize {
    /// Large hero card for #1 match (rank 1)
    case hero
    /// Medium featured card for #2-3 matches (ranks 2-3)
    case featured

    var avatarSize: CharacterAvatar.AvatarSize {
        switch self {
        case .hero: return .hero
        case .featured: return .large
        }
    }

    var titleFont: Font {
        switch self {
        case .hero: return .title
        case .featured: return .headline
        }
    }

    var confidenceBarHeight: CGFloat {
        switch self {
        case .hero: return 10
        case .featured: return 6
        }
    }

    var cardPadding: CGFloat {
        switch self {
        case .hero: return 24
        case .featured: return 16
        }
    }

    var cornerRadius: CGFloat {
        switch self {
        case .hero: return 24
        case .featured: return 16
        }
    }
}

// MARK: - Rank Indicator

/// Visual rank indicator (gold, silver, bronze)
private struct RankIndicator: View {
    let rank: Int

    private var medalColor: Color {
        switch rank {
        case 1: return Color(red: 1.0, green: 0.84, blue: 0.0) // Gold
        case 2: return Color(red: 0.75, green: 0.75, blue: 0.75) // Silver
        case 3: return Color(red: 0.80, green: 0.50, blue: 0.20) // Bronze
        default: return .gray
        }
    }

    private var medalIcon: String {
        switch rank {
        case 1: return "star.fill"
        case 2: return "star.fill"
        case 3: return "star.fill"
        default: return "circle.fill"
        }
    }

    private var rankLabel: String {
        switch rank {
        case 1: return "Top Match"
        case 2: return "2nd Match"
        case 3: return "3rd Match"
        default: return "#\(rank) Match"
        }
    }

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: medalIcon)
                .font(.system(size: rank == 1 ? 14 : 12, weight: .bold))
                .foregroundStyle(medalColor)
                .shadow(color: medalColor.opacity(0.5), radius: rank == 1 ? 4 : 2)

            Text(rankLabel)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(medalColor)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(medalColor.opacity(0.15))
        .clipShape(Capsule())
        .accessibilityLabel("Rank \(rank), \(rankLabel)")
    }
}

// MARK: - Animated Confidence Bar

/// Animated progress bar showing confidence percentage
private struct AnimatedConfidenceBar: View {
    let confidence: Double
    let color: Color
    let height: CGFloat
    let animated: Bool

    @State private var animatedProgress: CGFloat = 0

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background track
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(Color(uiColor: .tertiarySystemFill))

                // Animated progress fill
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(
                        LinearGradient(
                            colors: [color, color.opacity(0.7)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * animatedProgress)
                    .shadow(color: color.opacity(0.3), radius: 2, x: 0, y: 1)
            }
        }
        .frame(height: height)
        .onAppear {
            if animated {
                withAnimation(.easeOut(duration: 1.0).delay(0.3)) {
                    animatedProgress = confidence
                }
            } else {
                animatedProgress = confidence
            }
        }
        .onChange(of: confidence) { _, newValue in
            if animated {
                withAnimation(.easeOut(duration: 0.5)) {
                    animatedProgress = newValue
                }
            } else {
                animatedProgress = newValue
            }
        }
        .accessibilityHidden(true)
    }
}

// MARK: - Animated Percentage Counter

/// Animated percentage text that counts up
private struct AnimatedPercentage: View {
    let targetPercentage: Int
    let color: Color
    let animated: Bool

    @State private var displayedPercentage: Int = 0

    var body: some View {
        Text("\(displayedPercentage)%")
            .font(.system(size: 32, weight: .bold, design: .rounded))
            .foregroundStyle(color)
            .contentTransition(.numericText())
            .onAppear {
                if animated {
                    animateToTarget()
                } else {
                    displayedPercentage = targetPercentage
                }
            }
            .onChange(of: targetPercentage) { _, newValue in
                if animated {
                    withAnimation(.easeOut(duration: 0.5)) {
                        displayedPercentage = newValue
                    }
                } else {
                    displayedPercentage = newValue
                }
            }
            .accessibilityLabel("\(targetPercentage) percent confidence")
    }

    private func animateToTarget() {
        let steps = 20
        let stepDuration = 1.0 / Double(steps)
        let increment = targetPercentage / steps

        for step in 0...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(step) * stepDuration + 0.3) {
                withAnimation(.easeOut(duration: stepDuration)) {
                    displayedPercentage = min(step * increment + (step == steps ? targetPercentage % steps : 0), targetPercentage)
                    if step == steps {
                        displayedPercentage = targetPercentage
                    }
                }
            }
        }
    }
}

// MARK: - Expandable Reasoning Section

/// Collapsible section showing match reasoning with optional journal excerpts
private struct ExpandableReasoningSection: View {
    let reasoning: String
    let journalExcerpts: [JournalExcerpt]
    @Binding var isExpanded: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Toggle button
            Button {
                withAnimation(.easeInOut(duration: 0.25)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    Image(systemName: "quote.opening")
                        .foregroundStyle(.secondary)
                        .font(.subheadline)

                    Text("Why this match?")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .background(Color(uiColor: .tertiarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
            .accessibilityHint(isExpanded ? "Tap to collapse reasoning" : "Tap to expand reasoning")

            // Expanded content
            if isExpanded {
                VStack(alignment: .leading, spacing: 16) {
                    // Reasoning text
                    Text(reasoning)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)

                    // Journal excerpts if available
                    if !journalExcerpts.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack(spacing: 6) {
                                Image(systemName: "text.book.closed")
                                    .font(.caption)
                                    .foregroundStyle(.purple)

                                Text("Evidence from your journal")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.secondary)
                            }

                            ForEach(journalExcerpts.prefix(3)) { excerpt in
                                VStack(alignment: .leading, spacing: 6) {
                                    // Quote with accent bar
                                    HStack(alignment: .top, spacing: 10) {
                                        Rectangle()
                                            .fill(Color.purple.opacity(0.6))
                                            .frame(width: 3)

                                        Text("\"\(excerpt.text)\"")
                                            .font(.subheadline)
                                            .foregroundStyle(.primary)
                                            .italic()
                                            .lineSpacing(2)
                                    }

                                    // Relevance explanation
                                    Text(excerpt.relevance)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .padding(.leading, 13)
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(Color.purple.opacity(0.05))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                    }
                }
                .padding()
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
}

// MARK: - Character Result Card

/// A visually engaging component to display individual character match results
/// with confidence level and reasoning explanation.
///
/// Usage:
/// ```swift
/// CharacterResultCard(
///     match: characterMatch,
///     character: fictionalCharacter,
///     universe: fictionalUniverse,
///     rank: 1,
///     journalExcerpts: ["Example excerpt..."],
///     animated: true
/// )
/// ```
public struct CharacterResultCard: View {
    // MARK: - Properties

    /// The character match data with confidence and reasoning
    let match: CharacterMatch

    /// The full character entity (optional, for displaying additional info)
    let character: FictionalCharacter?

    /// The universe the character belongs to
    let universe: FictionalUniverse

    /// The rank of this match (1, 2, or 3)
    let rank: Int

    /// Optional journal excerpts that contributed to the match
    let journalExcerpts: [JournalExcerpt]

    /// Whether to animate the reveal (confidence bar, percentage)
    let animated: Bool

    /// Size variant based on rank
    private var size: CharacterResultCardSize {
        rank == 1 ? .hero : .featured
    }

    // MARK: - State

    @State private var isReasoningExpanded: Bool = false
    @State private var hasAppeared: Bool = false

    // MARK: - Computed Properties

    private var confidenceColor: Color {
        switch match.confidence {
        case 0.8...: return .green
        case 0.6..<0.8: return .blue
        case 0.4..<0.6: return .orange
        default: return .gray
        }
    }

    private var confidencePercentage: Int {
        Int(match.confidence * 100)
    }

    // MARK: - Initialization

    /// Creates a new CharacterResultCard
    /// - Parameters:
    ///   - match: The character match data
    ///   - character: The full character entity (optional)
    ///   - universe: The universe the character belongs to
    ///   - rank: The rank of this match (1, 2, or 3)
    ///   - journalExcerpts: Optional journal excerpts (defaults to match.excerpts)
    ///   - animated: Whether to animate the reveal
    public init(
        match: CharacterMatch,
        character: FictionalCharacter? = nil,
        universe: FictionalUniverse,
        rank: Int,
        journalExcerpts: [JournalExcerpt]? = nil,
        animated: Bool = true
    ) {
        self.match = match
        self.character = character
        self.universe = universe
        self.rank = rank
        self.journalExcerpts = journalExcerpts ?? match.excerpts
        self.animated = animated
    }

    // MARK: - Body

    public var body: some View {
        VStack(spacing: size == .hero ? 20 : 16) {
            // Rank indicator
            HStack {
                RankIndicator(rank: rank)
                Spacer()
                UniverseBadge(universe: universe)
            }

            // Character avatar and name
            characterHeader

            // Confidence display
            confidenceSection

            // Character description (hero only)
            if size == .hero, let character = character {
                Text(character.description)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
                    .padding(.horizontal)
            }

            // Expandable reasoning
            ExpandableReasoningSection(
                reasoning: match.reasoning,
                journalExcerpts: journalExcerpts,
                isExpanded: $isReasoningExpanded
            )
        }
        .padding(size.cardPadding)
        .background(Color(uiColor: .systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: size.cornerRadius))
        .shadow(
            color: .black.opacity(size == .hero ? 0.1 : 0.06),
            radius: size == .hero ? 16 : 8,
            x: 0,
            y: size == .hero ? 6 : 3
        )
        .opacity(hasAppeared ? 1 : 0)
        .offset(y: hasAppeared ? 0 : 20)
        .onAppear {
            if animated {
                withAnimation(.easeOut(duration: 0.4).delay(Double(rank - 1) * 0.15)) {
                    hasAppeared = true
                }
            } else {
                hasAppeared = true
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(accessibilityDescription)
    }

    // MARK: - Subviews

    private var characterHeader: some View {
        VStack(spacing: size == .hero ? 16 : 12) {
            // Avatar
            if let character = character {
                CharacterAvatar(
                    character: character,
                    size: size.avatarSize,
                    style: .gradient
                )
            } else {
                PlaceholderAvatar(size: size.avatarSize)
            }

            // Character name
            Text(match.characterName)
                .font(size.titleFont)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
        }
    }

    private var confidenceSection: some View {
        VStack(spacing: 12) {
            // Animated percentage
            AnimatedPercentage(
                targetPercentage: confidencePercentage,
                color: confidenceColor,
                animated: animated
            )

            // Animated confidence bar
            AnimatedConfidenceBar(
                confidence: match.confidence,
                color: confidenceColor,
                height: size.confidenceBarHeight,
                animated: animated
            )
            .padding(.horizontal, size == .hero ? 40 : 20)

            // Confidence label
            Text(match.confidenceLabel)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(confidenceColor)
        }
    }

    // MARK: - Accessibility

    private var accessibilityDescription: String {
        var description = "Rank \(rank) match: \(match.characterName) from \(universe.name). "
        description += "\(confidencePercentage) percent confidence. "
        description += "\(match.confidenceLabel). "

        if let character = character {
            description += character.description
        }

        return description
    }
}

// MARK: - Reveal Animation Modifier

/// A modifier that adds staggered reveal animation to cards
public struct CharacterCardRevealModifier: ViewModifier {
    let index: Int
    let isRevealed: Bool

    public func body(content: Content) -> some View {
        content
            .opacity(isRevealed ? 1 : 0)
            .offset(y: isRevealed ? 0 : 30)
            .scaleEffect(isRevealed ? 1 : 0.95)
            .animation(
                .spring(response: 0.5, dampingFraction: 0.8)
                    .delay(Double(index) * 0.2),
                value: isRevealed
            )
    }
}

public extension View {
    /// Applies a staggered reveal animation based on index
    /// - Parameters:
    ///   - index: The index of the card for stagger timing
    ///   - isRevealed: Whether the card should be revealed
    func characterCardReveal(index: Int, isRevealed: Bool) -> some View {
        modifier(CharacterCardRevealModifier(index: index, isRevealed: isRevealed))
    }
}

// MARK: - Previews

#Preview("Hero Card - Top Match") {
    let mockMatch = CharacterMatch(
        characterId: "lotr-gandalf",
        characterName: "Gandalf",
        confidence: 0.87,
        reasoning: "Your journal entries reveal a deep wisdom and thoughtful approach to life's challenges. Like Gandalf, you guide others with patience and see the potential in those around you. You often reflect on the bigger picture while remaining grounded in practical wisdom.",
        excerpts: [
            JournalExcerpt(
                text: "Today I helped a colleague see a problem from a new perspective",
                relevance: "Shows your natural inclination to guide and mentor others"
            ),
            JournalExcerpt(
                text: "I find myself thinking about how small actions can lead to big changes",
                relevance: "Reflects Gandalf's belief in the power of small acts of kindness"
            )
        ]
    )

    let character = FictionalUniverse.lordOfTheRings.characters.first { $0.id == "lotr-gandalf" }

    ScrollView {
        CharacterResultCard(
            match: mockMatch,
            character: character,
            universe: .lordOfTheRings,
            rank: 1,
            animated: true
        )
        .padding()
    }
    .background(Color(uiColor: .systemGroupedBackground))
}

#Preview("Featured Cards - 2nd & 3rd Match") {
    let mockMatches = [
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
    ]

    let universe = FictionalUniverse.lordOfTheRings

    ScrollView {
        VStack(spacing: 16) {
            ForEach(Array(mockMatches.enumerated()), id: \.element.id) { index, match in
                let character = universe.characters.first { $0.id == match.characterId }

                CharacterResultCard(
                    match: match,
                    character: character,
                    universe: universe,
                    rank: index + 2,
                    animated: true
                )
            }
        }
        .padding()
    }
    .background(Color(uiColor: .systemGroupedBackground))
}

#Preview("All Three Matches") {
    let mockMatches = [
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
        ),
        CharacterMatch(
            characterId: "hp-neville",
            characterName: "Neville Longbottom",
            confidence: 0.45,
            reasoning: "Your growth mindset and quiet determination echo Neville's journey of self-discovery."
        )
    ]

    let universe = FictionalUniverse.harryPotter

    ScrollView {
        VStack(spacing: 20) {
            ForEach(Array(mockMatches.enumerated()), id: \.element.id) { index, match in
                let character = universe.characters.first { $0.id == match.characterId }

                CharacterResultCard(
                    match: match,
                    character: character,
                    universe: universe,
                    rank: index + 1,
                    animated: true
                )
            }
        }
        .padding()
    }
    .background(Color(uiColor: .systemGroupedBackground))
}

#Preview("Dark Mode") {
    let mockMatch = CharacterMatch(
        characterId: "sw-yoda",
        characterName: "Yoda",
        confidence: 0.84,
        reasoning: "Your reflective nature and appreciation for patience in growth reflect Yoda's ancient wisdom. 'Do or do not, there is no try' - your entries show this determined mindset.",
        excerpts: [
            JournalExcerpt(
                text: "Patience is something I've been working on lately",
                relevance: "Demonstrates your commitment to personal growth through patience"
            )
        ]
    )

    let character = FictionalUniverse.starWars.characters.first { $0.id == "sw-yoda" }

    ScrollView {
        CharacterResultCard(
            match: mockMatch,
            character: character,
            universe: .starWars,
            rank: 1,
            animated: false
        )
        .padding()
    }
    .background(Color(uiColor: .systemGroupedBackground))
    .preferredColorScheme(.dark)
}

#Preview("Without Character Entity") {
    let mockMatch = CharacterMatch(
        characterId: "unknown-character",
        characterName: "Mystery Character",
        confidence: 0.65,
        reasoning: "An unexpected match based on your unique personality traits."
    )

    ScrollView {
        CharacterResultCard(
            match: mockMatch,
            character: nil,
            universe: .marvel,
            rank: 2,
            animated: true
        )
        .padding()
    }
    .background(Color(uiColor: .systemGroupedBackground))
}

#Preview("Reveal Animation") {
    struct RevealDemo: View {
        @State private var isRevealed = false

        var body: some View {
            ScrollView {
                VStack(spacing: 16) {
                    Button("Toggle Reveal") {
                        withAnimation {
                            isRevealed.toggle()
                        }
                    }
                    .buttonStyle(.borderedProminent)

                    ForEach(0..<3) { index in
                        CharacterResultCard(
                            match: CharacterMatch(
                                characterId: "test-\(index)",
                                characterName: "Character \(index + 1)",
                                confidence: 0.9 - Double(index) * 0.15,
                                reasoning: "Test reasoning for character \(index + 1)"
                            ),
                            character: nil,
                            universe: .gameOfThrones,
                            rank: index + 1,
                            animated: false
                        )
                        .characterCardReveal(index: index, isRevealed: isRevealed)
                    }
                }
                .padding()
            }
            .background(Color(uiColor: .systemGroupedBackground))
        }
    }

    return RevealDemo()
}
#endif
