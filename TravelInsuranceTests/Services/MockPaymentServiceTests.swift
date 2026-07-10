import Foundation
import Testing
@testable import TravelInsurance

struct MockPaymentServiceTests {
    private let service = MockPaymentService(simulatedLatency: .zero)

    @Test func paymentReferenceHasExpectedShape() async throws {
        let reference = try await service.processPayment(amount: 562, currencyCode: "HKD")

        #expect(reference.hasPrefix("PAY-"))
        #expect(reference.count == "PAY-".count + 8)
    }

    @Test func paymentReferencesAreUnique() async throws {
        let first = try await service.processPayment(amount: 562, currencyCode: "HKD")
        let second = try await service.processPayment(amount: 562, currencyCode: "HKD")

        #expect(first != second)
    }
}
