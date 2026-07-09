import Foundation
import Observation

/// Local audit trail for the governance narrative. Mocked — persisted to a JSON file
/// in documents so the app UI can replay the full Siri journey after the fact.
@Observable
final class AuditLogStore {
    /// Shared instance used by both the Siri intent (headless) and the app UI.
    static let shared = AuditLogStore()

    private(set) var entries: [AuditEntry] = []

    private let fileURL: URL

    init(fileURL: URL = URL.documentsDirectory.appending(path: "audit-log.json")) {
        self.fileURL = fileURL
        load()
    }

    func record(_ step: AuditStep, detail: String) {
        entries.insert(AuditEntry(step: step, detail: detail), at: 0)
        save()
    }

    func removeAll() {
        entries.removeAll()
        save()
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL) else { return }
        entries = (try? JSONDecoder().decode([AuditEntry].self, from: data)) ?? []
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(entries) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
}
