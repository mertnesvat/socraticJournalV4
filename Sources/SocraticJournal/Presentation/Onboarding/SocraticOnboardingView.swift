// SocraticOnboardingView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// New 5-page onboarding flow for the Socratic Journal social voice app
/// Pages: Hook -> How It Works -> Profile Setup -> Invite Friends -> First Question Teaser
public struct SocraticOnboardingView: View {
    @State private var viewModel: SocraticOnboardingViewModel
    private let onDismiss: () -> Void

    public init(
        viewModel: SocraticOnboardingViewModel,
        onDismiss: @escaping () -> Void
    ) {
        _viewModel = State(initialValue: viewModel)
        self.onDismiss = onDismiss
    }

    public var body: some View {
        ZStack(alignment: .bottom) {
            // Page content
            TabView(selection: $viewModel.currentPage) {
                hookPage.tag(0)
                howItWorksPage.tag(1)
                profileSetupPage.tag(2)
                inviteFriendsPage.tag(3)
                firstQuestionPage.tag(4)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.spring(response: 0.4, dampingFraction: 0.85), value: viewModel.currentPage)

            // Page indicator dots
            pageIndicator
                .padding(.bottom, 16)
        }
        .onChange(of: viewModel.isComplete) { _, isComplete in
            if isComplete {
                onDismiss()
            }
        }
        .task {
            await viewModel.loadTodaysQuestion()
        }
    }

