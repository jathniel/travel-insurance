import AppIntents

/// Registers the Siri phrases that launch the journey. App Shortcut phrases
/// must include the application name — the demo script says the phrase as written here.
struct TravelInsuranceShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: BuyTravelInsuranceIntent(),
            phrases: [
                "Buy travel insurance with \(.applicationName)",
                "Buy travel insurance for this flight with \(.applicationName)",
                "Get travel insurance from \(.applicationName)",
                "Insure my trip with \(.applicationName)"
            ],
            shortTitle: "Buy Travel Insurance",
            systemImageName: "airplane.departure"
        )
    }
}
