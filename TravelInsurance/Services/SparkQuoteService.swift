import Foundation

/// Live Coherent SPARK client. Executes the `traveltest` rules service with
/// the trip dates and maps the returned tier prices onto the catalog's fixed
/// tier metadata. Any failure — transport, auth (the bearer token expires
/// after ~2 hours), or an unexpected payload — throws
/// `BuyTravelInsuranceError.quoteServiceUnavailable` so Siri reports the
/// problem instead of silently falling back to mocked quotes.
struct SparkQuoteService: QuoteService {
    static let endpoint = URL(
        string: "https://excel.sit.coherent.global/coherent/api/V3/folders/01_jath_test/services/traveltest/Execute"
    )!
    static let versionID = "8190c402-3c14-4907-ab00-0a2afd4cf3ae"

    func fetchQuotes(for flight: FlightDetails) async throws -> [InsuranceQuote] {
        var request = URLRequest(url: Self.endpoint)
        request.httpMethod = "POST"
        request.setValue("Bearer \(SparkSecrets.bearerToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("coherent", forHTTPHeaderField: "x-tenant-name")
        request.httpBody = try JSONEncoder().encode(ExecuteRequest(flight: flight))

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw BuyTravelInsuranceError.quoteServiceUnavailable
        }

        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw BuyTravelInsuranceError.quoteServiceUnavailable
        }

        return try Self.quotes(fromResponseData: data)
    }

    /// Maps an Execute response body onto the catalog tiers, replacing each
    /// tier's price with the live SPARK value. Pure, so tests can exercise it
    /// with fixtures without touching the network.
    static func quotes(fromResponseData data: Data) throws -> [InsuranceQuote] {
        guard let response = try? JSONDecoder().decode(ExecuteResponse.self, from: data),
              response.status == "Success" else {
            throw BuyTravelInsuranceError.quoteServiceUnavailable
        }

        let outputs = response.responseData.outputs
        let livePrices: [String: Decimal] = [
            "standard": outputs.standard,
            "elite": outputs.elite,
            "family": outputs.family
        ]

        return QuoteTierCatalog.baseTiers.map { tier in
            var quote = tier
            if let livePrice = livePrices[tier.id] {
                quote.price = livePrice
            }
            return quote
        }
    }
}

extension SparkQuoteService {
    /// Body for the SPARK Execute call, mirroring the API Tester's request.
    struct ExecuteRequest: Encodable {
        struct RequestData: Encodable {
            struct Inputs: Encodable {
                var arrivalDate: String
                var departureDate: String
            }

            var inputs: Inputs
        }

        struct RequestMeta: Encodable {
            var versionID = SparkQuoteService.versionID
            var callPurpose = "TravelInsurance iOS Siri demo"
            var sourceSystem = "SPARK"
            var compilerType = "Neuron"

            enum CodingKeys: String, CodingKey {
                case versionID = "version_id"
                case callPurpose = "call_purpose"
                case sourceSystem = "source_system"
                case compilerType = "compiler_type"
            }
        }

        var requestData: RequestData
        var requestMeta = RequestMeta()

        init(flight: FlightDetails) {
            let dateFormat = Date.ISO8601FormatStyle.iso8601.year().month().day().dateSeparator(.dash)
            requestData = RequestData(
                inputs: .init(
                    arrivalDate: flight.returnDate.formatted(dateFormat),
                    departureDate: flight.departureDate.formatted(dateFormat)
                )
            )
        }

        enum CodingKeys: String, CodingKey {
            case requestData = "request_data"
            case requestMeta = "request_meta"
        }
    }

    /// The subset of the Execute response the app consumes: the per-tier prices.
    struct ExecuteResponse: Decodable {
        struct ResponseData: Decodable {
            struct Outputs: Decodable {
                var standard: Decimal
                var elite: Decimal
                var family: Decimal
            }

            var outputs: Outputs
        }

        var status: String
        var responseData: ResponseData

        enum CodingKeys: String, CodingKey {
            case status
            case responseData = "response_data"
        }
    }
}
