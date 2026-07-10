import Foundation
import Testing
@testable import TravelInsurance

struct MockSparkQuoteServiceTests {
    private let service = MockSparkQuoteService(simulatedLatency: .zero)

    @Test func returnsThreeTiers() async throws {
        let quotes = try await service.fetchQuotes(for: .demo)

        #expect(quotes.map(\.id) == ["standard", "elite", "family"])
    }

    @Test func exactlyOneTierIsRecommended() async throws {
        let quotes = try await service.fetchQuotes(for: .demo)

        let recommended = quotes.filter(\.isRecommended)
        #expect(recommended.map(\.id) == ["elite"])
    }

    @Test func everyTierIsWellFormed() async throws {
        let quotes = try await service.fetchQuotes(for: .demo)

        for quote in quotes {
            #expect(quote.price > 0)
            #expect(quote.currencyCode == "HKD")
            #expect(!quote.tierName.isEmpty)
            #expect(!quote.benefits.isEmpty)
        }
    }

    @Test func tiersArePricedInAscendingOrder() async throws {
        let quotes = try await service.fetchQuotes(for: .demo)

        let prices = quotes.map(\.price)
        #expect(prices == prices.sorted())
    }
}
