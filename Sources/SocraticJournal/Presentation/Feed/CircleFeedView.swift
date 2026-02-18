// CircleFeedView.swift
// Circle
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// The main daily interaction screen for a circle.
/// Shows today's prompt, member response cards, date navigation, and a record CTA.
struct CircleFeedView: View {
    @Environment(ServiceContainer.self) private var services
    @State private var viewModel: CircleFeedViewModel

    init(viewModel: CircleFeedViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            // Main scrollable content
            ScrollView {
                VStack(spacing: 16) {
                    // Circle selector (only if multiple circles)
                    if viewModel.circles.count > 1 {
                        circleSelectorBar
                    }

                    // Date scroller
                    dateScrollerBar

                    // Daily prompt (compact)
                    if viewModel.isToday, let circle = viewModel.selectedCircle {
                        DailyPromptView(
                            viewModel: DailyPromptViewModel(
                                promptService: services.promptService,
                                circleId: circle.id
                            ),
                            isCompact: true,
                            onRecordTapped: {
                                viewModel.startRecording()
                            }
                        )
                        .padding(.horizontal, 16)
                    }

                    // Response count
                    responseCountBar

                    // Response cards or empty state
                    if viewModel.isLoading && viewModel.memberItems.isEmpty {
                        loadingView
                    } else if viewModel.memberItems.isEmpty {
                        emptyStateView
                    } else {
                        responseList
                    }
                }
                .padding(.bottom, 100) // Space for floating button
            }
            .refreshable { await viewModel.loadFeed() }
            .background(Color(uiColor: .systemGroupedBackground))

            // Floating record button
            if viewModel.isToday && !viewModel.currentUserHasResponded {
                recordButton
            }
        }
        .navigationTitle(viewModel.selectedCircle?.name ?? "Feed")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadCircles()
            await viewModel.loadFeed()
        }
        .sheet(isPresented: $viewModel.showRecorder) {
            VoiceRecorderView(
                viewModel: VoiceRecorderViewModel(
                    voiceRecordingService: services.voiceRecordingService,
                    circleId: viewModel.selectedCircle?.id,
                    promptId: viewModel.prompt?.id
                ),
                onConfirm: { voiceNote in
                    Task { await viewModel.handleRecordingConfirmed(voiceNote: voiceNote) }
                },
                onDismiss: {
                    viewModel.showRecorder = false
                }
            )
        }
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

    // MARK: - Circle Selector

    private var circleSelectorBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(viewModel.circles) { circle in
                    Button {
                        viewModel.selectCircle(circle)
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: circle.emojiIcon)
                                .font(.caption)
                            Text(circle.name)
                                .font(.subheadline.weight(.medium))
                        }
                        .foregroundStyle(
                            viewModel.selectedCircle?.id == circle.id
                                ? .white
                                : CircleTheme.warmBrown
                        )
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(
                            viewModel.selectedCircle?.id == circle.id
                                ? AnyShapeStyle(CircleTheme.primaryGradient)
                                : AnyShapeStyle(Color(uiColor: .secondarySystemBackground))
                        )
                        .clipShape(Capsule())
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }

    // MARK: - Date Scroller

    private var dateScrollerBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(viewModel.datePills, id: \.self) { date in
                    datePill(for: date)
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private func datePill(for date: Date) -> some View {
        let calendar = Calendar.current
        let isSelected = calendar.isDate(date, inSameDayAs: viewModel.selectedDate)
        let isToday = calendar.isDateInToday(date)

        return Button {
            viewModel.selectDate(date)
        } label: {
            VStack(spacing: 2) {
                Text(dayAbbreviation(for: date))
                    .font(.caption2.weight(.medium))
                Text(dayNumber(for: date))
                    .font(.subheadline.weight(.semibold))
            }
            .foregroundStyle(
                isSelected
                    ? .white
                    : isToday
                        ? CircleTheme.warmAmber
                        : .secondary
            )
            .frame(width: 44, height: 52)
            .background(
                isSelected
                    ? AnyShapeStyle(CircleTheme.primaryGradient)
                    : AnyShapeStyle(
                        isToday
                            ? CircleTheme.warmAmber.opacity(0.12)
                            : Color(uiColor: .secondarySystemBackground)
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private func dayAbbreviation(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date).uppercased()
    }

    private func dayNumber(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }

    // MARK: - Response Count

    private var responseCountBar: some View {
        HStack {
            Text("\(viewModel.respondedCount) of \(viewModel.totalMemberCount) responded")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)

            Spacer()

            if viewModel.hasUnheardResponses {
                HStack(spacing: 4) {
                    SwiftUI.Circle()
                        .fill(CircleTheme.warmAmber)
                        .frame(width: 6, height: 6)
                    Text("New responses")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(CircleTheme.warmAmber)
                }
            }
        }
        .padding(.horizontal, 16)
    }

    // MARK: - Response List

    private var responseList: some View {
        LazyVStack(spacing: 10) {
            ForEach(viewModel.memberItems) { item in
                ResponseCardView(
                    item: item,
                    playbackService: services.voicePlaybackService,
                    onHeard: {
                        Task { await viewModel.markAsHeard(item) }
                    }
                )
            }
        }
        .padding(.horizontal, 16)
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer(minLength: 40)

            ZStack {
                SwiftUI.Circle()
                    .fill(CircleTheme.warmAmber.opacity(0.15))
                    .frame(width: 80, height: 80)

                Image(systemName: "mic.badge.plus")
                    .font(.system(size: 32))
                    .foregroundStyle(CircleTheme.warmAmber)
            }

            VStack(spacing: 6) {
                Text(viewModel.isToday ? "No responses yet today" : "No responses on this day")
                    .font(.headline)
                    .foregroundStyle(.primary)

                if viewModel.isToday {
                    Text("Be the first to share!")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            if viewModel.isToday {
                Button {
                    viewModel.startRecording()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "mic.fill")
                        Text("Record yours")
                    }
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 14)
                    .background(CircleTheme.primaryGradient, in: Capsule())
                }
            }

            Spacer(minLength: 40)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Loading

    private var loadingView: some View {
        VStack(spacing: 12) {
            Spacer(minLength: 60)
            ProgressView()
                .tint(CircleTheme.warmAmber)
            Text("Loading responses...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer(minLength: 60)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Floating Record Button

    private var recordButton: some View {
        Button {
            viewModel.startRecording()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "mic.fill")
                    .font(.body.weight(.semibold))
                Text("Record yours")
                    .font(.headline)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(CircleTheme.primaryGradient, in: RoundedRectangle(cornerRadius: 16))
            .shadow(color: CircleTheme.warmAmber.opacity(0.3), radius: 12, x: 0, y: 6)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
    }
}

// MARK: - Previews

#Preview("Feed with Responses") {
    NavigationStack {
        CircleFeedView(
            viewModel: CircleFeedViewModel(
                responseService: MockResponseService(),
                promptService: MockPromptService(),
                circleService: MockCircleService(),
                voicePlaybackService: MockVoicePlaybackService(),
                voiceRecordingService: MockVoiceRecordingService(),
                authService: MockAuthService(isSignedIn: true)
            )
        )
    }
    .environment(ServiceContainer(
        authService: MockAuthService(isSignedIn: true),
        voiceRecordingService: MockVoiceRecordingService(),
        voicePlaybackService: MockVoicePlaybackService(),
        circleService: MockCircleService(),
        promptService: MockPromptService()
    ))
}

#Preview("Empty Feed") {
    NavigationStack {
        CircleFeedView(
            viewModel: CircleFeedViewModel(
                responseService: MockResponseService(withSampleData: false),
                promptService: MockPromptService(),
                circleService: MockCircleService(),
                voicePlaybackService: MockVoicePlaybackService(),
                voiceRecordingService: MockVoiceRecordingService(),
                authService: MockAuthService(isSignedIn: true)
            )
        )
    }
    .environment(ServiceContainer(
        authService: MockAuthService(isSignedIn: true),
        voiceRecordingService: MockVoiceRecordingService(),
        voicePlaybackService: MockVoicePlaybackService(),
        circleService: MockCircleService(),
        promptService: MockPromptService()
    ))
}
#endif
