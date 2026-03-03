// BreathSessionRepositoryTests.swift
// SocraticJournalTests
// Copyright 2024 StudioNext

import Testing
import Foundation
@testable import SocraticJournal

@Suite("BreathSession Repository Tests")
struct BreathSessionRepositoryTests {

    /// Creates a fresh UserDefaults-backed repository with an isolated suite name
    private func makeRepository() -> UserDefaultsBreathSessionRepository {
        let suiteName = "test.breath.sessions.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        return UserDefaultsBreathSessionRepository(defaults: defaults)
    }

    /// Helper to create a completed session at a given date
    private func makeSession(
        techniqueId: String = "resonance",
        startedAt: Date = Date(),
        durationSeconds: TimeInterval = 300,
        cyclesCompleted: Int = 5
    ) -> BreathSession {
        BreathSession(
            techniqueId: techniqueId,
            techniqueName: "Resonance Breathing",
            startedAt: startedAt,
            completedAt: startedAt.addingTimeInterval(durationSeconds),
            targetDuration: 300,
            cyclesCompleted: cyclesCompleted
        )
    }

    // MARK: - Save and Retrieve

    @Suite("Save and Retrieve")
    struct SaveAndRetrieveTests {

        private func makeRepository() -> UserDefaultsBreathSessionRepository {
            let suiteName = "test.breath.sessions.\(UUID().uuidString)"
            let defaults = UserDefaults(suiteName: suiteName)!
            return UserDefaultsBreathSessionRepository(defaults: defaults)
        }

        @Test("Saving a session and retrieving all returns it")
        func saveAndRetrieveSession() async throws {
            let repo = makeRepository()
            let session = BreathSession(
                techniqueId: "resonance",
                techniqueName: "Resonance Breathing",
                startedAt: Date(),
                completedAt: Date().addingTimeInterval(300),
                targetDuration: 300,
                cyclesCompleted: 5
            )

            try await repo.saveSession(session)
            let all = try await repo.getAllSessions()

            #expect(all.count == 1)
            #expect(all.first?.id == session.id)
            #expect(all.first?.techniqueId == "resonance")
        }

        @Test("Saving multiple sessions preserves all")
        func saveMultipleSessions() async throws {
            let repo = makeRepository()
            let session1 = BreathSession(
                techniqueId: "resonance",
                techniqueName: "Resonance",
                startedAt: Date(),
                completedAt: Date().addingTimeInterval(300),
                targetDuration: 300,
                cyclesCompleted: 5
            )
            let session2 = BreathSession(
                techniqueId: "box",
                techniqueName: "Box",
                startedAt: Date(),
                completedAt: Date().addingTimeInterval(240),
                targetDuration: 300,
                cyclesCompleted: 4
            )

            try await repo.saveSession(session1)
            try await repo.saveSession(session2)
            let all = try await repo.getAllSessions()

            #expect(all.count == 2)
        }

        @Test("Empty repository returns empty array")
        func emptyRepositoryReturnsEmpty() async throws {
            let repo = makeRepository()
            let all = try await repo.getAllSessions()
            #expect(all.isEmpty)
        }
    }

    // MARK: - Get Sessions For Date

    @Suite("Get Sessions For Date")
    struct GetSessionsForDateTests {

        private func makeRepository() -> UserDefaultsBreathSessionRepository {
            let suiteName = "test.breath.sessions.\(UUID().uuidString)"
            let defaults = UserDefaults(suiteName: suiteName)!
            return UserDefaultsBreathSessionRepository(defaults: defaults)
        }

