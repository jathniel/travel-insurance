import Foundation

/// One step in the governance chain: invocation → analysis → selection → confirmation → success.
/// Mocked/local — exists to tell the "how would this be governed" story in the demo.
struct AuditEntry: Codable, Hashable, Identifiable, Sendable {
    var id: UUID
    var timestamp: Date
    var step: AuditStep
    var detail: String

    init(step: AuditStep, detail: String) {
        self.id = UUID()
        self.timestamp = .now
        self.step = step
        self.detail = detail
    }
}
