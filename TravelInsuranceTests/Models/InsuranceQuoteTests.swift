import Foundation
import Testing
@testable import TravelInsurance

struct InsuranceQuoteTests {
    private func makeQuote(price: Decimal = 562, benefits: [String] = ["Medical cover"]) -> InsuranceQuote {
        InsuranceQuote(
            id: "test",
            tierName: "Test",
            price: price,
            currencyCode: "HKD",
            benefits: benefits,
            isRecommended: false
        )
    }

    @Test func formattedPriceShowsISOCurrencyCode() {
        let quote = makeQuote(price: 562)

        #expect(quote.formattedPrice.contains("HKD"))
        #expect(quote.formattedPrice.contains("562"))
    }

    @Test func formattedPriceOmitsFractionDigits() {
        let quote = makeQuote(price: Decimal(string: "468.75") ?? 0)

        #expect(!quote.formattedPrice.contains("75"))
    }

    @Test func topBenefitReturnsFirstBenefit() {
        let quote = makeQuote(benefits: ["First benefit", "Second benefit"])

        #expect(quote.topBenefit == "First benefit")
    }

    @Test func topBenefitIsEmptyWhenNoBenefits() {
        let quote = makeQuote(benefits: [])

        #expect(quote.topBenefit.isEmpty)
    }

    @Test func codableRoundTripPreservesAllProperties() throws {
        let quote = makeQuote()

        let data = try JSONEncoder().encode(quote)
        let decoded = try JSONDecoder().decode(InsuranceQuote.self, from: data)

        #expect(decoded == quote)
    }
}
