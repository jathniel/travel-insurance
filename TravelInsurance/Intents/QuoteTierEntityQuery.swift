import AppIntents

/// Resolves tier identifiers against the most recently fetched quotes, so a
/// rehydrated tier carries its live SPARK price. Falls back to the catalog's
/// canned tiers before any fetch has happened.
struct QuoteTierEntityQuery: EntityQuery {
    @MainActor
    func entities(for identifiers: [String]) async throws -> [QuoteTierEntity] {
        QuoteRepository.shared.latestQuotes
            .filter { identifiers.contains($0.id) }
            .map(QuoteTierEntity.init)
    }

    @MainActor
    func suggestedEntities() async throws -> [QuoteTierEntity] {
        QuoteRepository.shared.latestQuotes.map(QuoteTierEntity.init)
    }
}
