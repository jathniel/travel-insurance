import Foundation

/// A purchased travel insurance policy. Mocked — written locally, never sent to a real system.
struct Policy: Codable, Hashable, Identifiable, Sendable {
    var id: UUID
    var policyNumber: String
    var quote: InsuranceQuote
    var flight: FlightDetails
    var purchaseDate: Date
    var paymentReference: String

    static func issued(for quote: InsuranceQuote, flight: FlightDetails, paymentReference: String) -> Policy {
        let id = UUID()
        let suffix = id.uuidString.prefix(8)

        return Policy(
            id: id,
            policyNumber: "TI-\(suffix)",
            quote: quote,
            flight: flight,
            purchaseDate: .now,
            paymentReference: paymentReference
        )
    }
}
