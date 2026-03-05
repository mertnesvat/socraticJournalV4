// BreathProgram.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// A multi-day guided breathing program
public struct BreathProgram: Identifiable, Codable, Sendable {
    public let id: String
    public let title: String
    public let subtitle: String
    public let description: String
    public let durationDays: Int
    public let difficulty: BreathDifficulty
    public let tagColorHex: String
    public let iconName: String
    public let days: [ProgramDay]

    public init(
        id: String,
        title: String,
        subtitle: String,
        description: String,
        durationDays: Int,
        difficulty: BreathDifficulty,
        tagColorHex: String,
        iconName: String,
        days: [ProgramDay]
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.description = description
        self.durationDays = durationDays
        self.difficulty = difficulty
        self.tagColorHex = tagColorHex
        self.iconName = iconName
        self.days = days
    }

    /// Returns the display name for a pattern ID
    public static func patternName(for patternId: String) -> String {
        BreathPattern.allPatterns.first { $0.id == patternId }?.name ?? patternId
    }

    /// Difficulty display string
    public var difficultyLabel: String {
        switch difficulty {
        case .beginner: return "Beginner"
        case .intermediate: return "Intermediate"
        case .advanced: return "Advanced"
        }
    }
}

/// A single day within a breathing program
public struct ProgramDay: Identifiable, Codable, Sendable {
    public let id: String
    public let dayNumber: Int
    public let title: String
    public let lesson: String
    public let patternId: String
    public let durationMinutes: Int
    public let focusNote: String

    public init(
        id: String,
        dayNumber: Int,
        title: String,
        lesson: String,
        patternId: String,
        durationMinutes: Int,
        focusNote: String
    ) {
        self.id = id
        self.dayNumber = dayNumber
        self.title = title
        self.lesson = lesson
        self.patternId = patternId
        self.durationMinutes = durationMinutes
        self.focusNote = focusNote
    }
}

// MARK: - All Programs

extension BreathProgram {

    /// All 4 guided breathing programs
    public static let allPrograms: [BreathProgram] = [
        .nasalBreathingReset,
        .stressResilience,
        .breathMastery,
        .eveningWindDown,
    ]

    // MARK: - Program 1: 7-Day Nasal Breathing Reset

    public static let nasalBreathingReset = BreathProgram(
        id: "nasal-reset-7",
        title: "7-Day Nasal Breathing Reset",
        subtitle: "Retrain your default breath",
        description: "Your nose is a miraculous organ \u{2014} it filters, humidifies, pressurises air and produces nitric oxide. Yet most of us breathe through our mouths. This 7-day reset retrains your default breathing pathway. By the end, nasal breathing will feel natural again.",
        durationDays: 7,
        difficulty: .beginner,
        tagColorHex: "2D5F5D",
        iconName: "nose",
        days: [
            ProgramDay(
                id: "nasal-d1",
                dayNumber: 1,
                title: "The Nose Knows",
                lesson: "Your nose produces nitric oxide, a molecule that dilates blood vessels, fights pathogens, and improves oxygen transfer. Mouth breathing bypasses all of this. Today, simply notice: are you a nose breather or a mouth breather?",
                patternId: "coherent",
                durationMinutes: 5,
                focusNote: "Breathe only through your nose for the entire session"
            ),
            ProgramDay(
                id: "nasal-d2",
                dayNumber: 2,
                title: "Slow Down",
                lesson: "The average person takes 12-20 breaths per minute. Optimal is closer to 5.5. Today we slow down to resonance pace \u{2014} the rate that synchronises your heart and lungs.",
                patternId: "resonance",
                durationMinutes: 5,
                focusNote: "Count each breath cycle. Don\u{2019}t rush."
            ),
            ProgramDay(
                id: "nasal-d3",
                dayNumber: 3,
                title: "The Exhale is Everything",
                lesson: "The exhale activates the parasympathetic nervous system \u{2014} your body\u{2019}s brake pedal. A longer exhale relative to inhale is the fastest way to calm down.",
                patternId: "coherent",
                durationMinutes: 10,
                focusNote: "Make your exhale feel effortless, like a slow deflation"
            ),
            ProgramDay(
                id: "nasal-d4",
                dayNumber: 4,
                title: "Finding Your Rhythm",
                lesson: "By day 4, the 5.5 rhythm should start to feel natural. Your body has a resonance frequency \u{2014} a pace at which your cardiovascular system operates most efficiently. This is it.",
                patternId: "resonance",
                durationMinutes: 10,
                focusNote: "Close your eyes. Let the haptic taps guide you."
            ),
            ProgramDay(
                id: "nasal-d5",
                dayNumber: 5,
                title: "Hold Your Ground",
                lesson: "Holds build CO\u{2082} tolerance \u{2014} the real key to comfortable breathing. When you hold, CO\u{2082} rises, and your body learns that this is safe.",
                patternId: "box",
                durationMinutes: 5,
                focusNote: "During holds, relax your throat and jaw completely"
            ),
            ProgramDay(
                id: "nasal-d6",
                dayNumber: 6,
                title: "The Evening Reset",
                lesson: "Dr. Andrew Weil calls this pattern a \u{2018}natural tranquiliser for the nervous system.\u{2019} The extended hold and exhale are genuinely sedating.",
                patternId: "478",
                durationMinutes: 10,
                focusNote: "Practice this lying down if possible"
            ),
            ProgramDay(
                id: "nasal-d7",
                dayNumber: 7,
                title: "Your New Default",
                lesson: "One week of conscious nasal breathing rewires your default. Notice how different your breathing feels compared to day 1.",
                patternId: "resonance",
                durationMinutes: 10,
                focusNote: "This is your daily practice going forward. Come back anytime."
            ),
        ]
    )

