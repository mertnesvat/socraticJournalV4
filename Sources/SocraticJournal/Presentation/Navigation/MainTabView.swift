// MainTabView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Tab selection options for main navigation
public enum MainTab: Int, CaseIterable {
    case home
    case statistics
}

/// Main tab container with custom tab bar and floating plus button
public struct MainTabView: View {
    @State private var selectedTab: MainTab = .home
    @State private var showingNewSession: Bool = false
    @Environment(ThemeManager.self) private var themeManager

    private let repository: JournalRepositoryProtocol
    private let settingsRepository: SettingsRepositoryProtocol
    private let notificationService: NotificationServiceProtocol?

    // HomeViewModel shared to trigger reload after session
    @State private var homeViewModel: HomeViewModel

    public init(
        repository: JournalRepositoryProtocol,
        settingsRepository: SettingsRepositoryProtocol,
        notificationService: NotificationServiceProtocol? = nil
    ) {
        self.repository = repository
        self.settingsRepository = settingsRepository
        self.notificationService = notificationService
        _homeViewModel = State(initialValue: HomeViewModel(repository: repository))
    }

    public var body: some View {
        ZStack(alignment: .bottom) {
            // Tab Content
            tabContent

            // Custom Tab Bar with floating button
            CustomTabBar(
                selectedTab: $selectedTab,
                onPlusTapped: {
                    showingNewSession = true
                }
            )
        }
        .fullScreenCover(isPresented: $showingNewSession) {
            // Reload data when session is dismissed
            Task {
                await homeViewModel.loadData()
            }
        } content: {
            DialogueSessionView(
                viewModel: DialogueSessionViewModel(
                    questionService: MockQuestionService(),
                    repository: repository
                ),
                repository: repository
            )
            .environment(themeManager)
            .preferredColorScheme(themeManager.colorScheme)
        }
    }

    @ViewBuilder
    private var tabContent: some View {
        switch selectedTab {
        case .home:
            HomeTabView(
                viewModel: homeViewModel,
                repository: repository,
                settingsRepository: settingsRepository,
                notificationService: notificationService
            )
        case .statistics:
            StatisticsTabView(
                viewModel: StatisticsViewModel(repository: repository)
            )
        }
    }
}

// MARK: - Custom Tab Bar

/// Custom tab bar with floating center plus button
struct CustomTabBar: View {
    @Binding var selectedTab: MainTab
    let onPlusTapped: () -> Void
    @Environment(\.colorScheme) private var colorScheme

    private let tabBarHeight: CGFloat = 60
    private let plusButtonSize: CGFloat = 56
    private let plusButtonOffset: CGFloat = -20

    var body: some View {
        ZStack {
            // Tab bar background
            tabBarBackground

            // Tab buttons
            HStack(spacing: 0) {
                // Home tab
                TabBarButton(
                    icon: "house",
                    filledIcon: "house.fill",
                    label: "Home",
                    isSelected: selectedTab == .home
                ) {
                    selectedTab = .home
                }

                // Center spacer for plus button
                Spacer()
                    .frame(width: plusButtonSize + 20)

                // Statistics tab
                TabBarButton(
                    icon: "chart.bar",
                    filledIcon: "chart.bar.fill",
                    label: "Stats",
                    isSelected: selectedTab == .statistics
                ) {
                    selectedTab = .statistics
                }
            }
            .padding(.horizontal, 40)

            // Floating Plus Button
            floatingPlusButton
                .offset(y: plusButtonOffset)
        }
        .frame(height: tabBarHeight)
        .padding(.bottom, 20) // Account for safe area
    }

    private var tabBarBackground: some View {
        Rectangle()
            .fill(Color(uiColor: .systemBackground))
            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: -4)
            .ignoresSafeArea(edges: .bottom)
    }

    private var floatingPlusButton: some View {
        Button(action: onPlusTapped) {
            ZStack {
                Circle()
                    .fill(Color.accentColor)
                    .frame(width: plusButtonSize, height: plusButtonSize)
                    .shadow(color: Color.accentColor.opacity(0.4), radius: 8, x: 0, y: 4)

                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(.white)
            }
        }
        .accessibilityLabel("Start new session")
    }
}

// MARK: - Tab Bar Button

/// Individual tab bar button
struct TabBarButton: View {
    let icon: String
    let filledIcon: String
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: isSelected ? filledIcon : icon)
                    .font(.system(size: 22))
                    .foregroundStyle(isSelected ? Color.accentColor : Color.secondary)

                Text(label)
                    .font(.caption2)
                    .foregroundStyle(isSelected ? Color.accentColor : Color.secondary)
            }
            .frame(maxWidth: .infinity)
        }
        .accessibilityLabel(label)
    }
}

#Preview {
    let repository = InMemoryJournalRepository()
    let settingsRepository = UserDefaultsSettingsRepository()
    return MainTabView(
        repository: repository,
        settingsRepository: settingsRepository
    )
    .environment(ThemeManager.shared)
}
#endif