        @Test("Returns only sessions for the specified date")
        func filtersByDate() async throws {
            let repo = makeRepository()
            let calendar = Calendar.current
            let today = Date()
            let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

            let todaySession = BreathSession(
                techniqueId: "resonance",
                techniqueName: "Resonance",
                startedAt: today,
                completedAt: today.addingTimeInterval(300),
                targetDuration: 300,
                cyclesCompleted: 5
            )
            let yesterdaySession = BreathSession(
                techniqueId: "box",
                techniqueName: "Box",
                startedAt: yesterday,
                completedAt: yesterday.addingTimeInterval(240),
                targetDuration: 300,
                cyclesCompleted: 4
            )

            try await repo.saveSession(todaySession)
            try await repo.saveSession(yesterdaySession)

            let todaySessions = try await repo.getSessions(for: today)
            #expect(todaySessions.count == 1)
            #expect(todaySessions.first?.techniqueId == "resonance")

            let yesterdaySessions = try await repo.getSessions(for: yesterday)
            #expect(yesterdaySessions.count == 1)
            #expect(yesterdaySessions.first?.techniqueId == "box")
        }

        @Test("Returns empty for date with no sessions")
        func emptyForDateWithNoSessions() async throws {
            let repo = makeRepository()
            let calendar = Calendar.current
            let yesterday = calendar.date(byAdding: .day, value: -1, to: Date())!

            let session = BreathSession(
                techniqueId: "resonance",
                techniqueName: "Resonance",
                startedAt: Date(),
                completedAt: Date().addingTimeInterval(300),
                targetDuration: 300,
                cyclesCompleted: 5
            )
            try await repo.saveSession(session)

            let yesterdaySessions = try await repo.getSessions(for: yesterday)
            #expect(yesterdaySessions.isEmpty)
        }
    }

    // MARK: - Streak Calculation

    @Suite("Streak Calculation")
    struct StreakTests {

        private func makeRepository() -> UserDefaultsBreathSessionRepository {
            let suiteName = "test.breath.sessions.\(UUID().uuidString)"
            let defaults = UserDefaults(suiteName: suiteName)!
            return UserDefaultsBreathSessionRepository(defaults: defaults)
        }

        @Test("Streak is 0 with no sessions")
        func streakZeroWithNoSessions() async throws {
            let repo = makeRepository()
            let streak = try await repo.getCurrentStreak()
            #expect(streak == 0)
        }

        @Test("Streak is 1 with session today only")
        func streakOneWithTodayOnly() async throws {
            let repo = makeRepository()
            let now = Date()
            let session = BreathSession(
                techniqueId: "resonance",
                techniqueName: "Resonance",
                startedAt: now,
                completedAt: now.addingTimeInterval(300),
                targetDuration: 300,
                cyclesCompleted: 5
            )
            try await repo.saveSession(session)

            let streak = try await repo.getCurrentStreak()
            #expect(streak == 1)
        }

        @Test("Streak counts consecutive days")
        func streakMultipleDays() async throws {
            let repo = makeRepository()
            let calendar = Calendar.current
            let today = Date()

            // Create sessions for today, yesterday, and the day before
            for daysAgo in 0..<3 {
                let date = calendar.date(byAdding: .day, value: -daysAgo, to: today)!
                let session = BreathSession(
                    techniqueId: "resonance",
                    techniqueName: "Resonance",
                    startedAt: date,
                    completedAt: date.addingTimeInterval(300),
                    targetDuration: 300,
                    cyclesCompleted: 5
                )
                try await repo.saveSession(session)
            }

            let streak = try await repo.getCurrentStreak()
            #expect(streak == 3)
        }

        @Test("Broken streak stops counting")
        func brokenStreakStopsCounting() async throws {
            let repo = makeRepository()
            let calendar = Calendar.current
            let today = Date()

            // Today
            let todaySession = BreathSession(
                techniqueId: "resonance",
                techniqueName: "Resonance",
                startedAt: today,
                completedAt: today.addingTimeInterval(300),
                targetDuration: 300,
                cyclesCompleted: 5
            )
            try await repo.saveSession(todaySession)

            // Skip yesterday, add day before yesterday
            let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: today)!
            let oldSession = BreathSession(
                techniqueId: "resonance",
                techniqueName: "Resonance",
                startedAt: twoDaysAgo,
                completedAt: twoDaysAgo.addingTimeInterval(300),
                targetDuration: 300,
                cyclesCompleted: 5
            )
            try await repo.saveSession(oldSession)

