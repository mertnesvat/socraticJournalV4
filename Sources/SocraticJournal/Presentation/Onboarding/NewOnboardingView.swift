// NewOnboardingView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Reminder time slot option for onboarding
private enum ReminderSlot: CaseIterable, Identifiable {
    case morning
    case midday
    case evening

    var id: String { label }

    var label: String {
        switch self {
        case .morning: return "Morning calm"
        case .midday: return "Work focus"
        case .evening: return "Evening wind-down"
        }
    }

    var timeDescription: String {
        switch self {
        case .morning: return "7:00 AM"
        case .midday: return "12:00 PM"
        case .evening: return "9:00 PM"
        }
    }

    var hour: Int {
        switch self {
        case .morning: return 7
        case .midday: return 12
        case .evening: return 21
        }
    }

    var minute: Int { 0 }

    var icon: String {
        switch self {
        case .morning: return "sunrise"
        case .midday: return "sun.max"
        case .evening: return "moon.stars"
        }
    }
}

/// Full 3-screen onboarding flow for new users
public struct NewOnboardingView: View {
    // MARK: - Dependencies

    private let settingsRepository: SettingsRepositoryProtocol
    private let notificationService: NotificationServiceProtocol?
    private let onDismiss: () -> Void

    // MARK: - State

    @State private var currentPage: Int = 0
    @State private var selectedSlot: ReminderSlot?
    @State private var breathPhase: Double = 0  // 0-1 for mini animation

    // MARK: - Init

    public init(
        settingsRepository: SettingsRepositoryProtocol,
        notificationService: NotificationServiceProtocol? = nil,
        onDismiss: @escaping () -> Void
    ) {
        self.settingsRepository = settingsRepository
        self.notificationService = notificationService
        self.onDismiss = onDismiss
    }

    // MARK: - Body

    public var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()

