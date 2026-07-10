import Foundation
import Testing
@testable import TravelInsurance

struct FlightDetailsTests {
    @Test func demoTripLastsSevenDays() {
        let flight = FlightDetails.demo

        #expect(flight.tripDurationDays == 7)
    }

    @Test func demoDepartureIsBeforeReturn() {
        let flight = FlightDetails.demo

        #expect(flight.departureDate < flight.returnDate)
    }

    @Test func demoDepartsInTheFuture() {
        let flight = FlightDetails.demo

        #expect(flight.departureDate > .now)
    }

    @Test func tripDurationCountsWholeDaysBetweenDates() throws {
        let departure = try Date("2026-08-01T09:00:00Z", strategy: .iso8601)
        let returnDate = try Date("2026-08-11T09:00:00Z", strategy: .iso8601)

        var flight = FlightDetails.demo
        flight.departureDate = departure
        flight.returnDate = returnDate

        #expect(flight.tripDurationDays == 10)
    }

    @Test func codableRoundTripPreservesAllProperties() throws {
        let flight = FlightDetails.demo

        let data = try JSONEncoder().encode(flight)
        let decoded = try JSONDecoder().decode(FlightDetails.self, from: data)

        #expect(decoded == flight)
    }
}
