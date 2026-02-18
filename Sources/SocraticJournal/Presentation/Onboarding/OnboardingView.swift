// OnboardingView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Four-screen onboarding flow that introduces the Circle app,
/// explains how it works, optionally creates a circle, and requests notifications.
public struct OnboardingView: View {
    @State private var viewModel: OnboardingViewModel
    private let onComplete: () -> Void

    public init(viewModel: OnboardingViewModel, onComplete: @escaping () -> Void) {
        _viewModel = State(initialValue: viewModel)
        self.onComplete = onComplete
    }

    public var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $viewModel.currentPage) {
                welcomeScreen
                    .tag(0)

                howItWorksScreen
                    .tag(1)

                createCircleScreen
                    .tag(2)

                readyScreen
                    .tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            .animation(.easeInOut(duration: 0.3), value: viewModel.currentPage)
        }
        .background(Color(.systemBackground))
    }

    // MARK: - Screen 1: Welcome

    private var welcomeScreen: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 24) {
                Text("\u{1F4AC}")
                    .font(.system(size: 80))
                    .accessibilityLabel("Speech bubble")

                VStack(spacing: 16) {
                    Text("The people you love\nare one voice note away")
                        .font(.largeTitle.bold())
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)

                    Text("Circle brings you closer to the\npeople who matter most")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(.horizontal, 32)

            Spacer()

            primaryButton(title: "Get Started") {
                viewModel.advancePage()
            }
            .padding(.bottom, 60)
        }
    }

    // MARK: - Screen 2: How It Works

    private var howItWorksScreen: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 40) {
                Text("How It Works")
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)

                VStack(spacing: 32) {
                    howItWorksStep(
                        emoji: "\u{2753}",
                        title: "A question arrives",
                        description: "Every day, your circle gets the same thought-provoking prompt"
                    )

                    howItWorksStep(
                        emoji: "\u{1F399}\u{FE0F}",
                        title: "You record 30 seconds",
                        description: "Share your honest answer in a quick voice note"
                    )

                    howItWorksStep(
                        emoji: "\u{1F442}",
                        title: "You hear your people",
                        description: "Listen to the people who matter \u{2014} no small talk needed"
                    )
                }
            }
            .padding(.horizontal, 32)

            Spacer()

            primaryButton(title: "Next") {
                viewModel.advancePage()
            }
            .padding(.bottom, 60)
        }
    }

    // MARK: - Screen 3: Create Your Circle

    private var createCircleScreen: some View {
        ScrollView {
            VStack(spacing: 0) {
                VStack(spacing: 8) {
                    Text("Start your first circle")
                        .font(.largeTitle.bold())
                        .multilineTextAlignment(.center)

                    Text("You can always do this later")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 40)
                .padding(.bottom, 32)

                // Circle name field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Circle Name")
                        .font(.headline)
                        .foregroundStyle(.secondary)

                    TextField("e.g. Family, Best Friends", text: $viewModel.circleName)
                        .font(.title3)
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color(.secondarySystemBackground))
                        )
                        .accessibilityLabel("Circle name")
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 24)

                // Emoji picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("Choose an Emoji")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 32)

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
                        ForEach(viewModel.emojis, id: \.self) { emoji in
                            Button {
                                viewModel.circleEmoji = emoji
                            } label: {
                                Text(emoji)
                                    .font(.system(size: 32))
                                    .frame(width: 52, height: 52)
                                    .background(
                                        viewModel.circleEmoji == emoji
                                            ? Color.accentColor.opacity(0.2)
                                            : Color(.secondarySystemBackground)
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(
                                                viewModel.circleEmoji == emoji ? Color.accentColor : Color.clear,
                                                lineWidth: 2
                                            )
                                    )
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Emoji \(emoji)")
                            .accessibilityAddTraits(viewModel.circleEmoji == emoji ? .isSelected : [])
                        }
                    }
                    .padding(.horizontal, 32)
                }
                .padding(.bottom, 24)

                // Add Members section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Add Members")
                        .font(.headline)
                        .foregroundStyle(.secondary)

                    HStack(spacing: 12) {
                        TextField("Type a name", text: $viewModel.newMemberName)
                            .font(.body)
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(.secondarySystemBackground))
                            )
                            .submitLabel(.done)
                            .onSubmit {
                                viewModel.addMember()
                            }
                            .accessibilityLabel("Member name")

                        Button {
                            viewModel.addMember()
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundStyle(Color.accentColor)
                        }
                        .disabled(viewModel.newMemberName.trimmingCharacters(in: .whitespaces).count < 2)
                        .accessibilityLabel("Add member")
                    }

                    if !viewModel.memberNames.isEmpty {
                        VStack(spacing: 8) {
                            ForEach(Array(viewModel.memberNames.enumerated()), id: \.offset) { index, name in
                                HStack {
                                    Text(name)
                                        .font(.body)

                                    Spacer()

                                    Button {
                                        viewModel.removeMember(at: index)
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundStyle(.secondary)
                                    }
                                    .accessibilityLabel("Remove \(name)")
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color(.secondarySystemBackground))
                                )
                            }
                        }
                        .padding(.top, 4)
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 24)

                if let error = viewModel.circleCreationError {
                    Text(error)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .padding(.horizontal, 32)
                        .padding(.bottom, 8)
                }

                // Continue button
                primaryButton(title: "Continue") {
                    viewModel.advancePage()
                }
                .padding(.bottom, 8)

                // Skip link
                Button {
                    viewModel.circleName = ""
                    viewModel.memberNames = []
                    viewModel.advancePage()
                } label: {
                    Text("Skip for now")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .underline()
                }
                .accessibilityLabel("Skip circle creation")
                .padding(.bottom, 40)
            }
        }
        .scrollDismissesKeyboard(.interactively)
    }

    // MARK: - Screen 4: Ready

    private var readyScreen: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 24) {
                Text("\u{1F389}")
                    .font(.system(size: 80))
                    .accessibilityLabel("Celebration")

                VStack(spacing: 16) {
                    Text("You\u{2019}re all set!")
                        .font(.largeTitle.bold())
                        .multilineTextAlignment(.center)

                    Text("Your first question arrives today")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)

                    Text("Check in daily. Just 30 seconds.\nStay connected.")
                        .font(.body)
                        .foregroundStyle(.tertiary)
                        .multilineTextAlignment(.center)
                        .padding(.top, 4)
                }
            }
            .padding(.horizontal, 32)

            Spacer()

            primaryButton(title: "Start Using Circle") {
                Task {
                    await viewModel.completeOnboarding()
                    onComplete()
                }
            }
            .padding(.bottom, 60)
        }
    }

    // MARK: - Reusable Components

    private func primaryButton(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Group {
                if viewModel.isCreatingCircle {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text(title)
                        .font(.headline)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(Color.accentColor)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .disabled(viewModel.isCreatingCircle)
        .padding(.horizontal, 32)
        .accessibilityLabel(title)
    }

    private func howItWorksStep(emoji: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Text(emoji)
                .font(.system(size: 36))
                .frame(width: 50)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.title3.bold())

                Text(description)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    OnboardingView(
        viewModel: OnboardingViewModel(
            circleRepository: LocalCircleRepository(),
            authState: AuthState(service: LocalAuthService())
        ),
        onComplete: {}
    )
}
#endif
