import AppIntents
import LocalAuthentication
import SwiftUI
import UIKit

/// The demo journey in one intent: quote → 3-tier selection → consent
/// confirmation → Face ID → mocked purchase → success card.
///
/// iOS forbids a headless intent from presenting its own Face ID sheet
/// (LAContext fails with `notInteractive` while the app is backgrounded under
/// Siri), so the intent runs headless through quoting and confirmation, then
/// briefly transitions the app to the foreground — just long enough for the
/// real Face ID sheet — before completing the purchase.
struct BuyTravelInsuranceIntent: AppIntent {
    static let title: LocalizedStringResource = "Buy Travel Insurance"
    static let description = IntentDescription(
        "Get quotes and buy travel insurance for your upcoming flight, entirely within Siri."
    )
    static let authenticationPolicy: IntentAuthenticationPolicy = .requiresLocalDeviceAuthentication
    static let supportedModes: IntentModes = [.background, .foreground(.dynamic)]

    @Parameter(title: "Plan")
    var tier: QuoteTierEntity?

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        let auditLog = AuditLogStore.shared
        // Flight context "extracted from the on-screen email" — hardcoded for the demo.
        let flight = FlightDetails.demo

        auditLog.record(.invocation, detail: "Siri intent invoked for \(flight.airline) \(flight.flightNumber) to \(flight.destinationDisplayName)")
        auditLog.record(.sessionValidation, detail: "Voice ID confirmed speaker; session validated (mocked)")

        let quotes: [InsuranceQuote]
        do {
            quotes = try await SparkQuoteService().fetchQuotes(for: flight)
        } catch {
            auditLog.record(.quoteReturned, detail: "Live SPARK quote call failed — journey aborted")
            throw error
        }
        QuoteRepository.shared.latestQuotes = quotes
        auditLog.record(.quoteReturned, detail: "SPARK returned \(quotes.count) tiers for \(flight.tripDurationDays)-day trip (live)")
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

        // Face ID can't be presented headlessly, so hop to the foreground for
        // just the biometric beat.
        try await continueInForeground(
            IntentDialog("Confirm with Face ID to complete your purchase."),
            alwaysConfirm: false
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
        auditLog.record(.journeyComplete, detail: "Journey completed in Siri; app auto-suspended after Face ID")

        // Demo-only: iOS offers no public API to background an app, and the
        // brief demands the success beat land back on Siri over Mail rather
        // than in the app. The private "suspend" selector achieves that but
        // would be rejected by App Review — strip before any store submission.
        // The short sleep lets the Face ID sheet finish dismissing first.
        try? await Task.sleep(for: .milliseconds(300))
        UIApplication.shared.perform(NSSelectorFromString("suspend"))

        return .result(
            dialog: IntentDialog("Your \(selected.quote.tierName) travel insurance is confirmed for your \(flight.destinationDisplayName) trip."),
            content: {
                SuccessSnippetView(policy: policy)
            }
        )
    }

    /// Face ID with automatic passcode fallback, run while the app is briefly
    /// in the foreground. Any failure aborts the purchase — the payment stub
    /// is never reached without authentication.
    @MainActor
    private func authenticatePurchase(auditLog: AuditLogStore) async throws {
        let context = LAContext()
        var availabilityError: NSError?

        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &availabilityError) else {
            let reason = availabilityError?.localizedDescription ?? "unknown reason"
            auditLog.record(.biometricAuth, detail: "Authentication unavailable (\(reason)) — purchase aborted")
            throw BuyTravelInsuranceError.authenticationUnavailable
        }

        do {
            let authenticated = try await context.evaluatePolicy(
                .deviceOwnerAuthentication,
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
        } catch let error as BuyTravelInsuranceError {
            throw error
        } catch {
            auditLog.record(.biometricAuth, detail: "Authentication error (\(error.localizedDescription)) — purchase aborted")
            throw BuyTravelInsuranceError.biometricFailed
        }
    }
}
