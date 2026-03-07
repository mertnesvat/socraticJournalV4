// AllBOLTScoresView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Full BOLT score history pushed from the Progress view
struct AllBOLTScoresView: View {
    let scores: [BOLTScore]

    var body: some View {
        ScrollView {
            BOLTHistoryList(recentScores: scores, allScores: scores)
        }
        .background(AppColors.background)
        .navigationTitle("BOLT History")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(AppColors.background, for: .navigationBar)
        .toolbarColorScheme(.light, for: .navigationBar)
    }
}
#endif
