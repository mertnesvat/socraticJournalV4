// UniverseIcon.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

// MARK: - Universe Icon Configuration

/// Enhanced SF Symbol mapping for fictional universes
public extension FictionalUniverse {
    /// Returns the primary SF Symbol name for this universe
    var sfSymbol: String {
        switch id {
        case "lotr":
            return "mountain.2.fill"  // Represents mountains/epic journey
        case "hp":
            return "wand.and.stars"  // Magic wand
        case "sw":
            return "staroflife.fill"  // Star symbol for space
        case "marvel":
            return "bolt.shield.fill"  // Power/heroism
        case "dc":
            return "shield.checkered"  // Justice/protection
        case "got":
            return "crown.fill"  // Royalty/thrones
        case "narnia":
            return "door.left.hand.open"  // The wardrobe door
        default:
            return icon  // Fallback to existing icon
        }
    }

    /// Returns a secondary/alternate SF Symbol for variety
    var alternateSymbol: String {
        switch id {
        case "lotr":
            return "flame.fill"  // Mount Doom
        case "hp":
            return "sparkles"  // Magic
        case "sw":
            return "moon.stars.fill"  // Space
        case "marvel":
            return "bolt.fill"  // Power
        case "dc":
            return "shield.fill"  // Protection
        case "got":
            return "flame.fill"  // Dragons
        case "narnia":
            return "leaf.fill"  // Nature/magic
        default:
            return "questionmark.circle"
        }
    }

    /// Returns a color associated with this universe
    var themeColor: Color {
        switch id {
        case "lotr":
            return Color(red: 0.4, green: 0.3, blue: 0.2)  // Earthy brown
        case "hp":
            return Color(red: 0.5, green: 0.1, blue: 0.1)  // Gryffindor red
        case "sw":
            return Color(red: 0.1, green: 0.2, blue: 0.5)  // Space blue
        case "marvel":
            return Color(red: 0.8, green: 0.1, blue: 0.1)  // Marvel red
        case "dc":
            return Color(red: 0.0, green: 0.3, blue: 0.6)  // DC blue
        case "got":
            return Color(red: 0.3, green: 0.3, blue: 0.3)  // Steel gray
        case "narnia":
            return Color(red: 0.2, green: 0.5, blue: 0.3)  // Forest green
        default:
            return .accentColor
        }
    }

    /// Returns a gradient for card backgrounds
    var themeGradient: LinearGradient {
        LinearGradient(
            colors: [themeColor.opacity(0.8), themeColor.opacity(0.4)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - Universe Icon View

/// A view component that renders a universe icon with consistent styling
public struct UniverseIcon: View {
    // MARK: - Properties

    private let universe: FictionalUniverse
    private let size: IconSize
    private let style: IconStyle

    // MARK: - Enums

    /// Available icon sizes
    public enum IconSize {
        case small      // 24pt
        case medium     // 40pt
        case large      // 56pt
        case extraLarge // 80pt

        var dimension: CGFloat {
            switch self {
            case .small: return 24
            case .medium: return 40
            case .large: return 56
            case .extraLarge: return 80
            }
        }

        var fontSize: CGFloat {
            switch self {
            case .small: return 12
            case .medium: return 18
            case .large: return 24
            case .extraLarge: return 36
            }
        }

        var cornerRadius: CGFloat {
            switch self {
            case .small: return 6
            case .medium: return 10
            case .large: return 14
            case .extraLarge: return 20
            }
        }
    }

    /// Available icon styles
    public enum IconStyle {
        case filled     // Colored background with white icon
        case outlined   // Transparent background with colored icon
        case minimal    // Just the icon, no background
    }

    // MARK: - Initialization

    public init(
        universe: FictionalUniverse,
        size: IconSize = .medium,
        style: IconStyle = .filled
    ) {
        self.universe = universe
        self.size = size
        self.style = style
    }

    // MARK: - Body

    public var body: some View {
        switch style {
        case .filled:
            filledStyle
        case .outlined:
            outlinedStyle
        case .minimal:
            minimalStyle
        }
    }

    // MARK: - Style Views

    private var filledStyle: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size.cornerRadius)
                .fill(universe.themeGradient)
                .frame(width: size.dimension, height: size.dimension)

            Image(systemName: universe.sfSymbol)
                .font(.system(size: size.fontSize, weight: .semibold))
                .foregroundStyle(.white)
        }
        .accessibilityLabel("\(universe.name) icon")
    }

    private var outlinedStyle: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size.cornerRadius)
                .stroke(universe.themeColor, lineWidth: 2)
                .frame(width: size.dimension, height: size.dimension)

            Image(systemName: universe.sfSymbol)
                .font(.system(size: size.fontSize, weight: .semibold))
                .foregroundStyle(universe.themeColor)
        }
        .accessibilityLabel("\(universe.name) icon")
    }

    private var minimalStyle: some View {
        Image(systemName: universe.sfSymbol)
            .font(.system(size: size.fontSize, weight: .semibold))
            .foregroundStyle(universe.themeColor)
            .accessibilityLabel("\(universe.name) icon")
    }
}

// MARK: - Universe Badge View

/// A compact badge showing universe name with icon
public struct UniverseBadge: View {
    private let universe: FictionalUniverse

    public init(universe: FictionalUniverse) {
        self.universe = universe
    }

    public var body: some View {
        HStack(spacing: 6) {
            Image(systemName: universe.sfSymbol)
                .font(.caption)

            Text(universe.name)
                .font(.caption)
                .fontWeight(.medium)
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(universe.themeColor)
        .clipShape(Capsule())
        .accessibilityLabel("\(universe.name)")
    }
}

// MARK: - Previews

#Preview("Universe Icons - Filled") {
    ScrollView {
        VStack(spacing: 20) {
            ForEach(FictionalUniverse.allUniverses) { universe in
                HStack(spacing: 16) {
                    UniverseIcon(universe: universe, size: .small, style: .filled)
                    UniverseIcon(universe: universe, size: .medium, style: .filled)
                    UniverseIcon(universe: universe, size: .large, style: .filled)

                    VStack(alignment: .leading) {
                        Text(universe.name)
                            .font(.headline)
                        Text(universe.sfSymbol)
                            .font(.caption)
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

#Preview("Universe Icons - Outlined") {
    ScrollView {
        VStack(spacing: 20) {
            ForEach(FictionalUniverse.allUniverses) { universe in
                HStack(spacing: 16) {
                    UniverseIcon(universe: universe, size: .medium, style: .outlined)
                    UniverseIcon(universe: universe, size: .large, style: .outlined)

                    VStack(alignment: .leading) {
                        Text(universe.name)
                            .font(.headline)
                    }

                    Spacer()
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
    }
}

#Preview("Universe Badges") {
    ScrollView {
        VStack(spacing: 12) {
            ForEach(FictionalUniverse.allUniverses) { universe in
                UniverseBadge(universe: universe)
            }
        }
        .padding()
    }
}

#Preview("Dark Mode") {
    ScrollView {
        VStack(spacing: 20) {
            ForEach(FictionalUniverse.allUniverses) { universe in
                HStack(spacing: 16) {
                    UniverseIcon(universe: universe, size: .large, style: .filled)
                    UniverseIcon(universe: universe, size: .large, style: .outlined)
                    UniverseBadge(universe: universe)
                    Spacer()
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
    }
    .preferredColorScheme(.dark)
}
#endif
