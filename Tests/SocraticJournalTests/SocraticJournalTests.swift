import Testing
@testable import SocraticJournal

@Test func testVersion() async throws {
    #expect(SocraticJournal.version == "1.0.0")
}
