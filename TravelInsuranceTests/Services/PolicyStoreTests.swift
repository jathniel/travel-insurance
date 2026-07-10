import Foundation
import Testing
@testable import TravelInsurance

struct PolicyStoreTests {
    private let fileURL = URL.temporaryDirectory.appending(path: "policies-\(UUID().uuidString).json")

    private func makePolicy(paymentReference: String = "PAY-TEST1234") -> Policy {
        .issued(for: MockSparkQuoteService.cannedQuotes[0], flight: .demo, paymentReference: paymentReference)
    }

    private func removeStoreFile() {
        try? FileManager.default.removeItem(at: fileURL)
    }

    @Test func startsEmptyWhenNoFileExists() {
        defer { removeStoreFile() }
        let store = PolicyStore(fileURL: fileURL)

        #expect(store.policies.isEmpty)
    }

    @Test func addInsertsNewestFirst() {
        defer { removeStoreFile() }
        let store = PolicyStore(fileURL: fileURL)
        let older = makePolicy(paymentReference: "PAY-OLDER")
        let newer = makePolicy(paymentReference: "PAY-NEWER")

        store.add(older)
        store.add(newer)

        #expect(store.policies.map(\.id) == [newer.id, older.id])
    }

    @Test func policiesPersistAcrossStoreInstances() {
        defer { removeStoreFile() }
        let policy = makePolicy()
        let store = PolicyStore(fileURL: fileURL)
        store.add(policy)

        let reloaded = PolicyStore(fileURL: fileURL)

        #expect(reloaded.policies == [policy])
    }

    @Test func removeAllClearsStoreAndDisk() {
        defer { removeStoreFile() }
        let store = PolicyStore(fileURL: fileURL)
        store.add(makePolicy())

        store.removeAll()

        #expect(store.policies.isEmpty)
        let reloaded = PolicyStore(fileURL: fileURL)
        #expect(reloaded.policies.isEmpty)
    }

    @Test func corruptFileLoadsAsEmpty() throws {
        defer { removeStoreFile() }
        try Data("not json".utf8).write(to: fileURL)

        let store = PolicyStore(fileURL: fileURL)

        #expect(store.policies.isEmpty)
    }
}
