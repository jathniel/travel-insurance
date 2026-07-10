import Foundation
import Testing
@testable import TravelInsurance

struct AuditLogStoreTests {
    private let fileURL = URL.temporaryDirectory.appending(path: "audit-log-\(UUID().uuidString).json")

    private func removeStoreFile() {
        try? FileManager.default.removeItem(at: fileURL)
    }

    @Test func startsEmptyWhenNoFileExists() {
        defer { removeStoreFile() }
        let store = AuditLogStore(fileURL: fileURL)

        #expect(store.entries.isEmpty)
    }

    @Test func recordInsertsNewestFirst() {
        defer { removeStoreFile() }
        let store = AuditLogStore(fileURL: fileURL)

        store.record(.invocation, detail: "Journey started")
        store.record(.journeyComplete, detail: "Journey finished")

        #expect(store.entries.map(\.step) == [.journeyComplete, .invocation])
    }

    @Test func recordCapturesStepAndDetail() throws {
        defer { removeStoreFile() }
        let store = AuditLogStore(fileURL: fileURL)

        store.record(.consentCheck, detail: "Consent requested")

        let entry = try #require(store.entries.first)
        #expect(entry.step == .consentCheck)
        #expect(entry.detail == "Consent requested")
    }

    @Test func entriesPersistAcrossStoreInstances() {
        defer { removeStoreFile() }
        let store = AuditLogStore(fileURL: fileURL)
        store.record(.invocation, detail: "Journey started")

        let reloaded = AuditLogStore(fileURL: fileURL)

        #expect(reloaded.entries == store.entries)
    }

    @Test func removeAllClearsStoreAndDisk() {
        defer { removeStoreFile() }
        let store = AuditLogStore(fileURL: fileURL)
        store.record(.invocation, detail: "Journey started")

        store.removeAll()

        #expect(store.entries.isEmpty)
        let reloaded = AuditLogStore(fileURL: fileURL)
        #expect(reloaded.entries.isEmpty)
    }

    @Test func corruptFileLoadsAsEmpty() throws {
        defer { removeStoreFile() }
        try Data("not json".utf8).write(to: fileURL)

        let store = AuditLogStore(fileURL: fileURL)

        #expect(store.entries.isEmpty)
    }
}
