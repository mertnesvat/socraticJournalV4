// LearnView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Learn tab with science editorial content organized into chapters
public struct LearnView: View {
    let settingsRepository: SettingsRepositoryProtocol
    var onStartProgramPattern: ((String, Int) -> Void)?

    @State private var expandedArticle: Int?
    @State private var expandedChapters: Set<Int> = [1] // Chapter 1 expanded by default
    @State private var readArticles: Set<Int> = []
    @State private var readTimers: [Int: Task<Void, Never>] = [:]
    @State private var selectedProgram: Program?
    @State private var selectedExercise: TrainingData.Exercise?
    @Environment(ThemeManager.self) private var themeManager

    public init(
        settingsRepository: SettingsRepositoryProtocol = UserDefaultsSettingsRepository(),
        onStartProgramPattern: ((String, Int) -> Void)? = nil
    ) {
        self.settingsRepository = settingsRepository
        self.onStartProgramPattern = onStartProgramPattern
    }

    private var totalRead: Int { readArticles.count }

    public var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header
                learnHeader
                HairlineDivider()

                // Programs carousel
                ProgramCarousel { program in
                    selectedProgram = program
                }
                HairlineDivider()

                // Training exercises
                TrainingGrid { exercise in
                    selectedExercise = exercise
                }
                HairlineDivider()

                // Quick fact strip
                quickFactStrip
                HairlineDivider()

                // Chapters
                ForEach(LearnContent.chapters) { chapter in
                    ChapterSection(
                        chapter: chapter,
                        isExpanded: expandedChapters.contains(chapter.id),
                        expandedArticle: expandedArticle,
                        readArticles: readArticles,
                        onToggle: {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                if expandedChapters.contains(chapter.id) {
                                    expandedChapters.remove(chapter.id)
                                } else {
                                    expandedChapters.insert(chapter.id)
                                }
                            }
                        },
                        onArticleTap: { articleId in
                            withAnimation(.easeInOut(duration: 0.25)) {
                                if expandedArticle == articleId {
                                    cancelReadTimer(for: articleId)
                                    expandedArticle = nil
                                } else {
                                    if let prev = expandedArticle {
                                        cancelReadTimer(for: prev)
                                    }
                                    expandedArticle = articleId
                                    startReadTimer(for: articleId)
                                }
                            }
                        }
                    )
                    HairlineDivider()
                }

                Spacer(minLength: AppSpacing.sectionGap)
            }
        }
        .background(AppColors.background)
        .task { await loadReadProgress() }
        .sheet(item: $selectedExercise) { exercise in
            TrainingFlowView(exercise: exercise)
                .environment(themeManager)
                .preferredColorScheme(themeManager.colorScheme)
        }
        .sheet(item: $selectedProgram) { program in
            ProgramDetailView(program: program) { patternId, duration in
                selectedProgram = nil
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    onStartProgramPattern?(patternId, duration)
                }
            }
            .environment(themeManager)
            .preferredColorScheme(themeManager.colorScheme)
        }
    }

    // MARK: - Header

    private var learnHeader: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("The Science")
                .font(.system(size: 22, weight: .bold, design: .serif))
                .foregroundStyle(AppColors.textPrimary)
                .tracking(-0.2)

            Text("Why slow nasal breathing changes everything")
                .font(.system(size: 12))
                .foregroundStyle(AppColors.textSecondary)

            Text("\(totalRead) of 12 read")
                .font(.system(size: 11))
                .foregroundStyle(AppColors.accent)
                .padding(.top, 2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, AppSpacing.screenPadding)
        .padding(.top, AppSpacing.lg)
        .padding(.bottom, AppSpacing.md)
    }

    // MARK: - Quick Fact Strip

    private var quickFactStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(LearnContent.quickFacts) { fact in
                    VStack(alignment: .leading, spacing: 3) {
                        Text(fact.value)
                            .font(.system(size: 18, weight: .bold, design: .serif))
                            .foregroundStyle(AppColors.textPrimary)

                        Text(fact.label)
                            .font(.system(size: 9))
                            .foregroundStyle(AppColors.textTertiary)
                            .lineSpacing(2)
                            .frame(maxWidth: 70, alignment: .leading)
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, AppSpacing.md)

                    if fact.id != LearnContent.quickFacts.last?.id {
                        HairlineDivider(axis: .vertical)
                            .frame(height: 40)
                    }
                }
            }
        }
    }

    // MARK: - Reading Progress

    private func startReadTimer(for articleId: Int) {
        guard !readArticles.contains(articleId) else { return }
        let task = Task {
            try? await Task.sleep(for: .seconds(5))
            if !Task.isCancelled {
                readArticles.insert(articleId)
                await saveReadProgress()
            }
        }
        readTimers[articleId] = task
    }

    private func cancelReadTimer(for articleId: Int) {
        readTimers[articleId]?.cancel()
        readTimers.removeValue(forKey: articleId)
    }

    private func loadReadProgress() async {
        do {
            let settings = try await settingsRepository.getSettings()
            readArticles = settings.readArticleIndices
        } catch {}
    }

    private func saveReadProgress() async {
        do {
            var settings = try await settingsRepository.getSettings()
            settings.readArticleIndices = readArticles
            try await settingsRepository.saveSettings(settings)
        } catch {}
    }
}

#Preview {
    LearnView()
}
#endif
