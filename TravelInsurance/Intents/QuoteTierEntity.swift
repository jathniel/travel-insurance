import AppIntents

/// App Intents entity wrapping one quote tier so Siri can render the 3-tier
/// selection natively — tappable list with voice selection, narrated dialog.
struct QuoteTierEntity: AppEntity {
    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Insurance Plan"
    static let defaultQuery = QuoteTierEntityQuery()

    var id: String
    var quote: InsuranceQuote

    init(quote: InsuranceQuote) {
        self.id = quote.id
        self.quote = quote
    }

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: "\(quote.tierName) — \(quote.formattedPrice)",
            subtitle: quote.isRecommended ? "Recommended · \(quote.topBenefit)" : "\(quote.topBenefit)",
            image: .init(systemName: quote.isRecommended ? "star.circle.fill" : "shield")
        )
    }
}
