// ProfileView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// User Profile & Streak Dashboard - main view for the Profile tab
public struct ProfileView: View {
    @State private var viewModel: ProfileViewModel

    public init(viewModel: ProfileViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        NavigationStack {
            content
                .navigationTitle("Profile")
                .toolbar { toolbarContent }
                .sheet(isPresented: $viewModel.showingEditProfile) {
                    // Reload profile after edit
                    Task { await viewModel.loadProfile() }
                } content: {
                    if let profile = viewModel.userProfile {
                        EditProfileSheet(
                            profile: profile,
                            onSave: { updatedProfile in
                                Task {
                                    await viewModel.updateProfile(updatedProfile)
                                }
                            }
                        )
                    }
                }
                .sheet(isPresented: $viewModel.showingSettings) {
                    ProfileSettingsPlaceholderView()
                }
                .task {
                    await viewModel.loadProfile()
                    await viewModel.loadStats()
                }
        }
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading && viewModel.userProfile == nil {
            ProgressView("Loading profile...")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            ScrollView {
                VStack(spacing: 24) {
                    profileHeader
                    streakSection
                    statsGrid
                    recentAnswersSection
                    Spacer(minLength: 40)
                }
                .padding()
            }
            .background(Color(uiColor: .systemGroupedBackground))
        }
    }

    // MARK: - Profile Header

    private var profileHeader: some View {
        VStack(spacing: 12) {
            // Avatar with edit overlay
            ZStack(alignment: .bottomTrailing) {
                Image(systemName: viewModel.userProfile?.avatarImageName ?? "person.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(Color.accentColor)
                    .frame(width: 100, height: 100)

                Image(systemName: "pencil.circle.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(.white, Color.accentColor)
                    .offset(x: 4, y: 4)
            }

            // Display name
            Text(viewModel.userProfile?.displayName ?? "User")
                .font(.system(size: 20, weight: .bold))

            // Username
            Text("@\(viewModel.userProfile?.username ?? "username")")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            // Edit Profile button
            Button {
                viewModel.showingEditProfile = true
            } label: {
                Text("Edit Profile")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.accentColor)
            }
        }
        .padding(.top, 8)
    }

    // MARK: - Streak Section

    private var streakSection: some View {
        VStack(spacing: 16) {
            // Fire icon with glow
            Image(systemName: "flame.fill")
                .font(.system(size: 44))
                .foregroundStyle(viewModel.currentStreak > 0 ? .orange : .gray)
                .shadow(color: .orange.opacity(0.5), radius: viewModel.currentStreak > 0 ? 10 : 0)

            // Current streak number
            Text("\(viewModel.currentStreak)")
                .font(.system(size: 48, weight: .bold, design: .rounded))

            Text("day streak")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            // Best streak
            Text("Best: \(viewModel.longestStreak) days")
                .font(.caption)
                .foregroundStyle(.tertiary)

            // Weekly activity dots
            weeklyActivityDots

            // Streak milestone badges
            streakMilestoneBadges

            // Motivational text when streak is 0
            if viewModel.currentStreak == 0 {
                Text("Start your streak today!")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.orange)
                    .padding(.top, 4)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(uiColor: .secondarySystemGroupedBackground))
        )
    }

    private var weeklyActivityDots: some View {
        VStack(spacing: 4) {
            HStack(spacing: 12) {
                ForEach(0..<7, id: \.self) { index in
                    Circle()
                        .fill(viewModel.weeklyActivity[index] ? Color.accentColor : Color.clear)
                        .stroke(viewModel.weeklyActivity[index] ? Color.accentColor : Color.secondary.opacity(0.3), lineWidth: 2)
                        .frame(width: 28, height: 28)
                }
            }

            HStack(spacing: 12) {
                ForEach(["M", "T", "W", "T", "F", "S", "S"], id: \.self) { day in
                    Text(day)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .frame(width: 28)
                }
            }
        }
    }

    private var streakMilestoneBadges: some View {
        HStack(spacing: 16) {
            if viewModel.longestStreak >= 7 {
                milestoneBadge(icon: "star.fill", color: .brown, label: "7 days")
            }
            if viewModel.longestStreak >= 30 {
                milestoneBadge(icon: "star.fill", color: .gray, label: "30 days")
            }
            if viewModel.longestStreak >= 100 {
                milestoneBadge(icon: "star.fill", color: .yellow, label: "100 days")
            }
        }
    }

    private func milestoneBadge(icon: String, color: Color, label: String) -> some View {
        VStack(spacing: 2) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Stats Grid

    private var statsGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ], spacing: 12) {
            statCard(
                icon: "number",
                value: "\(viewModel.totalAnswers)",
                label: "Questions Answered"
            )
            statCard(
                icon: "person.2.fill",
                value: "\(viewModel.friendCount)",
                label: "Friends"
            )
            statCard(
                icon: "headphones",
                value: "8 min",
                label: "Listening Time"
            )
            statCard(
                icon: "calendar",
                value: "Thursday",
                label: "Top Day"
            )
        }
    }

    private func statCard(icon: String, value: String, label: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(Color.accentColor)

            Text(value)
                .font(.title3.weight(.bold))

            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(uiColor: .secondarySystemGroupedBackground))
        )
    }

    // MARK: - Recent Answers

    private var recentAnswersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Answers")
                    .font(.headline)
                Spacer()
                Button("See All") {
                    // Placeholder action
                }
                .font(.subheadline)
            }

            VStack(spacing: 0) {
                ForEach(viewModel.recentAnswers) { answer in
                    Button {
                        // Placeholder tap action
                    } label: {
                        recentAnswerRow(answer)
                    }
                    .buttonStyle(.plain)

                    if answer.id != viewModel.recentAnswers.last?.id {
                        Divider()
                            .padding(.leading, 16)
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(uiColor: .secondarySystemGroupedBackground))
            )
        }
    }

    private func recentAnswerRow(_ answer: ProfileViewModel.RecentAnswer) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(answer.date, style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(answer.questionPreview)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }

            Spacer()

            Text(answer.formattedDuration)
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(Color(uiColor: .tertiarySystemGroupedBackground))
                )
        }
        .padding(16)
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                viewModel.showingSettings = true
            } label: {
                Image(systemName: "gearshape")
                    .font(.body)
            }
        }
    }
}

// MARK: - Profile Settings Placeholder

/// Lightweight settings placeholder presented from the Profile tab
/// The full SettingsView requires additional repository dependencies
/// that are not available in the Profile tab context
private struct ProfileSettingsPlaceholderView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section("Account") {
                    Label("Notifications", systemImage: "bell")
                    Label("Privacy", systemImage: "lock")
                }
                Section("App") {
                    Label("Appearance", systemImage: "paintbrush")
                    Label("Data & Storage", systemImage: "internaldrive")
                }
                Section("Support") {
                    Label("Help Center", systemImage: "questionmark.circle")
                    Label("About", systemImage: "info.circle")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.body.weight(.medium))
                    }
                }
            }
        }
    }
}
#endif
