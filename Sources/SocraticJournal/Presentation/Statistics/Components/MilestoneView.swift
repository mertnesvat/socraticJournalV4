// MilestoneView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Individual milestone achievement display
public struct MilestoneView: View {
    let milestone: Milestone

    @State private var animatedProgress: Double = 0

    public init(milestone: Milestone) {
        self.milestone = milestone
    }

    public var body: some View {
        VStack(spacing: 8) {
            // Icon with progress ring
            ZStack {
                // Background circle
                Circle()
                    .fill(milestone.isUnlocked ? iconColor.opacity(0.15) : Color(uiColor: .systemGray5))
                    .frame(width: 56, height: 56)

                // Progress ring (only if not unlocked)
                if !milestone.isUnlocked {
                    Circle()
                        .stroke(Color(uiColor: .systemGray4), lineWidth: 3)
                        .frame(width: 56, height: 56)

                    Circle()
                        .trim(from: 0, to: animatedProgress)
                        .stroke(iconColor, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                        .frame(width: 56, height: 56)
                        .rotationEffect(.degrees(-90))
                }

                // Icon
                Image(systemName: milestone.type.icon)
                    .font(.title3)
                    .foregroundStyle(milestone.isUnlocked ? iconColor : .secondary)
            }

            // Title
            Text(milestone.type.rawValue)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(milestone.isUnlocked ? .primary : .secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)

            // Status
            if milestone.isUnlocked {
                Image(systemName: "checkmark.circle.fill")
                    .font(.caption)
                    .foregroundStyle(.green)
            } else {
                Text(progressText)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color(uiColor: .systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                animatedProgress = milestone.progress
            }
        }
    }

    private var iconColor: Color {
        switch milestone.type {
        case .firstEntry: return .blue
        case .streak3, .streak7: return .orange
        case .streak14, .streak30: return .red
        case .entries10, .entries25: return .green
        case .entries50, .entries100: return .purple
        }
    }

    private var progressText: String {
        let current = Int(milestone.progress * Double(milestone.type.threshold))
        return "\(current)/\(milestone.type.threshold)"
    }
}

/// Expanded milestone detail view
public struct MilestoneDetailView: View {
    let milestone: Milestone

    public init(milestone: Milestone) {
        self.milestone = milestone
    }

    public var body: some View {
        VStack(spacing: 16) {
            // Large icon
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.2))
                    .frame(width: 100, height: 100)

                Image(systemName: milestone.type.icon)
                    .font(.largeTitle)
                    .foregroundStyle(milestone.isUnlocked ? iconColor : .secondary)
            }

            // Title and description
            VStack(spacing: 4) {
                Text(milestone.type.rawValue)
                    .font(.title3)
                    .fontWeight(.bold)

                Text(milestone.type.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            // Progress bar
            if !milestone.isUnlocked {
                VStack(spacing: 8) {
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(uiColor: .systemGray5))
                                .frame(height: 8)

                            RoundedRectangle(cornerRadius: 4)
                                .fill(iconColor)
                                .frame(width: geometry.size.width * milestone.progress, height: 8)
                        }
                    }
                    .frame(height: 8)

                    let current = Int(milestone.progress * Double(milestone.type.threshold))
                    let remaining = milestone.type.threshold - current
                    Text("\(remaining) more to unlock")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 32)
            } else {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Text("Achieved!")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.green)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(uiColor: .systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var iconColor: Color {
        switch milestone.type {
        case .firstEntry: return .blue
        case .streak3, .streak7: return .orange
        case .streak14, .streak30: return .red
        case .entries10, .entries25: return .green
        case .entries50, .entries100: return .purple
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            MilestoneView(milestone: Milestone(type: .firstEntry, isUnlocked: true, progress: 1.0))
            MilestoneView(milestone: Milestone(type: .streak3, isUnlocked: true, progress: 1.0))
            MilestoneView(milestone: Milestone(type: .streak7, isUnlocked: false, progress: 0.57))
            MilestoneView(milestone: Milestone(type: .entries10, isUnlocked: false, progress: 0.3))
            MilestoneView(milestone: Milestone(type: .entries25, isUnlocked: false, progress: 0.12))
            MilestoneView(milestone: Milestone(type: .entries100, isUnlocked: false, progress: 0.03))
        }

        MilestoneDetailView(milestone: Milestone(type: .streak7, isUnlocked: false, progress: 0.57))
    }
    .padding()
    .background(Color(uiColor: .systemGroupedBackground))
}
#endif
