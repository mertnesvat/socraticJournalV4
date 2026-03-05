// ProgramCard.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Card displaying a breath program in the browser list
public struct ProgramCard: View {
    let program: BreathProgram
    let isActive: Bool
    let progress: ProgramProgress?

    public init(program: BreathProgram, isActive: Bool = false, progress: ProgramProgress? = nil) {
        self.program = program
        self.isActive = isActive
        self.progress = progress
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack(spacing: AppSpacing.sm) {
                Image(systemName: program.iconSystemName)
                    .font(.system(size: 20))
                    .foregroundStyle(AppColors.accent)
                    .frame(width: 36, height: 36)
                    .background(AppColors.accentLight)
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(program.name)
                            .font(.system(size: 15, weight: .bold, design: .serif))
                            .foregroundStyle(AppColors.textPrimary)

                        if isActive {
                            Text("ACTIVE")
                                .font(.system(size: 9, weight: .heavy))
                                .tracking(0.8)
                                .foregroundStyle(AppColors.accent)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(
                                    RoundedRectangle(cornerRadius: 3)
                                        .fill(AppColors.accentLight)
                                )
                        }
                    }

                    Text(program.subtitle)
                        .font(.system(size: 12))
                        .foregroundStyle(AppColors.textSecondary)
                }

                Spacer()

                Text("\(program.totalDays)d")
                    .font(.system(size: 13, weight: .semibold, design: .serif))
                    .foregroundStyle(AppColors.textTertiary)
            }

            if let progress = progress, isActive {
                // Progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(AppColors.surface)
                            .frame(height: 4)

                        RoundedRectangle(cornerRadius: 2)
                            .fill(AppColors.accent)
                            .frame(width: geo.size.width * progress.progressFraction, height: 4)
                    }
                }
                .frame(height: 4)

                Text("Day \(progress.currentDay) of \(progress.totalDays)")
                    .font(.system(size: 11))
                    .foregroundStyle(AppColors.textTertiary)
            }
        }
        .padding(AppSpacing.cardPadding)
    }
}

#Preview {
    VStack(spacing: 0) {
        ProgramCard(program: .calmFoundation, isActive: true, progress: ProgramProgress(
            programId: "calm-foundation", currentDay: 4, completedDays: [1, 2, 3], totalDays: 7
        ))
        HairlineDivider()
        ProgramCard(program: .sleepReset)
    }
    .background(AppColors.background)
}
#endif
