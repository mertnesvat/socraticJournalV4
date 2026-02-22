// AwardsBadgeView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Grid of achievement badges — 3-column editorial icon grid
struct AwardsBadgeView: View {
    let awards: [SpicyTakeAward]

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 3)

    var body: some View {
        VStack(spacing: 0) {
            SectionHeaderView("AWARDS")

            if awards.isEmpty {
                emptyState
                    .padding(.horizontal, AppSpacing.screenPadding)
            } else {
                awardsGrid
                    .padding(.horizontal, AppSpacing.screenPadding)
            }
        }
    }

    // MARK: - Awards Grid

    private var awardsGrid: some View {
        LazyVGrid(columns: columns, spacing: 0) {
            ForEach(Array(awards.enumerated()), id: \.element.id) { index, award in
                GridCell(isAccented: index == 0) {
                    VStack(spacing: AppSpacing.xs) {
                        Image(systemName: award.category.sfSymbol)
                            .font(.system(size: 24, weight: .light))
                            .foregroundStyle(index == 0 ? AppColors.textOnAccent : AppColors.textPrimary)

                        Text(award.category.displayTitle)
                            .font(AppTypography.caption)
                            .foregroundStyle(index == 0 ? AppColors.textOnAccent : AppColors.textSecondary)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                    }
                    .padding(.vertical, AppSpacing.lg)
                }
            }

            // Fill remaining cells to complete the row
            let remaining = (3 - (awards.count % 3)) % 3
            ForEach(0..<remaining, id: \.self) { _ in
                GridCell {
                    Color.clear
                        .frame(height: 80)
                }
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        HStack {
            Spacer()
            VStack(spacing: AppSpacing.xs) {
                Image(systemName: "trophy")
                    .font(.system(size: 24, weight: .light))
                    .foregroundStyle(AppColors.textTertiary)
                Text("No awards yet")
                    .font(AppTypography.bodyBold)
                    .foregroundStyle(AppColors.textSecondary)
                Text("Keep sharing your takes!")
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textTertiary)
            }
            .padding(.vertical, AppSpacing.lg)
            Spacer()
        }
    }
}

// MARK: - SpicyTakeCategory Display Extensions

extension SpicyTakeCategory {
    var emoji: String {
        switch self {
        case .mostControversial: return "!"
        case .mostPassionate: return "^"
        case .mostSurprising: return "?"
        }
    }

    var sfSymbol: String {
        switch self {
        case .mostControversial: return "bolt.fill"
        case .mostPassionate: return "flame"
        case .mostSurprising: return "sparkles"
        }
    }

    var displayTitle: String {
        switch self {
        case .mostControversial: return "Most Controversial"
        case .mostPassionate: return "Most Passionate"
        case .mostSurprising: return "Most Surprising"
        }
    }

    var backgroundColor: Color {
        switch self {
        case .mostControversial: return .red
        case .mostPassionate: return .orange
        case .mostSurprising: return .purple
        }
    }
}

#Preview {
    AwardsBadgeView(awards: MockDataProvider.awards)
        .background(AppColors.background)
}
#endif
