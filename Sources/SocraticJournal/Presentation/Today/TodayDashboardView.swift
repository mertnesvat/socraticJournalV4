// TodayDashboardView.swift
// Breathe
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

struct TodayDashboardView: View {
    @State private var streak: Int = 0
    @State private var todaySessions: [BreathSession] = []
    @State private var weekCompletion: [Bool] = Array(repeating: false, count: 7)
    let sessionRepository: BreathSessionRepositoryProtocol
    let settingsRepository: SettingsRepositoryProtocol

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 { return "Good morning." }
        if hour < 17 { return "Good afternoon." }
        return "Good evening."
    }

    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d MMMM"
        return formatter.string(from: Date()).uppercased()
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Date header
                dateHeader
                HairlineDivider()

                // Streak + Week grid
                streakWeekGrid
                HairlineDivider()

                // Today's practice
                practiceChecklist
                HairlineDivider()

                // Reminders
                remindersSection
                HairlineDivider()

                // Haptic note
                hapticBanner
                    .padding(16)
            }
        }
        .task { await loadData() }
    }

    // MARK: - Date Header

    private var dateHeader: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(dateString)
                .font(.system(size: 11))
                .tracking(1.3)
                .foregroundStyle(AppColors.textQuaternary)

            Text(greeting)
                .font(AppTypography.greeting)
                .tracking(-0.3)
                .foregroundStyle(AppColors.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.top, 24)
        .padding(.bottom, 20)
    }

    // MARK: - Streak + Week

    private var streakWeekGrid: some View {
        HStack(spacing: 0) {
            // Streak
            VStack(alignment: .leading, spacing: 8) {
                Text("STREAK")
                    .font(.system(size: 11))
                    .tracking(1.1)
                    .foregroundStyle(AppColors.textQuaternary)

                Text("\(streak)")
                    .font(AppTypography.stat)
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(1)

                Text("days")
                    .font(.system(size: 11))
                    .foregroundStyle(AppColors.textTertiary)
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)

            HairlineDivider(axis: .vertical)
                .frame(height: 100)

            // This week
            VStack(alignment: .leading, spacing: 8) {
                Text("THIS WEEK")
                    .font(.system(size: 11))
                    .tracking(1.1)
                    .foregroundStyle(AppColors.textQuaternary)

                HStack(spacing: 6) {
                    let days = ["S", "M", "T", "W", "T", "F", "S"]
                    let today = Calendar.current.component(.weekday, from: Date()) - 1 // 0-based Sunday

                    ForEach(0..<7, id: \.self) { i in
                        VStack(spacing: 3) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(i < today ? AppColors.accent : AppColors.surfaceElevated)
                                    .frame(width: 26, height: 26)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 4)
                                            .stroke(i < today ? Color.clear : AppColors.border, lineWidth: 1)
                                    )

                                if i < today {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundStyle(.white)
                                }
                            }

                            Text(days[i])
                                .font(.system(size: 8))
                                .tracking(0.4)
                                .foregroundStyle(AppColors.textQuaternary)
                        }
                    }
                }
                .padding(.top, 4)
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Practice Checklist

    private var practiceChecklist: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("TODAY'S PRACTICE")
                .font(.system(size: 11))
                .tracking(1.1)
                .foregroundStyle(AppColors.textQuaternary)
                .padding(.bottom, 16)

            let items: [(String, String, Bool)] = [
                ("5 min · Resonance 5.5", "Morning · Default", !todaySessions.isEmpty),
                ("10 min · Coherent Breathing", "Evening · Optional", false)
            ]

            ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                HStack(spacing: 14) {
                    Circle()
                        .fill(item.2 ? AppColors.accent : Color.clear)
                        .frame(width: 22, height: 22)
                        .overlay(
                            Circle()
                                .stroke(item.2 ? AppColors.accent : AppColors.border, lineWidth: 1.5)
                        )
                        .overlay {
                            if item.2 {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundStyle(.white)
                            }
                        }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.0)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(item.2 ? AppColors.textQuaternary : AppColors.textPrimary)
                            .strikethrough(item.2)

                        Text(item.1)
                            .font(.system(size: 11))
                            .foregroundStyle(AppColors.textQuaternary)
                    }
                }
                .padding(.vertical, 12)

                if index < items.count - 1 {
                    HairlineDivider()
                }
            }
        }
        .padding(20)
    }

    // MARK: - Reminders

    private var remindersSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("REMINDERS")
                .font(.system(size: 11))
                .tracking(1.1)
                .foregroundStyle(AppColors.textQuaternary)
                .padding(.bottom, 14)

            let reminders: [(String, String, Bool)] = [
                ("07:30", "Morning calm", true),
                ("21:00", "Evening wind-down", true)
            ]

            ForEach(Array(reminders.enumerated()), id: \.offset) { index, r in
                HStack {
                    HStack(spacing: 10) {
                        Text(r.0)
                            .font(AppTypography.reminderTime)
                            .foregroundStyle(AppColors.textPrimary)

                        Text(r.1)
                            .font(.system(size: 11))
                            .foregroundStyle(AppColors.textTertiary)
                    }

                    Spacer()

                    // Toggle switch
                    RoundedRectangle(cornerRadius: 10)
                        .fill(r.2 ? AppColors.accent : AppColors.border)
                        .frame(width: 36, height: 20)
                        .overlay(alignment: r.2 ? .trailing : .leading) {
                            Circle()
                                .fill(AppColors.background)
                                .frame(width: 16, height: 16)
                                .padding(2)
                        }
                }
                .padding(.vertical, 10)

                if index < reminders.count - 1 {
                    HairlineDivider()
                }
            }
        }
        .padding(20)
    }

    // MARK: - Haptic Banner

    private var hapticBanner: some View {
        HStack(spacing: 10) {
            Image(systemName: "iphone.radiowaves.left.and.right")
                .font(.system(size: 16))
                .foregroundStyle(AppColors.accent)

            Text("Haptic rhythm is on \u{2014} phase changes use a soft taptic cue so you can breathe eyes-closed.")
                .font(.system(size: 12))
                .foregroundStyle(AppColors.accent)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(AppColors.accentLight)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(AppColors.accent.opacity(0.12), lineWidth: 1)
                )
        )
    }

    // MARK: - Data Loading

    private func loadData() async {
        do {
            streak = try await sessionRepository.getStreak()
            todaySessions = try await sessionRepository.getSessionsForDate(Date())

            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            let weekday = calendar.component(.weekday, from: today) - 1
            let weekStart = calendar.date(byAdding: .day, value: -weekday, to: today)!

            for i in 0..<7 {
                let day = calendar.date(byAdding: .day, value: i, to: weekStart)!
                let sessions = try await sessionRepository.getSessionsForDate(day)
                if i < weekCompletion.count {
                    weekCompletion[i] = !sessions.isEmpty
                }
            }
        } catch {}
    }
}
#endif
