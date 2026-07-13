import Foundation

/// Holds the most recently fetched quote tiers so App Intents entity queries
/// can rehydrate a selected tier with its live SPARK price rather than the
/// catalog's stale canned one.
@MainActor
final class QuoteRepository {
    static let shared = QuoteRepository()

    var latestQuotes: [InsuranceQuote] = QuoteTierCatalog.baseTiers

    private init() {}
}
