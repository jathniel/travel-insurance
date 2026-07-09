import Foundation

/// Mocked Coherent SPARK rules engine. Returns the canned 3-tier quote set
/// after a short artificial delay so Siri's progress state is visible.
struct MockSparkQuoteService: QuoteService {
    /// The canned tiers from the story map. Deterministic so App Intent
    /// entity queries can resolve tier identifiers without a network round trip.
    static let cannedQuotes: [InsuranceQuote] = [
        InsuranceQuote(
            id: "standard",
            tierName: "Standard",
            price: 468,
            currencyCode: "HKD",
            benefits: [
                "Medical cover up to HKD 500,000",
                "Trip cancellation up to HKD 20,000",
                "Baggage delay cover"
            ],
            isRecommended: false
        ),
        InsuranceQuote(
            id: "elite",
            tierName: "Elite",
            price: 562,
            currencyCode: "HKD",
            benefits: [
                "Medical cover up to HKD 1,200,000",
                "Trip cancellation up to HKD 50,000",
                "Adventure activities included",
                "24/7 emergency assistance"
            ],
            isRecommended: true
        ),
        InsuranceQuote(
            id: "family",
            tierName: "Family",
            price: 702,
            currencyCode: "HKD",
            benefits: [
                "Covers 2 adults + 3 children",
                "Medical cover up to HKD 1,000,000 per person",
                "Trip cancellation up to HKD 40,000",
                "Family baggage protection"
            ],
            isRecommended: false
        )
    ]

    var simulatedLatency: Duration = .seconds(1.5)

    func fetchQuotes(for flight: FlightDetails) async throws -> [InsuranceQuote] {
        try await Task.sleep(for: simulatedLatency)
        return Self.cannedQuotes
    }
}
