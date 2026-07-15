import SwiftUI

@main
struct TravelInsuranceApp: App {
    @State private var policyStore = PolicyStore.shared
    @State private var auditLog = AuditLogStore.shared
    @State private var purchaseFlow = PurchaseFlowPresenter.shared

    var body: some Scene {
        WindowGroup {
            HomeView()
                .fullScreenCover(isPresented: Bindable(purchaseFlow).isPresentingVerification) {
                    PurchaseVerificationView()
                        .environment(purchaseFlow)
                }
                .environment(policyStore)
                .environment(auditLog)
                .environment(purchaseFlow)
        }
    }
}
