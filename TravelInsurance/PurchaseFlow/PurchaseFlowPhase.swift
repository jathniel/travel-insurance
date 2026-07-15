import Foundation

/// The in-app beats of the purchase journey once the app comes to the
/// foreground for Face ID: verifying under the biometric sheet, then a brief
/// success beat before returning to the home screen.
enum PurchaseFlowPhase: Equatable {
    case idle
    case verifying(quote: InsuranceQuote, flight: FlightDetails)
    case success(Policy)
}