    // MARK: - Program 2: Stress Resilience — 10 Days

    public static let stressResilience = BreathProgram(
        id: "stress-resilience-10",
        title: "Stress Resilience \u{2014} 10 Days",
        subtitle: "Build your stress response toolkit",
        description: "Stress isn\u{2019}t the problem \u{2014} your response to it is. This program uses patterns clinically proven to interrupt the stress cycle: Box Breathing for acute stress, Physiological Sighs for panic, and Resonance for long-term resilience.",
        durationDays: 10,
        difficulty: .intermediate,
        tagColorHex: "C4502A",
        iconName: "bolt.heart",
        days: [
            ProgramDay(
                id: "stress-d1",
                dayNumber: 1,
                title: "The Stress Response",
                lesson: "When stress hits, your sympathetic nervous system fires: heart rate up, breathing shallow, muscles tense. Box Breathing interrupts this cascade with structured attention.",
                patternId: "box",
                durationMinutes: 5,
                focusNote: "Notice your heartbeat during the holds"
            ),
            ProgramDay(
                id: "stress-d2",
                dayNumber: 2,
                title: "The 30-Second Reset",
                lesson: "The physiological sigh is the fastest stress reset known to science. A double inhale pops open collapsed alveoli; the long exhale activates your vagus nerve.",
                patternId: "physiological",
                durationMinutes: 5,
                focusNote: "Double inhale through the nose, long exhale through the mouth"
            ),
            ProgramDay(
                id: "stress-d3",
                dayNumber: 3,
                title: "Building the Baseline",
                lesson: "Resonance breathing builds long-term resilience. The daily practice raises your baseline HRV, which means your nervous system starts from a calmer place.",
                patternId: "resonance",
                durationMinutes: 10,
                focusNote: "This isn\u{2019}t about today\u{2019}s stress. This is about next month\u{2019}s resilience."
            ),
            ProgramDay(
                id: "stress-d4",
                dayNumber: 4,
                title: "CO\u{2082} Tolerance",
                lesson: "The holds in Box Breathing gently raise CO\u{2082}. Your chemoreceptors learn to tolerate it. Higher CO\u{2082} tolerance = less anxiety about breathing itself.",
                patternId: "box",
                durationMinutes: 10,
                focusNote: "If the hold feels uncomfortable, that\u{2019}s the training working"
            ),
            ProgramDay(
                id: "stress-d5",
                dayNumber: 5,
                title: "The Emergency Tool",
                lesson: "Practice this until it\u{2019}s automatic. When panic strikes at 3 AM or before a presentation, you won\u{2019}t need to think \u{2014} your body will know what to do.",
                patternId: "physiological",
                durationMinutes: 5,
                focusNote: "Speed matters less than the double-inhale-long-exhale shape"
            ),
            ProgramDay(
                id: "stress-d6",
                dayNumber: 6,
                title: "Sustained Calm",
                lesson: "At 5.5 BPM for 10 minutes, your HRV enters a sustained coherent state. Brain imaging shows reduced amygdala activity \u{2014} the fear centre quiets.",
                patternId: "resonance",
                durationMinutes: 10,
                focusNote: "If thoughts arise, label them \u{2018}thinking\u{2019} and return to the breath"
            ),
            ProgramDay(
                id: "stress-d7",
                dayNumber: 7,
                title: "Under Pressure",
                lesson: "This is what Navy SEALs do before operations. The demand for attentional control during holds makes it impossible to ruminate.",
                patternId: "box",
                durationMinutes: 10,
                focusNote: "Imagine you\u{2019}re about to do something that requires total focus"
            ),
            ProgramDay(
                id: "stress-d8",
                dayNumber: 8,
                title: "The Quick Draw",
                lesson: "By day 8, the sigh should feel like second nature. Test it: think of something stressful, then sigh. Notice how fast the arousal drops.",
                patternId: "physiological",
                durationMinutes: 5,
                focusNote: "Practice the transition from stress to sigh"
            ),
            ProgramDay(
                id: "stress-d9",
                dayNumber: 9,
                title: "Deep Resilience",
                lesson: "15 minutes at resonance pace. This is the dose that produces measurable changes in HRV over weeks. You\u{2019}re building something lasting.",
                patternId: "resonance",
                durationMinutes: 15,
                focusNote: "This is your longest session yet. Stay with it."
            ),
            ProgramDay(
                id: "stress-d10",
                dayNumber: 10,
                title: "Your Toolkit",
                lesson: "You now have three tools: Box for acute focus, Sighs for emergency reset, Resonance for daily maintenance. Use them all.",
                patternId: "box",
                durationMinutes: 10,
                focusNote: "Choose which tool fits each situation in your life"
            ),
        ]
    )

