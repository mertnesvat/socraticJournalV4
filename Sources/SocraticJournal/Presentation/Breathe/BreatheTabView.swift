// BreatheTabView.swift
// Breathe
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// The Breathe tab — pattern selector, duration picker, and session launcher
public struct BreatheTabView: View {
    @State private var selectedTechnique: BreathTechnique = .resonant
    @State private var selectedDuration: Int = 5
    @State private var showPacingView: Bool = false
    let sessionRepository: BreathSessionRepositoryProtocol

    private let durations = [5, 10]

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    header
                    patternSection
                        .padding(.top, AppSpacing.lg)
                    durationSection
                        .padding(.top, AppSpacing.sectionGap)
                    beginButton
                        .padding(.top, AppSpacing.sectionGap)

                    Spacer(minLength: AppSpacing.sectionGap)
                }
            }
            .background(AppColors.background)
            .fullScreenCover(isPresented: $showPacingView) {
                BreathPacingView(
                    technique: selectedTechnique,
                    durationMinutes: selectedDuration,
                    sessionRepository: sessionRepository,
                    onDismiss: { showPacingView = false }
                )
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Text("Breathe")
                .font(AppTypography.displayMedium)
                .foregroundStyle(AppColors.textPrimary)
            Spacer()
        }
        .padding(.horizontal, AppSpacing.screenPadding)
        .padding(.top, AppSpacing.heroTopPadding)
    }

    // MARK: - Pattern Selector

    private var patternSection: some View {
        VStack(spacing: 0) {
            SectionHeaderView("Choose a Pattern", showTopBorder: false)

            VStack(spacing: AppSpacing.cardGap) {
                ForEach(BreathTechnique.allTechniques) { technique in
                    PatternCard(
                        technique: technique,
                        isSelected: selectedTechnique.id == technique.id,
                        onTap: { selectedTechnique = technique }
                    )
                }
            }
            .padding(.horizontal, AppSpacing.screenPadding)
        }
    }

    // MARK: - Duration Picker

    private var durationSection: some View {
        VStack(spacing: 0) {
            SectionHeaderView("Duration", showTopBorder: false)

            HStack(spacing: AppSpacing.sm) {
                ForEach(durations, id: \.self) { minutes in
                    Button {
                        selectedDuration = minutes
                    } label: {
                        Text("\(minutes) min")
                            .font(AppTypography.bodyBold)
                            .foregroundStyle(
                                selectedDuration == minutes
                                    ? AppColors.textOnAccent
                                    : AppColors.textPrimary
                            )
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, AppSpacing.md)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(
                                        selectedDuration == minutes
                                            ? AppColors.accent
                                            : AppColors.surfaceElevated
                                    )
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, AppSpacing.screenPadding)
        }
    }

    // MARK: - Begin Button

    private var beginButton: some View {
        AccentPillButton("Begin", icon: "play.fill") {
            showPacingView = true
        }
        .padding(.horizontal, AppSpacing.screenPadding)
    }
}

// MARK: - Pattern Card

struct PatternCard: View {
    let technique: BreathTechnique
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                    Text(technique.name)
                        .font(AppTypography.bodyBold)
                        .foregroundStyle(isSelected ? AppColors.textOnDark : AppColors.textPrimary)

                    Text(technique.subtitle)
                        .font(AppTypography.caption)
                        .foregroundStyle(isSelected ? AppColors.textOnDark.opacity(0.8) : AppColors.textSecondary)

                    Text(technique.timingDescription)
                        .font(AppTypography.caption)
                        .foregroundStyle(isSelected ? AppColors.textOnDark.opacity(0.6) : AppColors.textTertiary)
                        .padding(.top, 2)
                }

                Spacer()

                Image(systemName: "play.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(isSelected ? AppColors.textOnDark : AppColors.textTertiary)
            }
            .padding(AppSpacing.cardPadding)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? AppColors.accent : AppColors.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.clear : AppColors.border, lineWidth: AppSpacing.gridGutter)
            )
        }
        .buttonStyle(.plain)
    }
}
#endif
