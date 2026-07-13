import Foundation

/// Errors surfaced to Siri when the purchase journey cannot complete.
enum BuyTravelInsuranceError: Error, CustomLocalizedStringResourceConvertible {
    case biometricFailed
    case authenticationUnavailable
    case quoteServiceUnavailable

    var localizedStringResource: LocalizedStringResource {
        switch self {
        case .biometricFailed:
            "The purchase wasn't authorized, so no payment was taken."
        case .authenticationUnavailable:
            "Authentication is required to confirm this purchase. Set up Face ID or a passcode and try again."
        case .quoteServiceUnavailable:
            "I couldn't get live quotes right now. Check the SPARK token and connection, then try again."
        }
    }
}
