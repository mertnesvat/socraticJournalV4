// InMemoryDataSource.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// In-memory data source for development and testing
/// Will be replaced with Firebase implementation
actor InMemoryDataSource {
    private var sessions: [String: JournalSession]
    private var letters: [String: FutureLetter]

    init(seedSampleData: Bool = true) {
        // Initialize empty dictionaries first
        self.sessions = [:]
        self.letters = [:]

        // Seed with sample data for development (disabled for testing)
        if seedSampleData {
            self.populateSampleData()
        }
    }

    /// Populates sample data synchronously during init (called from nonisolated context)
    private nonisolated func populateSampleData() {
        Task { await self.seedSampleData() }
    }

    // MARK: - Sessions

    func getAllSessions() -> [JournalSession] {
        Array(sessions.values).sorted { $0.createdAt > $1.createdAt }
    }

    func getSession(id: String) -> JournalSession? {
        sessions[id]
    }

    func saveSession(_ session: JournalSession) {
        sessions[session.id] = session
    }

    func deleteSession(id: String) {
        sessions.removeValue(forKey: id)
    }

    func getSessions(for date: Date) -> [JournalSession] {
        let calendar = Calendar.current
        return sessions.values.filter { session in
            calendar.isDate(session.createdAt, inSameDayAs: date)
        }.sorted { $0.createdAt > $1.createdAt }
    }

    // MARK: - Letters

    func getAllLetters() -> [FutureLetter] {
        Array(letters.values).sorted { $0.createdAt > $1.createdAt }
    }

    func getLetters(status: FutureLetterStatus) -> [FutureLetter] {
        letters.values
            .filter { $0.status == status }
            .sorted { $0.createdAt > $1.createdAt }
    }

    func saveLetter(_ letter: FutureLetter) {
        letters[letter.id] = letter
    }

    func updateLetterStatus(id: String, status: FutureLetterStatus) {
        if var letter = letters[id] {
            letter.status = status
            if status == .read {
                letter.readAt = Date()
            }
            letters[id] = letter
        }
    }

    func getReadyLettersCount() -> Int {
        letters.values.filter { letter in
            letter.status == .sealed && Date() >= letter.deliveryDate
        }.count + letters.values.filter { $0.status == .ready }.count
    }

    // MARK: - Data Management

    func clearAllSessions() {
        sessions.removeAll()
    }

    func clearAllLetters() {
        letters.removeAll()
    }

    func clearAllData() {
        sessions.removeAll()
        letters.removeAll()
    }

    // MARK: - Sample Data

    private func seedSampleData() {
        let calendar = Calendar.current

        // Create sample sessions spanning multiple days
        let session1 = JournalSession(
            id: UUID().uuidString,
            createdAt: Date(),
            exchanges: [
                Exchange(
                    question: "What's on your mind today?",
                    answer: "I've been thinking about my career direction and whether I'm making the right choices."
                ),
                Exchange(
                    question: "What makes you question your current path?",
                    answer: "Sometimes I feel like I'm just going through the motions without real purpose."
                ),
                Exchange(
                    question: "When do you feel most aligned with your purpose?",
                    answer: "When I'm creating something new and helping others learn from my experience."
                )
            ],
            clarityScore: ClarityScore(
                total: 75,
                completion: 100,
                depth: 70,
                emotional: 55,
                label: "Deep Dive",
                message: "Your deep reflection today reveals a mind truly engaged with its inner wisdom."
            ),
            wisdomQuote: WisdomQuote(
                text: "The unexamined life is not worth living.",
                author: "Socrates"
            ),
            isComplete: true
        )

        let session2 = JournalSession(
            id: UUID().uuidString,
            createdAt: calendar.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
            exchanges: [
                Exchange(
                    question: "What brought you here today?",
                    answer: "I had a difficult conversation with a friend and I'm trying to process it."
                ),
                Exchange(
                    question: "What made the conversation difficult?",
                    answer: "We disagreed about something important and I'm not sure how to move forward."
                )
            ],
            clarityScore: ClarityScore(
                total: 52,
                completion: 67,
                depth: 50,
                emotional: 40,
                label: "Thoughtful Reflection",
                message: "You've taken meaningful steps in your reflection today."
            ),
            isComplete: true
        )

        let session3 = JournalSession(
            id: UUID().uuidString,
            createdAt: calendar.date(byAdding: .day, value: -2, to: Date()) ?? Date(),
            exchanges: [
                Exchange(
                    question: "What's weighing on your heart?",
                    answer: "I've been feeling grateful for the small things lately."
                )
            ],
            clarityScore: ClarityScore(
                total: 80,
                completion: 100,
                depth: 75,
                emotional: 70,
                label: "Deep Dive",
                message: "What a profound journey you've taken today."
            ),
            isComplete: true
        )

        let session4 = JournalSession(
            id: UUID().uuidString,
            createdAt: calendar.date(byAdding: .day, value: -3, to: Date()) ?? Date(),
            exchanges: [
                Exchange(
                    question: "What's on your mind?",
                    answer: "Just taking a moment to reflect on the week."
                )
            ],
            clarityScore: ClarityScore(
                total: 60,
                completion: 100,
                depth: 45,
                emotional: 40,
                label: "Thoughtful Reflection",
                message: "Today's session shows your commitment to self-understanding."
            ),
            isComplete: true
        )

        sessions[session1.id] = session1
        sessions[session2.id] = session2
        sessions[session3.id] = session3
        sessions[session4.id] = session4

        // Create sample letters
        let readyLetter = FutureLetter(
            id: UUID().uuidString,
            content: "Dear future me, remember how far you've come...",
            createdAt: calendar.date(byAdding: .month, value: -1, to: Date()) ?? Date(),
            deliveryDate: calendar.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
            status: .ready
        )

        let sealedLetter = FutureLetter(
            id: UUID().uuidString,
            content: "I hope you're still pursuing your dreams...",
            createdAt: Date(),
            deliveryDate: calendar.date(byAdding: .month, value: 3, to: Date()) ?? Date(),
            status: .sealed
        )

        letters[readyLetter.id] = readyLetter
        letters[sealedLetter.id] = sealedLetter
    }
}
