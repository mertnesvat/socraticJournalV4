// LearnFeedView.swift
// Breathe
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

struct LearnArticle: Identifiable {
    let id: Int
    let title: String
    let subtitle: String
    let tag: String
    let tagColorHex: String
    let readTime: String
    let body: String
}

private let articles: [LearnArticle] = [
    LearnArticle(
        id: 0,
        title: "You breathe 25,000 times a day.\nMost of them wrong.",
        subtitle: "The core thesis \u{2014} mouth vs nasal breathing",
        tag: "Start here",
        tagColorHex: "C4502A",
        readTime: "3 min",
        body: "Nasal breathing filters, humidifies, and pressurises air before it reaches the lungs. It also produces nitric oxide \u{2014} a molecule that dilates blood vessels, improves oxygen transfer, and kills pathogens. Mouth breathing does none of this. The evidence from anthropology is stark: skull records show our ancestors had wide jaws, straight teeth, and open nasal passages. Modern skulls are narrower, more crowded \u{2014} a direct result of the shift to mouth breathing over centuries."
    ),
    LearnArticle(
        id: 1,
        title: "The nasal cycle and your brain",
        subtitle: "Why your nostrils take turns \u{2014} and what it means",
        tag: "Awareness",
        tagColorHex: "2D5F5D",
        readTime: "4 min",
        body: "Every 90 minutes or so, your body shifts airflow from one nostril to the other \u{2014} the nasal cycle. This isn\u{2019}t random. The right nostril activates the sympathetic nervous system (alertness, left-brain activity). The left nostril activates the parasympathetic (calm, creative, right-brain). You can test this right now: close your right nostril and breathe only through your left. Within minutes, your nervous system follows."
    ),
    LearnArticle(
        id: 2,
        title: "5.5 \u{2014} why this number",
        subtitle: "HRV, resonance frequency, and the baroreflex",
        tag: "Science",
        tagColorHex: "2D5F5D",
        readTime: "5 min",
        body: "The cardiovascular system has a natural resonance frequency \u{2014} a rhythm at which the baroreflex (blood pressure regulator) and heart rate variability are perfectly synchronised. For most humans this is ~0.1 Hz, or about 5.5 breaths per minute. Breathing at this exact rate maximises HRV, lowers blood pressure, and creates a feedback loop between heart, lungs, and brain that has measurable effects on anxiety, sleep, and athletic performance."
    ),
    LearnArticle(
        id: 3,
        title: "The CO\u{2082} problem",
        subtitle: "Why less breathing means more oxygen",
        tag: "Counter-intuitive",
        tagColorHex: "7A6030",
        readTime: "4 min",
        body: "The Bohr Effect: oxygen clings more tightly to haemoglobin when CO\u{2082} is high. If you over-breathe and deplete CO\u{2082}, paradoxically less oxygen is released to your tissues. Buteyko\u{2019}s entire system is built on this insight. The chronic \u{2018}air hunger\u{2019} anxiety sufferers feel is usually not a lack of oxygen \u{2014} it\u{2019}s a trained intolerance to CO\u{2082}. Slow, reduced breathing rebuilds this tolerance over weeks."
    )
]

struct LearnFeedView: View {
    @State private var expandedId: Int? = nil

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header
                learnHeader
                HairlineDivider()

                // Quick fact strip
                quickFactStrip
                HairlineDivider()

                // Articles
                ForEach(articles) { article in
                    articleCard(article)
                    HairlineDivider()
                }

                Spacer(minLength: 20)
            }
        }
    }

    // MARK: - Header

    private var learnHeader: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("The Science")
                .font(AppTypography.headlineSmall)
                .foregroundStyle(AppColors.textPrimary)

            Text("Why slow nasal breathing changes everything")
                .font(.system(size: 12))
                .foregroundStyle(AppColors.textTertiary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.top, 24)
        .padding(.bottom, 16)
    }

    // MARK: - Quick Fact Strip

    private var quickFactStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                let facts: [(String, String)] = [
                    ("5.5", "optimal breaths per min"),
                    ("25k", "breaths per day"),
                    ("90 min", "nasal cycle"),
                    ("NO", "nitric oxide from nose"),
                    ("Bohr", "CO\u{2082} releases O\u{2082}")
                ]

                ForEach(Array(facts.enumerated()), id: \.offset) { _, fact in
                    VStack(alignment: .leading, spacing: 3) {
                        Text(fact.0)
                            .font(AppTypography.factValue)
                            .foregroundStyle(AppColors.textPrimary)

                        Text(fact.1)
                            .font(.system(size: 9))
                            .foregroundStyle(AppColors.textQuaternary)
                            .lineSpacing(2)
                            .frame(maxWidth: 70, alignment: .leading)
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 16)
                    .overlay(alignment: .trailing) {
                        HairlineDivider(axis: .vertical)
                            .frame(height: 50)
                    }
                }
            }
        }
    }

    // MARK: - Article Card

    @ViewBuilder
    private func articleCard(_ article: LearnArticle) -> some View {
        let isExpanded = expandedId == article.id
        let tagColor = Color(hex: article.tagColorHex)

        Button {
            withAnimation(.easeInOut(duration: 0.25)) {
                expandedId = isExpanded ? nil : article.id
            }
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 8) {
                    // Tag + read time
                    HStack {
                        Text(article.tag.uppercased())
                            .font(.system(size: 10, weight: .bold))
                            .tracking(0.8)
                            .foregroundStyle(tagColor)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 2)
                            .background(
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(tagColor.opacity(0.08))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 3)
                                    .stroke(tagColor.opacity(0.19), lineWidth: 1)
                            )

                        Spacer()

                        Text(article.readTime)
                            .font(.system(size: 11))
                            .foregroundStyle(AppColors.textQuaternary)
                    }

                    // Title
                    Text(article.title)
                        .font(AppTypography.articleTitle)
                        .foregroundStyle(AppColors.textPrimary)
                        .lineSpacing(3)
                        .multilineTextAlignment(.leading)

                    // Subtitle
                    Text(article.subtitle)
                        .font(.system(size: 11))
                        .foregroundStyle(AppColors.textTertiary)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 18)

                // Expanded body
                if isExpanded {
                    VStack(alignment: .leading) {
                        HairlineDivider()

                        Text(article.body)
                            .font(.system(size: 13))
                            .foregroundStyle(AppColors.textSecondary)
                            .lineSpacing(5)
                            .padding(.top, 14)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 18)
                }
            }
        }
        .buttonStyle(.plain)
    }
}
#endif
