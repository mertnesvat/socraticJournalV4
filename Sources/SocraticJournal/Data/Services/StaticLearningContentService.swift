// StaticLearningContentService.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Static implementation of LearningContentServiceProtocol with hardcoded articles
public final class StaticLearningContentService: LearningContentServiceProtocol, @unchecked Sendable {
    private let articles: [LearningArticle]

    public init() {
        self.articles = Self.createArticles()
    }

    // MARK: - LearningContentServiceProtocol

    public func getAllArticles() -> [LearningArticle] {
        articles
    }

    public func getArticles(for category: LearningCategory) -> [LearningArticle] {
        articles.filter { $0.category == category }
    }

    public func getArticle(by id: String) -> LearningArticle? {
        articles.first { $0.id == id }
    }

    // MARK: - Article Content

    private static func createArticles() -> [LearningArticle] {
        [
            mouthVsNasalBreathing,
            theNasalCycle,
            hrvAndResonanceFrequency
        ]
    }

    // MARK: - Article 1: Mouth vs Nasal Breathing

    private static let mouthVsNasalBreathing = LearningArticle(
        id: "mouth-vs-nasal",
        title: "Mouth vs Nasal Breathing",
        summary: "Your nose does far more than you think. From producing nitric oxide to filtering pathogens, nasal breathing is a cornerstone of respiratory health.",
        body: """
        For most of human history, breathing through the nose was simply how people breathed. It was \
        unremarkable, automatic, the default. But somewhere along the way, modern humans became chronic \
        mouth breathers. Soft diets shrank our jaws. Allergies congested our nasal passages. Office work \
        hunched us forward, collapsing our airways. Today, an estimated 25 to 50 percent of adults \
        breathe primarily through their mouths, and the consequences are far more serious than most \
        people realise.

        The difference between nasal and mouth breathing is not merely one of preference. It is \
        physiological. Your nose is an extraordinarily sophisticated organ. The nasal cavity is lined \
        with turbinates, bony structures covered in mucous membrane that warm incoming air to body \
        temperature and humidify it to nearly 100 percent relative humidity before it reaches the \
        lungs. This conditioning is critical. Cold, dry air hitting the delicate alveoli of the lungs \
        triggers bronchoconstriction, the tightening of airways that asthmatics know all too well. \
        Mouth breathing bypasses this entire conditioning system.

        But warming and humidifying are only the beginning. The nasal passages also serve as a \
        filtration system. Tiny hairs called cilia, combined with sticky mucus, trap bacteria, \
        viruses, dust, and allergens before they can reach the lungs. Studies have shown that nasal \
        breathing filters out approximately 90 percent of airborne pathogens. Mouth breathing offers \
        essentially no filtration, delivering raw, unprocessed air directly to the lower airways.

        Perhaps the most important discovery about nasal breathing involves nitric oxide. In 1995, \
        researchers at the Karolinska Institute in Stockholm discovered that the paranasal sinuses \
        produce enormous quantities of nitric oxide, a gas that plays a critical role in immune \
        defence, blood vessel dilation, and oxygen absorption. When you breathe through your nose, \
        you carry this nitric oxide into your lungs, where it dilates the blood vessels surrounding \
        the alveoli, increasing oxygen uptake by as much as 10 to 15 percent. The concentration of \
        nitric oxide in nasal air is approximately six times higher than in mouth-breathed air. Your \
        nose is, in effect, a pharmacy producing its own bronchodilator and antimicrobial agent with \
        every breath.

        James Nestor, in his 2020 book Breath, made this tangible through a dramatic self-experiment. \
        Working with researchers at Stanford University, Nestor plugged his nose with silicone and \
        surgical tape and breathed exclusively through his mouth for ten days. The results were \
        alarming. His blood pressure rose by an average of 13 points. His heart rate variability, \
        a key marker of autonomic nervous system health, plummeted. He developed sleep apnoea, with \
        oxygen saturation dropping into the low 80s at night. He snored loudly, woke frequently, \
        and felt chronically fatigued during the day. His cognitive performance measurably declined.

        When Nestor switched back to nasal breathing for the following ten days, every single metric \
        reversed. Blood pressure normalised. Snoring stopped completely. Sleep quality improved \
        dramatically. HRV recovered. The experiment, while conducted on only two subjects, painted \
        a vivid picture of what millions of chronic mouth breathers experience every day without \
        realising it.

        The sleep implications are particularly significant. Mouth breathing during sleep is a \
        primary driver of snoring and obstructive sleep apnoea. When the mouth falls open during \
        sleep, the tongue slides backward, narrowing the airway. The resulting turbulent airflow \
        vibrates the soft palate, producing snoring. In severe cases, the airway collapses entirely, \
        causing apnoea events that can occur dozens or even hundreds of times per night. Nasal \
        breathing keeps the tongue pressed against the palate, maintaining airway patency and \
        promoting deeper, more restorative sleep.

        The practical takeaway is straightforward. During the day, notice when your mouth is open and \
        gently close it. During exercise, try to maintain nasal breathing at moderate intensities. \
        During sleep, some practitioners use mouth tape, a small strip of surgical tape over the \
        lips, to encourage nasal breathing throughout the night. The adjustment can feel uncomfortable \
        at first, especially if nasal congestion is present, but the nasal passages respond to use. \
        Like a muscle, they open more readily the more consistently you breathe through them.
        """,
        category: .science,
        keyTakeaway: "Your nose is a pharmacy \u{2014} it produces nitric oxide, humidifies air, and filters pathogens. Your mouth does none of this.",
        sourceNote: "James Nestor, Breath: The New Science of a Lost Art (2020)",
        readTimeMinutes: 4
    )

