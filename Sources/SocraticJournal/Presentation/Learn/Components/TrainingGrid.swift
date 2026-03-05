// TrainingGrid.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// 2x2 grid of training exercise cards for the Learn tab
struct TrainingGrid: View {
    let onSelectExercise: (TrainingData.Exercise) -> Void

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("TRAINING")
                .font(.system(size: 11))
                .tracking(1.0)
                .foregroundStyle(AppColors.textTertiary)
                .padding(.horizontal, AppSpacing.screenPadding)

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(TrainingData.allExercises) { exercise in
                    TrainingExerciseCard(
                        exercise: exercise,
                        completionCount: TrainingData.completionCount(for: exercise.id),
                        onTap: { onSelectExercise(exercise) }
                    )
                }
            }
            .padding(.horizontal, AppSpacing.screenPadding)
        }
        .padding(.vertical, AppSpacing.md)
    }
}

// MARK: - Exercise Card

private struct TrainingExerciseCard: View {
    let exercise: TrainingData.Exercise
    let completionCount: Int
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 6) {
                Image(systemName: exercise.icon)
                    .font(.system(size: 20))
                    .foregroundStyle(AppColors.accent)

                Text(exercise.name)
                    .font(.system(size: 13, weight: .bold, design: .serif))
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                Spacer()

                HStack {
                    Text(exercise.duration)
                        .font(.system(size: 9))
                        .foregroundStyle(AppColors.textTertiary)

                    Spacer()

                    if completionCount > 0 {
                        Text("Done \(completionCount)\u{00d7}")
                            .font(.system(size: 9))
                            .foregroundStyle(AppColors.accent)
                    } else {
                        Text("New")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(AppColors.accent)
                            .clipShape(Capsule())
                    }
                }
            }
            .padding(12)
            .frame(height: 100)
            .frame(maxWidth: .infinity, alignment: .topLeading)
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
