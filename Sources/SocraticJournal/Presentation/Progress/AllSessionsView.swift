// AllSessionsView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Full session history pushed from the Progress view
struct AllSessionsView: View {
    let dateGroups: [ProgressViewModel.DateGroup]
    let viewModel: ProgressViewModel

    var body: some View {
        ScrollView {
            SessionHistoryList(dateGroups: dateGroups, viewModel: viewModel)
        }
        .background(AppColors.background)
        .navigationTitle("All Sessions")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(AppColors.background, for: .navigationBar)
        .toolbarColorScheme(.light, for: .navigationBar)
    }
}
#endif
