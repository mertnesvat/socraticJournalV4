// MainTabView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Tab selection options for main navigation
public enum MainTab: Int, CaseIterable {
    case home
    case selfDiscovery
    case statistics
}

/// Main tab container with native tab bar and floating plus button
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
            // Native TabView with liquid glass effect
            TabView(selection: $selectedTab) {
                HomeTabView(
                    viewModel: homeViewModel,
                    repository: repository,
                    settingsRepository: settingsRepository,
                    notificationService: notificationService,
                    onStatsCardTapped: {
                        selectedTab = .statistics
                    }
                )
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(MainTab.home)

                SelfDiscoveryTabView()
                .tabItem {
                    Label("Discover", systemImage: "sparkles")
                }
                .tag(MainTab.selfDiscovery)

                StatisticsTabView(
                    viewModel: StatisticsViewModel(repository: repository)
                )
                .tabItem {
                    Label("Stats", systemImage: "chart.bar.fill")
                }
                .tag(MainTab.statistics)
            }

            // Floating Plus Button above tab bar
            floatingPlusButton
                .padding(.bottom, 60) // Position above tab bar
        }
        .fullScreenCover(isPresented: $showingNewSession) {
            // Reload data when session is dismissed
            Task {
                await homeViewModel.loadData()
            }
        } content: {
            DialogueSessionView(
                viewModel: DialogueSessionViewModel(
                    questionService: FirebaseQuestionService.shared,
                    repository: repository
                ),
                repository: repository
            )
            .environment(themeManager)
            .preferredColorScheme(themeManager.colorScheme)
        }
    }

    private var floatingPlusButton: some View {
        Button {
            showingNewSession = true
        } label: {
            ZStack {
                Circle()
                    .fill(Color.accentColor)
                    .frame(width: 56, height: 56)
                    .shadow(color: Color.accentColor.opacity(0.4), radius: 8, x: 0, y: 4)

                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(.white)
            }
        }
        .accessibilityLabel("Start new session")
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
