import Foundation
import Observation

/// Local store of purchased policies. Backed by a JSON file in the app's documents
/// directory so headless App Intent runs and the app UI see the same data.
@Observable
final class PolicyStore {
    /// Shared instance used by both the Siri intent (headless) and the app UI.
    static let shared = PolicyStore()

    private(set) var policies: [Policy] = []

    private let fileURL: URL

    init(fileURL: URL = URL.documentsDirectory.appending(path: "policies.json")) {
        self.fileURL = fileURL
        load()
    }

    func add(_ policy: Policy) {
        policies.insert(policy, at: 0)
        save()
    }

    func removeAll() {
        policies.removeAll()
        save()
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL) else { return }
        policies = (try? JSONDecoder().decode([Policy].self, from: data)) ?? []
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(policies) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
}
