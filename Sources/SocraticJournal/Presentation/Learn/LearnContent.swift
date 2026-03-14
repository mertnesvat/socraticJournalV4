// LearnContent.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// All content data for the Learn tab
enum LearnContent {

    struct QuickFact: Identifiable {
        let id = UUID()
        let value: String
        let label: String
    }

    struct Article: Identifiable {
        let id: Int // Global article index (0-15)
        let title: String
        let subtitle: String
        let tag: String
        let tagColorHex: String
        let readTime: String
        let body: String
    }

    struct Chapter: Identifiable {
        let id: Int
        let title: String
        let subtitle: String
        let articles: [Article]
    }

    // MARK: - Quick Facts (8 total)

    static let quickFacts: [QuickFact] = [
        QuickFact(value: "5.5", label: "optimal breaths per min"),
        QuickFact(value: "25k", label: "breaths per day"),
        QuickFact(value: "90 min", label: "nasal cycle"),
        QuickFact(value: "NO", label: "nitric oxide from nose"),
        QuickFact(value: "Bohr", label: "CO\u{2082} releases O\u{2082}"),
        QuickFact(value: "70%", label: "of breathing should be nasal"),
        QuickFact(value: "4x", label: "more NO via humming"),
        QuickFact(value: "20%", label: "more O\u{2082} via nose"),
        QuickFact(value: "40s+", label: "excellent BOLT score"),
        QuickFact(value: "50%", label: "larger Bajau spleens"),
        QuickFact(value: "80%", label: "of apnea is mental"),
        QuickFact(value: "10\u{2013}25%", label: "heart rate drop in dive reflex"),
    ]

    // MARK: - Chapters (5 chapters, 16 articles total)

