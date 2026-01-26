// DiscoveryCard.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

// MARK: - Discovery Card Configuration

/// Configuration for a discovery feature card
public struct DiscoveryCardConfiguration: Equatable, Sendable {
    /// The SF Symbol icon name
    public let icon: String

    /// The card title
    public let title: String

    /// The card subtitle/description
    public let subtitle: String

    /// Optional badge text (e.g., "New", "3")
    public let badge: DiscoveryBadge?

    /// Accent color for the card
    public let accentColor: Color

    /// Whether the feature is locked
    public let isLocked: Bool

    /// Progress toward unlocking (0.0 to 1.0), nil if no progress requirement
    public let unlockProgress: Double?

    /// Entries required to unlock, nil if no requirement
    public let entriesRequired: Int?

    /// Current entry count for progress display
    public let currentEntries: Int?

    public init(
        icon: String,
        title: String,
        subtitle: String,
        badge: DiscoveryBadge? = nil,
        accentColor: Color = .accentColor,
        isLocked: Bool = false,
        unlockProgress: Double? = nil,
        entriesRequired: Int? = nil,
        currentEntries: Int? = nil
    ) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.badge = badge
        self.accentColor = accentColor
        self.isLocked = isLocked
        self.unlockProgress = unlockProgress
        self.entriesRequired = entriesRequired
        self.currentEntries = currentEntries
    }
}

// MARK: - Discovery Badge

/// Badge types for discovery cards
public enum DiscoveryBadge: Equatable, Sendable {
    /// "New" badge for new features
    case new

    /// Notification count badge
    case count(Int)

    /// Custom text badge
    case custom(String)

    var text: String {
        switch self {
        case .new:
            return "New"
        case .count(let value):
            return value > 99 ? "99+" : "\(value)"
        case .custom(let text):
            return text
        }
    }

    var backgroundColor: Color {
        switch self {
        case .new:
            return .blue
        case .count:
            return .red
        case .custom:
            return .orange
        }
    }
}

// MARK: - Discovery Card View

/// A visually appealing card that invites users to explore self-discovery features
public struct DiscoveryCard: View {
    // MARK: - Properties

    private let configuration: DiscoveryCardConfiguration
    private let action: () -> Void

    @State private var isPressed = false

    // MARK: - Initialization

    public init(
        configuration: DiscoveryCardConfiguration,
        action: @escaping () -> Void
    ) {
        self.configuration = configuration
        self.action = action
    }

    /// Convenience initializer with individual parameters
    public init(
        icon: String,
        title: String,
        subtitle: String,
        badge: DiscoveryBadge? = nil,
        accentColor: Color = .accentColor,
        isLocked: Bool = false,
        unlockProgress: Double? = nil,
        entriesRequired: Int? = nil,
        currentEntries: Int? = nil,
        action: @escaping () -> Void
    ) {
        self.configuration = DiscoveryCardConfiguration(
            icon: icon,
            title: title,
            subtitle: subtitle,
            badge: badge,
            accentColor: accentColor,
            isLocked: isLocked,
            unlockProgress: unlockProgress,
            entriesRequired: entriesRequired,
            currentEntries: currentEntries
        )
        self.action = action
    }

    // MARK: - Body

    public var body: some View {
        Button(action: action) {
            cardContent
        }
        .buttonStyle(DiscoveryCardButtonStyle(isLocked: configuration.isLocked))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint(accessibilityHint)
        .accessibilityAddTraits(configuration.isLocked ? [] : .isButton)
    }

    // MARK: - Card Content

