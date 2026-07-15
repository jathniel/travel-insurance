import SwiftUI

/// Full-screen page shown while the Siri purchase intent runs its in-app
/// beats: the real Face ID sheet appears over the verifying state, and after
/// payment the page shows a brief success beat before auto-dismissing to the
/// home screen with the new policy on top.
struct PurchaseVerificationView: View {
    @Environment(PurchaseFlowPresenter.self) private var presenter

    private var theme: BrandTheme {
        BrandTheme.theme(for: Brand.current)
    }

    var body: some View {
        ZStack {
            theme.accentColor.opacity(0.08)
                .ignoresSafeArea()

            switch presenter.phase {
            case .verifying(let quote, let flight):
                VerifyingContentView(quote: quote, flight: flight)
            case .success(let policy):
                SuccessContentView(policy: policy)
            case .idle:
                Color.clear
            }
        }
        .animation(.default, value: presenter.phase)
        .interactiveDismissDisabled()
    }
}

#Preview("Verifying") {
    let presenter = PurchaseFlowPresenter()
    presenter.beginVerification(quote: QuoteTierCatalog.baseTiers[1], flight: .demo)

    return PurchaseVerificationView()
        .environment(presenter)
}

#Preview("Success") {
    let presenter = PurchaseFlowPresenter()
    presenter.showSuccess(
        for: .issued(for: QuoteTierCatalog.baseTiers[1], flight: .demo, paymentReference: "PAY-DEMO123"),
        dismissAfter: .seconds(3600)
    )

    return PurchaseVerificationView()
        .environment(presenter)
}
