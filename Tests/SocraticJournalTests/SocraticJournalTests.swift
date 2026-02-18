import Testing
@testable import SocraticJournal

@Test func testDefaultUserSettings() async throws {
    let settings = UserSettings.default
    #expect(settings.themeMode == .system)
    #expect(settings.dailyReminderEnabled == false)
    #expect(settings.hasCompletedOnboarding == false)
    #expect(settings.isPremium == false)
}