    static let chapters: [Chapter] = [
        // Chapter 1: Foundations
        Chapter(
            id: 1,
            title: "Chapter 1 \u{00b7} Foundations",
            subtitle: "The basics of nasal breathing",
            articles: [
                Article(
                    id: 0,
                    title: "You breathe 25,000 times a day.\nMost of them wrong.",
                    subtitle: "The core thesis \u{2014} mouth vs nasal breathing",
                    tag: "Start here",
                    tagColorHex: "C4502A",
                    readTime: "3 min",
                    body: "Nasal breathing filters, humidifies, and pressurises air before it reaches the lungs. It also produces nitric oxide \u{2014} a molecule that dilates blood vessels, improves oxygen transfer, and kills pathogens. Mouth breathing does none of this. The evidence from anthropology is stark: skull records show our ancestors had wide jaws, straight teeth, and open nasal passages. Modern skulls are narrower, more crowded \u{2014} a direct result of the shift to mouth breathing over centuries."
                ),
                Article(
                    id: 1,
                    title: "Your nose is a pharmacy",
                    subtitle: "Nitric oxide, filtration, and the Nobel Prize discovery",
                    tag: "Fundamentals",
                    tagColorHex: "2D5F5D",
                    readTime: "4 min",
                    body: "The nasal cavity is lined with turbinates \u{2014} bony shelves coated in mucous membrane that warm, filter, and humidify air. But the real discovery is nitric oxide. In 1998, Robert Furchgott, Louis Ignarro, and Ferid Murad won the Nobel Prize for discovering NO's role in vasodilation. Your paranasal sinuses produce nitric oxide continuously \u{2014} but only when you breathe through your nose. NO dilates pulmonary blood vessels (improving O\u{2082} absorption by up to 15%), kills bacteria and viruses on contact, and regulates blood pressure. Mouth breathing bypasses all of this. Humming increases nasal NO production by 15-fold \u{2014} this is why traditions from yoga to Orthodox Christian chanting all involve sustained nasal exhalation with vibration."
                ),
                Article(
                    id: 2,
                    title: "The mouth-breathing epidemic",
                    subtitle: "George Catlin, skull records, and the Stanford experiment",
                    tag: "History",
                    tagColorHex: "7A6030",
                    readTime: "5 min",
                    body: "George Catlin, a 19th-century painter who lived among 50 Native American tribes, observed that indigenous mothers gently closed their babies\u{2019} mouths during sleep. His 1862 book \u{2018}Shut Your Mouth and Save Your Life\u{2019} documented what he saw: tribes that breathed nasally had wide jaws, straight teeth, and robust health. Catlin\u{2019}s observations were dismissed for 150 years. Then came the Stanford mouth-breathing experiment Nestor participated in: 10 days of forced mouth breathing caused his blood pressure to spike 13 points, his snoring index to increase 4,820%, and his cognitive performance to measurably decline. The reversal was equally dramatic \u{2014} 10 days of nasal-only breathing restored every metric. Modern orthodontics now acknowledges that mouth breathing during childhood literally reshapes the skull."
                ),
            ]
        ),

        // Chapter 2: The Numbers
        Chapter(
            id: 2,
            title: "Chapter 2 \u{00b7} The Numbers",
            subtitle: "The mathematics of breath",
            articles: [
                Article(
                    id: 3,
                    title: "5.5 \u{2014} why this number",
                    subtitle: "HRV, resonance frequency, and the baroreflex",
                    tag: "Science",
                    tagColorHex: "2D5F5D",
                    readTime: "5 min",
                    body: "The cardiovascular system has a natural resonance frequency \u{2014} a rhythm at which the baroreflex (blood pressure regulator) and heart rate variability are perfectly synchronised. For most humans this is ~0.1 Hz, or about 5.5 breaths per minute. Breathing at this exact rate maximises HRV, lowers blood pressure, and creates a feedback loop between heart, lungs, and brain that has measurable effects on anxiety, sleep, and athletic performance. The prayer connection is remarkable: Nestor discovered that the Ave Maria recited in Latin, Japanese Buddhist mantras, and Hindu Japa Mala prayers all produce breathing rates between 5.5 and 6 breaths per minute. These traditions arrived at the resonance frequency independently, across centuries and continents, through subjective experience alone."
                ),
                Article(
                    id: 4,
                    title: "The nasal cycle and your brain",
                    subtitle: "Why your nostrils take turns \u{2014} and what it means",
                    tag: "Awareness",
                    tagColorHex: "2D5F5D",
                    readTime: "4 min",
                    body: "Every 90 minutes or so, your body shifts airflow from one nostril to the other \u{2014} the nasal cycle. This isn\u{2019}t random. The right nostril activates the sympathetic nervous system (alertness, left-brain activity). The left nostril activates the parasympathetic (calm, creative, right-brain). You can test this right now: close your right nostril and breathe only through your left. Within minutes, your nervous system follows."
                ),
                Article(
                    id: 5,
                    title: "Heart rate variability \u{2014} the vital sign medicine forgot",
                    subtitle: "Why HRV matters more than heart rate",
                    tag: "Measurement",
                    tagColorHex: "2D5F5D",
                    readTime: "5 min",
                    body: "HRV is the variation in time between consecutive heartbeats \u{2014} and it\u{2019}s the single best non-invasive marker of autonomic nervous system health. High HRV means your vagus nerve is strong, your stress response is flexible, and your body recovers quickly. Low HRV predicts cardiovascular disease, depression, and all-cause mortality. The connection to breathing is direct: slow breathing at resonance frequency (5.5 BPM) produces the highest possible HRV for any given individual. This is not a subtle effect \u{2014} a single 5-minute session can increase HRV by 50% compared to normal breathing. Wearable devices like Apple Watch now track HRV, making it possible to see the effect of your breath practice in real data."
                ),
            ]
        ),

        // Chapter 3: The Paradox
        Chapter(
            id: 3,
            title: "Chapter 3 \u{00b7} The Paradox",
            subtitle: "When less is more",
            articles: [
                Article(
                    id: 6,
                    title: "The CO\u{2082} problem",
                    subtitle: "Why less breathing means more oxygen",
                    tag: "Counter-intuitive",
                    tagColorHex: "7A6030",
                    readTime: "4 min",
                    body: "The Bohr Effect: oxygen clings more tightly to haemoglobin when CO\u{2082} is high. If you over-breathe and deplete CO\u{2082}, paradoxically less oxygen is released to your tissues. Buteyko\u{2019}s entire system is built on this insight. The chronic \u{2018}air hunger\u{2019} anxiety sufferers feel is usually not a lack of oxygen \u{2014} it\u{2019}s a trained intolerance to CO\u{2082}. Slow, reduced breathing rebuilds this tolerance over weeks. The practical test is the BOLT score (Body Oxygen Level Test): after a normal exhale, time how long until you feel the first urge to breathe. Most untrained people score 15-20 seconds. Patrick McKeown\u{2019}s Buteyko training aims for 40+. The improvement curve is steep \u{2014} a few weeks of reduced-volume breathing can add 10-15 seconds to your BOLT score. Breath-hold training \u{2014} from simple exhale holds to freediver CO\u{2082} tables \u{2014} is the most direct way to retrain these chemoreceptors. Even a few weeks of structured practice can shift your CO\u{2082} alarm threshold significantly."
                ),
                Article(
                    id: 7,
                    title: "Why athletes are taping their mouths shut",
                    subtitle: "Nasal breathing, VO\u{2082}, and Soviet Olympic training",
                    tag: "Performance",
                    tagColorHex: "2D5F5D",
                    readTime: "4 min",
                    body: "Mouth taping during sleep sounds extreme, but the logic is sound. Nasal breathing during exercise forces the body to tolerate higher CO\u{2082} levels \u{2014} exactly the training stimulus that improves aerobic capacity. Olga Kharitidi, a Russian physician, documented how Soviet Olympic athletes used Buteyko-style reduced breathing to gain measurable performance advantages. The modern application: training at nasal-only breathing up to the ventilatory threshold teaches the body to extract more oxygen per breath. John Douillard\u{2019}s research with cyclists showed that nasal breathing during moderate exercise produced the same VO\u{2082} with lower perceived exertion. The mouth tape during sleep simply prevents the jaw from falling open \u{2014} maintaining nasal breathing for 8 hours of passive CO\u{2082} tolerance training."
                ),
                Article(
                    id: 8,
                    title: "The Bohr Effect \u{2014} why less is more",
                    subtitle: "Christian Bohr, haemoglobin, and the oxygen delivery paradox",
                    tag: "Deep dive",
                    tagColorHex: "7A6030",
                    readTime: "6 min",
                    body: "Christian Bohr (father of Niels Bohr, the quantum physicist) discovered in 1904 that haemoglobin\u{2019}s affinity for oxygen changes with pH \u{2014} specifically, with CO\u{2082} concentration. When tissue CO\u{2082} is high, haemoglobin releases oxygen more readily. When CO\u{2082} is depleted by over-breathing, oxygen stays bound to haemoglobin and never reaches your cells. This is the Bohr Effect, and it\u{2019}s the foundational science behind Buteyko, behind altitude training, and behind the counter-intuitive finding that chronic over-breathers are often tissue-hypoxic despite having 99% blood oxygen saturation. The pulse oximeter on your finger tells you nothing \u{2014} it measures arterial saturation, not tissue delivery. The real metric is the gap between arterial O\u{2082} and venous O\u{2082} \u{2014} and slow, reduced breathing widens this gap in exactly the right direction."
                ),
            ]
        ),

        // Chapter 4: The Practice
        Chapter(
            id: 4,
            title: "Chapter 4 \u{00b7} The Practice",
            subtitle: "From theory to daily habit",
            articles: [
                Article(
                    id: 9,
                    title: "The double inhale that Stanford validated",
                    subtitle: "Cyclic sighing, controlled trials, and one-breath rescue",
                    tag: "Technique",
                    tagColorHex: "2D5F5D",
                    readTime: "3 min",
                    body: "In 2022, Stanford\u{2019}s Huberman Lab published a randomised controlled trial comparing cyclic sighing (the physiological sigh), mindfulness meditation, box breathing, and a control group. Cyclic sighing won decisively \u{2014} it produced the greatest improvement in mood, the largest reduction in respiratory rate, and the most significant increase in HRV. The mechanism: the double inhale maximally inflates alveoli (the tiny air sacs where gas exchange occurs). Some alveoli collapse during normal breathing; the second sniff \u{2018}pops\u{2019} them open, maximising the surface area for CO\u{2082} offloading. The long exhale then activates the vagus nerve more powerfully than any single-inhale pattern. It\u{2019}s fast, it\u{2019}s free, and it works in a single breath."
                ),
                Article(
                    id: 10,
                    title: "Breathing before sleep \u{2014} the 90-minute rule",
                    subtitle: "Parasympathetic activation and sleep onset science",
                    tag: "Sleep",
                    tagColorHex: "6B4C8A",
                    readTime: "4 min",
                    body: "The transition from wakefulness to sleep requires a shift from sympathetic to parasympathetic dominance. Most people try to make this shift in bed \u{2014} lying awake, minds racing. The research suggests starting 90 minutes before your target sleep time: dim the lights (melatonin is light-sensitive), lower the room temperature (core body temperature drops during sleep onset), and do 5-10 minutes of 4-7-8 or Coherent breathing. Andrew Weil reports that patients who do 4-7-8 consistently for 6-8 weeks fall asleep in under 2 minutes. The nasal cycle also plays a role: left-nostril dominance activates the parasympathetic right hemisphere. If you notice your right nostril is dominant before bed, 5 minutes of left-nostril-only breathing can manually shift your nervous system toward sleep."
                ),
                Article(
                    id: 11,
                    title: "Building a daily practice \u{2014} from 5 minutes to transformation",
                    subtitle: "Minimum effective dose and the 4-week curve",
                    tag: "Getting started",
                    tagColorHex: "5A6E3D",
                    readTime: "4 min",
                    body: "The minimum effective dose is remarkably small. Five minutes of Resonance breathing (5.5 in, 5.5 out) produces a measurable HRV increase that lasts 30-60 minutes after the session. Two sessions per day \u{2014} morning and evening \u{2014} create a training effect that accumulates over weeks. By week 4, most practitioners notice: lower resting heart rate (2-5 bpm), longer BOLT score (+5-15 seconds), reduced sleep onset time, and a subjective sense of calm that wasn\u{2019}t there before. The key insight from Nestor\u{2019}s reporting is that breathing is a skill, not a gift. Every human can learn to breathe optimally. The patterns in this app aren\u{2019}t exotic \u{2014} they\u{2019}re the natural rhythms your ancestors used. You\u{2019}re just remembering."
                ),
            ]
        ),

        // Chapter 5: The Breath Hold
        Chapter(
            id: 5,
            title: "Chapter 5 \u{00b7} The Breath Hold",
            subtitle: "The science of not breathing",
            articles: [
                Article(
                    id: 12,
                    title: "Full lungs or empty?\nThe hold that matters.",
                    subtitle: "Why the type of breath hold changes everything",
                    tag: "Physiology",
                    tagColorHex: "7A6030",
                    readTime: "5 min",
                    body: "Not all breath holds are equal. A full-lung hold (at total lung capacity) and an empty-lung hold (after a passive exhale, at functional residual capacity) produce fundamentally different training stimuli. Full-lung holds are easier and longer because stretch receptors in the lungs suppress the urge to breathe. The diaphragm is relaxed, the chest is expanded, and there is a large reservoir of oxygen to draw from. This is why beginners instinctively gulp air before holding. But the training effect is limited \u{2014} you are mostly testing oxygen stores, not CO\u{2082} tolerance. Empty-lung holds are harder and shorter, but far more effective for chemoreceptor training. With less oxygen available, CO\u{2082} rises faster. The urge to breathe arrives sooner and more intensely, which is precisely the stimulus that recalibrates your body\u{2019}s CO\u{2082} alarm threshold. This is why the BOLT test is measured after a passive exhale, not after a full inhale \u{2014} it tests your tolerance to CO\u{2082}, not the size of your lungs. The Bohr Effect connects both: higher CO\u{2082} during an empty-lung hold causes haemoglobin to release oxygen more readily to tissues. You are training your body to work efficiently with less air, which is the entire foundation of Buteyko\u{2019}s method. For most practitioners, empty-lung holds after gentle breathing are the priority. Full-lung holds have their place in freediving training, but for improving everyday breathing, the empty-lung hold is the one that matters."
                ),
                Article(
                    id: 13,
                    title: "The dive reflex\nyou didn\u{2019}t know you had",
                    subtitle: "Bradycardia, vasoconstriction, and the Bajau spleen",
                    tag: "Evolution",
                    tagColorHex: "2D5F5D",
                    readTime: "5 min",
                    body: "Every human carries an ancient survival mechanism called the mammalian dive reflex. It activates during breath holds \u{2014} especially when cold water contacts the face \u{2014} and it has four remarkable components. First, apnea itself triggers the sequence. The moment you stop breathing, your body begins preparing for oxygen conservation. Second, bradycardia: your heart rate drops 10\u{2013}25%, sometimes more. This is involuntary \u{2014} even experienced freedivers cannot override it. The vagus nerve slows the heart to reduce oxygen consumption. Third, peripheral vasoconstriction. Blood vessels in your extremities constrict, shunting blood toward your brain and heart \u{2014} the organs that cannot survive without oxygen. Your fingers and toes get cold, but your core stays oxygenated. Fourth, splenic contraction. Your spleen squeezes out stored red blood cells, temporarily increasing your blood\u{2019}s oxygen-carrying capacity by up to 6%. The Bajau people of Southeast Asia \u{2014} a community of sea nomads who have been free-diving for thousands of years \u{2014} have spleens approximately 50% larger than neighbouring non-diving populations. Genetic analysis published in Cell in 2018 confirmed this is natural selection, not acclimatisation \u{2014} a variant in the PDE10A gene is responsible. Trained freedivers show a more pronounced dive reflex than untrained people, suggesting the response is both innate and trainable. Even simple breath-hold practice on dry land activates a mild version of this reflex. Cold face immersion amplifies it dramatically \u{2014} this is why splashing cold water on your face during a panic attack works. You are triggering the same vagal bradycardia that slows a diving seal\u{2019}s heart."
                ),
                Article(
                    id: 14,
                    title: "Your spleen is a scuba tank",
                    subtitle: "The organ that gives you extra oxygen on demand",
                    tag: "Surprising",
                    tagColorHex: "C4502A",
                    readTime: "4 min",
                    body: "Your spleen is doing something remarkable that most people never learn about. This fist-sized organ in your upper left abdomen stores a reserve of red blood cells \u{2014} and during a breath hold, it contracts to release them into your bloodstream. The effect is measurable: hematocrit (the percentage of blood that is red blood cells) increases by 2\u{2013}6% within seconds of splenic contraction. More red blood cells means more haemoglobin, which means more oxygen-carrying capacity. Your body is giving itself a blood transfusion. The trigger is the sympathetic nervous system responding to apnea. As CO\u{2082} rises and oxygen falls, adrenaline causes the smooth muscle surrounding the spleen to contract. The stored red blood cells flood into circulation, buying you extra time before hypoxia becomes dangerous. The Bajau people of Southeast Asia have been diving for fish for thousands of years, and their spleens are roughly 50% larger than those of their land-dwelling neighbours. A 2018 study in Cell found a genetic variant (PDE10A) responsible for this enlargement \u{2014} genuine natural selection for diving ability, occurring over perhaps a thousand generations. Trained freedivers show more pronounced splenic contraction than untrained individuals, even during dry breath holds. The adaptation is partly genetic but also partly trainable \u{2014} regular apnea practice appears to enhance the response. However, the effect is temporary. Once you resume breathing, the spleen re-sequesters its red blood cells within minutes. This is not a permanent increase in oxygen capacity \u{2014} it is an emergency reserve, evolved for exactly the situation your body thinks it is in when you hold your breath. The takeaway is both humbling and awe-inspiring: your body has a built-in oxygen reserve that most people never activate. Even a few weeks of structured breath-hold training begins to awaken this ancient mechanism."
                ),
                Article(
                    id: 15,
                    title: "How freedivers hold their breath\nfor 10 minutes",
                    subtitle: "CO\u{2082} tables, O\u{2082} tables, and the 80% mental rule",
                    tag: "Extreme",
                    tagColorHex: "C4502A",
                    readTime: "6 min",
                    body: "The current static apnea world record exceeds 11 minutes. This is not a genetic gift \u{2014} it is trained. Competitive freedivers use two primary table protocols to systematically extend their breath-hold capacity. CO\u{2082} tables keep the hold duration fixed while progressively shortening the rest period between holds. This means CO\u{2082} never fully clears between rounds, forcing the chemoreceptors to tolerate progressively higher levels. Over weeks, the CO\u{2082} alarm threshold shifts upward. O\u{2082} tables are the inverse: rest periods stay constant while hold durations increase. This primarily trains the body\u{2019}s tolerance to falling oxygen levels and builds the psychological confidence to sit with discomfort. Most freedivers consider apnea to be 80% mental. The physiological urge to breathe \u{2014} diaphragm contractions, rising chest pressure \u{2014} is uncomfortable but not dangerous for trained individuals operating within safe limits. The mental techniques are remarkably specific: body scanning (systematically relaxing each muscle group to reduce oxygen consumption), visualisation (imagining a calm scene to prevent panic), segmented thinking (breaking a long hold into 30-second blocks rather than contemplating the total duration), and mantras (simple repeated phrases that occupy the mind). Relaxation is the master skill. A tense body consumes oxygen far faster than a relaxed one. Elite freedivers achieve heart rates of 20\u{2013}30 BPM during static holds \u{2014} not through effort, but through deep parasympathetic activation. Some advanced freedivers use lung packing (also called carping) \u{2014} using the glottis to force additional air into already-full lungs. This can increase total lung volume by 1\u{2013}2 litres but carries serious risks including lung squeeze and pneumomediastinum. It should never be attempted without expert supervision. The safety rules are absolute: never practise breath holds in water without a trained buddy, never hold your breath after hyperventilating (this depletes CO\u{2082} and eliminates the warning urge to breathe, risking shallow-water blackout), and always stop if you feel tingling, warmth, or visual disturbances. For the average user, the goal is not a 10-minute hold. It is a BOLT score above 40 and the calm, efficient breathing that comes with it. The freediver\u{2019}s techniques \u{2014} CO\u{2082} tables, relaxation, and progressive training \u{2014} are the same principles, scaled to everyday life."
                ),
            ]
        ),
    ]

    static var allArticles: [Article] {
        chapters.flatMap(\.articles)
    }
}
