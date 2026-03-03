// LearnFeedView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

public struct LearnFeedView: View {
    @State private var viewModel = LearnFeedViewModel()

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.sectionGap) {
                    // Header
                    Text("Learn")
                        .font(AppTypography.display2)
                        .foregroundStyle(AppColors.textPrimary)
                        .padding(.top, AppSpacing.heroTopPadding)

                    // Category filter
                    CategoryFilterBar(selectedCategory: $viewModel.selectedCategory)

                    // Learning cards
                    ForEach(Array(viewModel.filteredBits.enumerated()), id: \.element.id) { index, bit in
                        LearningCard(
                            bit: bit,
                            useElevatedBackground: index % 2 == 0
                        )
                    }
                }
                .padding(.horizontal, AppSpacing.screenPadding)
                .padding(.bottom, AppSpacing.sectionGap)
            }
            .background(AppColors.background)
        }
    }
}
#endif
