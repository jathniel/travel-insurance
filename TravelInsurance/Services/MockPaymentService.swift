import Foundation

/// Always-succeeds payment stub, mirroring the pattern from the prior banking demo.
/// No card details, no gateway — returns a fake reference after a short delay.
struct MockPaymentService: Sendable {
    var simulatedLatency: Duration = .seconds(0.8)

    func processPayment(amount: Decimal, currencyCode: String) async throws -> String {
        try await Task.sleep(for: simulatedLatency)
        return "PAY-\(UUID().uuidString.prefix(8))"
    }
}
