import AppIntents

/// Resolves tier identifiers against the deterministic mocked quote set,
/// so Siri can rehydrate a selected tier without a network round trip.
struct QuoteTierEntityQuery: EntityQuery {
    @MainActor
    func entities(for identifiers: [String]) async throws -> [QuoteTierEntity] {
        MockSparkQuoteService.cannedQuotes
            .filter { identifiers.contains($0.id) }
            .map(QuoteTierEntity.init)
    }

    @MainActor
    func suggestedEntities() async throws -> [QuoteTierEntity] {
        MockSparkQuoteService.cannedQuotes.map(QuoteTierEntity.init)
    }
}
