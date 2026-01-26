// CharacterAvatar.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

// MARK: - Character Icon Configuration

/// SF Symbol mapping for fictional characters using abstract representations
/// These are abstract/archetypal symbols to avoid licensing issues
public extension FictionalCharacter {
    /// Returns an abstract SF Symbol that represents this character's archetype
    var sfSymbol: String {
        // Map based on character ID for consistent results
        // Using archetypal symbols rather than literal representations
        switch id {
        // LOTR Characters
        case "lotr-frodo":
            return "circle.dotted"  // Ring bearer - burden/responsibility
        case "lotr-aragorn":
            return "crown"  // King
        case "lotr-gandalf":
            return "wand.and.rays"  // Wizard
        case "lotr-legolas":
            return "arrow.up.right"  // Archer
        case "lotr-gimli":
            return "hammer.fill"  // Dwarf warrior
        case "lotr-boromir":
            return "shield.lefthalf.filled"  // Fallen warrior
        case "lotr-sam":
            return "leaf.fill"  // Gardener/loyal friend
        case "lotr-gollum":
            return "eye"  // Obsession/watching
        case "lotr-eowyn":
            return "figure.fencing"  // Warrior
        case "lotr-faramir":
            return "book.closed"  // Scholar warrior

        // Harry Potter Characters
        case "hp-harry":
            return "bolt.fill"  // Lightning scar
        case "hp-hermione":
            return "book.fill"  // Knowledge
        case "hp-ron":
            return "gamecontroller"  // Chess/games
        case "hp-dumbledore":
            return "brain.head.profile"  // Wisdom
        case "hp-snape":
            return "flask.fill"  // Potions
        case "hp-luna":
            return "moon.stars"  // Dreamy/mystical
        case "hp-neville":
            return "leaf.circle"  // Herbology
        case "hp-draco":
            return "lizard.fill"  // Serpent house
        case "hp-hagrid":
            return "pawprint.fill"  // Creature keeper
        case "hp-mcgonagall":
            return "cat.fill"  // Animagus

        // Star Wars Characters
        case "sw-luke":
            return "sun.max.fill"  // Light side/hope
        case "sw-leia":
            return "star.circle.fill"  // Leader/royalty
        case "sw-han":
            return "airplane"  // Pilot/smuggler
        case "sw-obiwan":
            return "figure.mind.and.body"  // Meditation/Jedi
        case "sw-yoda":
            return "sparkle"  // Force mastery
        case "sw-vader":
            return "circle.lefthalf.filled"  // Dark/light conflict
        case "sw-rey":
            return "sunrise.fill"  // Rising hope
        case "sw-kylo":
            return "xmark.circle.fill"  // Conflict/darkness
        case "sw-ahsoka":
            return "figure.walk"  // Independent path
        case "sw-mandalorian":
            return "shield.fill"  // Armor/protection

        // Marvel Characters
        case "marvel-ironman":
            return "cpu.fill"  // Technology
        case "marvel-cap":
            return "shield.checkered"  // Iconic shield
        case "marvel-thor":
            return "bolt.horizontal.fill"  // Thunder
        case "marvel-widow":
            return "eye.slash"  // Spy/stealth
        case "marvel-spiderman":
            return "network"  // Web pattern
        case "marvel-hulk":
            return "burst.fill"  // Explosive power
        case "marvel-panther":
            return "cat.fill"  // Panther
        case "marvel-scarlet":
            return "waveform.circle.fill"  // Reality manipulation
        case "marvel-strange":
            return "eye.trianglebadge.exclamationmark"  // Third eye
        case "marvel-groot":
            return "tree.fill"  // Tree

        // DC Characters
        case "dc-batman":
            return "moon.fill"  // Night/dark knight
        case "dc-superman":
            return "sun.max.circle.fill"  // Solar power
        case "dc-wonderwoman":
            return "star.fill"  // Amazon warrior
        case "dc-aquaman":
            return "water.waves"  // Ocean
        case "dc-flash":
            return "bolt.circle.fill"  // Speed
        case "dc-greenlantern":
            return "circle.hexagongrid.fill"  // Construct creation
        case "dc-joker":
            return "theatermasks.fill"  // Chaos/performance
        case "dc-harley":
            return "diamond.fill"  // Playing card
        case "dc-alfred":
            return "house.fill"  // Butler/home
        case "dc-catwoman":
            return "cat.circle.fill"  // Cat burglar

        // Game of Thrones Characters
        case "got-jon":
            return "snowflake"  // The North/Winter
        case "got-daenerys":
            return "flame.fill"  // Dragons
        case "got-tyrion":
            return "text.bubble.fill"  // Wit/words
        case "got-arya":
            return "figure.fencing"  // Assassin
        case "got-cersei":
            return "crown.fill"  // Queen
        case "got-jaime":
            return "hand.raised.fill"  // Kingslayer's hand
        case "got-sansa":
            return "bird.fill"  // Little bird
        case "got-brienne":
            return "shield.fill"  // Knight
        case "got-hound":
            return "dog.fill"  // The Hound
        case "got-varys":
            return "ear.fill"  // Spymaster

        // Narnia Characters
        case "narnia-aslan":
            return "sparkle.magnifyingglass"  // Divine lion
        case "narnia-peter":
            return "figure.walk"  // Leader/eldest
        case "narnia-susan":
            return "target"  // Archer
        case "narnia-edmund":
            return "scale.3d"  // Justice
        case "narnia-lucy":
            return "heart.fill"  // Faith/love
        case "narnia-witch":
            return "snowflake.circle.fill"  // Eternal winter
        case "narnia-reepicheep":
            return "figure.fencing"  // Valiant mouse knight
        case "narnia-tumnus":
            return "music.note"  // Musical faun
        case "narnia-caspian":
            return "sailboat.fill"  // Voyager
        case "narnia-puddleglum":
            return "drop.fill"  // Marsh creature

        default:
            return "person.circle"  // Generic fallback
        }
    }

