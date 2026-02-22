// ThemeSelectorView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Segmented control for theme selection — editorial hairline style
struct ThemeSelectorView: View {
    @Binding var selectedTheme: ThemeMode

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 0) {
                ForEach(Array(ThemeMode.allCases.enumerated()), id: \.element) { index, mode in
                    Button {
                        selectedTheme = mode
                    } label: {
                        VStack(spacing: AppSpacing.xs) {
                            Image(systemName: mode.iconName)
                                .font(.system(size: 20, weight: .medium))
                            Text(mode.displayName)
                                .font(AppTypography.caption)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppSpacing.md)
                        .foregroundStyle(
                            selectedTheme == mode ? AppColors.accent : AppColors.textSecondary
                        )
                    }
                    .buttonStyle(.plain)

                    // Vertical hairline between options
                    if index < ThemeMode.allCases.count - 1 {
                        HairlineDivider(axis: .vertical)
                            .frame(height: 40)
                    }
                }
            }
            .padding(.vertical, AppSpacing.xs)

            // Bottom indicator bar for selected
            GeometryReader { geometry in
                let segmentWidth = geometry.size.width / CGFloat(ThemeMode.allCases.count)
                let selectedIndex = CGFloat(ThemeMode.allCases.firstIndex(of: selectedTheme) ?? 0)

                Rectangle()
                    .fill(AppColors.accent)
                    .frame(width: segmentWidth, height: 2)
                    .offset(x: segmentWidth * selectedIndex)
            }
            .frame(height: 2)
        }
        .background(AppColors.surface)
        .overlay(
            Rectangle()
                .stroke(AppColors.border, lineWidth: AppSpacing.gridGutter)
        )
    }
}

#Preview {
    ThemeSelectorView(selectedTheme: .constant(.system))
        .padding(AppSpacing.screenPadding)
        .background(AppColors.background)
}
#endif
