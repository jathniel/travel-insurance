import Foundation

/// A single quote tier returned by the (mocked) SPARK rules engine.
struct InsuranceQuote: Codable, Hashable, Identifiable, Sendable {
    /// Stable identifier such as "standard", "elite", or "family".
    var id: String
    var tierName: String
    var price: Decimal
    var currencyCode: String
    var benefits: [String]
    var isRecommended: Bool

    /// Price formatted for display, e.g. "HKD 562.00".
    var formattedPrice: String {
        price.formatted(.currency(code: currencyCode).presentation(.isoCode).precision(.fractionLength(0)))
    }

    /// The headline benefit shown in compact contexts like the Siri tier list.
    var topBenefit: String {
        benefits.first ?? ""
    }
}