    private var cardContent: some View {
        HStack(spacing: 16) {
            // Icon container
            iconView

            // Text content
            VStack(alignment: .leading, spacing: 4) {
                titleRow

                Text(configuration.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                // Progress indicator if applicable
                if let progress = configuration.unlockProgress, configuration.isLocked {
                    progressView(progress: progress)
                }
            }

            Spacer(minLength: 8)

            // Trailing content
            trailingView
        }
        .padding(16)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(cardOverlay)
        .shadow(color: shadowColor, radius: 8, x: 0, y: 2)
    }

    // MARK: - Icon View

    private var iconView: some View {
        ZStack {
            Circle()
                .fill(iconBackgroundColor)
                .frame(width: 56, height: 56)

            Image(systemName: configuration.icon)
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(iconForegroundColor)

            // Lock overlay for locked cards
            if configuration.isLocked {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 56, height: 56)

                Image(systemName: "lock.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
        }
        .accessibilityHidden(true)
    }

    // MARK: - Title Row

    private var titleRow: some View {
        HStack(spacing: 8) {
            Text(configuration.title)
                .font(.headline)
                .foregroundStyle(configuration.isLocked ? .secondary : .primary)

            if let badge = configuration.badge, !configuration.isLocked {
                badgeView(badge)
            }
        }
    }

    // MARK: - Badge View

    private func badgeView(_ badge: DiscoveryBadge) -> some View {
        Text(badge.text)
            .font(.caption2)
            .fontWeight(.bold)
            .foregroundStyle(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(badge.backgroundColor)
            .clipShape(Capsule())
    }

    // MARK: - Progress View

    private func progressView(progress: Double) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background track
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.gray.opacity(0.2))

                    // Progress fill
                    RoundedRectangle(cornerRadius: 2)
                        .fill(configuration.accentColor.opacity(0.6))
                        .frame(width: geometry.size.width * min(max(progress, 0), 1))
                }
            }
            .frame(height: 4)

            // Progress text
            if let required = configuration.entriesRequired,
               let current = configuration.currentEntries {
                Text("\(current)/\(required) entries to unlock")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.top, 4)
    }

    // MARK: - Trailing View

    private var trailingView: some View {
        Group {
            if configuration.isLocked {
                // Locked indicator already shown in icon
                EmptyView()
            } else {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.tertiary)
            }
        }
    }

    // MARK: - Styling

    private var cardBackground: some View {
        Group {
            if configuration.isLocked {
                Color(uiColor: .secondarySystemBackground)
            } else {
                Color(uiColor: .systemBackground)
            }
        }
    }

    private var cardOverlay: some View {
        RoundedRectangle(cornerRadius: 16)
            .stroke(
                configuration.isLocked
                    ? Color.gray.opacity(0.1)
                    : configuration.accentColor.opacity(0.15),
                lineWidth: 1
            )
    }

    private var shadowColor: Color {
        configuration.isLocked
            ? .black.opacity(0.03)
            : .black.opacity(0.05)
    }

    private var iconBackgroundColor: Color {
        configuration.isLocked
            ? Color.gray.opacity(0.1)
            : configuration.accentColor.opacity(0.15)
    }

    private var iconForegroundColor: Color {
        configuration.isLocked
            ? .secondary
            : configuration.accentColor
    }

    // MARK: - Accessibility

    private var accessibilityLabel: String {
        var label = configuration.title

        if let badge = configuration.badge {
            switch badge {
            case .new:
                label += ", new feature"
            case .count(let count):
                label += ", \(count) notifications"
            case .custom(let text):
                label += ", \(text)"
            }
        }

        label += ". \(configuration.subtitle)"

        if configuration.isLocked {
            label += ". Locked"
            if let required = configuration.entriesRequired,
               let current = configuration.currentEntries {
                label += ", \(current) of \(required) entries completed"
            }
        }

        return label
    }

    private var accessibilityHint: String {
        if configuration.isLocked {
            if let required = configuration.entriesRequired,
               let current = configuration.currentEntries {
                let remaining = required - current
                return "Complete \(remaining) more journal \(remaining == 1 ? "entry" : "entries") to unlock"
            }
            return "Feature is locked"
        }
        return "Double tap to explore"
    }
}

// MARK: - Button Style

