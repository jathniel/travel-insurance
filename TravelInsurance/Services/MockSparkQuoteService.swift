import Foundation

/// Mocked Coherent SPARK rules engine. Returns the canned 3-tier quote set
/// after a short artificial delay so Siri's progress state is visible.
struct MockSparkQuoteService: QuoteService {
    var simulatedLatency: Duration = .seconds(1.5)

    func fetchQuotes(for flight: FlightDetails) async throws -> [InsuranceQuote] {
        try await Task.sleep(for: simulatedLatency)
        return QuoteTierCatalog.baseTiers
    }
}
