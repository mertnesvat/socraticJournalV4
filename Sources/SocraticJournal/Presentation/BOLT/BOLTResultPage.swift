// BOLTResultPage.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Page 3 of BOLT test: result display with tier classification
public struct BOLTResultPage: View {
    let score: TimeInterval
    let previousScore: BOLTScore?
    let sessionRepository: BreathSessionRepositoryProtocol
    let onSave: () -> Void
    let onRetake: () -> Void

    private var tier: BOLTTier { BOLTTier.from(score: score) }
    private var tierColor: Color { Color(hex: tier.colorHex) }

    public var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Spacer(minLength: 40)

                // Score display
                Text(String(format: "%.1f", score))
                    .font(.system(size: 56, weight: .bold, design: .serif))
                    .foregroundStyle(tierColor)

                Text("seconds")
                    .font(.system(size: 13))
                    .foregroundStyle(AppColors.textTertiary)
                    .padding(.top, 2)

                // Tier badge
                Text(tier.label.uppercased())
                    .font(.system(size: 10, weight: .bold))
                    .tracking(0.5)
                    .foregroundStyle(tierColor)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(tierColor.opacity(0.08))
                    )
                    .overlay(
                        Capsule()
                            .stroke(tierColor.opacity(0.2), lineWidth: 1)
                    )
                    .padding(.top, AppSpacing.sm)

                HairlineDivider()
                    .padding(.horizontal, AppSpacing.screenPadding)
                    .padding(.vertical, AppSpacing.lg)

                // Interpretation
                Text(tier.interpretation)
                    .font(.system(size: 13))
                    .foregroundStyle(AppColors.textPrimary)
                    .lineSpacing(13 * 0.75)
                    .padding(.horizontal, AppSpacing.screenPadding)

                // Previous score comparison
                if let previous = previousScore {
                    let trend = BOLTTier.trend(previous: previous.score, current: score)
                    let daysAgo = Calendar.current.dateComponents([.day], from: previous.recordedAt, to: Date()).day ?? 0

                    HStack(spacing: 4) {
                        Text("Previous: \(String(format: "%.1fs", previous.score)) (\(daysAgo) days ago)")
                            .font(.system(size: 11))
                            .foregroundStyle(AppColors.textTertiary)

                        Text(trend.symbol)
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(Color(hex: trend.colorHex))
                    }
                    .padding(.top, AppSpacing.md)
                    .padding(.horizontal, AppSpacing.screenPadding)
                }

                Spacer(minLength: AppSpacing.xxl)

                // Save button
                Button {
                    saveAndClose()
                } label: {
                    Text("SAVE & CLOSE")
                        .font(.system(size: 12, weight: .bold, design: .serif))
                        .tracking(1)
                        .foregroundStyle(AppColors.surface)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(AppColors.textPrimary)
                        )
                }
                .buttonStyle(.plain)
                .padding(.horizontal, AppSpacing.screenPadding)

                // Retake button
                Button(action: onRetake) {
                    Text("Retake")
                        .font(.system(size: 11))
                        .foregroundStyle(AppColors.accent)
                }
                .buttonStyle(.plain)
                .padding(.top, AppSpacing.sm)
                .padding(.bottom, AppSpacing.xxl)
            }
        }
        .background(AppColors.background)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
    }

    private func saveAndClose() {
        let boltScore = BOLTScore(score: score)
        Task {
            try? await sessionRepository.saveBOLTScore(boltScore)
        }
        onSave()
    }
}
#endif