    // MARK: - Page Indicator

    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<viewModel.totalPages, id: \.self) { index in
                Circle()
                    .fill(index == viewModel.currentPage ? Color.accentColor : Color.gray.opacity(0.4))
                    .frame(
                        width: index == viewModel.currentPage ? 10 : 8,
                        height: index == viewModel.currentPage ? 10 : 8
                    )
                    .animation(.easeInOut(duration: 0.2), value: viewModel.currentPage)
            }
        }
    }

    // MARK: - Page 0: Hook

    private var hookPage: some View {
        VStack(spacing: 32) {
            Spacer()

            Text("What do your friends\nREALLY think?")
                .font(.system(size: 32, weight: .bold))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            Text("Daily questions. Voice answers.\nNo hiding behind text.")
                .font(.title3)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            AudioWaveformView(
                mode: .idle,
                barCount: 40,
                barColor: Color.accentColor.opacity(0.3),
                activeColor: Color.accentColor
            )
            .frame(height: 60)
            .padding(.horizontal, 40)

            Spacer()

            Button {
                Task { await viewModel.nextPage() }
            } label: {
                Text("Get Started")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, 24)
            .padding(.bottom, 48)
        }
    }

    // MARK: - Page 1: How It Works

    private var howItWorksPage: some View {
        VStack(spacing: 32) {
            backButton

            Spacer()

            Text("How it works")
                .font(.title.bold())

            VStack(alignment: .leading, spacing: 24) {
                howItWorksStep(
                    icon: "questionmark.circle",
                    color: .blue,
                    text: "A new question drops every day"
                )
                howItWorksStep(
                    icon: "mic.circle",
                    color: .red,
                    text: "Record your honest answer"
                )
                howItWorksStep(
                    icon: "lock.open",
                    color: .green,
                    text: "Unlock your friends' answers"
                )
            }
            .padding(.horizontal, 32)

            Spacer()

            Button {
                Task { await viewModel.nextPage() }
            } label: {
                Text("Next")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, 24)
            .padding(.bottom, 48)
        }
    }

    private func howItWorksStep(icon: String, color: Color, text: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 36))
                .foregroundStyle(color)
                .frame(width: 48, height: 48)

            Text(text)
                .font(.body)
                .foregroundStyle(.primary)

            Spacer()
        }
    }

    // MARK: - Page 2: Profile Setup

    private var profileSetupPage: some View {
        ScrollView {
            VStack(spacing: 24) {
                backButton

                Text("Create your profile")
                    .font(.title.bold())
                    .padding(.top, 8)

                // Display name field
                VStack(alignment: .leading, spacing: 6) {
                    TextField("Your name", text: $viewModel.displayName)
                        .textContentType(.name)
                        .autocorrectionDisabled()
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                    if let nameError = viewModel.nameError {
                        Text(nameError)
                            .font(.caption)
                            .foregroundStyle(.red)
                            .padding(.leading, 4)
                    }
                }
                .padding(.horizontal, 24)

                // Username field
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 0) {
                        Text("@")
                            .foregroundStyle(.secondary)
                            .padding(.leading, 16)
                        TextField("username", text: $viewModel.username)
                            .textContentType(.username)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .padding(.vertical)
                            .padding(.trailing, 16)
                            .padding(.leading, 4)
                    }
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    if let usernameError = viewModel.usernameError {
                        Text(usernameError)
                            .font(.caption)
                            .foregroundStyle(.red)
                            .padding(.leading, 4)
                    }
                }
                .padding(.horizontal, 24)

                // Avatar picker
                VStack(spacing: 12) {
                    Text("Choose an avatar")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    LazyVGrid(columns: [
                        GridItem(.adaptive(minimum: 60), spacing: 16)
                    ], spacing: 16) {
                        ForEach(viewModel.avatarOptions, id: \.self) { avatarName in
                            Button {
                                viewModel.selectedAvatar = avatarName
                            } label: {
                                Image(systemName: avatarName)
                                    .font(.system(size: 40))
                                    .foregroundStyle(
                                        viewModel.selectedAvatar == avatarName
                                            ? Color.accentColor
                                            : Color.secondary
                                    )
                                    .frame(width: 60, height: 60)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(
                                                viewModel.selectedAvatar == avatarName
                                                    ? Color.accentColor.opacity(0.1)
                                                    : Color.clear
                                            )
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(
                                                viewModel.selectedAvatar == avatarName
                                                    ? Color.accentColor
                                                    : Color.clear,
                                                lineWidth: 2
                                            )
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 24)
                }

                Spacer(minLength: 24)

                Button {
                    Task { await viewModel.nextPage() }
                } label: {
                    if viewModel.isSaving {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                    } else {
                        Text("Continue")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.isSaving)
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
            }
        }
        .scrollDismissesKeyboard(.interactively)
    }

    // MARK: - Page 3: Invite Friends

    private var inviteFriendsPage: some View {
        VStack(spacing: 24) {
            backButton

            Spacer()

            Text("Invite 3 friends to get\nthe full experience")
                .font(.title2.bold())
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            Text("You need friends to unlock their voice answers")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            // Progress indicator
            VStack(spacing: 8) {
                Text("\(viewModel.friendsInvited)/3 friends invited")
                    .font(.headline)
                    .foregroundStyle(viewModel.friendsInvited >= 3 ? .green : .primary)

                ProgressView(value: Double(min(viewModel.friendsInvited, 3)), total: 3)
                    .tint(viewModel.friendsInvited >= 3 ? .green : .accentColor)
                    .padding(.horizontal, 60)
            }
            .padding(.top, 8)

            // Share invite link
            ShareLink(item: URL(string: "https://socratic.app/invite/mock")!) {
                Label("Share invite link", systemImage: "square.and.arrow.up")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, 24)

            // Search by username
            Button {
                viewModel.inviteFriend()
            } label: {
                Label("Search by username", systemImage: "magnifyingglass")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
            }
            .buttonStyle(.bordered)
            .padding(.horizontal, 24)

            Spacer()

            // Next / Skip
            if viewModel.friendsInvited >= 3 {
                Button {
                    Task { await viewModel.nextPage() }
                } label: {
                    Text("Next")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
                .buttonStyle(.borderedProminent)
                .padding(.horizontal, 24)
            }

            Button {
                Task { await viewModel.nextPage() }
            } label: {
                Text("Skip for now")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.bottom, 48)
        }
    }

    // MARK: - Page 4: First Question Teaser

    private var firstQuestionPage: some View {
        VStack(spacing: 32) {
            backButton

            Spacer()

            Text("Here's today's question...")
                .font(.title3)
                .foregroundStyle(.secondary)

            if let question = viewModel.todaysQuestion {
                Text(question.text)
                    .font(.system(size: 28, weight: .bold))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
            } else {
                ProgressView()
                    .padding()
            }

            Spacer()

            Button {
                Task { await viewModel.completeAndOpenRecording() }
            } label: {
                Label("Record Your First Answer", systemImage: "mic.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, 24)

            Button {
                Task { await viewModel.skipToApp() }
            } label: {
                Text("Skip for now")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.bottom, 48)
        }
        .animation(.easeIn(duration: 0.6), value: viewModel.todaysQuestion != nil)
    }

    // MARK: - Back Button

    private var backButton: some View {
        HStack {
            Button {
                viewModel.previousPage()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.primary)
                    .padding(8)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
}

// MARK: - Preview

#Preview {
    SocraticOnboardingView(
        viewModel: SocraticOnboardingViewModel(
            settingsRepository: PreviewOnboardingSettingsRepository(),
            userProfileRepository: MockUserProfileRepository(),
            friendshipRepository: MockFriendshipRepository(),
            questionRepository: MockQuestionRepository()
        ),
        onDismiss: { print("Onboarding dismissed") }
    )
}

/// Preview-only settings repository for onboarding
private final class PreviewOnboardingSettingsRepository: SettingsRepositoryProtocol {
    func getSettings() async throws -> UserSettings { UserSettings.default }
    func saveSettings(_ settings: UserSettings) async throws {}
    func resetSettings() async throws {}
    func clearAllData() async throws {}
}
#endif