    // MARK: - Article 2: The Nasal Cycle

    private static let theNasalCycle = LearningArticle(
        id: "nasal-cycle",
        title: "The Nasal Cycle",
        summary: "Your nostrils take turns being dominant in a rhythm you have never noticed. This ancient cycle governs energy, creativity, and calm.",
        body: """
        Right now, as you read this, one of your nostrils is doing most of the breathing work. Not \
        both equally. One is relatively open and clear, pulling in the majority of air, while the \
        other is partially congested, handling only a fraction of the airflow. In a few hours, they \
        will swap. This alternating pattern, called the nasal cycle, has been running continuously \
        since the day you were born, and you have almost certainly never noticed it.

        The nasal cycle was first described in the medical literature by German physician Richard \
        Kayser in 1895, though yogic traditions documented the phenomenon thousands of years earlier \
        under the concept of swara yoga, the science of breath flow. The mechanism is straightforward. \
        Erectile tissue in the nasal turbinates, remarkably similar to the tissue found in the \
        genitals, alternately swells and shrinks in each nostril. When the tissue in the right \
        nostril engorges, airflow through that side decreases, and the left nostril becomes dominant. \
        After a period, the pattern reverses.

        The typical cycle length ranges from 75 to 200 minutes, with most people experiencing a \
        full swap approximately every 90 minutes. This timing is not coincidental. The nasal cycle \
        is synchronised with what researchers call the ultradian rhythm, a 90-minute cycle of \
        alternating activity that governs sleep stages, hormonal fluctuations, cognitive performance, \
        and even appetite. During sleep, this is the rhythm that moves you through light sleep, deep \
        sleep, and REM stages in approximately 90-minute blocks. During waking hours, the same rhythm \
        creates natural peaks and troughs in alertness and concentration.

        What makes the nasal cycle particularly fascinating is its connection to brain laterality. \
        Research by David Shannahoff-Khalsa, published in the International Journal of Neuroscience \
        in 1991, demonstrated that nostril dominance correlates with contralateral brain hemisphere \
        activity. When the right nostril is dominant, the left hemisphere, associated with logical \
        thinking, verbal processing, and analytical reasoning, tends to be more active. When the \
        left nostril is dominant, the right hemisphere, associated with spatial awareness, creativity, \
        and emotional processing, shows greater activation.

        This has practical implications that ancient yogic practitioners understood intuitively. The \
        practice of alternate nostril breathing, known as nadi shodhana, was traditionally used to \
        balance these hemispheric influences. Modern research suggests this practice may indeed \
        promote bilateral brain coherence, a state associated with calm alertness and improved \
        cognitive flexibility.

        The nasal cycle also influences the autonomic nervous system. Right nostril dominance is \
        associated with increased sympathetic nervous system tone, corresponding to higher energy, \
        alertness, and physical readiness. Left nostril dominance correlates with increased \
        parasympathetic tone, promoting relaxation, digestion, and recovery. Your body is \
        essentially oscillating between these two states throughout the day, creating natural \
        windows of energy and natural windows of rest.

        Disruption of the nasal cycle has been linked to various health conditions. Chronic nasal \
        congestion, whether from allergies, deviated septum, or nasal polyps, can impair the normal \
        alternation pattern. Some researchers have observed irregular nasal cycles in patients with \
        schizophrenia, suggesting a connection between this fundamental rhythm and broader \
        neurological health. While the research is still evolving, the nasal cycle appears to be \
        a sensitive indicator of autonomic balance.

        For practical purposes, awareness of the nasal cycle can inform your daily rhythm. If you \
        notice that your right nostril feels clearer, you may be in a natural window of alertness \
        and focus, a good time for analytical work. If the left nostril is dominant, you might find \
        yourself naturally drawn to creative tasks or reflection. Rather than fighting these \
        fluctuations with caffeine or force of will, you can work with them.

        The nasal cycle is one of those hidden rhythms of the body that, once you become aware of \
        it, you cannot unnotice. It is a reminder that the body operates on cycles within cycles, \
        from the millisecond oscillations of brain waves to the 90-minute ultradian rhythm to the \
        24-hour circadian clock. Breathing, far from being the simple mechanical act we take it for, \
        is deeply woven into every one of these rhythms.
        """,
        category: .anatomy,
        keyTakeaway: "Your body naturally alternates between nostrils every 90 minutes \u{2014} this ancient rhythm governs your energy, creativity, and calm.",
        sourceNote: "Shannahoff-Khalsa, International Journal of Neuroscience (1991)",
        readTimeMinutes: 4
    )

