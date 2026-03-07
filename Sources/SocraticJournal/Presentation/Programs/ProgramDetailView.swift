// ProgramDetailView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Full program detail sheet with day cards and progress
struct ProgramDetailView: View {
    @State private var viewModel: ProgramViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(ThemeManager.self) private var themeManager
    let onStartPattern: (String, Int) -> Void

    init(program: Program, onStartPattern: @escaping (String, Int) -> Void) {
        _viewModel = State(initialValue: ProgramViewModel(program: program))
        self.onStartPattern = onStartPattern
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Header
                    programHeader
                    HairlineDivider()

                    // Day cards
                    ForEach(viewModel.program.days) { day in
                        ProgramDayCard(
                            day: day,
                            isCompleted: viewModel.isDayCompleted(day.id),
                            isCurrent: viewModel.isDayCurrent(day.id),
                            isLocked: viewModel.isDayLocked(day.id),
                            isExpanded: viewModel.expandedDay == day.id,
                            themeColorHex: viewModel.program.themeColorHex,
                            viewModel: viewModel,
                            onToggle: {
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    viewModel.toggleDay(day.id)
                                }
                            },
                            onStartPattern: { patternId, duration in
                                dismiss()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    onStartPattern(patternId, duration)
                                }
                            }
                        )
                        HairlineDivider()
                    }

                    // Start button (if not started)
                    if !viewModel.isStarted {
                        Button {
                            withAnimation {
                                viewModel.startProgram()
                            }
                        } label: {
                            Text("START PROGRAM")
                                .font(.system(size: 12, weight: .bold, design: .serif))
                                .tracking(1.0)
                                .foregroundStyle(AppColors.background)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color(hex: viewModel.program.themeColorHex))
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, AppSpacing.screenPadding)
                        .padding(.vertical, AppSpacing.lg)
                    }

                    Spacer(minLength: AppSpacing.sectionGap)
                }
            }
            .background(AppColors.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(AppColors.textSecondary)
                    }
                }
            }
        }
        .applyTheme(from: themeManager)
        .onAppear { viewModel.loadProgress() }
    }

    // MARK: - Header

    private var programHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(viewModel.program.name)
                .font(.system(size: 22, weight: .bold, design: .serif))
                .foregroundStyle(AppColors.textPrimary)

            Text(viewModel.program.description)
                .font(.system(size: 13))
                .foregroundStyle(AppColors.textSecondary)
                .lineSpacing(6)

            if viewModel.isStarted {
                HStack(spacing: 8) {
                    Text("Day \(viewModel.currentDay) of \(viewModel.program.totalDays)")
                        .font(.system(size: 11))
                        .tracking(0.8)
                        .foregroundStyle(Color(hex: viewModel.program.themeColorHex))

                    Spacer()
                }

                // Progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 1.5)
                            .fill(AppColors.surface)
                            .frame(height: 3)

                        RoundedRectangle(cornerRadius: 1.5)
                            .fill(Color(hex: viewModel.program.themeColorHex))
                            .frame(
                                width: geo.size.width * CGFloat(viewModel.progress?.completedDays.count ?? 0) / CGFloat(viewModel.program.totalDays),
                                height: 3
                            )
                    }
                }
                .frame(height: 3)
            }
        }
        .padding(.horizontal, AppSpacing.screenPadding)
        .padding(.top, AppSpacing.lg)
        .padding(.bottom, AppSpacing.md)
    }
}
#endif
