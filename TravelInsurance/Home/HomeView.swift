import SwiftUI

/// The in-app home screen. The demo never opens the app during the Siri journey —
/// this exists as a safety net and to show the issued policy + audit trail afterwards.
struct HomeView: View {
    @Environment(PolicyStore.self) private var policyStore
    @AppStorage(Brand.storageKey) private var brandSelection = Brand.generic

    private var theme: BrandTheme {
        BrandTheme.theme(for: brandSelection)
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    BrandHeaderView(theme: theme)
                        .listRowInsets(EdgeInsets())
                }

                Section("Your Policies") {
                    if policyStore.policies.isEmpty {
                        ContentUnavailableView(
                            "No Policies Yet",
                            systemImage: "shield.slash",
                            description: Text("Try asking Siri: \u{201C}Buy travel insurance with \(theme.productName)\u{201D}")
                        )
                    } else {
                        ForEach(policyStore.policies) { policy in
                            NavigationLink(value: policy) {
                                PolicyRowView(policy: policy, theme: theme)
                            }
                        }
                    }
                }

                Section("Governance") {
                    NavigationLink {
                        AuditLogView()
                    } label: {
                        Label("Audit Trail", systemImage: "checkmark.shield")
                    }
                }
            }
            .navigationTitle(theme.productName)
            .navigationDestination(for: Policy.self) { policy in
                PolicyDetailView(policy: policy, theme: theme)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu("Brand", systemImage: "paintbrush") {
                        Picker("Brand", selection: $brandSelection) {
                            ForEach(Brand.allCases) { brand in
                                Text(brand.displayName).tag(brand)
                            }
                        }
                    }
                }
            }
        }
        .tint(theme.accentColor)
    }
}

#Preview {
    HomeView()
        .environment(PolicyStore.shared)
        .environment(AuditLogStore.shared)
}
