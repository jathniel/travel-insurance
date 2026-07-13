import AppIntents

/// Registers the Siri phrases that launch the journey. App Shortcut phrases
/// must include the application name, so the display name is "Travel Insurance"
/// and the app name doubles as the noun — "I want to buy travel insurance"
/// contains the app name and routes without the user ever naming an app.
struct TravelInsuranceShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: BuyTravelInsuranceIntent(),
            phrases: [
                "I want to buy \(.applicationName)",
                "Buy \(.applicationName)",
                "Buy \(.applicationName) for this flight",
                "Buy \(.applicationName) for my trip",
                "Get \(.applicationName)",
                "Get \(.applicationName) for my flight",
                "I need \(.applicationName) for my trip"
            ],
            shortTitle: "Buy Travel Insurance",
            systemImageName: "airplane.departure"
        )
    }
}
