// ProgramData.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Static definitions for all 3 guided programs
enum ProgramData {

    static let allPrograms: [Program] = [nasalReset, betterSleep, stressResilience]

    // MARK: - Program 1: 14-Day Nasal Breathing Reset

    static let nasalReset = Program(
        id: "nasal_reset",
        name: "14-Day Nasal Breathing Reset",
        description: "Retrain your body to breathe through the nose \u{2014} day and night. Inspired by the Stanford mouth-breathing experiment James Nestor participated in.",
        themeColorHex: "2D5F5D",
        days: [
            ProgramDay(id: 1, prescriptions: [ProgramPrescription(patternId: "coherent", durationMinutes: 5)],
                       tip: "Today is about rhythm, not effort. Breathe in for 6 counts, out for 6. If you lose count, just restart the cycle."),
            ProgramDay(id: 2, prescriptions: [ProgramPrescription(patternId: "coherent", durationMinutes: 5)],
                       tip: "Same pattern, same duration. Repetition builds the neural groove. Notice if your mind wanders less today."),
            ProgramDay(id: 3, prescriptions: [ProgramPrescription(patternId: "coherent", durationMinutes: 5)],
                       tip: "Last day of Coherent focus. Pay attention to whether you naturally breathe through your nose more during the day."),
            ProgramDay(id: 4, prescriptions: [ProgramPrescription(patternId: "resonance", durationMinutes: 5)],
                       tip: "Shift to 5.5-second rhythm. This is the resonance frequency \u{2014} where your heart rate variability peaks."),
            ProgramDay(id: 5, prescriptions: [ProgramPrescription(patternId: "resonance", durationMinutes: 5)],
                       tip: "Same pattern. Notice the rhythm feels slightly faster than Coherent. Both are effective; this one maximises HRV."),
            ProgramDay(id: 6, prescriptions: [ProgramPrescription(patternId: "resonance", durationMinutes: 5)],
                       tip: "Three days at resonance. Your baroreflex is starting to entrain. You may notice calmer responses to stress."),
            ProgramDay(id: 7, prescriptions: [ProgramPrescription(patternId: "resonance", durationMinutes: 10)],
                       tip: "Double the duration. The first 5 minutes warm up the system; the second 5 are where the real training happens."),
            ProgramDay(id: 8, prescriptions: [ProgramPrescription(patternId: "resonance", durationMinutes: 10)],
                       tip: "Same extended session. If your mind wanders, that\u{2019}s normal \u{2014} just return to the count."),
            ProgramDay(id: 9, prescriptions: [ProgramPrescription(patternId: "resonance", durationMinutes: 10)],
                       tip: "Your third 10-minute session. By now the rhythm should feel natural. Check your BOLT score if you haven\u{2019}t."),
            ProgramDay(id: 10, prescriptions: [ProgramPrescription(patternId: "buteyko", durationMinutes: 5)],
                        tip: "New pattern: shorter, reduced breaths. This builds CO\u{2082} tolerance \u{2014} the key to reducing chronic over-breathing."),
            ProgramDay(id: 11, prescriptions: [ProgramPrescription(patternId: "buteyko", durationMinutes: 5)],
                        tip: "The air hunger you feel is not danger. It\u{2019}s your chemoreceptors recalibrating. Sit with the discomfort."),
            ProgramDay(id: 12, prescriptions: [
                ProgramPrescription(patternId: "buteyko", durationMinutes: 5),
                ProgramPrescription(patternId: "resonance", durationMinutes: 5),
            ], tip: "Combine: Buteyko to build tolerance, then Resonance to integrate. This is a powerful pairing."),
            ProgramDay(id: 13, prescriptions: [
                ProgramPrescription(patternId: "nadi", durationMinutes: 5),
                ProgramPrescription(patternId: "resonance", durationMinutes: 5),
            ], tip: "Alternate nostril balances hemispheres. Follow with Resonance for HRV benefit."),
            ProgramDay(id: 14, prescriptions: [ProgramPrescription(patternId: "resonance", durationMinutes: 10)],
                        tip: "Final session. You\u{2019}ve spent 14 days retraining your breathing. Check your BOLT score \u{2014} compare to Day 1."),
        ]
    )

    // MARK: - Program 2: Better Sleep in 7 Days

