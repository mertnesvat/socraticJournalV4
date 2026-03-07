// SampleDataGenerator.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Generates realistic breathing session and BOLT score data for demo/screenshot purposes.
/// Sessions cover 30 days with a 21-day consecutive streak.
/// BOLT scores follow a gradual upward trend with natural zigzag variation.
enum SampleDataGenerator {

    // Weighted pattern distribution (id, weight out of 100)
    private static let patternWeights: [(id: String, weight: Int)] = [
        ("resonance", 30),
        ("coherent", 20),
        ("box", 20),
        ("478", 15),
        ("physiological", 8),
        ("buteyko", 4),
        ("nadi", 3),
    ]

    // MARK: - Sessions

    static func generateSessions(days: Int = 30) -> [BreathSession] {
        var sessions: [BreathSession] = []
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        for daysAgo in 0..<days {
            guard let dayStart = calendar.date(byAdding: .day, value: -daysAgo, to: today) else { continue }

            // Last 21 days: guaranteed sessions (active streak)
            // Days 22–30 ago: ~50% chance (natural history before streak started)
            let shouldHaveSession = daysAgo < 21 || Bool.random()
            guard shouldHaveSession else { continue }

            let sessionCount = daysAgo < 10 ? Int.random(in: 1...2) : 1
            for _ in 0..<sessionCount {
                sessions.append(makeSession(on: dayStart, calendar: calendar))
            }
        }

        return sessions
    }

    // MARK: - BOLT Scores

    static func generateBOLTScores(count: Int = 14) -> [BOLTScore] {
        var scores: [BOLTScore] = []
        let calendar = Calendar.current
        let today = Date()

        // Space tests roughly 3–4 days apart, spanning ~7 weeks back
        var daysAgo = count * 4
        for i in 0..<count {
            guard let date = calendar.date(byAdding: .day, value: -daysAgo, to: today) else {
                daysAgo -= Int.random(in: 3...4)
                continue
            }

            // Gradual base curve: ~16s at start → ~31s at end
            let progress = Double(i) / Double(max(count - 1, 1))
            let baseValue = 16.0 + progress * 15.0

            // Zigzag: alternate positive/negative jitter for realism
            let jitterSign: Double = i % 2 == 0 ? 1.0 : -1.0
            let jitter = Double.random(in: 2.0...4.5) * jitterSign
            let finalScore = min(44.0, max(10.0, baseValue + jitter))

            scores.append(BOLTScore(
                id: UUID().uuidString,
                score: finalScore,
                recordedAt: date
            ))

            daysAgo -= Int.random(in: 3...4)
        }

        return scores.sorted { $0.recordedAt < $1.recordedAt }
    }

    // MARK: - Private Helpers

    private static func makeSession(on dayStart: Date, calendar: Calendar) -> BreathSession {
        let patternId = weightedRandomPattern()
        let durationSeconds = Double(Int.random(in: 3...12) * 60)
        let cycles = max(1, Int(durationSeconds / cycleDuration(for: patternId)))

        // Realistic practice times: morning (06–09) or evening (18–22)
        let hour = Bool.random() ? Int.random(in: 6...9) : Int.random(in: 18...22)
        let minute = Int.random(in: 0...59)

        let startedAt = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: dayStart) ?? dayStart
        let completedAt = startedAt.addingTimeInterval(durationSeconds)

        return BreathSession(
            id: UUID().uuidString,
            patternId: patternId,
            startedAt: startedAt,
            completedAt: completedAt,
            totalDuration: durationSeconds,
            cyclesCompleted: cycles
        )
    }

    private static func weightedRandomPattern() -> String {
        let total = patternWeights.reduce(0) { $0 + $1.weight }
        var roll = Int.random(in: 0..<total)
        for entry in patternWeights {
            if roll < entry.weight { return entry.id }
            roll -= entry.weight
        }
        return "resonance"
    }

    /// Approximate total phase duration (seconds) per cycle for each pattern
    private static func cycleDuration(for id: String) -> Double {
        switch id {
        case "resonance":     return 11.0  // 5.5 + 5.5
        case "coherent":      return 12.0  // 6 + 6
        case "box":           return 16.0  // 4+4+4+4
        case "478":           return 19.0  // 4+7+8
        case "physiological": return 11.5  // 2+1+0.5+8
        case "buteyko":       return 9.0   // 3+3+3
        case "wim":           return 3.5   // ~30 rapid cycles; large count is expected
        case "nadi":          return 12.0  // 4+4+4
        default:              return 12.0
        }
    }
}
