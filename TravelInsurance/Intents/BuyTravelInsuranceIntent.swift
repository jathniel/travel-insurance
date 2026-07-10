import AppIntents
import LocalAuthentication
import SwiftUI

/// The entire demo journey in one headless intent: quote → 3-tier selection →
/// consent confirmation → Face ID → mocked purchase → success card. The app UI
/// never comes to the foreground at any point.
struct BuyTravelInsuranceIntent: AppIntent {
    static let title: LocalizedStringResource = "Buy Travel Insurance"
    static let description = IntentDescription(
        "Get quotes and buy travel insurance for your upcoming flight, entirely within Siri."
    )

    @Parameter(title: "Plan")
    var tier: QuoteTierEntity?

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        let auditLog = AuditLogStore.shared
        // Flight context "extracted from the on-screen email" — hardcoded for the demo.
        let flight = FlightDetails.demo

        auditLog.record(.invocation, detail: "Siri intent invoked for \(flight.airline) \(flight.flightNumber) to \(flight.destinationDisplayName)")
        auditLog.record(.sessionValidation, detail: "Voice ID confirmed speaker; session validated (mocked)")

        let quotes = try await MockSparkQuoteService().fetchQuotes(for: flight)
        auditLog.record(.quoteReturned, detail: "SPARK returned \(quotes.count) tiers for \(flight.tripDurationDays)-day trip (mocked)")
        auditLog.record(.guardrailCheck, detail: "Quote structure passed guardrail validation (mocked)")

        let selected: QuoteTierEntity
        if let tier {
            selected = tier
        } else {
            selected = try await $tier.requestDisambiguation(
                among: quotes.map(QuoteTierEntity.init),
                dialog: IntentDialog("I found three plans for your \(flight.destinationDisplayName) trip. Elite is recommended. Which would you like?")
            )
        }
        auditLog.record(.tierSelected, detail: "\(selected.quote.tierName) selected at \(selected.quote.formattedPrice)")
        auditLog.record(.consentCheck, detail: "Consent requested before actionable purchase (mocked)")

        try await requestConfirmation(
            actionName: .buy,
            dialog: IntentDialog("Confirm \(selected.quote.tierName) cover for \(selected.quote.formattedPrice)?"),
            content: {
                PurchaseConfirmationSnippetView(quote: selected.quote, flight: flight)
            }
        )

        try await authenticatePurchase(auditLog: auditLog)

        let paymentReference = try await MockPaymentService().processPayment(
            amount: selected.quote.price,
            currencyCode: selected.quote.currencyCode
        )
        auditLog.record(.paymentProcessed, detail: "Payment stub succeeded, ref \(paymentReference)")

        let policy = Policy.issued(for: selected.quote, flight: flight, paymentReference: paymentReference)
        PolicyStore.shared.add(policy)
        auditLog.record(.policyIssued, detail: "Policy \(policy.policyNumber) written locally (mocked)")
        auditLog.record(.journeyComplete, detail: "Journey completed inside Siri; app never opened")

        return .result(
            dialog: IntentDialog("Your \(selected.quote.tierName) travel insurance is confirmed for your \(flight.destinationDisplayName) trip."),
            content: {
                SuccessSnippetView(policy: policy)
            }
        )
    }

    /// Face ID as a UX beat. If biometrics can't be presented in this context
    /// (e.g. fresh simulator), the demo proceeds and the audit trail says so;
    /// an explicit user cancellation still aborts the purchase.
    @MainActor
    private func authenticatePurchase(auditLog: AuditLogStore) async throws {
        let context = LAContext()
        var availabilityError: NSError?

        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &availabilityError) else {
            auditLog.record(.biometricAuth, detail: "Biometrics unavailable — step skipped (demo fallback)")
            return
        }

        do {
            let authenticated = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: "Confirm your travel insurance purchase"
            )
            guard authenticated else {
                auditLog.record(.biometricAuth, detail: "Face ID did not authenticate — purchase aborted")
                throw BuyTravelInsuranceError.biometricFailed
            }
            auditLog.record(.biometricAuth, detail: "Face ID authenticated the purchase")
        } catch let error as LAError where error.code == .userCancel {
            auditLog.record(.biometricAuth, detail: "Face ID cancelled by user — purchase aborted")
            throw BuyTravelInsuranceError.biometricFailed
        } catch let error as LAError where error.code == .authenticationFailed || error.code == .biometryLockout {
            auditLog.record(.biometricAuth, detail: "Face ID failed to authenticate — purchase aborted")
            throw BuyTravelInsuranceError.biometricFailed
        } catch let error as BuyTravelInsuranceError {
            throw error
        } catch {
            auditLog.record(.biometricAuth, detail: "Face ID unavailable in this context — step skipped (demo fallback)")
        }
    }
}
