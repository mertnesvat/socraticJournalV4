// PatternSelectionView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Pattern and duration picker before starting a session
public struct PatternSelectionView: View {
    @Binding var selectedPattern: BreathPattern
    @Binding var selectedDuration: SessionDuration
    let onBegin: () -> Void

    public var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Title
            VStack(spacing: AppSpacing.xs) {
                Text("Breathe")
                    .font(AppTypography.headline)
                    .foregroundStyle(AppColors.textPrimary)

                Text("Choose your pattern and duration")
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.textSecondary)
            }
            .padding(.bottom, AppSpacing.xl)

            // Pattern cards
            VStack(spacing: AppSpacing.sm) {
                ForEach(BreathPattern.allPatterns, id: \.id) { pattern in
                    patternCard(pattern)
                }
            }
            .padding(.horizontal, AppSpacing.screenPadding)
            .padding(.bottom, AppSpacing.lg)

            // Duration picker
            durationPicker
                .padding(.horizontal, AppSpacing.screenPadding)
                .padding(.bottom, AppSpacing.xl)

            Spacer()

            // Begin button
            AccentPillButton("Begin") {
                onBegin()
            }
            .padding(.horizontal, AppSpacing.screenPadding)
            .padding(.bottom, AppSpacing.xxl)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.background)
    }

    // MARK: - Pattern Card

    @ViewBuilder
    private func patternCard(_ pattern: BreathPattern) -> some View {
        let isSelected = selectedPattern.id == pattern.id

        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedPattern = pattern
            }
        } label: {
            HStack(spacing: AppSpacing.md) {
                VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                    Text(pattern.name)
                        .font(AppTypography.bodyBold)
                        .foregroundStyle(isSelected ? AppColors.accent : AppColors.textPrimary)

                    Text(String(format: "%.1f bpm", pattern.breathsPerMinute))
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.textSecondary)
                }

                Spacer()

                // Timing badge
                Text(String(format: "%.1fs / %.1fs", pattern.inhaleDuration, pattern.exhaleDuration))
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textTertiary)

                // Selection indicator
                Circle()
                    .fill(isSelected ? AppColors.accent : Color.clear)
                    .frame(width: 12, height: 12)
                    .overlay(
                        Circle()
                            .stroke(isSelected ? AppColors.accent : AppColors.textTertiary, lineWidth: 1.5)
                    )
            }
            .padding(AppSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? AppColors.accent.opacity(0.08) : AppColors.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? AppColors.accent.opacity(0.3) : AppColors.border, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Duration Picker

    private var durationPicker: some View {
        HStack(spacing: 0) {
            ForEach(SessionDuration.allCases) { duration in
                let isSelected = selectedDuration == duration

                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedDuration = duration
                    }
                } label: {
                    Text(duration.label)
                        .font(AppTypography.bodyBold)
                        .foregroundStyle(isSelected ? AppColors.textOnAccent : AppColors.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppSpacing.sm)
                        .background(
                            Capsule()
                                .fill(isSelected ? AppColors.accent : Color.clear)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(
            Capsule()
                .fill(AppColors.surface)
        )
    }
}

#Preview {
    PatternSelectionView(
        selectedPattern: .constant(.resonance),
        selectedDuration: .constant(.fiveMinutes),
        onBegin: {}
    )
}
#endif
