// LearnArticle.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// A hardcoded educational article about breathing science
public struct LearnArticle: Identifiable, Sendable {
    public let id: String
    public let category: String
    public let title: String
    public let preview: String
    public let readTimeMinutes: Int
    public let sections: [ArticleSection]
    public let keyTakeaway: String
}

/// A section within an article
public struct ArticleSection: Identifiable, Sendable {
    public let id: String
    public let heading: String
    public let body: String
}

// MARK: - Article Content

public enum LearnContent {

    /// All available articles
    public static let articles: [LearnArticle] = [
        mouthVsNasal,
        nasalCycle,
        hrvResonance,
    ]

    // MARK: - Article 1: Mouth vs Nasal Breathing

    static let mouthVsNasal = LearnArticle(
        id: "mouth-vs-nasal",
        category: "Fundamentals",
        title: "Mouth vs Nasal Breathing",
        preview: "Why your nose is a pharmacy and your mouth is an emergency exit.",
        readTimeMinutes: 4,
        sections: [
            ArticleSection(
                id: "mvn-1",
                heading: "The Emergency Exit Problem",
                body: "Most adults breathe through their mouths far more than they should. Mouth breathing evolved as an emergency backup -- a way to gulp air during intense physical exertion or when the nose is blocked. But somewhere along the way, many of us started using the emergency exit as the front door.\n\nChronic mouth breathing is linked to snoring, sleep apnea, dental problems, dry mouth, and increased anxiety. It bypasses every filter and conditioning system your body spent millions of years perfecting."
            ),
            ArticleSection(
                id: "mvn-2",
                heading: "Your Nose: A Built-In Pharmacy",
                body: "Your nasal passages are lined with mucous membranes that warm, humidify, and filter incoming air. By the time air reaches your lungs through the nose, it is close to body temperature and nearly 100% humidified -- regardless of whether you are in a desert or a blizzard.\n\nBut the real superpower is nitric oxide. Your paranasal sinuses produce this molecule continuously, and when you breathe through your nose, nitric oxide mixes with the incoming air. Nitric oxide is a vasodilator -- it opens blood vessels, improves oxygen absorption in the lungs, and has antimicrobial properties that help sterilise incoming air."
            ),
            ArticleSection(
                id: "mvn-3",
                heading: "The Nestor Experiment",
                body: "Journalist James Nestor, author of 'Breath: The New Science of a Lost Art', underwent a dramatic self-experiment at Stanford University. For ten days, he plugged his nose completely and breathed only through his mouth. The results were striking.\n\nWithin days, his blood pressure rose significantly. His snoring increased by over 4,000 percent. He developed sleep apnea, his heart rate variability dropped, and he reported feeling anxious and foggy throughout. When he switched back to nasal breathing for the second ten-day period, every metric reversed."
            ),
            ArticleSection(
                id: "mvn-4",
                heading: "Making the Switch",
                body: "The good news is that switching to nasal breathing is straightforward, if not always easy. Start by noticing your breath throughout the day. Are your lips parted? Is your tongue resting on the roof of your mouth or floating at the bottom?\n\nIdeal resting position: lips gently closed, tongue pressed lightly against the palate, breathing silently through the nose. During exercise, try to maintain nasal breathing for as long as possible before switching to mouth breathing -- you may be surprised how much your capacity increases with practice.\n\nSome people even tape their lips lightly during sleep (using specialised mouth tape) to train nasal breathing overnight. It sounds extreme, but the improvements in sleep quality can be remarkable."
            ),
        ],
        keyTakeaway: "Your nose is a pharmacy; your mouth is an emergency exit. Nasal breathing filters, warms, and enriches your air with nitric oxide -- a molecule that improves oxygen absorption and fights pathogens."
    )

    // MARK: - Article 2: Nasal Cycle and Ultradian Rhythm

