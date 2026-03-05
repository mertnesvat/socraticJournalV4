import Testing
@testable import SocraticJournal

@Test func testVersion() async throws {
    #expect(SocraticJournal.version == "2.0.0")
}
