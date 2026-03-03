// DurationPicker.swift
// Breathe
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Horizontal row of duration pill buttons for session setup
struct DurationPicker: View {
    @Binding var selectedDuration: TimeInterval

    private let options: [(label: String, seconds: TimeInterval)] = [
        ("3 min", 180),
        ("5 min", 300),
        ("10 min", 600),
        ("20 min", 1200)
    ]

    var body: some View {
        HStack(spacing: AppSpacing.xs) {
            ForEach(options, id: \.seconds) { option in
                durationPill(label: option.label, seconds: option.seconds)
            }
        }
    }

    private func durationPill(label: String, seconds: TimeInterval) -> some View {
        let isSelected = selectedDuration == seconds

        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedDuration = seconds
            }
        } label: {
            Text(label)
                .font(AppTypography.captionBold)
                .foregroundStyle(isSelected ? AppColors.textOnAccent : AppColors.textPrimary)
                .padding(.horizontal, AppSpacing.md)
                .padding(.vertical, AppSpacing.sm)
                .background(
                    Capsule()
                        .fill(isSelected ? AppColors.accent : Color.clear)
                )
                .overlay(
                    Capsule()
                        .stroke(isSelected ? Color.clear : AppColors.border, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ZStack {
        AppColors.background.ignoresSafeArea()
        DurationPicker(selectedDuration: .constant(300))
            .padding()
    }
}
#endif
