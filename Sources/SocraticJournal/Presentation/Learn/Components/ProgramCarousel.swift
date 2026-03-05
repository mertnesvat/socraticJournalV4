// ProgramCarousel.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Horizontal scrolling program cards for the Learn tab
struct ProgramCarousel: View {
    let onSelectProgram: (Program) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("PROGRAMS")
                .font(.system(size: 11))
                .tracking(1.0)
                .foregroundStyle(AppColors.textTertiary)
                .padding(.horizontal, AppSpacing.screenPadding)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(ProgramData.allPrograms) { program in
                        ProgramCard(
                            program: program,
                            progress: ProgramViewModel.progressFor(programId: program.id),
                            onTap: { onSelectProgram(program) }
                        )
                    }
                }
                .padding(.horizontal, AppSpacing.screenPadding)
            }
        }
        .padding(.vertical, AppSpacing.md)
    }
}

// MARK: - Program Card

private struct ProgramCard: View {
    let program: Program
    let progress: ProgramProgress?
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                Text(program.name)
                    .font(.system(size: 15, weight: .bold, design: .serif))
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                // Duration badge
                Text("\(program.totalDays) days")
                    .font(.system(size: 10, weight: .bold))
                    .tracking(0.8)
                    .foregroundStyle(Color(hex: program.themeColorHex))
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color(hex: program.themeColorHex).opacity(0.08))
                    )

                Spacer()

                if let progress {
                    // Progress bar
                    VStack(alignment: .leading, spacing: 4) {
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 1.5)
                                    .fill(AppColors.surface)
                                    .frame(height: 3)

                                RoundedRectangle(cornerRadius: 1.5)
                                    .fill(Color(hex: program.themeColorHex))
                                    .frame(
                                        width: geo.size.width * CGFloat(progress.completedDays.count) / CGFloat(program.totalDays),
                                        height: 3
                                    )
                            }
                        }
                        .frame(height: 3)

                        Text("Day \(progress.currentDay)")
                            .font(.system(size: 9))
                            .foregroundStyle(Color(hex: program.themeColorHex))
                    }
                } else {
                    HStack {
                        Spacer()
                        Text("START")
                            .font(.system(size: 10))
                            .tracking(0.8)
                            .foregroundStyle(Color(hex: program.themeColorHex))
                    }
                }
            }
            .padding(14)
            .frame(width: 200, height: 120, alignment: .topLeading)
            .background(AppColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(AppColors.border, lineWidth: 0.5)
            )
        }
        .buttonStyle(.plain)
    }
}
#endif