            TabView(selection: $currentPage) {
                hookScreen
                    .tag(0)

                methodScreen
                    .tag(1)

                reminderScreen
                    .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
        }
    }

    // MARK: - Screen 1: The Hook

    private var hookScreen: some View {
        VStack(spacing: AppSpacing.lg) {
            Spacer()

            // Decorative wave (subtle, slow)
            decorativeWave
                .frame(height: 60)
                .opacity(0.3)

            VStack(spacing: AppSpacing.md) {
                Text("You breathe 25,000\ntimes a day.")
                    .font(AppTypography.headline)
                    .foregroundStyle(AppColors.textPrimary)
                    .multilineTextAlignment(.center)

                Text("Most of them wrong.")
                    .font(AppTypography.headline)
                    .foregroundStyle(AppColors.accent)
                    .multilineTextAlignment(.center)
            }

            Text("This app teaches you to breathe better using science-backed patterns that calm your nervous system and strengthen your heart.")
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppSpacing.xl)

            Spacer()
            Spacer()
        }
    }

    // MARK: - Screen 2: The Method

    private var methodScreen: some View {
        VStack(spacing: AppSpacing.lg) {
            Spacer()

            // Mini breath animation
            breathCircle
                .frame(height: 120)

            VStack(spacing: AppSpacing.md) {
                Text("5.5 seconds in.\n5.5 seconds out.")
                    .font(AppTypography.headline)
                    .foregroundStyle(AppColors.textPrimary)
                    .multilineTextAlignment(.center)

                Text("Ancient monks and modern scientists agree: this is the perfect breath.")
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppSpacing.xl)
            }

            Spacer()
            Spacer()
        }
    }

    // MARK: - Screen 3: Reminder Setup

    private var reminderScreen: some View {
        VStack(spacing: AppSpacing.lg) {
            Spacer()

            Text("When do you want\nto breathe?")
                .font(AppTypography.headline)
                .foregroundStyle(AppColors.textPrimary)
                .multilineTextAlignment(.center)

            // Time slot cards
            VStack(spacing: AppSpacing.sm) {
                ForEach(ReminderSlot.allCases) { slot in
                    reminderSlotCard(slot)
                }
            }
            .padding(.horizontal, AppSpacing.screenPadding)

            Spacer()

            // Get Started button
            AccentPillButton("Get Started") {
                completeOnboarding()
            }
            .padding(.horizontal, AppSpacing.screenPadding)
            .padding(.bottom, AppSpacing.xxl)
        }
    }

    // MARK: - Reminder Slot Card

    @ViewBuilder
    private func reminderSlotCard(_ slot: ReminderSlot) -> some View {
        let isSelected = selectedSlot == slot

        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedSlot = selectedSlot == slot ? nil : slot
            }
        } label: {
            HStack(spacing: AppSpacing.md) {
                Image(systemName: slot.icon)
                    .font(.system(size: 20))
                    .foregroundStyle(isSelected ? AppColors.accent : AppColors.textSecondary)
                    .frame(width: 28)

                VStack(alignment: .leading, spacing: 2) {
                    Text(slot.label)
                        .font(AppTypography.bodyBold)
                        .foregroundStyle(AppColors.textPrimary)

                    Text(slot.timeDescription)
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.textSecondary)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(AppColors.accent)
                }
            }
            .padding(AppSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isSelected ? AppColors.accent.opacity(0.1) : AppColors.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(
                                isSelected ? AppColors.accent.opacity(0.4) : AppColors.border,
                                lineWidth: 1
                            )
                    )
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Decorative Elements

    private var decorativeWave: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 15)) { timeline in
            Canvas { context, size in
                let time = timeline.date.timeIntervalSinceReferenceDate
                let phase: CGFloat = CGFloat(time * 0.3)

                var path = Path()
                path.move(to: CGPoint(x: 0, y: size.height / 2))

                for x in stride(from: CGFloat(0), through: size.width, by: CGFloat(2)) {
                    let normalizedX: CGFloat = x / size.width
                    let angle: CGFloat = normalizedX * .pi * 2 + phase
                    let y: CGFloat = size.height / 2 + sin(angle) * size.height * 0.3
                    path.addLine(to: CGPoint(x: x, y: y))
                }

                context.stroke(path, with: .color(AppColors.accent), lineWidth: 2)
            }
        }
    }

    private var breathCircle: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30)) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate
            let cycleDuration: Double = 11.0 // 5.5s in + 5.5s out
            let progress = (time.truncatingRemainder(dividingBy: cycleDuration)) / cycleDuration
            let scale: CGFloat = progress < 0.5
                ? 0.5 + (progress * 2) * 0.5  // inhale: 0.5 -> 1.0
                : 1.0 - ((progress - 0.5) * 2) * 0.5  // exhale: 1.0 -> 0.5

            let isInhale = progress < 0.5

            VStack(spacing: AppSpacing.sm) {
                Circle()
                    .fill(AppColors.accent.opacity(0.2))
                    .overlay(
                        Circle()
                            .stroke(AppColors.accent.opacity(0.6), lineWidth: 2)
                    )
                    .frame(width: 80 * scale, height: 80 * scale)

                Text(isInhale ? "inhale" : "exhale")
                    .font(AppTypography.phaseLabelSmall)
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
    }

    // MARK: - Actions

    private func completeOnboarding() {
        Task {
            // Save reminder if selected
            if let slot = selectedSlot {
                do {
                    var settings = try await settingsRepository.getSettings()
                    settings.dailyReminderEnabled = true
                    settings.dailyReminderHour = slot.hour
                    settings.dailyReminderMinute = slot.minute
                    settings.hasCompletedOnboarding = true
                    try await settingsRepository.saveSettings(settings)

                    // Request notification permission and schedule
                    if let service = notificationService {
                        let granted = await service.requestPermission()
                        if granted {
                            try await service.scheduleBreathReminder(
                                hour: slot.hour,
                                minute: slot.minute
                            )
                        }
                    }
                } catch {
                    // Continue even on error
                }
            } else {
                // No reminder selected, just complete onboarding
                do {
                    var settings = try await settingsRepository.getSettings()
                    settings.hasCompletedOnboarding = true
                    try await settingsRepository.saveSettings(settings)
                } catch {
                    // Continue even on error
                }
            }

            await MainActor.run {
                onDismiss()
            }
        }
    }
}

// MARK: - Preview

#Preview {
    NewOnboardingView(
        settingsRepository: UserDefaultsSettingsRepository(),
        onDismiss: { print("Onboarding dismissed") }
    )
}
#endif
