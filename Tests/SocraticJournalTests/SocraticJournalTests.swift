import Testing
@testable import SocraticJournal

@Test func testBreathPatternsExist() async throws {
    #expect(BreathPattern.allPatterns.count == 8)
    #expect(BreathPattern.resonance.cycleDuration == 11.0)
    #expect(BreathPattern.box.phases.count == 4)
}
