// ProfileHeader.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Profile header with conversational greeting — no avatar, personality-driven
struct ProfileHeader: View {
    let user: User
    let questionsThisWeek: Int

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            // Greeting line
            Text("Hello \(user.displayName),")
                .font(AppTypography.headlineMedium)
                .foregroundStyle(AppColors.textPrimary)

            // Conversational stat line with accent number
            questionsText
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Attributed Questions Text

    private var questionsText: some View {
        (Text("you've answered ")
            .font(AppTypography.displayMedium)
            .foregroundStyle(AppColors.textPrimary)
        + Text("\(questionsThisWeek)")
            .font(AppTypography.displayMedium)
            .foregroundStyle(AppColors.accent)
        + Text(" questions this week")
            .font(AppTypography.displayMedium)
            .foregroundStyle(AppColors.textPrimary)
        )
        .lineSpacing(2)
    }
}

#Preview {
    ProfileHeader(
        user: MockDataProvider.currentUser,
        questionsThisWeek: 12
    )
    .padding(AppSpacing.screenPadding)
    .background(AppColors.background)
}
#endif