    /// Returns a secondary symbol for variation
    var alternateSymbol: String {
        // Use first trait to determine alternate symbol
        guard let primaryTrait = traits.first else {
            return "questionmark.circle"
        }

        switch primaryTrait.lowercased() {
        case "brave", "fierce":
            return "flame.fill"
        case "wise", "intelligent":
            return "lightbulb.fill"
        case "loyal", "faithful":
            return "heart.fill"
        case "noble", "honorable":
            return "crown.fill"
        case "cunning", "strategic":
            return "brain"
        case "powerful":
            return "bolt.fill"
        case "humble", "gentle":
            return "leaf.fill"
        case "determined", "resilient":
            return "mountain.2.fill"
        default:
            return "star.fill"
        }
    }

    /// Returns a color based on character's primary trait
    var traitColor: Color {
        guard let primaryTrait = traits.first else {
            return .gray
        }

        switch primaryTrait.lowercased() {
        case "brave", "fierce", "powerful":
            return Color(red: 0.8, green: 0.2, blue: 0.2)  // Bold red
        case "wise", "intelligent", "strategic":
            return Color(red: 0.3, green: 0.3, blue: 0.8)  // Deep blue
        case "loyal", "faithful", "protective":
            return Color(red: 0.8, green: 0.5, blue: 0.1)  // Warm gold
        case "noble", "honorable":
            return Color(red: 0.5, green: 0.1, blue: 0.5)  // Royal purple
        case "cunning", "mysterious":
            return Color(red: 0.2, green: 0.4, blue: 0.3)  // Dark green
        case "compassionate", "kind", "gentle":
            return Color(red: 0.4, green: 0.6, blue: 0.8)  // Soft blue
        case "humble", "optimistic", "joyful":
            return Color(red: 0.9, green: 0.7, blue: 0.2)  // Sunny yellow
        case "chaotic", "unpredictable":
            return Color(red: 0.6, green: 0.2, blue: 0.6)  // Chaotic purple
        case "conflicted", "tragic":
            return Color(red: 0.4, green: 0.4, blue: 0.4)  // Neutral gray
        default:
            return .accentColor
        }
    }
}

