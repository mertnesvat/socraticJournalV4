// CircleListView.swift
// Circle
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Displays all circles for the current user.
/// Shows a warm empty state CTA when no circles exist.
struct CircleListView: View {
    @Environment(ServiceContainer.self) private var services
    @State private var viewModel: CircleListViewModel
    @State private var selectedCircle: Circle?
    @State private var detailCircle: Circle?
    private let circleService: CircleServiceProtocol

    init(viewModel: CircleListViewModel, circleService: CircleServiceProtocol) {
        _viewModel = State(initialValue: viewModel)
        self.circleService = circleService
    }

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.circles.isEmpty {
                loadingView
            } else if viewModel.isEmpty {
                emptyStateView
            } else {
                circleListContent
            }
        }
        .sheet(isPresented: $viewModel.showCreateCircle) {
            CreateCircleView(
                circleService: circleService,
                onCreated: { await viewModel.onCircleCreated() }
            )
        }
        .navigationDestination(item: $selectedCircle) { circle in
            CircleFeedView(
                viewModel: CircleFeedViewModel(
                    responseService: services.responseService,
                    promptService: services.promptService,
                    circleService: services.circleService,
                    voicePlaybackService: services.voicePlaybackService,
                    voiceRecordingService: services.voiceRecordingService,
                    authService: services.authService,
                    circle: circle
                )
            )
        }
        .navigationDestination(item: $detailCircle) { circle in
            CircleDetailView(
                viewModel: CircleDetailViewModel(
                    circle: circle,
                    circleService: circleService,
                    promptService: services.promptService
                ),
                circleService: circleService
            )
        }
        .task { await viewModel.loadCircles() }
        .alert(
            "Something went wrong",
            isPresented: Binding(
                get: { viewModel.error != nil },
                set: { if !$0 { viewModel.clearError() } }
            )
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            if let error = viewModel.error {
                Text(error.localizedDescription)
            }
        }
    }

    // MARK: - Loading

    private var loadingView: some View {
        VStack {
            Spacer()
            ProgressView("Loading circles...")
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        ScrollView {
            VStack(spacing: 32) {
                Spacer(minLength: 60)

                VStack(spacing: 20) {
                    ZStack {
                        SwiftUI.Circle()
                            .fill(CircleTheme.warmAmber.opacity(0.15))
                            .frame(width: 120, height: 120)

                        Image(systemName: "person.3.fill")
                            .font(.system(size: 44))
                            .foregroundStyle(CircleTheme.warmAmber)
                    }

                    VStack(spacing: 8) {
                        Text("Your Circle Awaits")
                            .font(.title2.bold())
                            .foregroundStyle(.primary)

                        Text("Create a circle with 2-5 people you care about.\nOne question. Their voice. Every day.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(2)
                    }
                }

                Button {
                    viewModel.showCreateCircle = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                        Text("Create Your First Circle")
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .foregroundStyle(.white)
                    .background(CircleTheme.primaryGradient)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: CircleTheme.warmAmber.opacity(0.3), radius: 12, x: 0, y: 6)
                }
                .padding(.horizontal, 24)

                Text("or join a circle with an invite code")
                    .font(.caption)
                    .foregroundStyle(.tertiary)

                Spacer(minLength: 40)
            }
            .padding()
        }
        .background(Color(uiColor: .systemGroupedBackground))
    }

    // MARK: - Circle List

    private var circleListContent: some View {
        List {
            ForEach(viewModel.circles) { circle in
                Button {
                    selectedCircle = circle
                } label: {
                    CircleRowView(circle: circle, currentStreak: viewModel.currentStreak(for: circle.id))
                }
                .contextMenu {
                    Button {
                        detailCircle = circle
                    } label: {
                        Label("Circle Settings", systemImage: "gearshape")
                    }
                }
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            }
            .onDelete { indexSet in
                Task {
                    for index in indexSet {
                        await viewModel.deleteCircle(viewModel.circles[index])
                    }
                }
            }
        }
        .listStyle(.plain)
        .refreshable { await viewModel.loadCircles() }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    viewModel.showCreateCircle = true
                } label: {
                    Image(systemName: "plus")
                        .font(.body.weight(.medium))
                }
            }
        }
    }
}

// MARK: - Circle Row

/// A single row displaying a circle's icon, name, member count, and streak.
private struct CircleRowView: View {
    let circle: Circle
    var currentStreak: Int = 0

    var body: some View {
        HStack(spacing: 14) {
            // Circle icon
            ZStack {
                SwiftUI.Circle()
                    .fill(CircleTheme.warmAmber.opacity(0.15))
                    .frame(width: 48, height: 48)

                Image(systemName: circle.emojiIcon)
                    .font(.title3)
                    .foregroundStyle(CircleTheme.warmAmber)
            }

            // Name, member count, and streak
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(circle.name)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.primary)

                    CircleStreakView(currentStreak: currentStreak, longestStreak: currentStreak, isCompact: true)
                }

                Text("\(circle.memberCount) member\(circle.memberCount == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Member avatars stack
            memberAvatarStack

            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }

    private var memberAvatarStack: some View {
        HStack(spacing: -8) {
            ForEach(Array(circle.members.prefix(3))) { member in
                InitialsAvatarView(
                    initials: member.initials,
                    avatarImageData: member.avatarImageData,
                    size: 28
                )
                .overlay(
                    SwiftUI.Circle()
                        .stroke(Color(uiColor: .systemBackground), lineWidth: 2)
                )
            }
        }
    }
}

#Preview("With Circles") {
    NavigationStack {
        CircleListView(
            viewModel: CircleListViewModel(circleService: MockCircleService()),
            circleService: MockCircleService()
        )
        .navigationTitle("Circle")
    }
}

#Preview("Empty") {
    NavigationStack {
        CircleListView(
            viewModel: CircleListViewModel(circleService: MockCircleService(withSampleData: false)),
            circleService: MockCircleService(withSampleData: false)
        )
        .navigationTitle("Circle")
    }
}
#endif
