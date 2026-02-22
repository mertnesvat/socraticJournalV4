// ProfileView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Main profile screen displaying the user's voice identity, stats, and achievements
public struct ProfileView: View {
    @State private var viewModel: ProfileViewModel
    @State private var showingSettings: Bool = false
    @Environment(ThemeManager.self) private var themeManager

    // Services passed through for SettingsView
    private let settingsRepository: SettingsRepositoryProtocol?
    private let notificationService: NotificationServiceProtocol?
    private let subscriptionService: SubscriptionServiceProtocol?
    private let analyticsService: AnalyticsServiceProtocol?

    public init(
        viewModel: ProfileViewModel,
        settingsRepository: SettingsRepositoryProtocol? = nil,
        notificationService: NotificationServiceProtocol? = nil,
        subscriptionService: SubscriptionServiceProtocol? = nil,
        analyticsService: AnalyticsServiceProtocol? = nil
    ) {
        _viewModel = State(initialValue: viewModel)
        self.settingsRepository = settingsRepository
        self.notificationService = notificationService
        self.subscriptionService = subscriptionService
        self.analyticsService = analyticsService
    }

    public var body: some View {
        content
            .sheet(isPresented: $showingSettings) {
                settingsSheet
            }
            .task { await viewModel.loadData() }
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading && viewModel.user == nil {
            ProgressView("Loading profile...")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(AppColors.background)
        } else if let errorMessage = viewModel.errorMessage, viewModel.user == nil {
            ContentUnavailableView(
                "Unable to Load Profile",
                systemImage: "exclamationmark.triangle",
                description: Text(errorMessage)
            )
            .background(AppColors.background)
        } else {
            profileContent
        }
    }

    private var profileContent: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Top bar with settings gear
                topBar

                // Conversational greeting
                if let user = viewModel.user {
                    ProfileHeader(
                        user: user,
                        questionsThisWeek: viewModel.questionsAnswered
                    )
                    .padding(.horizontal, AppSpacing.screenPadding)
                    .padding(.bottom, AppSpacing.sectionGap)
                }

                // Three stat cards stacked vertically
                StatsRow(
                    questionsAnswered: viewModel.questionsAnswered,
                    streakDays: viewModel.streak?.currentStreak ?? 0,
                    friendCount: viewModel.user?.friendCount ?? 0
                )
                .padding(.horizontal, AppSpacing.screenPadding)
                .padding(.bottom, AppSpacing.sectionGap)

                // Streak calendar
                StreakCalendar(
                    weeklyDays: viewModel.weeklyStreakDays,
                    todayIndex: viewModel.todayWeekdayIndex
                )
                .padding(.bottom, AppSpacing.sectionGap)

                // Spicy takes section
                if !viewModel.spicyTakes.isEmpty {
                    SpicyTakesSection(takes: viewModel.spicyTakes)
                        .padding(.bottom, AppSpacing.sectionGap)
                }

                // Awards section
                AwardsBadgeView(awards: viewModel.awards)
                    .padding(.bottom, AppSpacing.sectionGap)

                // Sign out button
                signOutButton
                    .padding(.horizontal, AppSpacing.screenPadding)

                Spacer(minLength: 100)
            }
        }
        .background(AppColors.background)
        .refreshable {
            await viewModel.loadData()
        }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            Spacer()

            Button {
                showingSettings = true
            } label: {
                Image(systemName: "gearshape")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
        .padding(.horizontal, AppSpacing.screenPadding)
        .padding(.top, AppSpacing.md)
        .padding(.bottom, AppSpacing.xs)
    }

    // MARK: - Sign Out

    private var signOutButton: some View {
        Button {
            // Sign out action -- placeholder for auth integration
        } label: {
            Text("Sign Out")
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textSecondary)
        }
        .padding(.top, AppSpacing.xs)
    }

    // MARK: - Settings Sheet

    @ViewBuilder
    private var settingsSheet: some View {
        if let settingsRepository = settingsRepository {
            SettingsView(
                viewModel: SettingsViewModel(
                    settingsRepository: settingsRepository,
                    notificationService: notificationService,
                    subscriptionService: subscriptionService,
                    analyticsService: analyticsService
                )
            )
            .environment(themeManager)
            .preferredColorScheme(themeManager.colorScheme)
        } else {
            // Fallback minimal settings if no repository is provided
            NavigationStack {
                Text("Settings unavailable")
                    .foregroundStyle(.secondary)
                    .navigationTitle("Settings")
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button {
                                showingSettings = false
                            } label: {
                                Image(systemName: "xmark")
                                    .font(.body.weight(.medium))
                            }
                        }
                    }
            }
        }
    }
}

#Preview {
    ProfileView(
        viewModel: ProfileViewModel(userProfileService: MockUserProfileService())
    )
    .environment(ThemeManager.shared)
}
#endif