/// Custom button style for discovery cards with subtle press animation
private struct DiscoveryCardButtonStyle: ButtonStyle {
    let isLocked: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed && !isLocked ? 0.98 : 1.0)
            .opacity(configuration.isPressed && !isLocked ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - View Modifier for Card Styling

/// View modifier that applies consistent card styling across the app
public struct DiscoveryCardStyleModifier: ViewModifier {
    let cornerRadius: CGFloat
    let shadowRadius: CGFloat

    public init(cornerRadius: CGFloat = 16, shadowRadius: CGFloat = 8) {
        self.cornerRadius = cornerRadius
        self.shadowRadius = shadowRadius
    }

    public func body(content: Content) -> some View {
        content
            .background(Color(uiColor: .systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .shadow(color: .black.opacity(0.05), radius: shadowRadius, x: 0, y: 2)
    }
}

extension View {
    /// Applies the discovery card styling to any view
    public func discoveryCardStyle(cornerRadius: CGFloat = 16, shadowRadius: CGFloat = 8) -> some View {
        modifier(DiscoveryCardStyleModifier(cornerRadius: cornerRadius, shadowRadius: shadowRadius))
    }
}

// MARK: - Previews

#Preview("Unlocked Cards") {
    ScrollView {
        VStack(spacing: 16) {
            DiscoveryCard(
                icon: "person.fill.questionmark",
                title: "Character Discovery",
                subtitle: "Uncover your personality traits through Socratic dialogue",
                badge: .new,
                accentColor: .purple
            ) {
                print("Character Discovery tapped")
            }

            DiscoveryCard(
                icon: "envelope.fill",
                title: "Letters to Self",
                subtitle: "Write meaningful letters to your future self",
                badge: .count(3),
                accentColor: .orange
            ) {
                print("Letters tapped")
            }

            DiscoveryCard(
                icon: "chart.line.uptrend.xyaxis",
                title: "Clarity Trends",
                subtitle: "Track your emotional clarity over time",
                accentColor: .blue
            ) {
                print("Trends tapped")
            }

            DiscoveryCard(
                icon: "lightbulb.fill",
                title: "Daily Wisdom",
                subtitle: "Discover philosophical insights tailored to your journey",
                badge: .custom("Updated"),
                accentColor: .yellow
            ) {
                print("Wisdom tapped")
            }
        }
        .padding()
    }
    .background(Color(uiColor: .systemGroupedBackground))
}

#Preview("Locked Cards") {
    ScrollView {
        VStack(spacing: 16) {
            DiscoveryCard(
                icon: "person.fill.questionmark",
                title: "Character Discovery",
                subtitle: "Uncover your personality traits through Socratic dialogue",
                accentColor: .purple,
                isLocked: true,
                unlockProgress: 0.4,
                entriesRequired: 5,
                currentEntries: 2
            ) {
                print("Locked card tapped")
            }

            DiscoveryCard(
                icon: "chart.bar.doc.horizontal",
                title: "Advanced Insights",
                subtitle: "Deep analysis of your journaling patterns",
                accentColor: .indigo,
                isLocked: true,
                unlockProgress: 0.1,
                entriesRequired: 10,
                currentEntries: 1
            ) {
                print("Locked card tapped")
            }

            DiscoveryCard(
                icon: "sparkles",
                title: "AI Reflections",
                subtitle: "AI-powered insights from your journal entries",
                accentColor: .cyan,
                isLocked: true
            ) {
                print("Locked card tapped")
            }
        }
        .padding()
    }
    .background(Color(uiColor: .systemGroupedBackground))
}

#Preview("Mixed States") {
    ScrollView {
        VStack(spacing: 16) {
            DiscoveryCard(
                icon: "book.fill",
                title: "Journal",
                subtitle: "Start a Socratic dialogue session",
                accentColor: .green
            ) {}

            DiscoveryCard(
                icon: "person.fill.questionmark",
                title: "Character Discovery",
                subtitle: "Uncover your personality traits",
                badge: .new,
                accentColor: .purple,
                isLocked: true,
                unlockProgress: 0.6,
                entriesRequired: 5,
                currentEntries: 3
            ) {}

            DiscoveryCard(
                icon: "envelope.fill",
                title: "Letters to Self",
                subtitle: "Write to your future self",
                badge: .count(2),
                accentColor: .orange
            ) {}
        }
        .padding()
    }
    .background(Color(uiColor: .systemGroupedBackground))
}

#Preview("Dark Mode") {
    ScrollView {
        VStack(spacing: 16) {
            DiscoveryCard(
                icon: "person.fill.questionmark",
                title: "Character Discovery",
                subtitle: "Uncover your personality traits through Socratic dialogue",
                badge: .new,
                accentColor: .purple
            ) {}

            DiscoveryCard(
                icon: "envelope.fill",
                title: "Letters to Self",
                subtitle: "Write meaningful letters to your future self",
                accentColor: .orange,
                isLocked: true,
                unlockProgress: 0.5,
                entriesRequired: 5,
                currentEntries: 2
            ) {}
        }
        .padding()
    }
    .background(Color(uiColor: .systemGroupedBackground))
    .preferredColorScheme(.dark)
}
#endif