            let streak = try await repo.getCurrentStreak()
            #expect(streak == 1)
        }

        @Test("Incomplete sessions do not count toward streak")
        func incompleteSessionsIgnored() async throws {
            let repo = makeRepository()
            let now = Date()
            let incompleteSession = BreathSession(
                techniqueId: "resonance",
                techniqueName: "Resonance",
                startedAt: now,
                completedAt: nil,
                targetDuration: 300,
                cyclesCompleted: 0
            )
            try await repo.saveSession(incompleteSession)

            let streak = try await repo.getCurrentStreak()
            #expect(streak == 0)
        }
    }

    // MARK: - Total Minutes

    @Suite("Total Minutes")
    struct TotalMinutesTests {

        private func makeRepository() -> UserDefaultsBreathSessionRepository {
            let suiteName = "test.breath.sessions.\(UUID().uuidString)"
            let defaults = UserDefaults(suiteName: suiteName)!
            return UserDefaultsBreathSessionRepository(defaults: defaults)
        }

        @Test("Total minutes is 0 with no sessions")
        func totalMinutesZero() async throws {
            let repo = makeRepository()
            let minutes = try await repo.getTotalMinutesBreathed()
            #expect(minutes == 0.0)
        }

        @Test("Total minutes sums completed session durations")
        func totalMinutesSumsCorrectly() async throws {
            let repo = makeRepository()
            let now = Date()

            // 5 minute session
            let session1 = BreathSession(
                techniqueId: "resonance",
                techniqueName: "Resonance",
                startedAt: now,
                completedAt: now.addingTimeInterval(300),
                targetDuration: 300,
                cyclesCompleted: 5
            )
            // 3 minute session
            let session2 = BreathSession(
                techniqueId: "box",
                techniqueName: "Box",
                startedAt: now,
                completedAt: now.addingTimeInterval(180),
                targetDuration: 300,
                cyclesCompleted: 3
            )

            try await repo.saveSession(session1)
            try await repo.saveSession(session2)

            let minutes = try await repo.getTotalMinutesBreathed()
            #expect(minutes == 8.0)
        }

        @Test("Incomplete sessions contribute 0 minutes")
        func incompleteSessionsZeroMinutes() async throws {
            let repo = makeRepository()
            let now = Date()

            let session = BreathSession(
                techniqueId: "resonance",
                techniqueName: "Resonance",
                startedAt: now,
                completedAt: nil,
                targetDuration: 300,
                cyclesCompleted: 0
            )
            try await repo.saveSession(session)

            let minutes = try await repo.getTotalMinutesBreathed()
            #expect(minutes == 0.0)
        }
    }

    // MARK: - Total Sessions

    @Suite("Total Sessions Count")
    struct TotalSessionsTests {

        private func makeRepository() -> UserDefaultsBreathSessionRepository {
            let suiteName = "test.breath.sessions.\(UUID().uuidString)"
            let defaults = UserDefaults(suiteName: suiteName)!
            return UserDefaultsBreathSessionRepository(defaults: defaults)
        }

        @Test("Total sessions is 0 with no sessions")
        func totalSessionsZero() async throws {
            let repo = makeRepository()
            let count = try await repo.getTotalSessions()
            #expect(count == 0)
        }

        @Test("Total sessions counts all saved sessions")
        func totalSessionsCountsAll() async throws {
            let repo = makeRepository()
            let now = Date()

            for i in 0..<3 {
                let session = BreathSession(
                    techniqueId: "resonance",
                    techniqueName: "Resonance",
                    startedAt: now.addingTimeInterval(Double(i) * 600),
                    completedAt: now.addingTimeInterval(Double(i) * 600 + 300),
                    targetDuration: 300,
                    cyclesCompleted: 5
                )
                try await repo.saveSession(session)
            }

            let count = try await repo.getTotalSessions()
            #expect(count == 3)
        }
    }
}