// MARK: - Character Avatar View

/// A view component that renders a character avatar with consistent styling
public struct CharacterAvatar: View {
    // MARK: - Properties

    private let character: FictionalCharacter
    private let size: AvatarSize
    private let style: AvatarStyle

    // MARK: - Enums

    /// Available avatar sizes
    public enum AvatarSize {
        case small      // 32pt
        case medium     // 48pt
        case large      // 64pt
        case extraLarge // 96pt
        case hero       // 120pt (for result screens)

        var dimension: CGFloat {
            switch self {
            case .small: return 32
            case .medium: return 48
            case .large: return 64
            case .extraLarge: return 96
            case .hero: return 120
            }
        }

        var fontSize: CGFloat {
            switch self {
            case .small: return 14
            case .medium: return 20
            case .large: return 28
            case .extraLarge: return 42
            case .hero: return 52
            }
        }

        var borderWidth: CGFloat {
            switch self {
            case .small: return 1.5
            case .medium: return 2
            case .large: return 2.5
            case .extraLarge: return 3
            case .hero: return 4
            }
        }
    }

    /// Available avatar styles
    public enum AvatarStyle {
        case filled     // Colored background with white icon
        case gradient   // Gradient background with white icon
        case outlined   // White/clear background with colored icon and border
        case minimal    // Just the icon, no background
    }

    // MARK: - Initialization

    public init(
        character: FictionalCharacter,
        size: AvatarSize = .medium,
        style: AvatarStyle = .gradient
    ) {
        self.character = character
        self.size = size
        self.style = style
    }

    // MARK: - Body

    public var body: some View {
        switch style {
        case .filled:
            filledStyle
        case .gradient:
            gradientStyle
        case .outlined:
            outlinedStyle
        case .minimal:
            minimalStyle
        }
    }

    // MARK: - Style Views

    private var filledStyle: some View {
        ZStack {
            Circle()
                .fill(character.traitColor)
                .frame(width: size.dimension, height: size.dimension)

            Image(systemName: character.sfSymbol)
                .font(.system(size: size.fontSize, weight: .semibold))
                .foregroundStyle(.white)
        }
        .accessibilityLabel("\(character.name) avatar")
    }

    private var gradientStyle: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [character.traitColor, character.traitColor.opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size.dimension, height: size.dimension)

            Image(systemName: character.sfSymbol)
                .font(.system(size: size.fontSize, weight: .semibold))
                .foregroundStyle(.white)
        }
        .shadow(color: character.traitColor.opacity(0.3), radius: 4, x: 0, y: 2)
        .accessibilityLabel("\(character.name) avatar")
    }

    private var outlinedStyle: some View {
        ZStack {
            Circle()
                .stroke(character.traitColor, lineWidth: size.borderWidth)
                .frame(width: size.dimension, height: size.dimension)

            Image(systemName: character.sfSymbol)
                .font(.system(size: size.fontSize, weight: .semibold))
                .foregroundStyle(character.traitColor)
        }
        .accessibilityLabel("\(character.name) avatar")
    }

    private var minimalStyle: some View {
        Image(systemName: character.sfSymbol)
            .font(.system(size: size.fontSize, weight: .semibold))
            .foregroundStyle(character.traitColor)
            .accessibilityLabel("\(character.name) avatar")
    }
}

// MARK: - Character Card Header

/// A header component showing character avatar with name and universe
public struct CharacterCardHeader: View {
    private let character: FictionalCharacter
    private let universe: FictionalUniverse?

    public init(character: FictionalCharacter, universe: FictionalUniverse? = nil) {
        self.character = character
        self.universe = universe
    }

