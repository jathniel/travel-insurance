import Foundation
import Observation

/// Drives the full-screen in-app verification page shown while the Siri
/// purchase intent runs its Face ID and success beats. The intent runs
/// in-process on the main actor, so it mutates this shared state directly
/// and the app UI observes it.
@Observable
final class PurchaseFlowPresenter {
    /// Shared instance used by both the Siri intent and the app UI.
    static let shared = PurchaseFlowPresenter()

    private(set) var phase: PurchaseFlowPhase = .idle

    /// Pending auto-dismiss after the success beat; exposed so tests can await it.
    private(set) var dismissTask: Task<Void, Never>?

    /// Binding surface for `fullScreenCover(isPresented:)`.
    var isPresentingVerification: Bool {
        get { phase != .idle }
        set {
            if !newValue {
                reset()
            }
        }
    }

    func beginVerification(quote: InsuranceQuote, flight: FlightDetails) {
        dismissTask?.cancel()
        dismissTask = nil
        phase = .verifying(quote: quote, flight: flight)
    }

    /// Shows the success beat, then auto-dismisses back to idle so the home
    /// screen — with the new policy on top — is revealed. Non-blocking, so the
    /// intent can return its Siri dialog while the page lingers.
    func showSuccess(for policy: Policy, dismissAfter duration: Duration = .seconds(2.5)) {
        dismissTask?.cancel()
        phase = .success(policy)
        dismissTask = Task { [weak self] in
            try? await Task.sleep(for: duration)
            guard let self, !Task.isCancelled, case .success = self.phase else { return }
            self.phase = .idle
        }
    }

    func reset() {
        dismissTask?.cancel()
        dismissTask = nil
        phase = .idle
    }
}
