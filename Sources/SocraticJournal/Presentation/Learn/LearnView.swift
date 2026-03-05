// LearnView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Learn tab with science editorial content about breathing
public struct LearnView: View {
    @State private var expandedArticle: Int?
    @State private var selectedCategory: LearnCategory = .all

    public var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header
                learnHeader
                HairlineDivider()

                // Quick fact strip
                quickFactStrip
                HairlineDivider()

                // Category filter
                categoryFilter
                HairlineDivider()

                // Articles
                ForEach(Array(filteredArticles.enumerated()), id: \.element.id) { index, article in
                    articleRow(article, index: index)
                    if index < filteredArticles.count - 1 {
                        HairlineDivider()
                    }
                }

                Spacer(minLength: AppSpacing.sectionGap)
            }
        }
        .background(AppColors.background)
    }

    // MARK: - Filtered Articles

    private var filteredArticles: [LearnContent.Article] {
        if selectedCategory == .all {
            return LearnContent.articles
        }
        return LearnContent.articles.filter { $0.category == selectedCategory }
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

    // MARK: - Category Filter

    private var categoryFilter: some View {
        CategoryFilterBar(
            selectedCategory: selectedCategory,
            onSelect: { category in
                withAnimation(.easeInOut(duration: 0.3)) {
                    // Collapse any expanded article when switching categories
                    expandedArticle = nil
                    selectedCategory = category
                }
            }
        )
        .padding(.vertical, AppSpacing.sm)
    }

    // MARK: - Article Row

    private func articleRow(_ article: LearnContent.Article, index: Int) -> some View {
        let isExpanded = expandedArticle == index

        return VStack(spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.25)) {
                    expandedArticle = isExpanded ? nil : index
                }
            } label: {
                VStack(alignment: .leading, spacing: 8) {
                    // Tag + read time
                    HStack {
                        Text(article.tag.uppercased())
                            .font(.system(size: 10, weight: .bold))
                            .tracking(0.8)
                            .foregroundStyle(Color(hex: article.tagColorHex))
                            .padding(.horizontal, 7)
                            .padding(.vertical, 2)
                            .background(
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(Color(hex: article.tagColorHex).opacity(0.08))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 3)
                                    .stroke(Color(hex: article.tagColorHex).opacity(0.2), lineWidth: 1)
                            )

                        Spacer()

                        Text(article.readTime)
                            .font(.system(size: 11))
                            .foregroundStyle(AppColors.textTertiary)
                    }

                    // Title
                    Text(article.title)
                        .font(.system(size: 15, weight: .bold, design: .serif))
                        .foregroundStyle(AppColors.textPrimary)
                        .lineSpacing(3)
                        .multilineTextAlignment(.leading)

                    // Subtitle
                    Text(article.subtitle)
                        .font(.system(size: 11))
                        .foregroundStyle(AppColors.textSecondary)
                }
                .padding(.horizontal, AppSpacing.screenPadding)
                .padding(.vertical, 18)
            }
            .buttonStyle(.plain)

            // Expanded body
            if isExpanded {
                VStack(alignment: .leading) {
                    HairlineDivider()
                        .padding(.horizontal, AppSpacing.screenPadding)

                    Text(article.body)
                        .font(.system(size: 13))
                        .foregroundStyle(Color(hex: "3D3328"))
                        .lineSpacing(6)
                        .padding(.horizontal, AppSpacing.screenPadding)
                        .padding(.vertical, 14)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
}

// MARK: - Content Data

enum LearnContent {
    struct QuickFact: Identifiable {
        let id = UUID()
        let value: String
        let label: String
    }

    struct Article: Identifiable {
        let id = UUID()
        let title: String
        let subtitle: String
        let tag: String
        let tagColorHex: String
        let readTime: String
        let body: String
        let category: LearnCategory
    }

    static let quickFacts: [QuickFact] = [
        QuickFact(value: "5.5", label: "optimal breaths per min"),
        QuickFact(value: "25k", label: "breaths per day"),
        QuickFact(value: "90 min", label: "nasal cycle"),
        QuickFact(value: "NO", label: "nitric oxide from nose"),
        QuickFact(value: "Bohr", label: "CO\u{2082} releases O\u{2082}"),
        QuickFact(value: "40%", label: "of people are chronic mouth breathers"),
        QuickFact(value: "pH 7.4", label: "blood alkalinity from breathing"),
        QuickFact(value: "2x", label: "nitric oxide from humming"),
        QuickFact(value: "1500 L", label: "of air through your nose daily"),
        QuickFact(value: "10s", label: "one breath at resonance pace"),
    ]

    static let articles: [Article] = [
        Article(
            title: "You breathe 25,000 times a day.\nMost of them wrong.",
            subtitle: "The core thesis \u{2014} mouth vs nasal breathing",
            tag: "Start here",
            tagColorHex: "C4502A",
            readTime: "3 min",
            body: "Nasal breathing filters, humidifies, and pressurises air before it reaches the lungs. It also produces nitric oxide \u{2014} a molecule that dilates blood vessels, improves oxygen transfer, and kills pathogens. Mouth breathing does none of this. The evidence from anthropology is stark: skull records show our ancestors had wide jaws, straight teeth, and open nasal passages. Modern skulls are narrower, more crowded \u{2014} a direct result of the shift to mouth breathing over centuries.",
            category: .fundamentals
        ),
        Article(
            title: "The nasal cycle and your brain",
            subtitle: "Why your nostrils take turns \u{2014} and what it means",
            tag: "Awareness",
            tagColorHex: "2D5F5D",
            readTime: "4 min",
            body: "Every 90 minutes or so, your body shifts airflow from one nostril to the other \u{2014} the nasal cycle. This isn\u{2019}t random. The right nostril activates the sympathetic nervous system (alertness, left-brain activity). The left nostril activates the parasympathetic (calm, creative, right-brain). You can test this right now: close your right nostril and breathe only through your left. Within minutes, your nervous system follows.",
            category: .fundamentals
        ),
        Article(
            title: "5.5 \u{2014} why this number",
            subtitle: "HRV, resonance frequency, and the baroreflex",
            tag: "Science",
            tagColorHex: "2D5F5D",
            readTime: "5 min",
            body: "The cardiovascular system has a natural resonance frequency \u{2014} a rhythm at which the baroreflex (blood pressure regulator) and heart rate variability are perfectly synchronised. For most humans this is ~0.1 Hz, or about 5.5 breaths per minute. Breathing at this exact rate maximises HRV, lowers blood pressure, and creates a feedback loop between heart, lungs, and brain that has measurable effects on anxiety, sleep, and athletic performance.",
            category: .fundamentals
        ),
        Article(
            title: "The CO\u{2082} problem",
            subtitle: "Why less breathing means more oxygen",
            tag: "Counter-intuitive",
            tagColorHex: "7A6030",
            readTime: "4 min",
            body: "The Bohr Effect: oxygen clings more tightly to haemoglobin when CO\u{2082} is high. If you over-breathe and deplete CO\u{2082}, paradoxically less oxygen is released to your tissues. Buteyko\u{2019}s entire system is built on this insight. The chronic \u{2018}air hunger\u{2019} anxiety sufferers feel is usually not a lack of oxygen \u{2014} it\u{2019}s a trained intolerance to CO\u{2082}. Slow, reduced breathing rebuilds this tolerance over weeks.",
            category: .fundamentals
        ),
    ]
}

#Preview {
    LearnView()
}
#endif