    static let betterSleep = Program(
        id: "better_sleep",
        name: "Better Sleep in 7 Days",
        description: "A one-week protocol to improve sleep onset using parasympathetic activation. Practice within 90 minutes of bedtime.",
        themeColorHex: "6B4C8A",
        days: [
            ProgramDay(id: 1, prescriptions: [ProgramPrescription(patternId: "478", durationMinutes: 5)],
                       tip: "Do this within 30 minutes of bedtime. The 8-second exhale activates the vagus nerve."),
            ProgramDay(id: 2, prescriptions: [ProgramPrescription(patternId: "478", durationMinutes: 5)],
                       tip: "Dim lights 90 minutes before bed. Melatonin is suppressed by blue light."),
            ProgramDay(id: 3, prescriptions: [ProgramPrescription(patternId: "coherent", durationMinutes: 10)],
                       tip: "Try this lying in bed with eyes closed. Notice how your body temperature drops."),
            ProgramDay(id: 4, prescriptions: [ProgramPrescription(patternId: "478", durationMinutes: 10)],
                       tip: "Extended session tonight. If your mind races, don\u{2019}t fight it \u{2014} just return to the count."),
            ProgramDay(id: 5, prescriptions: [ProgramPrescription(patternId: "physiological", durationMinutes: 3)],
                       tip: "Use the sigh to clear any residual tension from the day, then settle into sleep."),
            ProgramDay(id: 6, prescriptions: [ProgramPrescription(patternId: "478", durationMinutes: 5)],
                       tip: "Left nostril breathing activates the parasympathetic hemisphere. Notice if sleep comes faster tonight."),
            ProgramDay(id: 7, prescriptions: [ProgramPrescription(patternId: "478", durationMinutes: 10)],
                       tip: "Final night. By now your body should be learning the pattern. Notice if sleep onset is faster."),
        ]
    )

    // MARK: - Program 3: Stress Resilience — 10 Days

    static let stressResilience = Program(
        id: "stress_resilience",
        name: "Stress Resilience \u{2014} 10 Days",
        description: "Build your stress response toolkit. From immediate rescue breaths to deep CO\u{2082} tolerance training.",
        themeColorHex: "C4502A",
        days: [
            ProgramDay(id: 1, prescriptions: [ProgramPrescription(patternId: "physiological", durationMinutes: 5)],
                       tip: "The fastest way to lower cortisol \u{2014} practice this until it\u{2019}s automatic."),
            ProgramDay(id: 2, prescriptions: [ProgramPrescription(patternId: "box", durationMinutes: 5)],
                       tip: "The Navy SEALs use this before operations. Equal phases demand total focus."),
            ProgramDay(id: 3, prescriptions: [
                ProgramPrescription(patternId: "physiological", durationMinutes: 3),
                ProgramPrescription(patternId: "box", durationMinutes: 7),
            ], tip: "Sigh to reset, box to sustain. This is your acute stress protocol."),
            ProgramDay(id: 4, prescriptions: [ProgramPrescription(patternId: "resonance", durationMinutes: 10)],
                       tip: "Long-term stress resilience comes from daily HRV training. This is the foundation."),
            ProgramDay(id: 5, prescriptions: [ProgramPrescription(patternId: "resonance", durationMinutes: 10)],
                       tip: "Your BOLT score is a proxy for stress tolerance. Check it today."),
            ProgramDay(id: 6, prescriptions: [
                ProgramPrescription(patternId: "buteyko", durationMinutes: 5),
                ProgramPrescription(patternId: "resonance", durationMinutes: 5),
            ], tip: "Reduced breathing trains the exact chemoreceptors that panic attacks hijack."),
            ProgramDay(id: 7, prescriptions: [ProgramPrescription(patternId: "box", durationMinutes: 10)],
                       tip: "Extend to 10 minutes. Notice how the holds get more comfortable over time."),
            ProgramDay(id: 8, prescriptions: [ProgramPrescription(patternId: "buteyko", durationMinutes: 10)],
                       tip: "The air hunger you feel is not danger \u{2014} it\u{2019}s CO\u{2082} sensitivity recalibrating."),
            ProgramDay(id: 9, prescriptions: [
                ProgramPrescription(patternId: "physiological", durationMinutes: 2),
                ProgramPrescription(patternId: "box", durationMinutes: 3),
                ProgramPrescription(patternId: "resonance", durationMinutes: 5),
            ], tip: "Practice chaining patterns. Real stress doesn\u{2019}t come with a menu."),
            ProgramDay(id: 10, prescriptions: [ProgramPrescription(patternId: "resonance", durationMinutes: 10)],
                        tip: "Final session. Compare how you feel now to Day 1. The toolkit is yours."),
        ]
    )
}
