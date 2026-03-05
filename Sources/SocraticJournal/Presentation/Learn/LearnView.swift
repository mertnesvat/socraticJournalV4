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
                        .foregroundStyle(AppColors.textPrimary)
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
        Article(
            title: "The evolution of the crooked jaw",
            subtitle: "How modern life changed the shape of our skulls",
            tag: "History",
            tagColorHex: "7A6030",
            readTime: "6 min",
            body: "For 2 million years, our ancestors had wide jaws, straight teeth, and spacious nasal passages. Then, about 300 years ago, something changed. The industrial revolution brought processed food \u{2014} softer, requiring less chewing. Within generations, human jaws narrowed, teeth crowded, and airways shrank. George Catlin documented this in 1870 among Indigenous peoples who had adopted Western diets. The skulls tell the story: pre-industrial humans rarely had crooked teeth. The modern epidemic of sleep apnea, snoring, and mouth breathing is, in part, an architectural problem \u{2014} our airways are literally too small for the air we need. James Nestor\u{2019}s experiment with Stanford showed that just 10 days of forced mouth breathing raised blood pressure, reduced blood oxygen, and increased snoring by 4,800%."
        ),
        Article(
            title: "Nitric oxide \u{2014} the miracle molecule",
            subtitle: "Why your nose makes its own medicine",
            tag: "Science",
            tagColorHex: "2D5F5D",
            readTime: "4 min",
            body: "In 1998, three scientists won the Nobel Prize for discovering nitric oxide\u{2019}s role in the body. Your paranasal sinuses produce it continuously \u{2014} but only when you breathe through your nose. NO dilates blood vessels (lowering blood pressure), improves oxygen transfer in the lungs, and has direct antimicrobial properties. Humming increases NO production by 15x. This is why many breathing traditions involve nasal breathing with vocalization. When you breathe through your mouth, you bypass this entire pharmacy. The military has studied nasal NO for its ability to prevent respiratory infections in close quarters. It\u{2019}s one of the strongest arguments for nose-over-mouth breathing."
        ),
        Article(
            title: "Box Breathing \u{2014} the Navy SEAL secret",
            subtitle: "How equal-phase breathing controls the stress response",
            tag: "Pattern",
            tagColorHex: "C4502A",
            readTime: "5 min",
            body: "Mark Divine, a retired Navy SEAL commander, introduced Box Breathing to the special operations community in the early 2000s. The pattern \u{2014} 4 seconds inhale, 4 hold, 4 exhale, 4 hold \u{2014} works because of the holds. During a hold, CO\u{2082} rises slightly, which triggers a mild stress response. But the structured pattern teaches the nervous system that this stress is manageable. Over weeks of practice, your CO\u{2082} tolerance increases, and your baseline anxiety decreases. The hold phases also demand attentional control \u{2014} you cannot hold your breath and ruminate simultaneously. This is why Box Breathing is prescribed before combat operations, high-stakes negotiations, and surgical procedures. The 4-4-4-4 ratio isn\u{2019}t magic \u{2014} it\u{2019}s the equality of phases that matters."
        ),
        Article(
            title: "The Wim Hof protocol \u{2014} science vs spectacle",
            subtitle: "What the ice man actually proved",
            tag: "Advanced",
            tagColorHex: "6B4C8A",
            readTime: "7 min",
            body: "Wim Hof\u{2019}s fame rests on spectacle \u{2014} swimming under ice, climbing Everest in shorts. But the science beneath is real and peer-reviewed. A 2014 study at Radboud University showed that Hof-trained subjects could voluntarily suppress their innate immune response \u{2014} something previously thought impossible. The mechanism: 30 rounds of rapid breathing (Tummo-style) depletes CO\u{2082}, creating respiratory alkalosis. This alkaline blood shift triggers adrenaline release, which suppresses inflammatory cytokines. The breath hold that follows creates a rebound \u{2014} CO\u{2082} floods back, vasodilation occurs, and the body enters a heightened state. The risks are real: loss of consciousness is possible during holds (never in water), and the hyperventilation can trigger panic in susceptible individuals. The practice builds resilience, not relaxation \u{2014} it\u{2019}s the opposite of slow breathing."
        ),
        Article(
            title: "Buteyko \u{2014} the doctor who said we breathe too much",
            subtitle: "A Ukrainian physician\u{2019}s counter-intuitive revolution",
            tag: "History",
            tagColorHex: "7A6030",
            readTime: "6 min",
            body: "In 1952, Konstantin Buteyko was monitoring critically ill patients in a Moscow hospital when he noticed something strange: the sickest patients breathed the most. Not less \u{2014} more. He spent the next 40 years developing a theory: modern humans chronically over-breathe, depleting CO\u{2082} and paradoxically reducing oxygen delivery to tissues (via the Bohr Effect). His Reduced Breathing technique \u{2014} deliberately taking smaller, lighter breaths \u{2014} was dismissed by Western medicine for decades. Then the evidence accumulated. A 2008 Cochrane review found Buteyko breathing reduced asthma medication use by 50-90% in clinical trials. The key metric he invented \u{2014} the Control Pause (comfortable breath-hold time after a normal exhale) \u{2014} remains the best proxy for CO\u{2082} tolerance. A healthy CP is 25-40 seconds. Most chronic mouth breathers score under 15."
        ),
        Article(
            title: "The vagus nerve \u{2014} your body\u{2019}s brake pedal",
            subtitle: "How exhaling activates your longest cranial nerve",
            tag: "Science",
            tagColorHex: "2D5F5D",
            readTime: "5 min",
            body: "The vagus nerve is the longest cranial nerve in the body, running from the brainstem to the gut. It controls heart rate, digestion, immune response, and mood. Exhaling stimulates it directly \u{2014} which is why every calming breath pattern emphasises the exhale. The mechanism is mechanical: your diaphragm descends during inhalation (compressing abdominal organs, increasing heart rate) and rises during exhalation (releasing pressure, decreasing heart rate). This is called respiratory sinus arrhythmia, and it\u{2019}s the basis of HRV. When you breathe at 5.5 BPM, the vagal stimulation from each exhale is maximised. People with high vagal tone \u{2014} measured by HRV \u{2014} recover faster from stress, sleep better, digest more efficiently, and report higher emotional wellbeing. You can train vagal tone. The tool is your breath."
        ),
        Article(
            title: "Alternate nostril breathing \u{2014} ancient practice, modern neuroscience",
            subtitle: "Why yogis have been right for 3,000 years",
            tag: "Pattern",
            tagColorHex: "C4502A",
            readTime: "5 min",
            body: "Nadi Shodhana (alternate nostril breathing) appears in the Hatha Yoga Pradipika from the 15th century. Modern neuroscience has validated its core claim: each nostril preferentially activates the opposite brain hemisphere. Right nostril breathing increases left-hemisphere activity (logic, language, analytical thinking) and sympathetic arousal. Left nostril breathing increases right-hemisphere activity (creativity, spatial awareness, intuition) and parasympathetic activation. The nasal cycle \u{2014} your body\u{2019}s natural alternation between nostrils every 90-120 minutes \u{2014} reflects this hemispheric oscillation. Alternate nostril breathing manually overrides the cycle, creating bilateral balance. Studies show it reduces blood pressure, improves cognitive performance, and decreases perceived stress more effectively than simple slow breathing alone."
        ),
        Article(
            title: "The future of breathing \u{2014} what\u{2019}s next",
            subtitle: "From ancient wisdom to biometric feedback",
            tag: "Advanced",
            tagColorHex: "6B4C8A",
            readTime: "4 min",
            body: "Breathing science is entering a new era. Wearable devices now measure respiratory rate, HRV, and blood oxygen in real-time \u{2014} giving us feedback loops our ancestors never had. Researchers at Stanford are studying how specific breathing patterns can modulate gene expression through epigenetic mechanisms. The military is investing in respiratory training for cognitive performance under extreme conditions. And the simplest intervention remains the most powerful: breathe through your nose, breathe slowly, breathe less. James Nestor\u{2019}s central insight isn\u{2019}t about any single technique \u{2014} it\u{2019}s that the quality of your breathing determines the quality of your health. Every breath is a choice."
        ),
    ]
}

#Preview {
    LearnView()
}
#endif
