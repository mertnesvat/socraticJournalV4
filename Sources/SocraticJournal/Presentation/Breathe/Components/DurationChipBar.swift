// DurationChipBar.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Duration selector chips (5 min, 10 min, 20 min)
public struct DurationChipBar: View {
    let durations: [BreatheViewModel.SessionDuration]
    let selected: BreatheViewModel.SessionDuration
    let onSelect: (BreatheViewModel.SessionDuration) -> Void

    public var body: some View {
        HStack(spacing: 10) {
            ForEach(durations, id: \.rawValue) { duration in
                let isSelected = duration == selected
                Button {
                    onSelect(duration)
                } label: {
                    Text(duration.label)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(isSelected ? AppColors.accent : AppColors.textSecondary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(isSelected ? AppColors.accentLight : Color.clear)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(isSelected ? AppColors.accent : AppColors.border, lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }
}

#Preview {
    DurationChipBar(
        durations: BreatheViewModel.SessionDuration.allCases,
        selected: .five,
        onSelect: { _ in }
    )
    .padding()
    .background(AppColors.background)
}
#endif
