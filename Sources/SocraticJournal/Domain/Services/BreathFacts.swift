// BreathFacts.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Curated breathing facts used across Today tab tips and Learn tab quick facts
public enum BreathFacts {

    /// A single breath fact
    public struct Fact: Identifiable, Sendable {
        public let id: Int
        public let text: String
    }

    /// All curated facts -- factually sourced from respiratory physiology and breathwork research
    public static let all: [Fact] = [
        Fact(id: 0, text: "You take roughly 25,000 breaths every day -- most of them without thinking."),
        Fact(id: 1, text: "Humming increases nasal nitric oxide production by up to 15 times, boosting air sterilization."),
        Fact(id: 2, text: "Five minutes of cyclic sighing has been shown to reduce anxiety more effectively than five minutes of mindfulness meditation."),
        Fact(id: 3, text: "The word 'spirit' comes from the Latin 'spirare', meaning 'to breathe'."),
        Fact(id: 4, text: "Breathing through your nose filters, warms, and humidifies air before it reaches your lungs."),
        Fact(id: 5, text: "Ancient prayer traditions across cultures converge on roughly 5.5 breaths per minute -- the same rate modern science calls resonance frequency."),
        Fact(id: 6, text: "Your nostrils alternate dominance every 2 to 4 hours in a pattern called the nasal cycle."),
        Fact(id: 7, text: "Slow, deep breathing activates the vagus nerve, shifting your body from fight-or-flight to rest-and-digest."),
        Fact(id: 8, text: "Mouth breathing during sleep is linked to snoring, dry mouth, and reduced sleep quality."),
        Fact(id: 9, text: "Breathing at resonance frequency (about 5.5 breaths per minute) maximises heart rate variability, a key marker of cardiovascular health."),
        Fact(id: 10, text: "James Nestor's 10-day mouth-breathing experiment raised his blood pressure, worsened his snoring, and disrupted his sleep."),
        Fact(id: 11, text: "Diaphragmatic breathing can lower cortisol levels, helping to reduce chronic stress."),
        Fact(id: 12, text: "Newborns breathe exclusively through their noses for the first few months of life."),
        Fact(id: 13, text: "A single deep breath can lower your heart rate within seconds via the baroreflex."),
        Fact(id: 14, text: "The diaphragm is the most efficient breathing muscle, yet most adults underuse it in favour of shallow chest breathing."),
    ]

    /// Deterministic tip of the day keyed to the day of year.
    /// Returns the same fact for any given calendar day, rotating through all facts.
    public static func tipOfTheDay(for date: Date = Date(), calendar: Calendar = .current) -> Fact {
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: date) ?? 1
        let index = (dayOfYear - 1) % all.count
        return all[index]
    }
}