    // MARK: - Program 3: 21-Day Breath Mastery

    public static let breathMastery = BreathProgram(
        id: "breath-mastery-21",
        title: "21-Day Breath Mastery",
        subtitle: "The complete breathing journey",
        description: "A comprehensive journey through every breathing pattern in the app. From basic nasal breathing to advanced Tummo practice. By day 21, you\u{2019}ll understand your respiratory system deeply and have the practice to prove it.",
        durationDays: 21,
        difficulty: .advanced,
        tagColorHex: "C4502A",
        iconName: "star.circle",
        days: [
            ProgramDay(
                id: "mastery-d1",
                dayNumber: 1,
                title: "Foundation",
                lesson: "We begin with the simplest pattern. Coherent breathing \u{2014} 6 seconds in, 6 seconds out. Whole numbers, easy counting, powerful effect.",
                patternId: "coherent",
                durationMinutes: 5,
                focusNote: "Just breathe. No expectations."
            ),
            ProgramDay(
                id: "mastery-d2",
                dayNumber: 2,
                title: "The Resonance Point",
                lesson: "5.5 BPM is your cardiovascular resonance frequency. Today we find it.",
                patternId: "resonance",
                durationMinutes: 5,
                focusNote: "Notice how your chest and belly move together"
            ),
            ProgramDay(
                id: "mastery-d3",
                dayNumber: 3,
                title: "Extending",
                lesson: "Doubling the duration. Your body is already adapting to slower breathing.",
                patternId: "coherent",
                durationMinutes: 10,
                focusNote: "If your mind wanders, gently return"
            ),
            ProgramDay(
                id: "mastery-d4",
                dayNumber: 4,
                title: "The Structure of Stress Control",
                lesson: "Introducing holds. The 4-4-4-4 pattern adds a new dimension \u{2014} CO\u{2082} tolerance.",
                patternId: "box",
                durationMinutes: 5,
                focusNote: "Holds should feel firm but not forced"
            ),
            ProgramDay(
                id: "mastery-d5",
                dayNumber: 5,
                title: "Deepening the Hold",
                lesson: "10 minutes of Box Breathing builds real CO\u{2082} tolerance.",
                patternId: "box",
                durationMinutes: 10,
                focusNote: "Relax your face and jaw during holds"
            ),
            ProgramDay(
                id: "mastery-d6",
                dayNumber: 6,
                title: "The Box at Length",
                lesson: "Repetition is the mechanism. Your chemoreceptors are recalibrating.",
                patternId: "box",
                durationMinutes: 10,
                focusNote: "Find ease within the structure"
            ),
            ProgramDay(
                id: "mastery-d7",
                dayNumber: 7,
                title: "The Sedating Breath",
                lesson: "The longest exhale in our repertoire. Genuinely sedating.",
                patternId: "478",
                durationMinutes: 5,
                focusNote: "Practice in the evening for best effect"
            ),
            ProgramDay(
                id: "mastery-d8",
                dayNumber: 8,
                title: "Going Deeper",
                lesson: "The 7-second hold pressurises oxygen into your bloodstream.",
                patternId: "478",
                durationMinutes: 10,
                focusNote: "If you feel drowsy, that\u{2019}s the pattern working"
            ),
            ProgramDay(
                id: "mastery-d9",
                dayNumber: 9,
                title: "Parasympathetic Flooding",
                lesson: "Three days of 4-7-8 rewires your evening nervous system.",
                patternId: "478",
                durationMinutes: 10,
                focusNote: "Let gravity hold your body"
            ),
            ProgramDay(
                id: "mastery-d10",
                dayNumber: 10,
                title: "The Emergency Sigh",
                lesson: "The fastest arousal reset \u{2014} one pattern, 30 seconds.",
                patternId: "physiological",
                durationMinutes: 5,
                focusNote: "Double inhale, long exhale. Simple and powerful."
            ),
            ProgramDay(
                id: "mastery-d11",
                dayNumber: 11,
                title: "Sighs on Demand",
                lesson: "Practice until it\u{2019}s reflexive. Your body should sigh before your mind decides to.",
                patternId: "physiological",
                durationMinutes: 5,
                focusNote: "Speed of deployment matters"
            ),
            ProgramDay(
                id: "mastery-d12",
                dayNumber: 12,
                title: "Combining Tools",
                lesson: "Return to resonance after learning sighs. Notice how much easier it feels now.",
                patternId: "resonance",
                durationMinutes: 10,
                focusNote: "Your baseline has shifted"
            ),
            ProgramDay(
                id: "mastery-d13",
                dayNumber: 13,
                title: "The Buteyko Insight",
                lesson: "Less is more. Buteyko\u{2019}s radical idea: you breathe too much.",
                patternId: "buteyko",
                durationMinutes: 5,
                focusNote: "Take the smallest breaths you can while staying comfortable"
            ),
            ProgramDay(
                id: "mastery-d14",
                dayNumber: 14,
                title: "Reduced Breathing",
                lesson: "Your CO\u{2082} tolerance is now high enough for this. Embrace the air hunger gently.",
                patternId: "buteyko",
                durationMinutes: 10,
                focusNote: "The urge to breathe more is just a signal, not a command"
            ),
            ProgramDay(
                id: "mastery-d15",
                dayNumber: 15,
                title: "The Patience of Less",
                lesson: "Three days of reduced breathing resets your chemoreceptor set point.",
                patternId: "buteyko",
                durationMinutes: 10,
                focusNote: "Breathe as if through a thin straw"
            ),
            ProgramDay(
                id: "mastery-d16",
                dayNumber: 16,
                title: "Nostril Awareness",
                lesson: "Which nostril is dominant right now? You\u{2019}re about to take manual control.",
                patternId: "nadi",
                durationMinutes: 5,
                focusNote: "Use your right thumb and ring finger"
            ),
            ProgramDay(
                id: "mastery-d17",
                dayNumber: 17,
                title: "Bilateral Balance",
                lesson: "Left nostril: calm. Right nostril: alert. Alternating: balanced.",
                patternId: "nadi",
                durationMinutes: 10,
                focusNote: "Feel the shift in hemispheric activation"
            ),
            ProgramDay(
                id: "mastery-d18",
                dayNumber: 18,
                title: "The Ancient Practice",
                lesson: "Nadi Shodhana has been practiced for 3,000 years. The neuroscience now confirms what yogis always knew.",
                patternId: "nadi",
                durationMinutes: 10,
                focusNote: "Let each nostril have its full cycle"
            ),
            ProgramDay(
                id: "mastery-d19",
                dayNumber: 19,
                title: "Power Breathing",
                lesson: "Advanced territory. Rapid breathing depletes CO\u{2082} and triggers adrenaline. Never in water. Never while driving.",
                patternId: "wim",
                durationMinutes: 5,
                focusNote: "30 rapid breaths, then hold. Feel the rush."
            ),
            ProgramDay(
                id: "mastery-d20",
                dayNumber: 20,
                title: "The Wim Hof Round",
                lesson: "Multiple rounds of power breathing. The alkaline blood shift, the adrenaline, the rebound. This is real.",
                patternId: "wim",
                durationMinutes: 10,
                focusNote: "Listen to your body. Stop if dizzy."
            ),
            ProgramDay(
                id: "mastery-d21",
                dayNumber: 21,
                title: "Your Practice",
                lesson: "The final day. 20 minutes of resonance \u{2014} your foundation pattern. You now know all 8 patterns and when to use each one.",
                patternId: "resonance",
                durationMinutes: 20,
                focusNote: "This is who you are now. A breather."
            ),
        ]
    )

