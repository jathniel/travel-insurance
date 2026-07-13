import Foundation
import Testing
@testable import TravelInsurance

struct PolicyTests {
    private var quote: InsuranceQuote {
        QuoteTierCatalog.baseTiers[0]
    }

    @Test func issuedPolicyNumberHasBrandedPrefixAndSuffix() {
        let policy = Policy.issued(for: quote, flight: .demo, paymentReference: "PAY-TEST1234")

        #expect(policy.policyNumber.hasPrefix("TI-"))
        #expect(policy.policyNumber.count == "TI-".count + 8)
    }

    @Test func issuedPolicyKeepsQuoteFlightAndPaymentReference() {
        let flight = FlightDetails.demo

        let policy = Policy.issued(for: quote, flight: flight, paymentReference: "PAY-TEST1234")

        #expect(policy.quote == quote)
        #expect(policy.flight == flight)
        #expect(policy.paymentReference == "PAY-TEST1234")
    }

    @Test func issuedPoliciesAreUnique() {
        let first = Policy.issued(for: quote, flight: .demo, paymentReference: "PAY-A")
        let second = Policy.issued(for: quote, flight: .demo, paymentReference: "PAY-B")

        #expect(first.id != second.id)
        #expect(first.policyNumber != second.policyNumber)
    }

    @Test func policyNumberSuffixMatchesPolicyID() {
        let policy = Policy.issued(for: quote, flight: .demo, paymentReference: "PAY-TEST1234")

        #expect(policy.policyNumber == "TI-\(policy.id.uuidString.prefix(8))")
    }

    @Test func codableRoundTripPreservesAllProperties() throws {
        let policy = Policy.issued(for: quote, flight: .demo, paymentReference: "PAY-TEST1234")

        let data = try JSONEncoder().encode(policy)
        let decoded = try JSONDecoder().decode(Policy.self, from: data)

        #expect(decoded == policy)
    }
}
