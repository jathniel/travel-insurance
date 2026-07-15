import Foundation
import Testing
@testable import TravelInsurance

struct PurchaseFlowPresenterTests {
    private let quote = QuoteTierCatalog.baseTiers[0]
    private let flight = FlightDetails.demo

    private func makePolicy() -> Policy {
        .issued(for: quote, flight: flight, paymentReference: "PAY-TEST1234")
    }

    @Test func startsIdle() {
        let presenter = PurchaseFlowPresenter()

        #expect(presenter.phase == .idle)
        #expect(presenter.isPresentingVerification == false)
        #expect(presenter.dismissTask == nil)
    }

    @Test func beginVerificationEntersVerifyingWithContext() {
        let presenter = PurchaseFlowPresenter()

        presenter.beginVerification(quote: quote, flight: flight)

        #expect(presenter.phase == .verifying(quote: quote, flight: flight))
        #expect(presenter.isPresentingVerification)
    }

    @Test func resetFromVerifyingReturnsToIdle() {
        let presenter = PurchaseFlowPresenter()
        presenter.beginVerification(quote: quote, flight: flight)

        presenter.reset()

        #expect(presenter.phase == .idle)
        #expect(presenter.isPresentingVerification == false)
    }

    @Test func showSuccessEntersSuccessPhase() {
        let presenter = PurchaseFlowPresenter()
        let policy = makePolicy()
        presenter.beginVerification(quote: quote, flight: flight)

        presenter.showSuccess(for: policy)

        #expect(presenter.phase == .success(policy))
        #expect(presenter.isPresentingVerification)
    }

    @Test func showSuccessAutoDismissesAfterDuration() async {
        let presenter = PurchaseFlowPresenter()

        presenter.showSuccess(for: makePolicy(), dismissAfter: .milliseconds(50))
        await presenter.dismissTask?.value

        #expect(presenter.phase == .idle)
        #expect(presenter.isPresentingVerification == false)
    }

    @Test func staleDismissTimerDoesNotClobberNewFlow() async {
        let presenter = PurchaseFlowPresenter()
        presenter.showSuccess(for: makePolicy(), dismissAfter: .milliseconds(50))
        let staleTask = presenter.dismissTask

        presenter.beginVerification(quote: quote, flight: flight)
        await staleTask?.value

        #expect(presenter.phase == .verifying(quote: quote, flight: flight))
    }

    @Test func resetCancelsPendingDismiss() async {
        let presenter = PurchaseFlowPresenter()
        presenter.showSuccess(for: makePolicy(), dismissAfter: .seconds(5))
        let pendingTask = presenter.dismissTask

        presenter.reset()
        await pendingTask?.value

        #expect(presenter.phase == .idle)
        #expect(presenter.dismissTask == nil)
    }

    @Test func settingIsPresentingFalseResets() {
        let presenter = PurchaseFlowPresenter()
        presenter.beginVerification(quote: quote, flight: flight)

        presenter.isPresentingVerification = false

        #expect(presenter.phase == .idle)
        #expect(presenter.dismissTask == nil)
    }
}
