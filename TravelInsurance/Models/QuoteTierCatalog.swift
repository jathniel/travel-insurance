import Foundation

/// The three demo tiers from the story map. Names, benefits, and the
/// recommendation flag are fixed product metadata; the live SPARK call
/// overrides prices, while the mock service returns these as-is.
enum QuoteTierCatalog {
    static let baseTiers: [InsuranceQuote] = [
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
}
