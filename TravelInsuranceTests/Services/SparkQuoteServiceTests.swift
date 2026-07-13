import Foundation
import Testing
@testable import TravelInsurance

struct SparkQuoteServiceTests {
    /// Captured from a real Execute call against the SIT `traveltest` service.
    private let successResponse = Data("""
    {"status":"Success","response_data":{"outputs":{"elite":390,"family":546,"standard":300,"standardPrice":300},"warnings":null,"errors":null},"response_meta":{"version_id":"8190c402-3c14-4907-ab00-0a2afd4cf3ae","compiler_type":"Neuron"}}
    """.utf8)

    @Test func mapsLivePricesOntoCatalogTiers() throws {
        let quotes = try SparkQuoteService.quotes(fromResponseData: successResponse)

        #expect(quotes.map(\.id) == ["standard", "elite", "family"])
        #expect(quotes.map(\.price) == [300, 390, 546])
    }

    @Test func preservesCatalogMetadata() throws {
        let quotes = try SparkQuoteService.quotes(fromResponseData: successResponse)

        for (quote, base) in zip(quotes, QuoteTierCatalog.baseTiers) {
            #expect(quote.tierName == base.tierName)
            #expect(quote.benefits == base.benefits)
            #expect(quote.isRecommended == base.isRecommended)
            #expect(quote.currencyCode == "HKD")
        }
        #expect(quotes.filter(\.isRecommended).map(\.id) == ["elite"])
    }

    @Test func throwsOnNonSuccessStatus() {
        let failure = Data("""
        {"status":"Failure","response_data":{"outputs":{"elite":390,"family":546,"standard":300}}}
        """.utf8)

        #expect(throws: BuyTravelInsuranceError.self) {
            try SparkQuoteService.quotes(fromResponseData: failure)
        }
    }

    @Test func throwsOnMissingTierOutput() {
        let missingTier = Data("""
        {"status":"Success","response_data":{"outputs":{"elite":390,"family":546}}}
        """.utf8)

        #expect(throws: BuyTravelInsuranceError.self) {
            try SparkQuoteService.quotes(fromResponseData: missingTier)
        }
    }

    @Test func throwsOnMalformedBody() {
        #expect(throws: BuyTravelInsuranceError.self) {
            try SparkQuoteService.quotes(fromResponseData: Data("not json".utf8))
        }
    }

    @Test func requestBodyMatchesSparkContract() throws {
        let body = try JSONEncoder().encode(SparkQuoteService.ExecuteRequest(flight: .demo))
        let json = try #require(try JSONSerialization.jsonObject(with: body) as? [String: Any])

        let requestData = try #require(json["request_data"] as? [String: Any])
        let inputs = try #require(requestData["inputs"] as? [String: Any])
        let departure = try #require(inputs["departureDate"] as? String)
        let arrival = try #require(inputs["arrivalDate"] as? String)
        #expect(departure.wholeMatch(of: /\d{4}-\d{2}-\d{2}/) != nil)
        #expect(arrival.wholeMatch(of: /\d{4}-\d{2}-\d{2}/) != nil)
        #expect(departure < arrival)

        let requestMeta = try #require(json["request_meta"] as? [String: Any])
        #expect(requestMeta["version_id"] as? String == SparkQuoteService.versionID)
        #expect(requestMeta["compiler_type"] as? String == "Neuron")
    }
}