// MARK: - Entity Tests

@Suite("BreathSession Entity Tests")
struct BreathSessionEntityTests {

    @Test("actualDuration returns correct value for completed session")
    func actualDurationCompleted() {
        let start = Date()
        let end = start.addingTimeInterval(300)
        let session = BreathSession(
            techniqueId: "resonance",
            techniqueName: "Resonance",
            startedAt: start,
            completedAt: end,
            targetDuration: 300,
            cyclesCompleted: 5
        )
        #expect(session.actualDuration == 300)
    }

    @Test("actualDuration returns 0 for incomplete session")
    func actualDurationIncomplete() {
        let session = BreathSession(
            techniqueId: "resonance",
            techniqueName: "Resonance",
            startedAt: Date(),
            completedAt: nil,
            targetDuration: 300,
            cyclesCompleted: 0
        )
        #expect(session.actualDuration == 0)
    }

    @Test("isCompleted is true when completedAt is set")
    func isCompletedTrue() {
        let session = BreathSession(
            techniqueId: "resonance",
            techniqueName: "Resonance",
            startedAt: Date(),
            completedAt: Date().addingTimeInterval(300),
            targetDuration: 300,
            cyclesCompleted: 5
        )
        #expect(session.isCompleted)
    }

    @Test("isCompleted is false when completedAt is nil")
    func isCompletedFalse() {
        let session = BreathSession(
            techniqueId: "resonance",
            techniqueName: "Resonance",
            startedAt: Date(),
            completedAt: nil,
            targetDuration: 300,
            cyclesCompleted: 0
        )
        #expect(!session.isCompleted)
    }
}

@Suite("BreathTechnique Entity Tests")
struct BreathTechniqueEntityTests {

    @Test("cycleDuration sums all phase durations")
    func cycleDurationSumsPhases() {
        let technique = BreathTechnique.box
        // 4 + 4 + 4 + 4 = 16
        #expect(technique.cycleDuration == 16.0)
    }

    @Test("resonance cycle duration is 11 seconds")
    func resonanceCycleDuration() {
        #expect(BreathTechnique.resonance.cycleDuration == 11.0)
    }

    @Test("fourSevenEight cycle duration is 19 seconds")
    func fourSevenEightCycleDuration() {
        #expect(BreathTechnique.fourSevenEight.cycleDuration == 19.0)
    }

    @Test("allTechniques contains 4 presets")
    func allTechniquesCount() {
        #expect(BreathTechnique.allTechniques.count == 4)
    }

    @Test("Equatable compares by id")
    func equatableComparesById() {
        let a = BreathTechnique.resonance
        let b = BreathTechnique.resonance
        #expect(a == b)
        #expect(BreathTechnique.resonance != BreathTechnique.box)
    }
}

@Suite("BreathPhase Entity Tests")
struct BreathPhaseEntityTests {

    @Test("displayLabel returns inhale for inhale phase")
    func displayLabelInhale() {
        let phase = BreathPhase(phaseType: .inhale, duration: 4.0)
        #expect(phase.displayLabel == "inhale")
    }

    @Test("displayLabel returns hold for holdAfterInhale")
    func displayLabelHoldAfterInhale() {
        let phase = BreathPhase(phaseType: .holdAfterInhale, duration: 4.0)
        #expect(phase.displayLabel == "hold")
    }

    @Test("displayLabel returns hold for holdAfterExhale")
    func displayLabelHoldAfterExhale() {
        let phase = BreathPhase(phaseType: .holdAfterExhale, duration: 4.0)
        #expect(phase.displayLabel == "hold")
    }