    // MARK: - Article 3: HRV and Resonance Frequency

    private static let hrvAndResonanceFrequency = LearningArticle(
        id: "hrv-resonance",
        title: "HRV and Resonance Frequency",
        summary: "At exactly 5.5 breaths per minute, your heart and lungs lock into a powerful feedback loop. This is the science of coherence.",
        body: """
        Your heart does not beat like a metronome. Even at rest, the interval between consecutive \
        heartbeats varies constantly. One beat might come 0.82 seconds after the last, the next \
        after 0.91 seconds, then 0.78 seconds. This variation, measured in milliseconds, is called \
        heart rate variability, or HRV. And contrary to what you might expect, more variation is \
        better. High HRV is one of the strongest biomarkers of physiological resilience, autonomic \
        flexibility, and overall health. Low HRV is associated with chronic stress, cardiovascular \
        disease, depression, and increased mortality risk.

        HRV reflects the dynamic interplay between the two branches of the autonomic nervous system. \
        The sympathetic branch, your fight-or-flight system, accelerates the heart. The \
        parasympathetic branch, operating primarily through the vagus nerve, decelerates it. In a \
        healthy individual, these two systems are constantly competing, pushing the heart rate up \
        and pulling it down in a continuous dance. The greater the range of this dance, the higher \
        the HRV, and the more adaptable the person is to stress, exercise, emotion, and recovery.

        What makes HRV particularly relevant to breathing is a phenomenon called respiratory sinus \
        arrhythmia, or RSA. With every inhalation, your heart rate naturally increases slightly. \
        With every exhalation, it decreases. This is not a bug but a feature, an evolved mechanism \
        that optimises gas exchange by matching blood flow to lung inflation. When you inhale, the \
        lungs expand and blood rushes into the pulmonary vessels. The heart speeds up to move this \
        blood efficiently. When you exhale, the lungs deflate and the heart slows, conserving \
        energy.

        In the early 2000s, researchers Paul Lehrer and Richard Gevirtz began investigating what \
        happens when you deliberately slow your breathing rate to approximately 5.5 breaths per \
        minute, corresponding to an inhale of about 5.5 seconds and an exhale of about 5.5 seconds. \
        What they discovered was a dramatic amplification of HRV. At this specific breathing rate, \
        the natural oscillation of the heart rate caused by breathing synchronises with another \
        oscillation, the baroreflex.

        The baroreflex is a feedback loop that regulates blood pressure. Baroreceptors in the aortic \
        arch and carotid arteries detect changes in blood pressure and signal the brainstem to adjust \
        heart rate accordingly. When blood pressure rises, the baroreflex slows the heart. When blood \
        pressure drops, it speeds the heart up. This baroreflex oscillation has its own natural \
        frequency, which in most adults falls at approximately 0.1 hertz, or one cycle every ten \
        seconds.

        At 5.5 breaths per minute, the respiratory cycle also lasts approximately ten seconds, five \
        and a half seconds in and five and a half seconds out. This means the respiratory oscillation \
        and the baroreflex oscillation are operating at the same frequency. When two oscillating \
        systems align in frequency, they resonate, producing dramatically amplified output. In the \
        cardiovascular system, this resonance manifests as a massive increase in HRV, often two \
        to ten times higher than baseline values.

        Lehrer and Gevirtz, in their landmark 2014 paper published in Applied Psychophysiology and \
        Biofeedback, termed this the resonance frequency. They demonstrated that breathing at or \
        near this frequency for as little as five minutes produces measurable improvements in \
        cardiac vagal tone, the strength of the parasympathetic influence on the heart. Regular \
        practice, typically 10 to 20 minutes daily, has been shown in controlled studies to reduce \
        symptoms of anxiety, depression, PTSD, asthma, and chronic pain. Athletes use resonance \
        frequency breathing to improve recovery and performance. Clinicians use it as a front-line \
        intervention for stress-related disorders.

        The mechanism is not mystical. When you breathe at resonance frequency, you are essentially \
        exercising your baroreflex. Each breath cycle forces the baroreceptors to detect a large \
        swing in blood pressure and respond by modulating heart rate through the vagus nerve. Over \
        time, this repeated stimulation strengthens the baroreflex, much as lifting weights \
        strengthens muscles. A stronger baroreflex means better blood pressure regulation, more \
        robust vagal tone, and greater autonomic flexibility in daily life.

        The individual resonance frequency varies slightly from person to person, typically falling \
        between 4.5 and 7 breaths per minute. Clinical HRV biofeedback protocols use sensors to \
        identify each person's exact resonance frequency. However, 5.5 breaths per minute is the \
        population average and an excellent starting point. This is the rate built into the \
        Resonance Breathing pattern in this app.

        What makes resonance breathing remarkable is its accessibility. No equipment is required \
        beyond a timing guide. The effects begin within a single session. And unlike pharmacological \
        interventions, the benefits compound with practice, building a more resilient nervous system \
        over weeks and months. It is, in the words of Lehrer and Gevirtz, a form of physiological \
        training that leverages the body's own regulatory architecture to produce lasting change.
        """,
        category: .science,
        keyTakeaway: "At 5.5 breaths per minute, your heart and lungs synchronise \u{2014} creating a state of maximum heart rate variability and physiological coherence.",
        sourceNote: "Lehrer & Gevirtz, Applied Psychophysiology and Biofeedback (2014)",
        readTimeMinutes: 5
    )
}
