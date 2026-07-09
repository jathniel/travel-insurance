import SwiftUI

@main
struct TravelInsuranceApp: App {
    @State private var policyStore = PolicyStore.shared
    @State private var auditLog = AuditLogStore.shared

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(policyStore)
                .environment(auditLog)
        }
    }
}
