import Foundation

/// Errors surfaced to Siri when the purchase journey cannot complete.
enum BuyTravelInsuranceError: Error, CustomLocalizedStringResourceConvertible {
    case biometricFailed

    var localizedStringResource: LocalizedStringResource {
        switch self {
        case .biometricFailed: "The purchase wasn't authorized, so no payment was taken."
        }
    }
}