    static let nasalCycle = LearnArticle(
        id: "nasal-cycle",
        category: "Science",
        title: "Nasal Cycle and Ultradian Rhythm",
        preview: "Your body already knows how to breathe optimally -- it switches sides every few hours.",
        readTimeMinutes: 3,
        sections: [
            ArticleSection(
                id: "nc-1",
                heading: "The Hidden Rhythm",
                body: "Right now, without knowing it, one of your nostrils is doing most of the breathing work. In about two to four hours, they will switch. This alternating pattern is called the nasal cycle, and it has been known to yogic practitioners for thousands of years under the name 'swara yoga'. Western science confirmed it in 1895, but it remains one of the least-known facts about human physiology."
            ),
            ArticleSection(
                id: "nc-2",
                heading: "How It Works",
                body: "The erectile tissue inside your nostrils -- yes, the same type of tissue found in other parts of the body -- swells on one side while shrinking on the other. This is controlled by your autonomic nervous system, the same system that manages your heart rate, digestion, and stress response.\n\nWhen your right nostril is dominant, your sympathetic nervous system tends to be more active. You may feel more alert, energised, and mentally sharp. When your left nostril takes over, the parasympathetic side gains influence, and you may feel calmer, more creative, and more introspective."
            ),
            ArticleSection(
                id: "nc-3",
                heading: "Ultradian Rhythms",
                body: "The nasal cycle is part of a larger pattern called the ultradian rhythm -- biological cycles that repeat multiple times within a 24-hour period. Unlike the circadian rhythm (your daily sleep-wake cycle), ultradian rhythms run in 90-to-120-minute waves.\n\nResearchers have found that these waves affect your cognitive performance, creativity, appetite, and even dream cycles during sleep. The nasal cycle appears to be both a marker and a driver of these rhythms, connecting your breath directly to your brain's oscillating states of focus and rest."
            ),
            ArticleSection(
                id: "nc-4",
                heading: "Working With Your Rhythm",
                body: "You cannot force the nasal cycle, and you do not need to. Simply being aware of it can help you work with your body's natural energy patterns rather than against them.\n\nIf you notice your right nostril is clearer, it may be a good time for focused, analytical work. If the left side is dominant, consider creative tasks, reflection, or rest. Alternate nostril breathing (nadi shodhana) is a traditional practice that deliberately balances both sides, and research suggests it can reduce blood pressure and heart rate while improving attention."
            ),
        ],
        keyTakeaway: "Your body already knows how to breathe optimally -- it cycles between active and restful modes all day. The nasal cycle is a hidden rhythm connecting your breath to your brain's natural oscillations."
    )

    // MARK: - Article 3: HRV and Resonance Frequency

    static let hrvResonance = LearnArticle(
        id: "hrv-resonance",
        category: "Performance",
        title: "HRV and Resonance Frequency",
        preview: "Ancient monks and modern scientists landed on the same number: 5.5 breaths per minute.",
        readTimeMinutes: 4,
        sections: [
            ArticleSection(
                id: "hrv-1",
                heading: "What Is Heart Rate Variability?",
                body: "Your heart does not beat like a metronome. Even at rest, the time between heartbeats varies slightly -- sometimes 0.8 seconds, sometimes 1.1 seconds. This variation is called heart rate variability, or HRV, and it is one of the most important biomarkers in modern health science.\n\nHigher HRV generally indicates a healthy, resilient nervous system that can adapt quickly to stress. Lower HRV is associated with chronic stress, fatigue, anxiety, and increased risk of cardiovascular disease. Elite athletes, meditators, and people with low stress levels tend to have high HRV."
            ),
            ArticleSection(
                id: "hrv-2",
                heading: "The Resonance Sweet Spot",
                body: "Every person has a resonance frequency -- a breathing rate at which their HRV reaches its maximum amplitude. For most adults, this frequency falls between 4.5 and 7 breaths per minute, with the average clustering around 5.5 breaths per minute (approximately 5.5 seconds inhale, 5.5 seconds exhale).\n\nAt this rate, your breathing rhythm synchronises with your cardiovascular system's natural oscillation (known as the baroreflex). The result is called cardiac coherence -- a state where your heart rate, blood pressure, and breathing are in harmonious alignment."
            ),
            ArticleSection(
                id: "hrv-3",
                heading: "The Prayer Convergence",
                body: "Perhaps the most remarkable finding in resonance frequency research is its convergence with ancient traditions. When researchers timed the recitation of the Ave Maria rosary prayer, they found it naturally produces a breathing rate of almost exactly 5.5 breaths per minute. The same rate appears in Buddhist chanting, Hindu mantras, and other contemplative practices across cultures.\n\nThese traditions developed independently over thousands of years, yet they converged on the same respiratory rhythm. Modern science suggests they stumbled upon the body's resonance frequency -- the rate at which breathing most efficiently regulates the autonomic nervous system."
            ),
            ArticleSection(
                id: "hrv-4",
                heading: "Training Your HRV",
                body: "The good news is that HRV is trainable. Regular practice of resonance-frequency breathing -- even just five minutes a day -- has been shown to increase resting HRV over weeks and months.\n\nA 2023 Stanford study found that five minutes of structured cyclic sighing (a pattern of double inhale followed by extended exhale) reduced self-reported anxiety and improved mood more effectively than an equal duration of mindfulness meditation. The key is consistency: brief daily practice outperforms occasional long sessions.\n\nThis is exactly what this app is designed to help you do. Each session at the Resonance pattern (5.5s in, 5.5s out) trains your nervous system toward greater coherence and resilience."
            ),
        ],
        keyTakeaway: "Ancient monks and modern scientists landed on the same number: 5.5 breaths per minute. Breathing at this resonance frequency maximises heart rate variability and creates cardiac coherence."
    )
}
