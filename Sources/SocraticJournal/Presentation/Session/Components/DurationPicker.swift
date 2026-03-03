// DurationPicker.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Segmented duration selector for session length
struct DurationPicker: View {
    @Binding var selectedMinutes: Int
    let options: [Int] = [1, 3, 5, 10]

    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            ForEach(options, id: \.self) { minutes in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedMinutes = minutes
                    }
                } label: {
                    Text("\(minutes) min")
                        .font(AppTypography.bodyBold)
                        .foregroundStyle(
                            selectedMinutes == minutes
                                ? AppColors.textOnAccent
                                : AppColors.textPrimary
                        )
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppSpacing.sm)
                        .background(
                            Capsule()
                                .fill(
                                    selectedMinutes == minutes
                                        ? AppColors.accent
                                        : AppColors.surfaceElevated
                                )
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }
}
#endif