    // MARK: - Program 4: Evening Wind-Down — 7 Days

    public static let eveningWindDown = BreathProgram(
        id: "evening-wind-down-7",
        title: "Evening Wind-Down \u{2014} 7 Days",
        subtitle: "Calm your nervous system before sleep",
        description: "Poor sleep often starts with an overactive nervous system. This 7-day program uses evening breathing patterns to activate your parasympathetic system, lower your heart rate, and prepare your body for rest.",
        durationDays: 7,
        difficulty: .beginner,
        tagColorHex: "6B4C8A",
        iconName: "moon.stars",
        days: [
            ProgramDay(
                id: "evening-d1",
                dayNumber: 1,
                title: "The Evening Breath",
                lesson: "Tonight, we begin the wind-down. The 4-7-8 pattern is designed to be sedating.",
                patternId: "478",
                durationMinutes: 5,
                focusNote: "Practice 30 minutes before your intended sleep time"
            ),
            ProgramDay(
                id: "evening-d2",
                dayNumber: 2,
                title: "Slow and Steady",
                lesson: "Coherent breathing lowers resting heart rate over time. Lower heart rate = easier sleep onset.",
                patternId: "coherent",
                durationMinutes: 5,
                focusNote: "Focus on making each breath exactly the same length"
            ),
            ProgramDay(
                id: "evening-d3",
                dayNumber: 3,
                title: "The Long Exhale",
                lesson: "The 8-second exhale activates your vagus nerve more than any other phase ratio.",
                patternId: "478",
                durationMinutes: 10,
                focusNote: "If you fall asleep during the session, that\u{2019}s success"
            ),
            ProgramDay(
                id: "evening-d4",
                dayNumber: 4,
                title: "Relief",
                lesson: "When anxious thoughts spike before bed, sighs break the cycle in 30 seconds.",
                patternId: "physiological",
                durationMinutes: 5,
                focusNote: "Double inhale through the nose, long exhale through the mouth"
            ),
            ProgramDay(
                id: "evening-d5",
                dayNumber: 5,
                title: "Coherent Calm",
                lesson: "Stephen Elliott\u{2019}s research shows coherent breathing measurably lowers resting heart rate.",
                patternId: "coherent",
                durationMinutes: 10,
                focusNote: "Make each breath a mirror image of the last"
            ),
            ProgramDay(
                id: "evening-d6",
                dayNumber: 6,
                title: "The Ritual",
                lesson: "Rituals signal transitions. Your brain is learning: this breathing pattern \u{2192} sleep follows.",
                patternId: "478",
                durationMinutes: 10,
                focusNote: "Same time, same place, same pattern"
            ),
            ProgramDay(
                id: "evening-d7",
                dayNumber: 7,
                title: "Your Evening Practice",
                lesson: "Seven days of evening practice. You now have a drug-free, side-effect-free tool for better sleep.",
                patternId: "478",
                durationMinutes: 10,
                focusNote: "This is yours forever. No subscription required."
            ),
        ]
    )
}