    @Test("displayLabel returns exhale for exhale phase")
    func displayLabelExhale() {
        let phase = BreathPhase(phaseType: .exhale, duration: 4.0)
        #expect(phase.displayLabel == "exhale")
    }
}

@Suite("DailyLog Entity Tests")
struct DailyLogEntityTests {

    @Test("totalMinutes sums session durations in minutes")
    func totalMinutesCalculation() {
        let now = Date()
        let sessions = [
            BreathSession(techniqueId: "resonance", techniqueName: "Resonance",
                          startedAt: now, completedAt: now.addingTimeInterval(300),
                          targetDuration: 300, cyclesCompleted: 5),
            BreathSession(techniqueId: "box", techniqueName: "Box",
                          startedAt: now, completedAt: now.addingTimeInterval(120),
                          targetDuration: 300, cyclesCompleted: 2)
        ]
        let log = DailyLog(date: now, sessions: sessions)
        #expect(log.totalMinutes == 7.0)
    }

    @Test("sessionsCount returns correct count")
    func sessionsCountCorrect() {
        let now = Date()
        let sessions = [
            BreathSession(techniqueId: "resonance", techniqueName: "Resonance",
                          startedAt: now, completedAt: now.addingTimeInterval(300),
                          targetDuration: 300, cyclesCompleted: 5)
        ]
        let log = DailyLog(date: now, sessions: sessions)
        #expect(log.sessionsCount == 1)
    }

    @Test("empty log has 0 minutes and 0 sessions")
    func emptyLog() {
        let log = DailyLog(date: Date(), sessions: [])
        #expect(log.totalMinutes == 0.0)
        #expect(log.sessionsCount == 0)
    }
}

@Suite("LearningArticle Entity Tests")
struct LearningArticleEntityTests {

    @Test("LearningCategory displayName returns correct values")
    func categoryDisplayNames() {
        #expect(LearningCategory.science.displayName == "Science")
        #expect(LearningCategory.practice.displayName == "Practice")
        #expect(LearningCategory.anatomy.displayName == "Anatomy")
    }

    @Test("LearningCategory is CaseIterable with 3 cases")
    func categoryCaseIterable() {
        #expect(LearningCategory.allCases.count == 3)
    }
}

@Suite("StaticLearningContentService Tests")
struct StaticLearningContentServiceTests {

    @Test("getAllArticles returns 3 articles")
    func allArticlesCount() {
        let service = StaticLearningContentService()
        #expect(service.getAllArticles().count == 3)
    }

    @Test("getArticles filters by category")
    func filterByCategory() {
        let service = StaticLearningContentService()
        let scienceArticles = service.getArticles(for: .science)
        #expect(scienceArticles.count == 2)

        let anatomyArticles = service.getArticles(for: .anatomy)
        #expect(anatomyArticles.count == 1)

        let practiceArticles = service.getArticles(for: .practice)
        #expect(practiceArticles.isEmpty)
    }

    @Test("getArticle by id returns correct article")
    func getArticleById() {
        let service = StaticLearningContentService()
        let article = service.getArticle(by: "mouth-vs-nasal")
        #expect(article != nil)
        #expect(article?.title == "Mouth vs Nasal Breathing")
    }

    @Test("getArticle with unknown id returns nil")
    func getArticleUnknownId() {
        let service = StaticLearningContentService()
        let article = service.getArticle(by: "nonexistent")
        #expect(article == nil)
    }

    @Test("All articles have non-empty body content")
    func allArticlesHaveContent() {
        let service = StaticLearningContentService()
        for article in service.getAllArticles() {
            #expect(!article.body.isEmpty)
            #expect(!article.title.isEmpty)
            #expect(!article.summary.isEmpty)
            #expect(!article.keyTakeaway.isEmpty)
            #expect(!article.sourceNote.isEmpty)
            #expect(article.readTimeMinutes > 0)
        }
    }
}
