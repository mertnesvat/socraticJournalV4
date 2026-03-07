// AllSessionsView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Full session history pushed from Progress view
struct AllSessionsView: View {
    let dateGroups: [ProgressViewModel.DateGroup]
    let viewModel: ProgressViewModel

    var body: some View {
        ScrollView {
            SessionHistoryList(
                dateGroups: dateGroups,
                viewModel: viewModel,
                showAll: true
            )
        }
        .background(AppColors.background)
        .navigationTitle("All Sessions")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(AppColors.background, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("All Sessions")
                    .font(.system(size: 18, weight: .bold, design: .serif))
                    .foregroundStyle(AppColors.textPrimary)
            }
        }
    }
}
#endif
