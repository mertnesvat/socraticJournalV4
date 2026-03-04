// MainTabView.swift
// Breathe
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

public enum MainTab: Int, CaseIterable {
    case today
    case breathe
    case learn

    var title: String {
        switch self {
        case .today: return "Today"
        case .breathe: return "Breathe"
        case .learn: return "Learn"
        }
    }
}

struct MainTabView: View {
    @State private var selectedTab: MainTab = .today
    @State private var showSettings: Bool = false
    @Environment(ThemeManager.self) private var themeManager

    let settingsRepository: SettingsRepositoryProtocol
    let sessionRepository: BreathSessionRepositoryProtocol
    let analyticsService: AnalyticsServiceProtocol

    init(
        settingsRepository: SettingsRepositoryProtocol,
        sessionRepository: BreathSessionRepositoryProtocol,
        analyticsService: AnalyticsServiceProtocol
    ) {
        self.settingsRepository = settingsRepository
        self.sessionRepository = sessionRepository
        self.analyticsService = analyticsService
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Page header
            pageHeader

            // Content
            ZStack {
                switch selectedTab {
                case .today:
                    TodayDashboardView(
                        sessionRepository: sessionRepository,
                        settingsRepository: settingsRepository
                    )
                case .breathe:
                    BreatheView(sessionRepository: sessionRepository)
                case .learn:
                    LearnFeedView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Tab bar
            tabBar
        }
        .background(AppColors.background)
        .ignoresSafeArea(.keyboard)
        .sheet(isPresented: $showSettings) {
            SettingsView(
                viewModel: SettingsViewModel(settingsRepository: settingsRepository)
            )
            .environment(themeManager)
            .preferredColorScheme(themeManager.colorScheme)
        }
    }

    // MARK: - Page Header

    private var pageHeader: some View {
        VStack(spacing: 0) {
            HStack {
                Text(selectedTab.title.uppercased())
                    .font(.system(size: 11, weight: .bold))
                    .tracking(1.5)
                    .foregroundStyle(AppColors.accent)

                Spacer()

                Button {
                    showSettings = true
                } label: {
                    Image(systemName: "gearshape")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(AppColors.textTertiary)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)

            HairlineDivider()
        }
    }

    // MARK: - Tab Bar

    private var tabBar: some View {
        VStack(spacing: 0) {
            HairlineDivider()

            HStack(spacing: 0) {
                ForEach(MainTab.allCases, id: \.rawValue) { tab in
                    tabButton(for: tab)
                }
            }
            .padding(.top, 10)
            .padding(.bottom, safeAreaBottom > 0 ? safeAreaBottom : 20)
            .background(AppColors.background)
        }
    }

    private func tabButton(for tab: MainTab) -> some View {
        let isSelected = selectedTab == tab

        return Button {
            selectedTab = tab
        } label: {
            VStack(spacing: 4) {
                Circle()
                    .fill(isSelected ? AppColors.accent : Color.clear)
                    .frame(width: 5, height: 5)
                    .padding(.bottom, 2)

                Text(tab.title.uppercased())
                    .font(AppTypography.tabLabel)
                    .fontWeight(isSelected ? .bold : .regular)
                    .foregroundStyle(isSelected ? AppColors.accent : AppColors.textTertiary)
                    .tracking(0.7)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var safeAreaBottom: CGFloat {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        return windowScene?.windows.first?.safeAreaInsets.bottom ?? 0
    }
}
#endif
