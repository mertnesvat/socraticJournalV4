// ProgramDayCard.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Expandable day row in a program detail view
struct ProgramDayCard: View {
    let day: ProgramDay
    let isCompleted: Bool
    let isCurrent: Bool
    let isLocked: Bool
    let isExpanded: Bool
    let themeColorHex: String
    let viewModel: ProgramViewModel
    let onToggle: () -> Void
    let onStartPattern: (String, Int) -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Header
            Button(action: onToggle) {
                HStack(spacing: 12) {
                    // Status icon
                    statusIcon

                    VStack(alignment: .leading, spacing: 2) {
                        Text("DAY \(day.id)")
                            .font(.system(size: 10))
                            .tracking(0.8)
                            .foregroundStyle(AppColors.textTertiary)

                        Text(viewModel.prescriptionSummary(for: day))
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(isLocked ? AppColors.textTertiary : AppColors.textPrimary)
                            .lineLimit(2)
                    }

                    Spacer()

                    if isLocked {
                        Image(systemName: "lock")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(AppColors.textTertiary)
                    } else {
                        Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(AppColors.textTertiary)
                    }
                }
                .padding(.horizontal, AppSpacing.screenPadding)
                .padding(.vertical, 14)
            }
            .buttonStyle(.plain)
            .disabled(isLocked)

            // Expanded content
            if isExpanded && !isLocked {
                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    HairlineDivider()
                        .padding(.horizontal, AppSpacing.screenPadding)

                    // Daily tip
                    Text(day.tip)
                        .font(.system(size: 13))
                        .foregroundStyle(AppColors.textPrimary)
                        .lineSpacing(6)
                        .padding(.horizontal, AppSpacing.screenPadding)

                    // Start buttons for each prescription
                    ForEach(day.prescriptions) { prescription in
                        Button {
                            onStartPattern(prescription.patternId, prescription.durationMinutes)
                        } label: {
                            Text("Start \(viewModel.patternName(for: prescription.patternId)) \u{00b7} \(prescription.durationMinutes) min")
                                .font(.system(size: 12, weight: .regular, design: .serif))
                                .tracking(0.5)
                                .foregroundStyle(Color(hex: themeColorHex))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(Color(hex: themeColorHex), lineWidth: 1)
                                )
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, AppSpacing.screenPadding)
                    }
                }
                .padding(.bottom, 14)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    @ViewBuilder
    private var statusIcon: some View {
        if isCompleted {
            ZStack {
                Circle()
                    .fill(Color(hex: themeColorHex))
                    .frame(width: 22, height: 22)
                Image(systemName: "checkmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.white)
            }
        } else if isCurrent {
            ZStack {
                Circle()
                    .stroke(Color(hex: themeColorHex), lineWidth: 1.5)
                    .frame(width: 22, height: 22)
                Circle()
                    .fill(Color(hex: themeColorHex))
                    .frame(width: 6, height: 6)
            }
        } else {
            Circle()
                .stroke(AppColors.border, lineWidth: 1.5)
                .frame(width: 22, height: 22)
        }
    }
}
#endif
