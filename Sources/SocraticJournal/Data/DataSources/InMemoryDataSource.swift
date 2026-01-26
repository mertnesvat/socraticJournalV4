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

        // Session 5: Exploring creativity and passion
        let session5 = JournalSession(
            id: UUID().uuidString,
            createdAt: calendar.date(byAdding: .day, value: -4, to: Date()) ?? Date(),
            exchanges: [
                Exchange(
                    question: "What drives you to create?",
                    answer: "There's something deeply satisfying about bringing ideas to life. I feel most alive when I'm building something from nothing, whether it's code, writing, or art."
                ),
                Exchange(
                    question: "How do you handle creative blocks?",
                    answer: "I've learned to step away and let my subconscious work on problems. A walk in nature or reading something unrelated often sparks new connections."
                ),
                Exchange(
                    question: "What would you create if you had unlimited resources?",
                    answer: "I'd build tools that help people understand themselves better - something that bridges technology and human wisdom."
                )
            ],
            clarityScore: ClarityScore(
                total: 85,
                completion: 100,
                depth: 80,
                emotional: 75,
                label: "Deep Dive",
                message: "Your creative spirit shines through in today's reflection."
            ),
            wisdomQuote: WisdomQuote(
                text: "Creativity takes courage.",
                author: "Henri Matisse"
            ),
            isComplete: true
        )

        // Session 6: Exploring relationships and connection
        let session6 = JournalSession(
            id: UUID().uuidString,
            createdAt: calendar.date(byAdding: .day, value: -5, to: Date()) ?? Date(),
            exchanges: [
                Exchange(
                    question: "What does meaningful connection look like to you?",
                    answer: "It's about being truly seen and understood. The conversations where time stops and you feel completely present with another person."
                ),
                Exchange(
                    question: "How do you nurture the relationships that matter most?",
                    answer: "I try to be intentional - really listening instead of just waiting to speak, remembering the small things that matter to people, showing up when it counts."
                ),
                Exchange(
                    question: "What have your relationships taught you about yourself?",
                    answer: "That I'm braver than I thought, more capable of love than I believed, and that vulnerability is actually strength in disguise."
                )
            ],
            clarityScore: ClarityScore(
                total: 90,
                completion: 100,
                depth: 88,
                emotional: 85,
                label: "Deep Dive",
                message: "A beautiful exploration of what connects us to others."
            ),
            wisdomQuote: WisdomQuote(
                text: "We are most alive when we're in love.",
                author: "John Updike"
            ),
            isComplete: true
        )

        sessions[session1.id] = session1
        sessions[session2.id] = session2
        sessions[session3.id] = session3
        sessions[session4.id] = session4
        sessions[session5.id] = session5
        sessions[session6.id] = session6

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
