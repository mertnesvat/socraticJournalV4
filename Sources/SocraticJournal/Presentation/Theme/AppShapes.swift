// AppShapes.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

// MARK: - Geometric Ring (Donut Chart)

/// A geometric ring/donut visualization — the hero shape from Bold Geometric design
/// Used for disagreement meter, streak progress, and stat visualizations
public struct GeometricRing: View {
    let progress: Double // 0.0 to 1.0
    let size: CGFloat
    let lineWidth: CGFloat
    let accentColor: Color
    let trackColor: Color

    public init(
        progress: Double,
        size: CGFloat = 200,
        lineWidth: CGFloat = 28,
        accentColor: Color = AppColors.accent,
        trackColor: Color = AppColors.border
    ) {
        self.progress = min(max(progress, 0), 1)
        self.size = size
        self.lineWidth = lineWidth
        self.accentColor = accentColor
        self.trackColor = trackColor
    }

    public var body: some View {
        ZStack {
            // Track
            Circle()
                .stroke(trackColor, lineWidth: lineWidth)

            // Progress
            Circle()
                .trim(from: 0, to: progress)
                .stroke(accentColor, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Hairline Divider

/// A 1px hairline divider for structured minimalism grid layouts
public struct HairlineDivider: View {
    let color: Color
    let axis: Axis

    public init(color: Color = AppColors.border, axis: Axis = .horizontal) {
        self.color = color
        self.axis = axis
    }

    public var body: some View {
        switch axis {
        case .horizontal:
            Rectangle()
                .fill(color)
                .frame(height: AppSpacing.gridGutter)
        case .vertical:
            Rectangle()
                .fill(color)
                .frame(width: AppSpacing.gridGutter)
        }
    }
}

// MARK: - Grid Cell

/// A bordered cell for icon grids — inspired by Image 2's 3x2 icon grid
public struct GridCell<Content: View>: View {
    let isAccented: Bool
    let content: () -> Content

    public init(isAccented: Bool = false, @ViewBuilder content: @escaping () -> Content) {
        self.isAccented = isAccented
        self.content = content
    }

    public var body: some View {
        content()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(isAccented ? AppColors.accent : Color.clear)
            .overlay(
                Rectangle()
                    .stroke(AppColors.border, lineWidth: AppSpacing.gridGutter)
            )
    }
}

// MARK: - Section Header

/// ALL-CAPS editorial section header with tracking — from Image 2
public struct SectionHeaderView: View {
    let title: String
    let showTopBorder: Bool

    public init(_ title: String, showTopBorder: Bool = true) {
        self.title = title
        self.showTopBorder = showTopBorder
    }

    public var body: some View {
        VStack(spacing: 0) {
            if showTopBorder {
                HairlineDivider()
            }

            HStack {
                Text(title.uppercased())
                    .font(AppTypography.sectionHeader)
                    .tracking(AppTypography.sectionHeaderTracking)
                    .foregroundStyle(AppColors.textPrimary)

                Spacer()
            }
            .padding(.horizontal, AppSpacing.screenPadding)
            .padding(.vertical, AppSpacing.md)
        }
    }
}

// MARK: - Accent Pill Button

/// Filled coral-red pill button — the main CTA style
public struct AccentPillButton: View {
    let title: String
    let icon: String?
    let action: () -> Void

    public init(_ title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                }

                Text(title)
                    .font(AppTypography.bodyBold)
            }
            .foregroundStyle(AppColors.textOnAccent)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                Capsule()
                    .fill(AppColors.accent)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Stat Card

/// Large stat card with contrasting background — from Image 3
public struct StatCard: View {
    let label: String
    let value: String
    let backgroundColor: Color
    let textColor: Color

    public init(
        label: String,
        value: String,
        backgroundColor: Color,
        textColor: Color = AppColors.textPrimary
    ) {
        self.label = label
        self.value = value
        self.backgroundColor = backgroundColor
        self.textColor = textColor
    }

    public var body: some View {
        HStack {
            Text(label)
                .font(AppTypography.bodyBold)
                .foregroundStyle(textColor.opacity(0.8))

            Spacer()

            Text(value)
                .font(AppTypography.stat)
                .foregroundStyle(textColor)
        }
        .padding(AppSpacing.cardPadding)
        .frame(maxWidth: .infinity)
        .frame(height: 120)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(backgroundColor)
        )
    }
}

// MARK: - Previews

#Preview("Geometric Ring") {
    VStack(spacing: 40) {
        GeometricRing(progress: 0.81, size: 200)
        GeometricRing(progress: 0.45, size: 120, lineWidth: 20)
    }
    .padding()
    .background(AppColors.background)
}

#Preview("Components") {
    VStack(spacing: 20) {
        SectionHeaderView("Condition Reports")

        HairlineDivider()

        StatCard(
            label: "Questions\nAnswered",
            value: "67",
            backgroundColor: AppColors.cardTeal
        )

        StatCard(
            label: "Day\nStreak",
            value: "14",
            backgroundColor: AppColors.cardYellow
        )

        StatCard(
            label: "Friends",
            value: "23",
            backgroundColor: AppColors.cardDark,
            textColor: .white
        )

        AccentPillButton("Record Your Take", icon: "mic.fill") {}
    }
    .padding()
    .background(AppColors.background)
}
#endif
