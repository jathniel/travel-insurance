import SwiftUI

/// The in-app success beat of the purchase verification page, shown briefly
/// after payment before the page auto-dismisses to the home screen.
struct SuccessContentView: View {
    var policy: Policy

    var body: some View {
        VStack {
            Spacer()

            SuccessSnippetView(policy: policy)
                .background(.background.secondary, in: .rect(cornerRadius: 16))
                .padding()

            Text("Returning to your policies…")
                .font(.footnote)
                .foregroundStyle(.secondary)

            Spacer()
        }
    }
}

#Preview {
    SuccessContentView(
        policy: .issued(
            for: QuoteTierCatalog.baseTiers[1],
            flight: .demo,
            paymentReference: "PAY-DEMO123"
        )
    )
}
