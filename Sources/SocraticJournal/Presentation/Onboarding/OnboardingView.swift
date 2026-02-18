// OnboardingView.swift
// Circle
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI
import AVFoundation
import UserNotifications

/// Onboarding flow: concept screens → permissions → create first circle
struct OnboardingView: View {
    let settingsRepository: SettingsRepositoryProtocol
    let circleRepository: CircleRepositoryProtocol
    let authService: AuthServiceProtocol
    let currentUserId: String
    let onComplete: () -> Void

    @State private var currentPage = 0
    @State private var showCreateCircle = false
    @State private var createdCircle: Circle?
    @State private var showInviteShare = false

    private let pages = OnboardingPage.allPages

    var body: some View {
        ZStack {
            if showCreateCircle {
                onboardingCreateCircle
            } else if let circle = createdCircle, showInviteShare {
                onboardingInviteShare(circle: circle)
            } else {
                onboardingPages
            }
        }
        .animation(.easeInOut(duration: 0.3), value: currentPage)
        .animation(.easeInOut(duration: 0.3), value: showCreateCircle)
        .animation(.easeInOut(duration: 0.3), value: showInviteShare)
    }

    // MARK: - Onboarding Pages

    private var onboardingPages: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Button("Skip") {
                    finishOnboarding()
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding()
            }

            TabView(selection: $currentPage) {
                ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                    pageView(page)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))

            Button {
                if currentPage < pages.count - 1 {
                    withAnimation { currentPage += 1 }
                } else {
                    requestPermissions()
                }
            } label: {
                Text(currentPage < pages.count - 1 ? "Next" : "Get Started")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(.blue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }

    private func pageView(_ page: OnboardingPage) -> some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: page.icon)
                .font(.system(size: 80))
                .foregroundStyle(page.iconColor)
                .padding(.bottom, 8)

            Text(page.title)
                .font(.title.bold())
                .multilineTextAlignment(.center)

            Text(page.subtitle)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Spacer()
            Spacer()
        }
        .padding()
    }

    // MARK: - Create Circle

    private var onboardingCreateCircle: some View {
        OnboardingCreateCircleView(
            circleRepository: circleRepository,
            currentUserId: currentUserId,
            onCreate: { circle in
                createdCircle = circle
                showCreateCircle = false
                showInviteShare = true
            },
            onSkip: {
                finishOnboarding()
            }
        )
    }

    // MARK: - Invite Share

    private func onboardingInviteShare(circle: Circle) -> some View {
        VStack(spacing: 32) {
            Spacer()

            Text(circle.emoji)
                .font(.system(size: 80))

            Text("\"\(circle.name)\" is ready!")
                .font(.title2.bold())

            Text("Share the invite code with your\nclosest people to get started.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            VStack(spacing: 8) {
                Text("Invite Code")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(circle.inviteCode)
                    .font(.system(size: 32, weight: .bold, design: .monospaced))
                    .tracking(6)
            }
            .padding(20)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))

            VStack(spacing: 12) {
                ShareLink(
                    item: "Join my circle \"\(circle.name)\" on Circle! Use code: \(circle.inviteCode)",
                    subject: Text("Join my Circle"),
                    message: Text("I'd love to hear your voice every day")
                ) {
                    Label("Share Invite", systemImage: "square.and.arrow.up")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(.blue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }

                Button {
                    finishOnboarding()
                } label: {
                    Text("I'll do this later")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 24)

            Spacer()
        }
        .padding()
    }

    // MARK: - Helpers

    private func requestPermissions() {
        Task {
            // Request microphone
            await AVAudioApplication.requestRecordPermission()

            // Request notifications
            let center = UNUserNotificationCenter.current()
            try? await center.requestAuthorization(options: [.alert, .badge, .sound])

            await MainActor.run {
                showCreateCircle = true
            }
        }
    }

    private func finishOnboarding() {
        Task {
            var settings = (try? await settingsRepository.getSettings()) ?? .default
            settings.hasCompletedOnboarding = true
            try? await settingsRepository.saveSettings(settings)
            await MainActor.run {
                onComplete()
            }
        }
    }
}

// MARK: - Onboarding Page Model

struct OnboardingPage {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String

    static let allPages: [OnboardingPage] = [
        OnboardingPage(
            icon: "waveform.circle.fill",
            iconColor: .blue,
            title: "Hear the voices of\npeople who matter",
            subtitle: "Circle replaces endless scrolling with 5 minutes of real connection — through voice."
        ),
        OnboardingPage(
            icon: "questionmark.bubble.fill",
            iconColor: .purple,
            title: "One question,\nevery day",
            subtitle: "A thoughtful AI-generated prompt goes to everyone in your circle. No awkward \"how are you\" needed."
        ),
        OnboardingPage(
            icon: "person.2.circle.fill",
            iconColor: .orange,
            title: "Your circle,\nyour people",
            subtitle: "2-5 of your closest people. Partner, best friend, parent, sibling. The ones who matter most."
        ),
        OnboardingPage(
            icon: "play.circle.fill",
            iconColor: .green,
            title: "15 seconds\nof real connection",
            subtitle: "Record a short voice note. Listen to theirs. No typing, no performing. Just your voice."
        ),
    ]
}

// MARK: - Onboarding Create Circle

struct OnboardingCreateCircleView: View {
    let circleRepository: CircleRepositoryProtocol
    let currentUserId: String
    let onCreate: (Circle) -> Void
    let onSkip: () -> Void

    @State private var circleName = ""
    @State private var selectedEmoji = "👨‍👩‍👧"
    @State private var isCreating = false

    private let emojis = ["👨‍👩‍👧", "💬", "❤️", "🏠", "🌟", "🎯", "🤝", "☕️", "🎵", "🌈"]

    var body: some View {
        VStack(spacing: 24) {
            HStack {
                Spacer()
                Button("Skip") { onSkip() }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding()
            }

            Spacer()

            Text("Create your first circle")
                .font(.title2.bold())

            Text("Give it a name and pick an emoji.\nYou can always change these later.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            TextField("Circle name (e.g., Family)", text: $circleName)
                .font(.title3)
                .multilineTextAlignment(.center)
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .padding(.horizontal, 32)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
                ForEach(emojis, id: \.self) { emoji in
                    Button {
                        selectedEmoji = emoji
                    } label: {
                        Text(emoji)
                            .font(.largeTitle)
                            .frame(width: 50, height: 50)
                            .background(
                                selectedEmoji == emoji
                                    ? Color.blue.opacity(0.2)
                                    : Color(.secondarySystemBackground)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
            }
            .padding(.horizontal, 32)

            Spacer()

            Button {
                Task { await createCircle() }
            } label: {
                Group {
                    if isCreating {
                        ProgressView().tint(.white)
                    } else {
                        Text("Create Circle")
                            .font(.headline)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(circleName.trimmingCharacters(in: .whitespaces).isEmpty ? .gray.opacity(0.3) : .blue)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .disabled(circleName.trimmingCharacters(in: .whitespaces).isEmpty || isCreating)
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }

    private func createCircle() async {
        isCreating = true
        let circle = Circle(
            name: circleName.trimmingCharacters(in: .whitespaces),
            emoji: selectedEmoji,
            createdBy: currentUserId,
            memberIds: [currentUserId]
        )
        do {
            try await circleRepository.createCircle(circle)
            let member = CircleMember(userId: currentUserId, displayName: "You", role: .owner)
            try await circleRepository.addMember(member, to: circle.id)
            onCreate(circle)
        } catch {
            isCreating = false
        }
    }
}
#endif
