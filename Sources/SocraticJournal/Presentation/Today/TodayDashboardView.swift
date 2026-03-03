// TodayDashboardView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

public struct TodayDashboardView: View {
    let breathSessionRepository: BreathSessionRepositoryProtocol
    let settingsRepository: SettingsRepositoryProtocol
    let notificationService: NotificationServiceProtocol
    let analyticsService: AnalyticsServiceProtocol

    @State private var showSettings = false
    @Environment(ThemeManager.self) private var themeManager

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.sectionGap) {
                    // Header
                    VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                        Text("Today")
                            .font(AppTypography.display2)
                            .foregroundStyle(AppColors.textPrimary)
                        Text(formattedDate)
                            .font(AppTypography.caption)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                    .padding(.top, AppSpacing.heroTopPadding)

                    // Placeholder for daily progress card (Feature 3)
                    VStack(spacing: AppSpacing.sm) {
                        Text("0")
                            .font(AppTypography.statLarge)
                            .foregroundStyle(AppColors.accent)
                        Text("minutes today")
                            .font(AppTypography.caption)
                            .foregroundStyle(AppColors.textSecondary)
                        Text("Start your first session")
                            .font(AppTypography.body)
                            .foregroundStyle(AppColors.textTertiary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(AppSpacing.cardPadding)
                    .background(AppColors.surface)
                    .overlay(
                        Rectangle()
                            .stroke(AppColors.border, lineWidth: AppSpacing.gridGutter)
                    )

                    // Technique cards section
                    SectionHeaderView("Techniques", showTopBorder: false)

                    ForEach(BreathTechnique.allTechniques) { technique in
                        techniqueCard(technique)
                    }
                }
                .padding(.horizontal, AppSpacing.screenPadding)
                .padding(.bottom, AppSpacing.sectionGap)
            }
            .background(AppColors.background)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                            .foregroundStyle(AppColors.textPrimary)
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView(
                    viewModel: SettingsViewModel(
                        settingsRepository: settingsRepository,
                        notificationService: notificationService,
                        analyticsService: analyticsService
                    )
                )
                .environment(themeManager)
                .preferredColorScheme(themeManager.colorScheme)
            }
        }
    }

    @ViewBuilder
    private func techniqueCard(_ technique: BreathTechnique) -> some View {
        let bgColor: Color = {
            switch technique.id {
            case "resonant": return AppColors.cardTeal
            case "box": return AppColors.surface
            case "478": return AppColors.cardYellow
            default: return AppColors.surfaceElevated
            }
        }()

        HStack {
            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                Text(technique.name)
                    .font(AppTypography.headlineMedium)
                    .foregroundStyle(AppColors.textPrimary)
                Text(technique.subtitle)
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.textSecondary)
                Text(timingString(for: technique))
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textTertiary)

                Text(technique.difficulty.rawValue.capitalized)
                    .font(AppTypography.captionBold)
                    .foregroundStyle(AppColors.accent)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(AppColors.accent.opacity(0.12)))
                    .padding(.top, AppSpacing.xxs)
            }

            Spacer()

            Image(systemName: "play.fill")
                .font(.system(size: 24))
                .foregroundStyle(AppColors.accent)
        }
        .padding(AppSpacing.cardPadding)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(bgColor)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(technique.id == "box" ? AppColors.border : Color.clear, lineWidth: AppSpacing.gridGutter)
        )
    }

    private func timingString(for technique: BreathTechnique) -> String {
        technique.phases.map { phase in
            let seconds = phase.duration
            if seconds == floor(seconds) {
                return "\(Int(seconds))s"
            } else {
                return String(format: "%.1fs", seconds)
            }
        }
        .joined(separator: " · ")
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: Date())
    }
}
#endif