    public var body: some View {
        HStack(spacing: 12) {
            CharacterAvatar(character: character, size: .large, style: .gradient)

            VStack(alignment: .leading, spacing: 4) {
                Text(character.name)
                    .font(.headline)
                    .foregroundStyle(.primary)

                if let universe = universe {
                    UniverseBadge(universe: universe)
                } else {
                    Text(character.universe)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()
        }
    }
}

// MARK: - Placeholder Avatar

/// A placeholder avatar for when character data is loading or unavailable
public struct PlaceholderAvatar: View {
    private let size: CharacterAvatar.AvatarSize

    public init(size: CharacterAvatar.AvatarSize = .medium) {
        self.size = size
    }

    public var body: some View {
        ZStack {
            Circle()
                .fill(Color(uiColor: .systemGray5))
                .frame(width: size.dimension, height: size.dimension)

            Image(systemName: "person.fill.questionmark")
                .font(.system(size: size.fontSize, weight: .semibold))
                .foregroundStyle(Color(uiColor: .systemGray3))
        }
        .accessibilityLabel("Unknown character")
    }
}

// MARK: - Previews

#Preview("Character Avatars - LOTR") {
    ScrollView {
        VStack(spacing: 16) {
            ForEach(FictionalUniverse.lordOfTheRings.characters) { character in
                HStack(spacing: 12) {
                    CharacterAvatar(character: character, size: .small, style: .gradient)
                    CharacterAvatar(character: character, size: .medium, style: .gradient)
                    CharacterAvatar(character: character, size: .large, style: .gradient)

                    VStack(alignment: .leading) {
                        Text(character.name)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Text(character.sfSymbol)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
    }
}

#Preview("Character Avatars - All Styles") {
    let character = FictionalUniverse.harryPotter.characters.first!

    VStack(spacing: 24) {
        Text(character.name)
            .font(.headline)

        HStack(spacing: 20) {
            VStack {
                CharacterAvatar(character: character, size: .large, style: .filled)
                Text("Filled")
                    .font(.caption)
            }

            VStack {
                CharacterAvatar(character: character, size: .large, style: .gradient)
                Text("Gradient")
                    .font(.caption)
            }

            VStack {
                CharacterAvatar(character: character, size: .large, style: .outlined)
                Text("Outlined")
                    .font(.caption)
            }

            VStack {
                CharacterAvatar(character: character, size: .large, style: .minimal)
                Text("Minimal")
                    .font(.caption)
            }
        }

        Divider()

        Text("Hero Size")
            .font(.subheadline)

        CharacterAvatar(character: character, size: .hero, style: .gradient)
    }
    .padding()
}

#Preview("Character Card Headers") {
    VStack(spacing: 16) {
        ForEach(FictionalUniverse.marvel.characters.prefix(5)) { character in
            CharacterCardHeader(
                character: character,
                universe: .marvel
            )
            .padding()
            .background(Color(uiColor: .secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    .padding()
}

#Preview("Placeholder Avatar") {
    HStack(spacing: 20) {
        PlaceholderAvatar(size: .small)
        PlaceholderAvatar(size: .medium)
        PlaceholderAvatar(size: .large)
        PlaceholderAvatar(size: .extraLarge)
    }
}

#Preview("Dark Mode") {
    ScrollView {
        VStack(spacing: 16) {
            ForEach(FictionalUniverse.starWars.characters.prefix(5)) { character in
                CharacterCardHeader(
                    character: character,
                    universe: .starWars
                )
                .padding()
                .background(Color(uiColor: .secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding()
    }
    .preferredColorScheme(.dark)
}

#Preview("All Universes Sample") {
    ScrollView {
        VStack(spacing: 24) {
            ForEach(FictionalUniverse.allUniverses) { universe in
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        UniverseIcon(universe: universe, size: .medium, style: .filled)
                        Text(universe.name)
                            .font(.headline)
                    }

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(universe.characters) { character in
                                CharacterAvatar(character: character, size: .medium, style: .gradient)
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
    }
}
#endif
