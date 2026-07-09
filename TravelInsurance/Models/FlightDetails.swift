import Foundation

/// Flight information "extracted from the confirmation email" — hardcoded for the demo,
/// standing in for iOS on-screen awareness reading the Mail content.
struct FlightDetails: Codable, Hashable, Sendable {
    var flightNumber: String
    var airline: String
    var origin: String
    var destination: String
    var destinationDisplayName: String
    var departureDate: Date
    var returnDate: Date
    var travelers: Int

    /// The canned Bali trip used throughout the demo.
    static var demo: FlightDetails {
        let calendar = Calendar.current
        let departure = calendar.date(byAdding: .day, value: 14, to: .now) ?? .now
        let returnDate = calendar.date(byAdding: .day, value: 21, to: .now) ?? .now

        return FlightDetails(
            flightNumber: "CX785",
            airline: "Cathay Pacific",
            origin: "Hong Kong (HKG)",
            destination: "Denpasar (DPS)",
            destinationDisplayName: "Bali",
            departureDate: departure,
            returnDate: returnDate,
            travelers: 1
        )
    }

    /// Trip length in days, used for quote context.
    var tripDurationDays: Int {
        Calendar.current.dateComponents([.day], from: departureDate, to: returnDate).day ?? 0
    }
}
