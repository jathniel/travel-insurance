import SwiftUI

/// Visual identity for a `Brand` — used by the home screen and the Siri snippet views.
struct BrandTheme {
    var productName: String
    var tagline: String
    var accentColor: Color
    var secondaryColor: Color
    var logoSystemImage: String

    static func theme(for brand: Brand) -> BrandTheme {
        switch brand {
        case .generic:
            BrandTheme(
                productName: "Voyager Travel Cover",
                tagline: "Insurance that travels with you",
                accentColor: .indigo,
                secondaryColor: .teal,
                logoSystemImage: "airplane.circle.fill"
            )
        case .hsbc:
            BrandTheme(
                productName: "HSBC TravelSurance",
                tagline: "Travel with confidence",
                accentColor: Color(red: 0.86, green: 0.0, blue: 0.07),
                secondaryColor: Color(red: 0.2, green: 0.2, blue: 0.2),
                logoSystemImage: "hexagon.fill"
            )
        }
    }
}
