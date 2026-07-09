import Foundation

/// Abstraction over the quoting engine. The demo uses `MockSparkQuoteService`;
/// a real Coherent SPARK client can be swapped in behind this protocol later.
protocol QuoteService: Sendable {
    func fetchQuotes(for flight: FlightDetails) async throws -> [InsuranceQuote]
}
